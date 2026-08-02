import { Component, computed, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { ContentService } from '../core/content.service';
import { GameStoreService } from '../core/game-store.service';

@Component({
  selector: 'app-scoreboard',
  imports: [RouterLink],
  templateUrl: './scoreboard.html',
  styleUrl: './scoreboard.scss',
})
export class Scoreboard {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  private readonly router = inject(Router);
  readonly solved = computed(() =>
    this.content.playableMissions().filter((m) => this.game.isCompleted(m)),
  );
  readonly example = [
    ['Detektiv Lupin', 512],
    ['Familien Nord', 448],
    ['Kaninen Vera', 390],
    ['Havnens Skygge', 275],
  ] as const;
  reset(): void {
    if (confirm('Slet løste gåder, brugte hints og point på denne enhed?')) {
      this.game.resetProgress();
      void this.router.navigate(['/']);
    }
  }
}
