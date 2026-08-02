import { Component, Input, inject, signal } from '@angular/core';
import { ContentService } from '../core/content.service';

@Component({
  selector: 'app-mission-image',
  standalone: true,
  template: `
    @if (content.media(mediaId); as asset) {
      <figure [class.hero]="hero">
        <button
          type="button"
          class="image-button"
          (click)="zoomed.set(true)"
          aria-label="Vis billedet stort"
        >
          <img
            [src]="content.mediaUrl(mediaId)"
            [alt]="asset.altText"
            [attr.loading]="hero ? 'eager' : 'lazy'"
            [attr.fetchpriority]="hero ? 'high' : null"
          />
        </button>
        @if (asset.kind === 'aiGenerated') {
          <span class="ai-badge">✦ AI-genereret billede</span>
        }
        @if (asset.creditLine || asset.credit) {
          <figcaption>{{ asset.creditLine || asset.credit }}</figcaption>
        }
      </figure>
      @if (zoomed()) {
        <div
          class="lightbox"
          role="dialog"
          aria-modal="true"
          aria-label="Billede i stor størrelse"
          (click)="zoomed.set(false)"
        >
          <button type="button" aria-label="Luk billedet" (click)="zoomed.set(false)">×</button>
          <img [src]="content.mediaUrl(mediaId)" [alt]="asset.altText" />
        </div>
      }
    }
  `,
  styles: [
    `
      :host,
      figure {
        display: block;
        margin: 0;
      }
      figure {
        position: relative;
        overflow: hidden;
        background: #d9ddd5;
      }
      .image-button {
        display: block;
        width: 100%;
        padding: 0;
        border: 0;
        background: none;
        cursor: zoom-in;
      }
      img {
        display: block;
        width: 100%;
        aspect-ratio: 4/3;
        object-fit: cover;
      }
      .hero img {
        aspect-ratio: 16/9;
      }
      figcaption {
        position: absolute;
        inset: auto 0 0;
        padding: 28px 12px 9px;
        color: white;
        background: linear-gradient(transparent, rgba(0, 0, 0, 0.72));
        font-size: 0.72rem;
      }
      .ai-badge {
        position: absolute;
        top: 10px;
        left: 10px;
        padding: 6px 9px;
        border-radius: 999px;
        color: #382713;
        background: #f4d18c;
        font-size: 0.72rem;
        font-weight: 700;
      }
      .lightbox {
        position: fixed;
        inset: 0;
        z-index: 3000;
        display: grid;
        place-items: center;
        padding: 50px 16px 20px;
        background: rgba(7, 19, 18, 0.94);
      }
      .lightbox img {
        width: auto;
        max-width: min(1100px, 96vw);
        height: auto;
        max-height: 88vh;
        object-fit: contain;
      }
      .lightbox button {
        position: absolute;
        top: 16px;
        right: 20px;
        width: 44px;
        height: 44px;
        border: 1px solid #ffffff55;
        border-radius: 50%;
        background: #ffffff15;
        color: white;
        font-size: 30px;
        cursor: pointer;
      }
    `,
  ],
})
export class MissionImage {
  @Input() mediaId: string | null | undefined;
  @Input() hero = false;
  readonly content = inject(ContentService);
  readonly zoomed = signal(false);
}
