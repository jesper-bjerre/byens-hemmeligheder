import { CommonModule } from '@angular/common';
import {
  Component,
  EventEmitter,
  Input,
  OnInit,
  Output,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ContentApiService } from '../core/content-api.service';
import { ContentStoreService } from '../core/content-store.service';
import { ChoiceOption, MediaAsset, MissionCard, MissionStep } from '../core/models';
import { prepareJpeg } from '../core/image';
import { PostalCodesService } from '../core/postal-codes.service';
import { displayName, regions, statusChoices } from '../core/vocabulary';
import { LocationMap } from '../location-map/location-map';

type EditorTab = 'opgaven' | 'stedet' | 'detaljer' | 'spoergsmaal' | 'hints';

@Component({
  selector: 'app-mission-editor',
  standalone: true,
  imports: [CommonModule, FormsModule, LocationMap],
  templateUrl: './mission-editor.html',
  styleUrl: './mission-editor.scss',
})
export class MissionEditor implements OnInit {
  @Input({ required: true }) missionIndex!: number;
  @Output() closed = new EventEmitter<void>();

  readonly store = inject(ContentStoreService);
  readonly api = inject(ContentApiService);
  readonly postcodes = inject(PostalCodesService);
  readonly tabs: { id: EditorTab; label: string; icon: string }[] = [
    { id: 'opgaven', label: 'Opgaven', icon: '◫' },
    { id: 'stedet', label: 'Stedet', icon: '⌖' },
    { id: 'detaljer', label: 'Detaljer', icon: '▤' },
    { id: 'spoergsmaal', label: 'Spørgsmål', icon: '?' },
    { id: 'hints', label: 'Hints', icon: '✦' },
  ];
  readonly regions = regions;
  readonly activeTab = signal<EditorTab>('opgaven');
  readonly locating = signal(false);
  readonly locationError = signal<string | null>(null);
  readonly lastAccuracy = signal<number | null>(null);
  readonly uploadCardIndex = signal<number | null>(null);
  readonly uploadFile = signal<File | null>(null);
  readonly uploadPreview = signal<string | null>(null);
  readonly uploadAltText = signal('');
  readonly uploading = signal(false);
  readonly uploadError = signal<string | null>(null);
  readonly narrationFile = signal<File | null>(null);
  readonly narrationUploading = signal(false);
  readonly narrationError = signal<string | null>(null);
  region = '';

  readonly mission = computed(() => this.store.pack()?.missions[this.missionIndex] ?? null);
  readonly location = computed(() => {
    const mission = this.mission();
    return mission
      ? (this.store.pack()?.locations.find((location) => location.id === mission.locationId) ??
          null)
      : null;
  });
  readonly assessedStep = computed(() => {
    const steps = this.mission()?.steps ?? [];
    return steps.find((step) => step.kind !== 'narrative') ?? steps[0] ?? null;
  });
  readonly narrationMedia = computed(() => {
    const mediaId = this.mission()?.narrationMediaId;
    return this.store.pack()?.media.find((media) => media.id === mediaId) ?? null;
  });

  ngOnInit(): void {
    this.region = this.postcodes.place(this.location()?.postalCode ?? '')?.region ?? regions[0];
  }

  changed(): void {
    this.store.markChanged();
  }

  titleChanged(title: string): void {
    const mission = this.mission();
    if (!mission) return;
    const previous = mission.title;
    mission.title = title;
    if (!mission.shortTitle || mission.shortTitle === previous) mission.shortTitle = title;
    this.changed();
  }

  choices(current: string): string[] {
    return statusChoices(current);
  }

  name(value: string): string {
    return displayName(value);
  }

  placesInRegion() {
    return this.postcodes.inRegion(this.region);
  }

  regionChanged(): void {
    const location = this.location();
    if (!location) return;
    const choices = this.placesInRegion();
    if (!choices.some((place) => place.code === location.postalCode) && choices[0]) {
      location.postalCode = choices[0].code;
      this.changed();
    }
  }

