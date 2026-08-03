import { Injectable, computed, inject, signal } from '@angular/core';
import {
  BackendKind,
  ContentPack,
  Draft,
  Mission,
  MissionAggregate,
  ObjectRevisions,
  SaveResult,
} from './models';
import { ContentApiService, ObjectConflictError } from './content-api.service';
import {
  clone,
  createMission,
  deleteMission,
  equal,
  mergePacks,
  normaliseBeforeSave,
} from './pack-utils';

const draftKey = 'bh.webadmin.draft.v2';
const quizmasterKey = 'bh.webadmin.quizmaster';

@Injectable({ providedIn: 'root' })
export class ContentStoreService {
  readonly api = inject(ContentApiService);

  readonly pack = signal<ContentPack | null>(null);
  readonly base = signal<ContentPack | null>(null);
  readonly revisions = signal<ObjectRevisions>(emptyRevisions());
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly status = signal<string | null>(null);
  readonly error = signal<string | null>(null);
  readonly conflicts = signal<string[]>([]);
  readonly availableDraft = signal<Draft | null>(null);
  readonly quizmaster = signal(globalThis.window?.localStorage?.getItem(quizmasterKey) ?? '');
  readonly isDirty = computed(() => {
    const pack = this.pack();
    const base = this.base();
    return !!pack && !!base && !equal(pack, base);
  });

  private draftTimer?: ReturnType<typeof setTimeout>;

  constructor() {
    globalThis.window?.addEventListener('beforeunload', () => this.persistDraft());
  }

