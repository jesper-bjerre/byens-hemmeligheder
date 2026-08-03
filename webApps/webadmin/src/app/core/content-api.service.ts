import { HttpClient, HttpErrorResponse, HttpHeaders, HttpResponse } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  AuditEntry,
  AuthoringSnapshot,
  BackendKind,
  ContentPack,
  MediaAsset,
  MissionAggregate,
  MissionIndex,
  ObjectRevisions,
  SaveResult,
  Source,
  VersionedMediaAsset,
  VersionedSource,
} from './models';

const backendKey = 'bh.webadmin.backend';

export class ObjectConflictError extends Error {
  constructor(readonly id: string) {
    super(`${id} er ændret af en anden quizmaster.`);
  }
}

@Injectable({ providedIn: 'root' })
export class ContentApiService {
  private readonly http = inject(HttpClient);
  readonly backend = signal<BackendKind>(this.initialBackend());
  readonly baseUrl = computed(() =>
    this.backend() === 'lokal'
      ? 'http://localhost:5199'
      : environment.apiBaseUrl,
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

  async loadAuthoring(): Promise<AuthoringSnapshot> {
    const [published, index, media, sources] = await Promise.all([
      this.loadPack(),
      firstValueFrom(this.http.get<MissionIndex>(`${this.authoringUrl()}/missions`)),
      firstValueFrom(this.http.get<VersionedMediaAsset[]>(`${this.authoringUrl()}/media`)),
      firstValueFrom(this.http.get<VersionedSource[]>(`${this.authoringUrl()}/sources`)),
    ]);
    const missionResponses = await Promise.all(
      index.missions.map((summary) =>
        firstValueFrom(
          this.http.get<MissionAggregate>(
            `${this.authoringUrl()}/missions/${encodeURIComponent(summary.id)}`,
            { observe: 'response' },
          ),
        ),
      ),
    );
    const aggregates = missionResponses.map((response) => {
      if (!response.body) throw new Error('Serveren sendte en tom opgave.');
      return response.body;
    });
    const revisions: ObjectRevisions = {
      missions: Object.fromEntries(
        missionResponses.map((response, index) => [
          aggregates[index].mission.id,
          response.headers.get('ETag') ?? '',
        ]),
      ),
      media: Object.fromEntries(media.map((item) => [item.asset.id, item.etag])),
      sources: Object.fromEntries(sources.map((item) => [item.source.id, item.etag])),
    };
    return {
      pack: {
        ...published.pack,
        schemaVersion: aggregates[0]?.schemaVersion ?? published.pack.schemaVersion,
        locale: index.locale,
        missions: aggregates.map((aggregate) => aggregate.mission),
        locations: aggregates.map((aggregate) => aggregate.location),
        media: media.map((item) => item.asset),
        sources: sources.map((item) => item.source),
      },
      revisions,
    };
  }

  saveMission(
    aggregate: MissionAggregate,
    etag: string | null,
    quizmaster: string,
  ): Promise<SaveResult> {
    return this.putObject('missions', aggregate.mission.id, aggregate, etag, quizmaster);
  }

  saveMedia(asset: MediaAsset, etag: string | null, quizmaster: string): Promise<SaveResult> {
    return this.putObject('media', asset.id, asset, etag, quizmaster);
  }

  saveSource(source: Source, etag: string | null, quizmaster: string): Promise<SaveResult> {
    return this.putObject('sources', source.id, source, etag, quizmaster);
  }

  deleteMission(id: string, etag: string, quizmaster: string): Promise<SaveResult> {
    return this.deleteObject('missions', id, etag, quizmaster);
  }

  deleteMedia(id: string, etag: string, quizmaster: string): Promise<SaveResult> {
    return this.deleteObject('media', id, etag, quizmaster);
  }

  deleteSource(id: string, etag: string, quizmaster: string): Promise<SaveResult> {
    return this.deleteObject('sources', id, etag, quizmaster);
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

  async uploadNarration(filename: string, source: File): Promise<void> {
    const extension = source.name.split('.').pop()?.toLowerCase() ?? '';
    await firstValueFrom(
      this.http.post(`${this.contentUrl()}/narration/${encodeURIComponent(filename)}`, source, {
        headers: new HttpHeaders({
          'Content-Type': source.type || 'application/octet-stream',
          'X-Source-Format': extension,
        }),
        responseType: 'text',
      }),
    );
  }

  describe(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      if (error.status === 0)
        return 'Kunne ikke få forbindelse til serveren. Er backenden startet?';
      const detail = error.error?.detail ?? error.error?.title;
      return detail || `Serveren svarede ${error.status}.`;
    }
    return error instanceof Error ? error.message : 'Der skete en ukendt fejl.';
  }

  private async putObject<T>(
    collection: 'missions' | 'media' | 'sources',
    id: string,
    body: T,
    etag: string | null,
    quizmaster: string,
  ): Promise<SaveResult> {
    const headers = this.writeHeaders(etag, quizmaster);
    try {
      const response = await firstValueFrom(
        this.http.put<Omit<SaveResult, 'etag'>>(
          `${this.authoringUrl()}/${collection}/${encodeURIComponent(id)}`,
          body,
          { headers, observe: 'response' },
        ),
      );
      return this.saveResult(response, id);
    } catch (error) {
      this.rethrowConflict(error, id);
    }
  }

  private async deleteObject(
    collection: 'missions' | 'media' | 'sources',
    id: string,
    etag: string,
    quizmaster: string,
  ): Promise<SaveResult> {
    try {
      const response = await firstValueFrom(
        this.http.delete(`${this.authoringUrl()}/${collection}/${encodeURIComponent(id)}`, {
          headers: new HttpHeaders({
            'If-Match': etag,
            'X-Quizmaster': encodeURIComponent(quizmaster.trim()),
          }),
          observe: 'response',
          responseType: 'text',
        }),
      );
      return {
        id,
        publication: this.publication(response),
        publishedContentVersion: null,
        etag: null,
      };
    } catch (error) {
      this.rethrowConflict(error, id);
    }
  }

  private writeHeaders(etag: string | null, quizmaster: string): HttpHeaders {
    let headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'X-Quizmaster': encodeURIComponent(quizmaster.trim()),
    });
    return etag ? headers.set('If-Match', etag) : headers.set('If-None-Match', '*');
  }

  private saveResult(response: HttpResponse<Omit<SaveResult, 'etag'>>, id: string): SaveResult {
    if (!response.body) throw new Error(`Serveren sendte intet gemmeresultat for ${id}.`);
    return { ...response.body, etag: response.headers.get('ETag') };
  }

  private publication(response: HttpResponse<unknown>): SaveResult['publication'] {
    const value = response.headers.get('X-Content-Publication');
    return value === 'published' || value === 'pending' ? value : 'unchanged';
  }

  private rethrowConflict(error: unknown, id: string): never {
    if (error instanceof HttpErrorResponse && error.status === 412) {
      throw new ObjectConflictError(id);
    }
    throw error;
  }

  private authoringUrl(): string {
    return `${this.baseUrl()}/authoring/content/${this.locale}`;
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