  useCurrentPosition(): void {
    if (!navigator.geolocation) {
      this.locationError.set('Browseren understøtter ikke positionsmåling.');
      return;
    }
    this.locating.set(true);
    this.locationError.set(null);
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const location = this.location();
        if (location) {
          location.latitude = position.coords.latitude;
          location.longitude = position.coords.longitude;
          this.lastAccuracy.set(position.coords.accuracy);
          this.changed();
        }
        this.locating.set(false);
      },
      (error) => {
        this.locationError.set(
          error.code === error.PERMISSION_DENIED
            ? 'Tillad adgang til position i browseren, og prøv igen.'
            : 'Positionen kunne ikke aflæses. Stå stille et øjeblik, og prøv igen.',
        );
        this.locating.set(false);
      },
      { enableHighAccuracy: true, timeout: 15_000, maximumAge: 0 },
    );
  }

  moveCard(index: number, direction: -1 | 1): void {
    const cards = this.mission()?.cards;
    const destination = index + direction;
    if (!cards || destination < 0 || destination >= cards.length) return;
    [cards[index], cards[destination]] = [cards[destination], cards[index]];
    cards.forEach((card, position) => (card.order = position + 1));
    this.changed();
  }

  addCard(): void {
    const mission = this.mission();
    if (!mission) return;
    const order = mission.cards.length + 1;
    mission.cards.push({ id: `card.${mission.slug}.${order}`, order, mediaId: null, text: '' });
    this.changed();
  }

  removeCard(index: number): void {
    const cards = this.mission()?.cards;
    if (!cards || !confirm(`Fjern detalje ${index + 1}?`)) return;
    cards.splice(index, 1);
    cards.forEach((card, position) => (card.order = position + 1));
    this.changed();
  }

  mediaFor(card: MissionCard): MediaAsset | undefined {
    return this.store.pack()?.media.find((media) => media.id === card.mediaId);
  }

  openUpload(index: number): void {
    this.uploadCardIndex.set(index);
    this.uploadFile.set(null);
    this.uploadAltText.set('');
    this.uploadError.set(null);
    this.revokePreview();
  }

  chooseFile(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0] ?? null;
    this.revokePreview();
    this.uploadFile.set(file);
    if (file) this.uploadPreview.set(URL.createObjectURL(file));
  }

  closeUpload(): void {
    if (this.uploading()) return;
    this.uploadCardIndex.set(null);
    this.revokePreview();
  }

  async upload(): Promise<void> {
    const pack = this.store.pack();
    const mission = this.mission();
    const cardIndex = this.uploadCardIndex();
    const file = this.uploadFile();
    const altText = this.uploadAltText().trim();
    if (!pack || !mission || cardIndex === null || !file || !altText) return;

    this.uploading.set(true);
    this.uploadError.set(null);
    try {
      const blob = await prepareJpeg(file);
      const number = this.nextMediaNumber(mission.slug);
      const suffix = String(number).padStart(3, '0');
      const filename = `${mission.slug}-${suffix}.jpg`;
      const mediaId = `media.${mission.slug}.${suffix}`;
      await this.api.uploadMedia(filename, blob);
      pack.media.push({
        id: mediaId,
        filename,
        altText,
        owner: this.store.quizmaster(),
        licence: 'Eget materiale — Byens Gåder ejer rettighederne',
        credit: 'Byens Gåder',
        creditLine: null,
        kind: 'contemporary',
        mediaType: 'image',
        manipulation: null,
        restrictions: null,
        expiresAt: null,
      });
      mission.cards[cardIndex].mediaId = mediaId;
      this.changed();
      this.uploading.set(false);
      this.closeUpload();
    } catch (error) {
      this.uploadError.set(this.api.describe(error));
    } finally {
      this.uploading.set(false);
    }
  }

  chooseNarration(event: Event): void {
    this.narrationFile.set((event.target as HTMLInputElement).files?.[0] ?? null);
    this.narrationError.set(null);
  }

  async uploadNarration(): Promise<void> {
    const pack = this.store.pack();
    const mission = this.mission();
    const source = this.narrationFile();
    if (!pack || !mission || !source) return;

    this.narrationUploading.set(true);
    this.narrationError.set(null);
    try {
      const stem = `narration-${mission.slug || 'opgave'}`;
      const number = this.nextMediaNumber(stem);
      const suffix = String(number).padStart(3, '0');
      const filename = `${stem}-${suffix}.mp3`;
      const mediaId = `media.${stem}.${suffix}`;

      await this.api.uploadNarration(filename, source);
      pack.media.push({
        id: mediaId,
        filename,
        altText: `Fortælling til ${mission.title}`,
        owner: this.store.quizmaster(),
        licence: 'Eget materiale — Byens Gåder ejer rettighederne',
        credit: 'Byens Gåder',
        creditLine: null,
        kind: 'contemporary',
        mediaType: 'audio',
        manipulation: 'Konverteret til MP3, mono, 64 kbit/s',
        restrictions: null,
        expiresAt: null,
      });
      mission.narrationMediaId = mediaId;
      this.narrationFile.set(null);
      this.changed();
    } catch (error) {
      this.narrationError.set(this.api.describe(error));
    } finally {
      this.narrationUploading.set(false);
    }
  }

  removeNarration(): void {
    const mission = this.mission();
    if (!mission) return;
    mission.narrationMediaId = null;
    this.narrationFile.set(null);
    this.narrationError.set(null);
    this.changed();
  }

  changeStepKind(kind: string): void {
    const step = this.assessedStep();
    if (!step || step.kind === kind) return;
    step.kind = kind;
    if (kind === 'singleChoice' && (step.options?.length ?? 0) < 2) {
      step.options = [
        { id: 'valg-1', label: '' },
        { id: 'valg-2', label: '' },
      ];
    }
    if (kind === 'numericCode') {
      step.length ??= 3;
      step.answerRule.kind = 'digitsOnly';
    } else {
      step.answerRule.kind = 'exact';
    }
    this.changed();
  }

  addOption(step: MissionStep): void {
    step.options ??= [];
    const option: ChoiceOption = { id: `valg-${step.options.length + 1}`, label: '' };
    step.options.push(option);
    this.changed();
  }

  removeOption(step: MissionStep, index: number): void {
    step.options?.splice(index, 1);
    this.changed();
  }

  addAnswer(step: MissionStep): void {
    step.answerRule.acceptedAnswers.push('');
    this.changed();
  }

  removeAnswer(step: MissionStep, index: number): void {
    step.answerRule.acceptedAnswers.splice(index, 1);
    this.changed();
  }

  async close(): Promise<void> {
    await this.store.save();
    this.closed.emit();
  }

  async save(): Promise<void> {
    await this.store.save();
  }

  private nextMediaNumber(stem: string): number {
    const numbers = (this.store.pack()?.media ?? [])
      .map((asset) => asset.filename.match(new RegExp(`^${escapeRegExp(stem)}-(\\d+)`))?.[1])
      .filter((value): value is string => !!value)
      .map(Number);
    return Math.max(-1, ...numbers) + 1;
  }

  private revokePreview(): void {
    const preview = this.uploadPreview();
    if (preview) URL.revokeObjectURL(preview);
    this.uploadPreview.set(null);
  }
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
