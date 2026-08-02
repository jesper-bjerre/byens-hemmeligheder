import { Component, computed, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ContentService } from '../core/content.service';
import { GameStoreService } from '../core/game-store.service';

@Component({
  selector: 'app-reward',
  imports: [RouterLink],
  templateUrl: './reward.html',
  styleUrl: './reward.scss',
})
export class Reward {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  private readonly route = inject(ActivatedRoute);
  readonly mission = computed(() => this.content.mission(this.route.snapshot.paramMap.get('id')));
  readonly sources = computed(() => {
    const ids = this.mission()?.sourceIds ?? [];
    return this.content.pack()?.sources.filter((s) => ids.includes(s.id)) ?? [];
  });
  presenceNote(missionId: string): string | null {
    const method = this.game
      .events()
      .find((e) => e.kind === 'presenceVerified' && e.payload.missionId === missionId)
      ?.payload.presenceMethod;
    return method === 'softOverride'
      ? 'I bekræftede selv, at I stod på stedet.'
      : method === 'demo'
        ? 'Stedet er ikke positionskontrolleret.'
        : method === 'simulated'
          ? 'Positionen var simuleret.'
          : null;
  }
  signed(points: number): string {
    return points < 0 ? String(points) : `+${points}`;
  }
}
