import { Component, HostListener, OnInit, inject } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';
import { AudioService } from './core/audio.service';
import { ContentService } from './core/content.service';
import { GameStoreService } from './core/game-store.service';

@Component({
  selector: 'app-root',
  imports: [RouterLink, RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App implements OnInit {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  readonly audio = inject(AudioService);

  ngOnInit(): void {
    void this.content.load();
  }

  @HostListener('document:visibilitychange')
  visibilityChanged(): void {
    if (document.hidden) this.audio.stop();
    else this.audio.start();
  }
}
