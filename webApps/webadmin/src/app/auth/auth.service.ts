import { HttpClient } from '@angular/common/http';
import { Injectable, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../environments/environment';

export interface AuthenticatedAccount {
  accountId: string;
  email: string | null;
  publicName: string | null;
  role: 'User' | 'Designer' | 'Admin';
  state: 'Active' | 'Blocked' | 'Deleted';
}

interface WebSession {
  accessToken: string;
  accessExpiresAt: string;
  refreshToken: null;
  refreshExpiresAt: null;
  account: AuthenticatedAccount;
}

interface AppleResult {
  authorization: { code: string; id_token: string; state: string };
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly token = signal<string | null>(null);

  readonly status = signal<'guest' | 'checking' | 'authorized' | 'forbidden' | 'error'>('guest');
  readonly account = signal<AuthenticatedAccount | null>(null);
  readonly error = signal<string | null>(null);

  accessToken(): string | null {
    return this.token();
  }

  async login(): Promise<boolean> {
    this.status.set('checking');
    this.error.set(null);
    try {
      const apple = await waitForApple();
      const state = randomValue();
      const nonce = randomValue();
      apple.auth.init({
        clientId: environment.appleClientId,
        scope: 'name email',
        redirectURI: environment.appleRedirectUri,
        state,
        nonce: await sha256(nonce),
        usePopup: true,
      });
      const result = await apple.auth.signIn();
      if (result.authorization.state !== state) {
        throw new Error('Apple-login svarede med en forkert state-værdi.');
      }
      const session = await firstValueFrom(
        this.http.post<WebSession>(`${environment.apiBaseUrl}/auth/apple/web/exchange`, {
          clientId: environment.appleClientId,
          identityToken: result.authorization.id_token,
          authorizationCode: result.authorization.code,
          nonce,
          redirectUri: environment.appleRedirectUri,
          clientKind: 'WebAdmin',
        }),
      );
      this.account.set(session.account);
      if (session.account.role !== 'Designer' && session.account.role !== 'Admin') {
        this.status.set('forbidden');
        return false;
      }
      this.token.set(session.accessToken);
      this.status.set('authorized');
      return true;
    } catch (error) {
      this.clear('error');
      this.error.set(
        error instanceof Error ? error.message : 'Apple-login kunne ikke gennemføres.',
      );
      return false;
    }
  }

  async logout(): Promise<void> {
    const token = this.token();
    if (token) {
      try {
        await firstValueFrom(
          this.http.post(`${environment.apiBaseUrl}/auth/logout`, null, {
            headers: { Authorization: `Bearer ${token}` },
          }),
        );
      } catch {
        // Lokal oprydning må ikke afhænge af netværket.
      }
    }
    this.clear('guest');
  }

  expire(): void {
    this.clear('guest');
    this.error.set('Din session er udløbet. Log ind igen for at fortsætte.');
  }

  private clear(status: 'guest' | 'error'): void {
    this.token.set(null);
    this.account.set(null);
    this.status.set(status);
  }
}

interface AppleApi {
  auth: {
    init(options: {
      clientId: string;
      scope: string;
      redirectURI: string;
      state: string;
      nonce: string;
      usePopup: boolean;
    }): void;
    signIn(): Promise<AppleResult>;
  };
}

declare global {
  interface Window { AppleID?: AppleApi; }
}

async function waitForApple(): Promise<AppleApi> {
  for (let attempt = 0; attempt < 50; attempt += 1) {
    if (window.AppleID) return window.AppleID;
    await new Promise((resolve) => window.setTimeout(resolve, 100));
  }
  throw new Error('Apple-login kunne ikke indlæses. Kontrollér forbindelsen og prøv igen.');
}

function randomValue(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return [...bytes].map((value) => value.toString(16).padStart(2, '0')).join('');
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value));
  return [...new Uint8Array(digest)]
    .map((item) => item.toString(16).padStart(2, '0'))
    .join('');
}
