import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Component, EventEmitter, OnInit, Output, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../environments/environment';
import { AuthenticatedAccount } from '../auth/auth.service';

@Component({
  selector: 'app-users-panel',
  imports: [FormsModule],
  template: `
    <div class="backdrop" (click)="closed.emit()">
      <section class="panel" role="dialog" aria-modal="true" aria-labelledby="users-title"
        (click)="$event.stopPropagation()">
        <header>
          <div><span>Administration</span><h2 id="users-title">Brugere og Designers</h2></div>
          <button type="button" (click)="closed.emit()" aria-label="Luk">×</button>
        </header>
        <form (ngSubmit)="load()">
          <input [(ngModel)]="query" name="query" maxlength="100"
            placeholder="Søg efter e-mail, navn eller konto-id" aria-label="Søg brugere" />
          <button type="submit">Søg</button>
        </form>
        @if (error()) { <p class="error">{{ error() }}</p> }
        @if (loading()) {
          <p class="empty">Henter brugere …</p>
        } @else {
          <div class="users">
            @for (account of accounts(); track account.accountId) {
              <article>
                <div>
                  <strong>{{ account.publicName || account.email || 'Uden navn' }}</strong>
                  <small>{{ account.email || account.accountId }}</small>
                </div>
                <span class="role">{{ roleName(account.role) }}</span>
                @if (account.role === 'User' || account.role === 'Designer') {
                  <button type="button" class="change" (click)="changeRole(account)">
                    {{ account.role === 'User' ? 'Gør til Designer' : 'Gør til bruger' }}
                  </button>
                }
              </article>
            } @empty { <p class="empty">Ingen brugere matcher søgningen.</p> }
          </div>
        }
      </section>
    </div>
  `,
  styles: `
    .backdrop { position: fixed; z-index: 100; inset: 0; display: grid; place-items: center;
      padding: 1rem; background: rgb(20 28 25 / 55%); backdrop-filter: blur(4px); }
    .panel { overflow: auto; width: min(760px, 100%); max-height: min(780px, 92dvh); padding: 1.5rem;
      border-radius: 24px; background: var(--paper); box-shadow: var(--shadow-md); }
    header { display: flex; align-items: start; justify-content: space-between; }
    header span { color: var(--muted); font-size: .72rem; font-weight: 800; letter-spacing: .12em; text-transform: uppercase; }
    h2 { margin: .2rem 0 1.5rem; font-family: var(--font-display); font-size: 2rem; }
    header button { border: 0; color: var(--muted); background: transparent; font-size: 2rem; cursor: pointer; }
    form { display: flex; gap: .5rem; }
    input { flex: 1; min-width: 0; padding: .8rem 1rem; border: 1px solid var(--line); border-radius: 12px; font: inherit; }
    form button, .change { padding: .75rem 1rem; border: 0; border-radius: 12px; color: white; background: var(--forest); font: inherit; font-weight: 750; cursor: pointer; }
    .users { display: grid; gap: .65rem; margin-top: 1.25rem; }
    article { display: grid; grid-template-columns: minmax(0, 1fr) auto auto; gap: 1rem; align-items: center;
      padding: .9rem; border: 1px solid var(--line); border-radius: 14px; }
    article div { display: grid; min-width: 0; }
    small { overflow: hidden; color: var(--muted); text-overflow: ellipsis; }
    .role { padding: .35rem .6rem; border-radius: 999px; background: var(--mint); font-size: .75rem; font-weight: 800; }
    .error { color: var(--danger); } .empty { padding: 2rem; color: var(--muted); text-align: center; }
    @media (max-width: 620px) { article { grid-template-columns: 1fr auto; } .change { grid-column: 1 / -1; } }
  `,
})
export class UsersPanel implements OnInit {
  private readonly http = inject(HttpClient);
  @Output() readonly closed = new EventEmitter<void>();
  readonly accounts = signal<AuthenticatedAccount[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  query = '';

  ngOnInit(): void { void this.load(); }

  async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    try {
      this.accounts.set(await firstValueFrom(this.http.get<AuthenticatedAccount[]>(
        `${environment.apiBaseUrl}/admin/accounts`, { params: { query: this.query.trim() } })));
    } catch (error) {
      this.error.set(describe(error));
    } finally {
      this.loading.set(false);
    }
  }

  async changeRole(account: AuthenticatedAccount): Promise<void> {
    const role = account.role === 'User' ? 'Designer' : 'User';
    const action = role === 'Designer' ? 'give Designer-adgang' : 'fjerne Designer-adgangen';
    if (!confirm(`Vil du ${action} for ${account.email || account.accountId}?`)) return;
    this.error.set(null);
    try {
      const updated = await firstValueFrom(this.http.put<AuthenticatedAccount>(
        `${environment.apiBaseUrl}/admin/accounts/${account.accountId}/role`,
        { role, reason: 'Ændret i web-admin' }));
      this.accounts.update((items) => items.map((item) =>
        item.accountId === updated.accountId ? updated : item));
    } catch (error) {
      this.error.set(describe(error));
    }
  }

  roleName(role: AuthenticatedAccount['role']): string {
    return role === 'Admin' ? 'Admin' : role === 'Designer' ? 'Designer' : 'Bruger';
  }
}

function describe(error: unknown): string {
  if (error instanceof HttpErrorResponse && error.status === 403) {
    return 'Kun en Admin kan vedligeholde Designers.';
  }
  return 'Brugerlisten kunne ikke opdateres. Prøv igen.';
}
