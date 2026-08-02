import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuditEntry, BackendKind, Mission } from './core/models';
import { ContentStoreService } from './core/content-store.service';
import { PostalCodesService } from './core/postal-codes.service';
import { auditChangeName, displayName, regions } from './core/vocabulary';
import { MissionEditor } from './mission-editor/mission-editor';

interface PlaceGroup {
  postalCode: string;
  title: string;
  missions: Mission[];
}

interface RegionGroup {
  region: string;
  title: string;
  places: PlaceGroup[];
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule, MissionEditor],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App implements OnInit {
  readonly store = inject(ContentStoreService);
  readonly postcodes = inject(PostalCodesService);
  readonly selectedMissionIndex = signal<number | null>(null);
  readonly showQuizmaster = signal(false);
  readonly showSettings = signal(false);
  readonly showAudit = signal(false);
  readonly auditEntries = signal<AuditEntry[]>([]);
  readonly auditLoading = signal(false);
  readonly auditError = signal<string | null>(null);
  quizmasterDraft = this.store.quizmaster();

  readonly releasedCount = computed(
    () =>
      this.store.pack()?.missions.filter((mission) => mission.status === 'fieldTestReady').length ??
      0,
  );

  readonly hierarchy = computed<RegionGroup[]>(() => {
    const pack = this.store.pack();
    this.postcodes.all();
    if (!pack) return [];
    const byRegion = new Map<string, Map<string, Mission[]>>();
    for (const mission of pack.missions) {
      const location = pack.locations.find((item) => item.id === mission.locationId);
      const postalCode = location?.postalCode ?? '';
      const region = this.postcodes.place(postalCode)?.region ?? '';
      if (!byRegion.has(region)) byRegion.set(region, new Map());
      const byPlace = byRegion.get(region)!;
      if (!byPlace.has(postalCode)) byPlace.set(postalCode, []);
      byPlace.get(postalCode)!.push(mission);
    }

    return [...byRegion.entries()]
      .sort(([left], [right]) => regionOrder(left) - regionOrder(right))
      .map(([region, places]) => ({
        region,
        title: region ? displayName(region) : 'Uden landsdel',
        places: [...places.entries()]
          .sort(([left], [right]) => left.localeCompare(right, 'da-DK'))
          .map(([postalCode, missions]) => ({
            postalCode,
            title: postalCode
              ? `${postalCode} ${this.postcodes.place(postalCode)?.city ?? '— ukendt'}`
              : 'Uden postnummer',
            missions: missions.sort((left, right) =>
              left.title.localeCompare(right.title, 'da-DK'),
            ),
          })),
      }));
  });

  async ngOnInit(): Promise<void> {
    await this.postcodes.load();
    await this.store.load();
    if (!this.store.quizmaster()) this.showQuizmaster.set(true);
  }

  statusName(status: string): string {
    return displayName(status);
  }

  openMission(mission: Mission): void {
    this.selectedMissionIndex.set(this.store.pack()?.missions.indexOf(mission) ?? null);
  }

  closeEditor(): void {
    this.selectedMissionIndex.set(null);
  }

  createMission(): void {
    if (!this.store.quizmaster()) {
      this.showQuizmaster.set(true);
      return;
    }
    const mission = this.store.newMission();
    if (mission) {
      const pack = this.store.pack()!;
      const location = pack.locations.find((item) => item.id === mission.locationId);
      if (location) {
        location.address = this.postcodes.place(location.postalCode)?.city ?? 'Danmark';
      }
      this.selectedMissionIndex.set(pack.missions.indexOf(mission));
    }
  }

  removeMission(mission: Mission): void {
    if (
      !confirm(`Slet ${mission.title || 'opgaven'}? Opgaven og dens sted fjernes, når du gemmer.`)
    ) {
      return;
    }
    this.store.removeMission(mission.id);
  }

  saveQuizmaster(): void {
    if (!this.quizmasterDraft.trim()) return;
    this.store.setQuizmaster(this.quizmasterDraft);
    this.showQuizmaster.set(false);
  }

  async reload(): Promise<void> {
    if (this.store.isDirty() && !confirm('Genindlæs og kassér dine ugemte rettelser?')) return;
    await this.store.load();
  }

  async changeBackend(value: BackendKind): Promise<void> {
    const changed = await this.store.switchBackend(value);
    if (changed) this.showSettings.set(false);
  }

  async openAudit(): Promise<void> {
    this.showAudit.set(true);
    this.auditLoading.set(true);
    this.auditError.set(null);
    try {
      this.auditEntries.set(await this.store.api.audit());
    } catch (error) {
      this.auditError.set(this.store.api.describe(error));
    } finally {
      this.auditLoading.set(false);
    }
  }

  auditHeadline(entry: AuditEntry): string {
    return `${entry.by} ${auditChangeName(entry.change)} ${entry.missionId ?? 'pakken'}`;
  }

  auditDetail(entry: AuditEntry): string | null {
    if (entry.from && entry.to) return `${displayName(entry.from)} → ${displayName(entry.to)}`;
    if (entry.to) return `Ny som ${displayName(entry.to)}`;
    if (entry.from) return `Var ${displayName(entry.from)}`;
    return null;
  }
}

function regionOrder(region: string): number {
  const index = regions.indexOf(region as (typeof regions)[number]);
  return index < 0 ? regions.length : index;
}
