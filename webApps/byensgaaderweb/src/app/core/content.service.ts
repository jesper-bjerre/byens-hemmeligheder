import { Injectable, computed, signal } from '@angular/core';
import { ContentPack, MediaAsset, Mission } from './models';

@Injectable({ providedIn: 'root' })
export class ContentService {
  readonly pack = signal<ContentPack | null>(null);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly isLocal = ['localhost', '127.0.0.1'].includes(globalThis.location?.hostname ?? '');
  readonly baseUrl = this.isLocal
    ? 'http://localhost:5199'
    : 'https://byensgaader-api-p.azurewebsites.net';
  readonly playableMissions = computed(() =>
    (this.pack()?.missions ?? []).filter(
      (mission) => mission.status === 'fieldTestReady' || mission.status === 'publishReady',
    ),
  );

  async load(): Promise<void> {
    if (this.loading()) return;
    this.loading.set(true);
    this.error.set(null);
    try {
      const response = await fetch(`${this.baseUrl}/content/da-DK/pack`, {
        cache: 'no-store',
      });
      if (!response.ok) throw new Error(`Tjenesten svarede ${response.status}.`);
      this.pack.set((await response.json()) as ContentPack);
    } catch {
      this.error.set('Indholdet kunne ikke indlæses. Kontrollér forbindelsen og prøv igen.');
    } finally {
      this.loading.set(false);
    }
  }

  mission(id: string | null): Mission | undefined {
    return this.pack()?.missions.find((mission) => mission.id === id);
  }

  locationFor(mission: Mission) {
    return this.pack()?.locations.find((location) => location.id === mission.locationId);
  }

  media(id: string | null | undefined): MediaAsset | undefined {
    return this.pack()?.media.find((asset) => asset.id === id);
  }

  mediaUrl(id: string | null | undefined): string | null {
    const asset = this.media(id);
    return asset
      ? `${this.baseUrl}/content/da-DK/media/${encodeURIComponent(asset.filename)}`
      : null;
  }
}
