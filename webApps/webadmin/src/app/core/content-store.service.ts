import { Injectable, computed, inject, signal } from '@angular/core';
import { BackendKind, ContentPack, Draft, Mission } from './models';
import { ContentApiService, PackConflictError } from './content-api.service';
import {
  clone,
  createMission,
  deleteMission,
  equal,
  mergePacks,
  normaliseBeforeSave,
} from './pack-utils';

const draftKey = 'bh.webadmin.draft.v1';
const quizmasterKey = 'bh.webadmin.quizmaster';

@Injectable({ providedIn: 'root' })
export class ContentStoreService {
  readonly api = inject(ContentApiService);

  readonly pack = signal<ContentPack | null>(null);
  readonly base = signal<ContentPack | null>(null);
  readonly etag = signal<string | null>(null);
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
      const fresh = await this.api.loadPack();
      this.adopt(fresh.pack, fresh.etag);
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
    normaliseBeforeSave(pack, base);
    this.pack.set({ ...pack });
    try {
      const etag = await this.api.savePack(pack, this.etag(), quizmaster);
      this.adopt(pack, etag);
      this.clearDraft();
      this.status.set('Gemt');
      return true;
    } catch (error) {
      if (error instanceof PackConflictError) return await this.mergeAndRetry(pack, quizmaster);
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
    this.etag.set(draft.etag);
    this.availableDraft.set(null);
    this.status.set('Dine rettelser er genoprettet. De er ikke gemt endnu.');
  }

  discardDraft(): void {
    this.clearDraft();
    this.availableDraft.set(null);
  }

  private async mergeAndRetry(ours: ContentPack, quizmaster: string): Promise<boolean> {
    try {
      const server = await this.api.loadPack();
      const base = this.base();
      if (!base) return false;
      const result = mergePacks(base, ours, server.pack);
      this.pack.set(result.root);
      this.base.set(clone(server.pack));
      this.etag.set(server.etag);

      const etag = await this.api.savePack(result.root, server.etag, quizmaster);
      this.adopt(result.root, etag);
      this.clearDraft();
      this.conflicts.set(result.conflicts);
      this.status.set(
        result.conflicts.length
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

  private adopt(pack: ContentPack, etag: string | null): void {
    this.pack.set(clone(pack));
    this.base.set(clone(pack));
    this.etag.set(etag);
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
      etag: this.etag(),
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
