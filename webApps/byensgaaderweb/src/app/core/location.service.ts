import { Injectable, computed, signal } from '@angular/core';
import { PositionFix } from './models';

export type LocationProblem = 'notDetermined' | 'denied' | 'unavailable' | 'timeout' | null;

@Injectable({ providedIn: 'root' })
export class LocationService {
  readonly fix = signal<PositionFix | null>(null);
  readonly problem = signal<LocationProblem>('notDetermined');
  readonly watching = signal(false);
  readonly isLocal = ['localhost', '127.0.0.1'].includes(globalThis.location?.hostname ?? '');
  readonly hasFix = computed(() => this.fix() !== null);
  private watchId: number | null = null;

  start(): void {
    if (this.watchId !== null || !globalThis.navigator?.geolocation) {
      if (!globalThis.navigator?.geolocation) this.problem.set('unavailable');
      return;
    }
    this.watching.set(true);
    this.watchId = navigator.geolocation.watchPosition(
      (position) => {
        this.problem.set(null);
        this.fix.set({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: Math.max(0, position.coords.accuracy),
          timestamp: position.timestamp,
        });
      },
      (error) => {
        this.problem.set(
          error.code === error.PERMISSION_DENIED
            ? 'denied'
            : error.code === error.TIMEOUT
              ? 'timeout'
              : 'unavailable',
        );
      },
      { enableHighAccuracy: true, maximumAge: 3_000, timeout: 15_000 },
    );
  }

  simulate(latitude: number, longitude: number, accuracy = 5): void {
    if (!this.isLocal) return;
    this.problem.set(null);
    this.fix.set({ latitude, longitude, accuracy, timestamp: Date.now(), simulated: true });
  }
}
