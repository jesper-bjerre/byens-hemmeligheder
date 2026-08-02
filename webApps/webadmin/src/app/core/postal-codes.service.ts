import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

export interface PostalCode {
  code: string;
  city: string;
  region: string;
  label: string;
}

/**
 * Danmarks postnumre, genereret fra samme Dataforsyningen-udtræk som iOS.
 * Datafilen er lokal, så en quizmaster stadig kan oprette en opgave uden net.
 */
@Injectable({ providedIn: 'root' })
export class PostalCodesService {
  private readonly http = inject(HttpClient);
  readonly all = signal<PostalCode[]>([]);
  readonly byCode = computed(() => new Map(this.all().map((place) => [place.code, place])));

  async load(): Promise<void> {
    if (this.all().length) return;
    const raw = await firstValueFrom(this.http.get('postnumre.txt', { responseType: 'text' }));
    this.all.set(
      raw
        .split('\n')
        .filter(Boolean)
        .map((line) => {
          const [code, city, region] = line.split('|');
          return { code, city, region, label: `${code} ${city}` };
        }),
    );
  }

  place(code: string): PostalCode | undefined {
    return this.byCode().get(code);
  }

  inRegion(region: string): PostalCode[] {
    return this.all().filter((place) => place.region === region);
  }
}
