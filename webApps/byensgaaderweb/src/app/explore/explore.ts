import { Component, computed, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ContentService } from '../core/content.service';
import { distanceMetres } from '../core/game-rules';
import { GameStoreService } from '../core/game-store.service';
import { LocationService } from '../core/location.service';
import { Mission } from '../core/models';
import { ExploreMap } from './explore-map';

@Component({
  selector: 'app-explore',
  imports: [RouterLink, ExploreMap],
  templateUrl: './explore.html',
  styleUrl: './explore.scss',
})
export class Explore {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  readonly location = inject(LocationService);
  readonly selected = signal<Mission | null>(null);
  readonly primer = signal(
    globalThis.window?.localStorage?.getItem('bh.player.locationPrimer') !== 'seen',
  );
  readonly solvedCount = computed(
    () =>
      this.content.playableMissions().filter((mission) => this.game.isCompleted(mission)).length,
  );

  distance(mission: Mission): number | null {
    const fix = this.location.fix();
    const place = this.content.locationFor(mission);
    if (!fix || place?.latitude == null || place.longitude == null) return null;
    return distanceMetres(fix, { latitude: place.latitude, longitude: place.longitude });
  }
  distanceLabel(mission: Mission): string {
    const value = this.distance(mission);
    if (value == null) return 'Afstand ukendt';
    return value < 1000
      ? `${Math.round(value)} m væk`
      : `${(value / 1000).toFixed(1).replace('.', ',')} km væk`;
  }
  difficulty(value: number): string {
    return ['', 'Let', 'Rolig', 'Udfordrende', 'Svær'][value] ?? 'Gåde';
  }
  missionNumber(index: number): string {
    return String(index + 1).padStart(2, '0');
  }
  allowLocation(): void {
    this.dismissPrimer();
    this.location.start();
  }
  dismissPrimer(): void {
    this.primer.set(false);
    globalThis.window?.localStorage?.setItem('bh.player.locationPrimer', 'seen');
  }
  simulate(mission: Mission): void {
    const place = this.content.locationFor(mission);
    if (place?.latitude != null && place.longitude != null)
      this.location.simulate(place.latitude, place.longitude);
  }
}
