import { Component, computed, effect, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ContentService } from '../core/content.service';
import { penalty } from '../core/game-rules';
import { GameStoreService } from '../core/game-store.service';
import { AnswerOutcome, Hint, MissionStep } from '../core/models';
import { MissionImage } from '../shared/mission-image';

@Component({
  selector: 'app-play',
  imports: [FormsModule, RouterLink, MissionImage],
  templateUrl: './play.html',
  styleUrl: './play.scss',
})
export class Play {
  readonly content = inject(ContentService);
  readonly game = inject(GameStoreService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly mission = computed(() => this.content.mission(this.route.snapshot.paramMap.get('id')));
  readonly orderedSteps = computed(() =>
    [...(this.mission()?.steps ?? [])].sort((a, b) => a.order - b.order),
  );
  readonly step = computed(
    () =>
      this.orderedSteps().find((item) => item.id === this.game.session()?.currentStepId) ??
      this.orderedSteps()[0],
  );
  readonly cards = computed(() =>
    [...(this.mission()?.cards ?? [])].sort((a, b) => a.order - b.order),
  );
  readonly hintsOpen = signal(false);
  readonly answerOutcome = signal<AnswerOutcome | null>(null);
  readonly safetyOpen = signal(false);
  answer = '';
  selectedChoice = '';
  private viewedStepId?: string;
  constructor() {
    effect(() => {
      const pack = this.content.pack(),
        mission = this.mission(),
        session = this.game.session();
      if (!pack || !mission) return;
      if (!session || session.missionId !== mission.id || !session.verified) {
        void this.router.navigate(['/opgave', mission.id, 'find']);
        return;
      }
      this.safetyOpen.set(!session.safetySeen);
      const step = this.step();
      if (step && this.viewedStepId !== step.id) {
        this.viewedStepId = step.id;
        this.game.viewStep(mission, step);
      }
    });
  }
  closeSafety(): void {
    this.game.markSafetySeen();
    this.safetyOpen.set(false);
  }
  hintsForStep(): Hint[] {
    const mission = this.mission(),
      step = this.step();
    if (!mission || !step) return [];
    return step.hintIds
      .map((id) => mission.hints.find((h) => h.id === id))
      .filter((h): h is Hint => !!h)
      .sort((a, b) => a.order - b.order);
  }
  allHints(): Hint[] {
    return [...(this.mission()?.hints ?? [])].sort((a, b) => a.order - b.order);
  }
  isRevealed(hint: Hint): boolean {
    const mission = this.mission();
    return mission ? this.game.revealedHintIds(mission).has(hint.id) : false;
  }
  isUnlocked(hint: Hint): boolean {
    const hints = this.allHints(),
      index = hints.findIndex((h) => h.id === hint.id);
    return index <= 0 || this.isRevealed(hints[index - 1]);
  }
  hintPenalty(hint: Hint): number {
    return penalty(this.mission()?.basePoints ?? 0, hint.penaltyPercent);
  }
  reveal(hint: Hint): void {
    const mission = this.mission();
    if (mission) this.game.revealHint(mission, hint);
  }
  choose(label: string): void {
    this.selectedChoice = label;
    this.answer = label;
    this.submit();
  }
  submit(): void {
    const mission = this.mission(),
      step = this.step();
    if (!mission || !step) return;
    this.answerOutcome.set(this.game.submit(this.answer, mission, step));
  }
  continue(): void {
    const mission = this.mission(),
      step = this.step();
    if (!mission || !step) return;
    const steps = this.orderedSteps();
    const index = steps.findIndex((item) => item.id === step.id);
    const next = steps
      .slice(index + 1)
      .find((item) => ['narrative', 'singleChoice', 'numericCode', 'freeText'].includes(item.kind));
    this.answer = '';
    this.selectedChoice = '';
    this.answerOutcome.set(null);
    if (next) {
      this.viewedStepId = next.id;
      this.game.viewStep(mission, next);
    } else {
      this.game.complete(mission);
      void this.router.navigate(['/opgave', mission.id, 'loest']);
    }
  }
  isChallenge(step: MissionStep): boolean {
    return ['singleChoice', 'numericCode', 'freeText'].includes(step.kind);
  }
}
