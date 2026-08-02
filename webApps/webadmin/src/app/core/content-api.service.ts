import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { AuditEntry, BackendKind, ContentPack } from './models';

const backendKey = 'bh.webadmin.backend';

export class PackConflictError extends Error {
  constructor() {
    super('Pakken er ændret af en anden quizmaster.');
  }
}

@Injectable({ providedIn: 'root' })
export class ContentApiService {
  private readonly http = inject(HttpClient);
  readonly backend = signal<BackendKind>(this.initialBackend());
  readonly baseUrl = computed(() =>
    this.backend() === 'lokal'
      ? 'http://localhost:5199'
      : 'https://byensgaader-api-p.azurewebsites.net',
  );
  readonly host = computed(() => new URL(this.baseUrl()).host);
  private readonly locale = 'da-DK';

  setBackend(backend: BackendKind): void {
    globalThis.window?.localStorage?.setItem(backendKey, backend);
    this.backend.set(backend);
  }

  async loadPack(): Promise<{ pack: ContentPack; etag: string | null }> {
    const response = await firstValueFrom(
      this.http.get<ContentPack>(this.packUrl(), {
        observe: 'response',
        headers: new HttpHeaders({ 'Cache-Control': 'no-cache' }),
      }),
    );
    if (!response.body) throw new Error('Serveren sendte en tom indholdspakke.');
    return { pack: response.body, etag: response.headers.get('ETag') };
  }

  async savePack(
    pack: ContentPack,
    etag: string | null,
    quizmaster: string,
  ): Promise<string | null> {
    let headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'X-Quizmaster': encodeURIComponent(quizmaster.trim()),
    });
    if (etag) headers = headers.set('If-Match', etag);

    try {
      const response = await firstValueFrom(
        this.http.put(this.packUrl(), JSON.stringify(pack, null, 2), {
          headers,
          observe: 'response',
          responseType: 'text',
        }),
      );
      return response.headers.get('ETag');
    } catch (error) {
      if (error instanceof HttpErrorResponse && error.status === 412) throw new PackConflictError();
      throw error;
    }
  }

  async audit(limit = 100): Promise<AuditEntry[]> {
    const response = await firstValueFrom(
      this.http.get<{ entries: AuditEntry[] }>(`${this.contentUrl()}/audit?limit=${limit}`),
    );
    return response.entries;
  }

  mediaUrl(filename: string): string {
    return `${this.contentUrl()}/media/${encodeURIComponent(filename)}`;
  }

  async uploadMedia(filename: string, body: Blob): Promise<void> {
    await firstValueFrom(
      this.http.post(`${this.contentUrl()}/media/${encodeURIComponent(filename)}`, body, {
        headers: new HttpHeaders({ 'Content-Type': body.type || 'image/jpeg' }),
        responseType: 'text',
      }),
    );
  }

  describe(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      if (error.status === 0)
        return 'Kunne ikke få forbindelse til serveren. Er backenden startet?';
      if (error.status === 409)
        return 'Filnavnet er allerede brugt. Prøv at lægge billedet op igen.';
      const detail = error.error?.detail ?? error.error?.title;
      return detail || `Serveren svarede ${error.status}.`;
    }
    return error instanceof Error ? error.message : 'Der skete en ukendt fejl.';
  }

  private contentUrl(): string {
    return `${this.baseUrl()}/content/${this.locale}`;
  }

  private packUrl(): string {
    return `${this.contentUrl()}/pack`;
  }

  private initialBackend(): BackendKind {
    const stored = globalThis.window?.localStorage?.getItem(backendKey);
    if (stored === 'lokal' || stored === 'drift') return stored;
    const hostname = globalThis.window?.location?.hostname;
    return hostname === 'localhost' || hostname === '127.0.0.1' ? 'lokal' : 'drift';
  }
}