  async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    try {
      const fresh = await this.api.loadAuthoring();
      this.adopt(fresh.pack, fresh.revisions);
      this.offerDraft();
    } catch (error) {
      this.error.set(this.api.describe(error));
    } finally {
      this.loading.set(false);
    }
  }

  setQuizmaster(name: string): void {
    const trimmed = name.trim();
    globalThis.window?.localStorage?.setItem(quizmasterKey, trimmed);
    this.quizmaster.set(trimmed);
  }

  async switchBackend(backend: BackendKind): Promise<boolean> {
    if (backend === this.api.backend()) return true;
    if (this.isDirty() && !confirm('Skift server og kassér dine ugemte rettelser?')) return false;
    this.clearDraft();
    this.pack.set(null);
    this.base.set(null);
    this.revisions.set(emptyRevisions());
    this.api.setBackend(backend);
    await this.load();
    return true;
  }

  markChanged(): void {
    this.pack.update((pack) => (pack ? { ...pack } : pack));
    this.status.set('Ugemte rettelser');
    clearTimeout(this.draftTimer);
    this.draftTimer = setTimeout(() => this.persistDraft(), 900);
  }

  newMission(): Mission | null {
    const pack = this.pack();
    if (!pack) return null;
    const mission = createMission(pack);
    this.markChanged();
    return mission;
  }

  removeMission(missionId: string): void {
    const pack = this.pack();
    if (!pack) return;
    deleteMission(pack, missionId);
    this.markChanged();
  }

  async save(): Promise<boolean> {
    const pack = this.pack();
    const base = this.base();
    const quizmaster = this.quizmaster().trim();
    if (!pack || !base || !this.isDirty()) return true;
    if (!quizmaster) {
      this.error.set('Skriv dit navn, før du gemmer.');
      return false;
    }

    this.saving.set(true);
    this.error.set(null);
    this.conflicts.set([]);
    normaliseBeforeSave(pack, base);
    this.pack.set({ ...pack });
    try {
      const saved = await this.saveChanges(pack, base, clone(this.revisions()), quizmaster);
      this.finishSave(pack, saved);
      return true;
    } catch (error) {
      if (error instanceof ObjectConflictError) return await this.mergeAndRetry(pack, quizmaster);
      this.error.set(this.api.describe(error));
      this.persistDraft();
      return false;
    } finally {
      this.saving.set(false);
    }
  }

  restoreDraft(): void {
    const draft = this.availableDraft();
    if (!draft) return;
    this.pack.set(clone(draft.root));
    this.base.set(clone(draft.base));
    this.revisions.set(clone(draft.revisions ?? emptyRevisions()));
    this.availableDraft.set(null);
    this.status.set('Dine rettelser er genoprettet. De er ikke gemt endnu.');
  }

  discardDraft(): void {
    this.clearDraft();
    this.availableDraft.set(null);
  }

  private async saveChanges(
    pack: ContentPack,
    base: ContentPack,
    revisions: ObjectRevisions,
    quizmaster: string,
  ): Promise<SaveProgress> {
    const progress: SaveProgress = {
      revisions,
      pending: false,
      published: false,
      contentVersion: pack.contentVersion,
    };
    const baseMedia = new Map(base.media.map((item) => [item.id, item]));
    const baseSources = new Map(base.sources.map((item) => [item.id, item]));
    const baseMissions = new Map(base.missions.map((item) => [item.id, item]));
    const baseLocations = new Map(base.locations.map((item) => [item.id, item]));

    for (const asset of pack.media) {
      if (!equal(asset, baseMedia.get(asset.id))) {
        this.record(
          progress,
          await this.api.saveMedia(asset, revisions.media[asset.id] ?? null, quizmaster),
          'media',
        );
      }
    }
    for (const source of pack.sources) {
      if (!equal(source, baseSources.get(source.id))) {
        this.record(
          progress,
          await this.api.saveSource(source, revisions.sources[source.id] ?? null, quizmaster),
          'sources',
        );
      }
    }
    for (const mission of pack.missions) {
      const aggregate = this.aggregate(pack, mission);
      const oldMission = baseMissions.get(mission.id);
      const oldLocation = oldMission ? baseLocations.get(oldMission.locationId) : undefined;
      if (
        !oldMission ||
        !equal(aggregate, this.aggregateFrom(base.schemaVersion, oldMission, oldLocation))
      ) {
        this.record(
          progress,
          await this.api.saveMission(aggregate, revisions.missions[mission.id] ?? null, quizmaster),
          'missions',
        );
      }
    }

    const currentMissionIds = new Set(pack.missions.map((item) => item.id));
    for (const mission of base.missions) {
      if (!currentMissionIds.has(mission.id)) {
        this.requireRevision(revisions.missions, mission.id);
        this.record(
          progress,
          await this.api.deleteMission(mission.id, revisions.missions[mission.id], quizmaster),
          'missions',
        );
      }
    }
    await this.deleteRemovedCatalog(
      base.media,
      new Set(pack.media.map((item) => item.id)),
      revisions.media,
      (id, etag) => this.api.deleteMedia(id, etag, quizmaster),
      'media',
      progress,
    );
    await this.deleteRemovedCatalog(
      base.sources,
      new Set(pack.sources.map((item) => item.id)),
      revisions.sources,
      (id, etag) => this.api.deleteSource(id, etag, quizmaster),
      'sources',
      progress,
    );
    return progress;
  }

  private async deleteRemovedCatalog(
    base: { id: string }[],
    currentIds: Set<string>,
    revisions: Record<string, string>,
    remove: (id: string, etag: string) => Promise<SaveResult>,
    collection: keyof ObjectRevisions,
    progress: SaveProgress,
  ): Promise<void> {
    for (const item of base) {
      if (!currentIds.has(item.id)) {
        this.requireRevision(revisions, item.id);
        this.record(progress, await remove(item.id, revisions[item.id]), collection);
      }
    }
  }

  private async mergeAndRetry(ours: ContentPack, quizmaster: string): Promise<boolean> {
    try {
      const server = await this.api.loadAuthoring();
      const base = this.base();
      if (!base) return false;
      const result = mergePacks(base, ours, server.pack);
      this.pack.set(result.root);
      this.base.set(clone(server.pack));
      this.revisions.set(clone(server.revisions));

      const saved = await this.saveChanges(
        result.root,
        server.pack,
        clone(server.revisions),
        quizmaster,
      );
      this.finishSave(result.root, saved);
      this.conflicts.set(result.conflicts);
      this.status.set(
        saved.pending
          ? 'Rettelserne er gemt, men publiceringen afventer automatisk genforsøg.'
          : result.conflicts.length
            ? `Gemt, men ${result.conflicts.length} felter var rettet af begge.`
            : 'Gemt. En andens rettelser blev flettet ind.',
      );
      return true;
    } catch (error) {
      this.error.set(
        `Kunne ikke flette: ${this.api.describe(error)} Dine rettelser er gemt lokalt.`,
      );
      this.persistDraft();
      return false;
    }
  }

  private aggregate(pack: ContentPack, mission: Mission): MissionAggregate {
    const location = pack.locations.find((item) => item.id === mission.locationId);
    if (!location) throw new Error(`Opgaven ${mission.id} mangler sit sted.`);
    return this.aggregateFrom(pack.schemaVersion, mission, location)!;
  }

  private aggregateFrom(
    schemaVersion: string,
    mission: Mission,
    location: ContentPack['locations'][number] | undefined,
  ): MissionAggregate | undefined {
    return location ? { schemaVersion, mission, location } : undefined;
  }

  private record(
    progress: SaveProgress,
    result: SaveResult,
    collection: keyof ObjectRevisions,
  ): void {
    if (result.etag) progress.revisions[collection][result.id] = result.etag;
    else delete progress.revisions[collection][result.id];
    if (result.publication === 'pending') progress.pending = true;
    if (result.publication === 'published') progress.published = true;
    if (result.publishedContentVersion) progress.contentVersion = result.publishedContentVersion;
  }

  private requireRevision(revisions: Record<string, string>, id: string): void {
    if (!revisions[id]) throw new Error(`Mangler revisionsnummer for ${id}. Hent indholdet igen.`);
  }

  private finishSave(pack: ContentPack, saved: SaveProgress): void {
    pack.contentVersion = saved.contentVersion;
    this.adopt(pack, saved.revisions);
    this.clearDraft();
    this.status.set(
      saved.pending
        ? 'Rettelserne er gemt. Publiceringen afventer automatisk genforsøg.'
        : saved.published
          ? 'Gemt og publiceret'
          : 'Gemt',
    );
  }

  private adopt(pack: ContentPack, revisions: ObjectRevisions): void {
    this.pack.set(clone(pack));
    this.base.set(clone(pack));
    this.revisions.set(clone(revisions));
    this.error.set(null);
  }

  private offerDraft(): void {
    try {
      const raw = globalThis.window?.localStorage?.getItem(draftKey);
      if (!raw) return;
      const draft = JSON.parse(raw) as Draft;
      if (draft.backend === this.api.backend()) this.availableDraft.set(draft);
    } catch {
      this.clearDraft();
    }
  }

  private persistDraft(): void {
    clearTimeout(this.draftTimer);
    const pack = this.pack();
    const base = this.base();
    if (!pack || !base || !this.isDirty()) {
      this.clearDraft();
      return;
    }
    const draft: Draft = {
      root: pack,
      base,
      revisions: this.revisions(),
      backend: this.api.backend(),
      savedAt: new Date().toISOString(),
    };
    globalThis.window?.localStorage?.setItem(draftKey, JSON.stringify(draft));
  }

  private clearDraft(): void {
    clearTimeout(this.draftTimer);
    globalThis.window?.localStorage?.removeItem(draftKey);
  }
}

interface SaveProgress {
  revisions: ObjectRevisions;
  pending: boolean;
  published: boolean;
  contentVersion: string;
}

function emptyRevisions(): ObjectRevisions {
  return { missions: {}, media: {}, sources: {} };
}
