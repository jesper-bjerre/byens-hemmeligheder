import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../environments/environment';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let http: HttpTestingController;
  let service: AuthService;
  let state = '';

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    http = TestBed.inject(HttpTestingController);
    service = TestBed.inject(AuthService);
    window.AppleID = {
      auth: {
        init: (options) => { state = options.state; },
        signIn: async () => ({
          authorization: { code: 'apple-code', id_token: 'apple-token', state },
        }),
      },
    };
  });

  afterEach(() => {
    http.verify();
    delete window.AppleID;
  });

  it('holder webtokenet i hukommelsen og giver Designer adgang', async () => {
    const login = service.login();
    await new Promise((resolve) => setTimeout(resolve, 50));
    const request = http.expectOne(`${environment.apiBaseUrl}/auth/apple/web/exchange`);
    expect(request.request.body.clientKind).toBe('WebAdmin');
    expect(request.request.body.nonce.length).toBe(64);
    request.flush(session('Designer'));

    expect(await login).toBe(true);
    expect(service.status()).toBe('authorized');
    expect(service.accessToken()).toBe('kort-access');
  });

  it('afviser en almindelig User fra redaktionen', async () => {
    const login = service.login();
    await new Promise((resolve) => setTimeout(resolve, 50));
    http.expectOne(`${environment.apiBaseUrl}/auth/apple/web/exchange`).flush(session('User'));

    expect(await login).toBe(false);
    expect(service.status()).toBe('forbidden');
    expect(service.accessToken()).toBeNull();
  });
});

function session(role: 'User' | 'Designer') {
  return {
    accessToken: 'kort-access',
    accessExpiresAt: '2026-08-07T15:00:00Z',
    refreshToken: null,
    refreshExpiresAt: null,
    account: {
      accountId: '11111111-1111-1111-1111-111111111111',
      email: 'designer@example.invalid',
      publicName: null,
      role,
      state: 'Active',
    },
  };
}
