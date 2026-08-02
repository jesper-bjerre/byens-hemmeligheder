import { Component, computed, inject } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ContentService } from '../core/content.service';
import { GameStoreService } from '../core/game-store.service';
import { MissionImage } from '../shared/mission-image';

@Component({
  selector: 'app-mission-detail',
  imports: [RouterLink, MissionImage],
  templateUrl: './mission-detail.html',
  styleUrl: './mission-detail.scss',
})
export class MissionDetail {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly mission = computed(() => this.content.mission(this.route.snapshot.paramMap.get('id')));
  readonly location = computed(() => {
    const mission = this.mission();
    return mission ? this.content.locationFor(mission) : undefined;
  });
  readonly sources = computed(() => {
    const ids = this.mission()?.sourceIds ?? [];
    return this.content.pack()?.sources.filter((source) => ids.includes(source.id)) ?? [];
  });
  heroMediaId(): string | null | undefined {
    const mission = this.mission();
    return (
      mission?.thumbnailMediaId ||
      mission?.heroMediaId ||
      [...(mission?.cards ?? [])].sort((a, b) => a.order - b.order)[0]?.mediaId
    );
  }
  difficulty(value: number): string {
    return ['', 'Let', 'Rolig', 'Udfordrende', 'Svær'][value] ?? 'Ukendt';
  }
  wheelchair(value: string): string {
    return (
      ({ yes: 'Ja', no: 'Nej', unknown: 'Ikke vurderet' } as Record<string, string>)[value] ?? value
    );
  }
  go(): void {
    const mission = this.mission();
    if (!mission) return;
    if (this.game.isCompleted(mission)) void this.router.navigate(['/opgave', mission.id, 'loest']);
    else {
      this.game.startMission(mission);
      void this.router.navigate(['/opgave', mission.id, 'find']);
    }
  }
}
