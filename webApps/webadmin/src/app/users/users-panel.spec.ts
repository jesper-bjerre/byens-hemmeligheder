import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../environments/environment';
import { UsersPanel } from './users-panel';

describe('UsersPanel', () => {
  it('kræver bekræftelse og opdaterer User til Designer', async () => {
    TestBed.configureTestingModule({
      imports: [UsersPanel],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    const http = TestBed.inject(HttpTestingController);
    const fixture = TestBed.createComponent(UsersPanel);
    fixture.detectChanges();
    http.expectOne(`${environment.apiBaseUrl}/admin/accounts?query=`).flush([]);
    http.expectOne(`${environment.apiBaseUrl}/admin/name-reports`).flush([]);
    await vi.waitFor(() => expect(fixture.componentInstance.loading()).toBe(false));
    const account = {
      accountId: '11111111-1111-1111-1111-111111111111',
      email: 'ny@example.invalid',
      publicName: null,
      role: 'User' as const,
      state: 'Active' as const,
    };
    fixture.componentInstance.accounts.set([account]);
    vi.spyOn(window, 'confirm').mockReturnValue(true);

    const update = fixture.componentInstance.changeRole(account);
    const request = http.expectOne(
      `${environment.apiBaseUrl}/admin/accounts/${account.accountId}/role`,
    );
    expect(request.request.body.role).toBe('Designer');
    request.flush({ ...account, role: 'Designer' });
    await update;

    expect(fixture.componentInstance.accounts()[0].role).toBe('Designer');
    http.verify();
  });

  it('skjuler et rapporteret profilnavn', async () => {
    TestBed.configureTestingModule({
      imports: [UsersPanel],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    const http = TestBed.inject(HttpTestingController);
    const fixture = TestBed.createComponent(UsersPanel);
    fixture.detectChanges();
    http.expectOne(`${environment.apiBaseUrl}/admin/accounts?query=`).flush([]);
    http.expectOne(`${environment.apiBaseUrl}/admin/name-reports`).flush([]);
    await vi.waitFor(() => expect(fixture.componentInstance.loading()).toBe(false));
    const account = {
      accountId: '22222222-2222-2222-2222-222222222222',
      email: 'spiller@example.invalid',
      publicName: 'Rapporteret navn',
      role: 'User' as const,
      state: 'Active' as const,
      nameModerationState: 'Visible' as const,
      nameModerationReason: null,
    };
    fixture.componentInstance.accounts.set([account]);
    vi.spyOn(window, 'confirm').mockReturnValue(true);

    const update = fixture.componentInstance.changeModeration(account);
    const request = http.expectOne(
      `${environment.apiBaseUrl}/admin/accounts/${account.accountId}/moderation`,
    );
    expect(request.request.body.hidden).toBe(true);
    request.flush({ ...account, nameModerationState: 'Hidden' });
    await update;

    expect(fixture.componentInstance.accounts()[0].nameModerationState).toBe('Hidden');
    http.verify();
  });

  it('blokerer en User og viser navnerapporter', async () => {
    TestBed.configureTestingModule({
      imports: [UsersPanel],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    const http = TestBed.inject(HttpTestingController);
    const fixture = TestBed.createComponent(UsersPanel);
    fixture.detectChanges();
    http.expectOne(`${environment.apiBaseUrl}/admin/accounts?query=`).flush([]);
    http.expectOne(`${environment.apiBaseUrl}/admin/name-reports`).flush([
      {
        reportId: '33333333-3333-3333-3333-333333333333',
        reporterAccountId: '44444444-4444-4444-4444-444444444444',
        reportedName: 'Uegnet navn',
        category: 'Offensive',
        createdAt: '2026-08-08T18:00:00Z',
      },
    ]);
    await vi.waitFor(() => expect(fixture.componentInstance.loading()).toBe(false));
    expect(fixture.componentInstance.reports()[0].reportedName).toBe('Uegnet navn');
    const account = {
      accountId: '55555555-5555-5555-5555-555555555555',
      email: null,
      publicName: 'Uegnet navn',
      role: 'User' as const,
      state: 'Active' as const,
      nameModerationState: 'Visible' as const,
      nameModerationReason: null,
    };
    fixture.componentInstance.accounts.set([account]);
    vi.spyOn(window, 'confirm').mockReturnValue(true);

    const update = fixture.componentInstance.changeState(account);
    const request = http.expectOne(
      `${environment.apiBaseUrl}/admin/accounts/${account.accountId}/state`,
    );
    expect(request.request.body.state).toBe('Blocked');
    request.flush({ ...account, state: 'Blocked' });
    await update;

    expect(fixture.componentInstance.accounts()[0].state).toBe('Blocked');
    http.verify();
  });
});
