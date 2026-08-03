import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { ContentApiService } from './content-api.service';
import { LocationRecord, Mission, MissionAggregate } from './models';

describe('ContentApiService authoring', () => {
  let api: ContentApiService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    api = TestBed.inject(ContentApiService);
    http = TestBed.inject(HttpTestingController);
    api.setBackend('lokal');
  });

  afterEach(() => http.verify());

  it('gemmer en eksisterende opgave med dens egen ETag', async () => {
    const aggregate = missionAggregate();
    const resultPromise = api.saveMission(aggregate, '"mission-etag"', 'Ada');

    const request = http.expectOne(
      'http://localhost:5199/authoring/content/da-DK/missions/mission.test',
    );
    expect(request.request.method).toBe('PUT');
    expect(request.request.headers.get('If-Match')).toBe('"mission-etag"');
    expect(request.request.headers.has('If-None-Match')).toBe(false);
    expect(request.request.headers.get('X-Quizmaster')).toBe('Ada');
    expect(request.request.body).toEqual(aggregate);
    request.flush(
      { id: 'mission.test', publication: 'published', publishedContentVersion: 'version-2' },
      { headers: { ETag: '"mission-etag-2"' } },
    );

    await expect(resultPromise).resolves.toEqual({
      id: 'mission.test',
      publication: 'published',
      publishedContentVersion: 'version-2',
      etag: '"mission-etag-2"',
    });
  });

  it('opretter en ny opgave med If-None-Match', async () => {
    const resultPromise = api.saveMission(missionAggregate(), null, 'Ada');

    const request = http.expectOne(
      'http://localhost:5199/authoring/content/da-DK/missions/mission.test',
    );
    expect(request.request.headers.get('If-None-Match')).toBe('*');
    expect(request.request.headers.has('If-Match')).toBe(false);
    request.flush(
      { id: 'mission.test', publication: 'unchanged', publishedContentVersion: null },
      { status: 201, statusText: 'Created', headers: { ETag: '"created"' } },
    );

    expect((await resultPromise).etag).toBe('"created"');
  });
});

function missionAggregate(): MissionAggregate {
  const mission = {
    id: 'mission.test',
    locationId: 'loc.test',
  } as Mission;
  const location = { id: 'loc.test' } as LocationRecord;
  return { schemaVersion: '1.0.0', mission, location };
}
