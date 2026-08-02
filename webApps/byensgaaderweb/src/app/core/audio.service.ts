import { Injectable, signal } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class AudioService {
  readonly enabled = signal(globalThis.window?.localStorage?.getItem('bh.player.audio') !== 'off');
  readonly playing = signal(false);
  private audio: HTMLAudioElement | null = null;

  toggle(): void {
    this.enabled.update((value) => !value);
    globalThis.window?.localStorage?.setItem('bh.player.audio', this.enabled() ? 'on' : 'off');
    if (this.enabled()) this.start();
    else this.stop();
  }

  start(): void {
    if (!this.enabled() || !globalThis.window) return;
    this.audio ??= new Audio('/audio/ambience-by.m4a');
    this.audio.loop = true;
    this.audio.volume = 0.18;
    void this.audio
      .play()
      .then(() => this.playing.set(true))
      .catch(() => this.playing.set(false));
  }

  stop(): void {
    this.audio?.pause();
    this.playing.set(false);
  }
}
