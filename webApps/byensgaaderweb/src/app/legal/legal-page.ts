import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-legal-page',
  imports: [RouterLink],
  template: `
    <article class="legal-shell">
      <a routerLink="/" class="back">← Tilbage til Vejles Gåder</a>
      <p class="eyebrow">Vejles Gåder og hemmeligheder</p>
      <h1>{{ title() }}</h1>
      <p class="updated">Senest opdateret 7. august 2026</p>
      <ng-content />
      <p class="contact">
        Spørgsmål kan sendes til
        <a href="mailto:jesper@hyldenbrandt.com">jesper&#64;hyldenbrandt.com</a>.
      </p>
    </article>
  `,
  styles: `
    :host { display: block; min-height: 100%; background: #f8f4ec; color: #241f1a; }
    .legal-shell { width: min(760px, calc(100% - 32px)); margin: 0 auto; padding: 40px 0 72px; line-height: 1.65; }
    .back { display: inline-block; margin-bottom: 32px; color: #81572a; font-weight: 700; text-decoration: none; }
    .eyebrow { margin: 0 0 6px; color: #81572a; font-size: .8rem; font-weight: 800; letter-spacing: .12em; text-transform: uppercase; }
    h1 { margin: 0; font-size: clamp(2rem, 7vw, 3.4rem); line-height: 1.05; }
    .updated { margin: 10px 0 36px; color: #6d655d; }
    :host ::ng-deep h2 { margin: 32px 0 8px; font-size: 1.25rem; }
    :host ::ng-deep ul { padding-left: 22px; }
    :host ::ng-deep a { color: #71471d; }
    .contact { margin-top: 40px; padding: 20px; border: 1px solid #dfd3c5; border-radius: 16px; background: #fff; }
  `,
})
export class LegalPage {
  readonly title = input.required<string>();
}
