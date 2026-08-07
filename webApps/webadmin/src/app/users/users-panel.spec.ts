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
    await fixture.whenStable();
    const account = {
      accountId: '11111111-1111-1111-1111-111111111111',
      email: 'ny@example.invalid', publicName: null,
      role: 'User' as const, state: 'Active' as const,
    };
    fixture.componentInstance.accounts.set([account]);
    vi.spyOn(window, 'confirm').mockReturnValue(true);

    const update = fixture.componentInstance.changeRole(account);
    const request = http.expectOne(
      `${environment.apiBaseUrl}/admin/accounts/${account.accountId}/role`);
    expect(request.request.body.role).toBe('Designer');
    request.flush({ ...account, role: 'Designer' });
    await update;

    expect(fixture.componentInstance.accounts()[0].role).toBe('Designer');
    http.verify();
  });
});
