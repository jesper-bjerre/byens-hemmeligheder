import { Component, OnDestroy, OnInit, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ContentService } from '../core/content.service';
import { bearingDegrees, distanceMetres } from '../core/game-rules';
import { GameStoreService } from '../core/game-store.service';
import { LocationService } from '../core/location.service';

@Component({
  selector: 'app-approach',
  imports: [RouterLink],
  templateUrl: './approach.html',
  styleUrl: './approach.scss',
})
export class Approach implements OnInit, OnDestroy {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  readonly locationService = inject(LocationService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly mission = computed(() => this.content.mission(this.route.snapshot.paramMap.get('id')));
  readonly place = computed(() => {
    const m = this.mission();
    return m ? this.content.locationFor(m) : undefined;
  });
  readonly distance = signal<number | null>(null);
  readonly bearing = signal(0);
  readonly credit = signal(0);
  readonly waited = signal(0);
  readonly state = signal<'position' | 'far' | 'approaching' | 'dwelling' | 'ready' | 'problem'>(
    'position',
  );
  private timer?: ReturnType<typeof setInterval>;
  private startedAt = Date.now();
  private lastTick = Date.now();
  ngOnInit(): void {
    const mission = this.mission();
    if (mission && this.game.session()?.missionId !== mission.id) this.game.startMission(mission);
    this.locationService.start();
    this.timer = setInterval(() => this.tick(), 1000);
    this.tick();
    const place = this.place();
    if (mission && (place?.latitude == null || place.longitude == null)) {
      this.game.verifyPresence(mission, 'demo');
      this.state.set('ready');
    }
  }
  ngOnDestroy(): void {
    if (this.timer) clearInterval(this.timer);
  }
  tick(): void {
    const mission = this.mission(),
      place = this.place(),
      fix = this.locationService.fix();
    if (!mission || place?.latitude == null || place.longitude == null) return;
    if (!fix) {
      this.state.set(this.locationService.problem() === 'denied' ? 'problem' : 'position');
      return;
    }
    const target = { latitude: place.latitude, longitude: place.longitude };
    const distance = distanceMetres(fix, target);
    this.distance.set(distance);
    this.bearing.set(bearingDegrees(fix, target));
    const now = Date.now(),
      delta = Math.min(2, (now - this.lastTick) / 1000);
    this.lastTick = now;
    this.waited.set((now - this.startedAt) / 1000);
    const radius = place.activationRadiusMetres ?? 0;
    const usableAccuracy = place.accuracyProfile === 'urbanCanyon' ? 120 : 100;
    const effective = Math.max(0, distance - fix.accuracy);
    const inside = effective <= radius && fix.accuracy <= usableAccuracy;
    if (inside) {
      this.credit.update((v) => Math.min(place.dwellSeconds, v + delta));
      this.state.set(this.credit() >= place.dwellSeconds ? 'ready' : 'dwelling');
    } else {
      this.credit.update((v) => Math.max(0, v - 1));
      this.state.set(distance <= radius * 2 ? 'approaching' : 'far');
    }
    if (this.state() === 'ready' && !this.game.session()?.verified)
      this.game.verifyPresence(mission, fix.simulated ? 'simulated' : 'gps');
  }
  remaining(): number {
    return Math.max(0, Math.ceil((this.place()?.dwellSeconds ?? 0) - this.credit()));
  }
  distanceLabel(): string {
    const d = this.distance();
    return d == null
      ? 'Finder din position…'
      : d < 1000
        ? `${Math.round(d)} meter`
        : `${(d / 1000).toFixed(1).replace('.', ',')} km`;
  }
  message(): string {
    switch (this.state()) {
      case 'far':
        return 'Gå i pilens retning. Læg telefonen væk, mens I bevæger jer.';
      case 'approaching':
        return 'I er tæt på. Find et sikkert sted at stå.';
      case 'dwelling':
        return `Bliv stående et øjeblik — ${this.remaining()} sek.`;
      case 'ready':
        return 'I er fremme. Gåden er klar.';
      case 'problem':
        return 'Browseren har ikke adgang til din position.';
      default:
        return 'Vi finder jer på kortet. Det kan tage et øjeblik.';
    }
  }
  acceptOverride(): void {
    const m = this.mission();
    if (m) {
      this.game.verifyPresence(m, 'softOverride');
      this.state.set('ready');
    }
  }
  play(): void {
    const m = this.mission();
    if (m) void this.router.navigate(['/opgave', m.id, 'spil']);
  }
  simulate(): void {
    const p = this.place();
    if (p?.latitude != null && p.longitude != null)
      this.locationService.simulate(p.latitude, p.longitude);
  }
}
