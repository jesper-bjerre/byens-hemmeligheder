import { Injectable, computed, inject, signal } from '@angular/core';
import { evaluateAnswer, normalizeAnswer, transactions, wrongAnswerPercent } from './game-rules';
import {
  AnswerOutcome,
  GameEvent,
  GameSession,
  Hint,
  Mission,
  MissionStep,
  ScoreTransaction,
} from './models';
import { ContentService } from './content.service';

const eventsKey = 'bh.player.events.v1';
const sessionKey = 'bh.player.session.v1';

@Injectable({ providedIn: 'root' })
export class GameStoreService {
  readonly content = inject(ContentService);
  readonly events = signal<GameEvent[]>(this.read<GameEvent[]>(eventsKey, []));
  readonly session = signal<GameSession | null>(this.read<GameSession | null>(sessionKey, null));
  readonly completedIds = computed(
    () =>
      new Set(
        this.events()
          .filter((event) => event.kind === 'missionCompleted')
          .map((event) => event.payload.missionId)
          .filter((id): id is string => !!id),
      ),
  );
  readonly allTransactions = computed(() => this.foldTransactions());
  readonly totalPoints = computed(() =>
    this.allTransactions().reduce((sum, item) => sum + item.points, 0),
  );

  isCompleted(mission: Mission): boolean {
    return this.completedIds().has(mission.id);
  }
  revealedHintIds(mission: Mission): Set<string> {
    return new Set(
      this.events()
        .filter((event) => event.kind === 'hintUsed' && event.payload.missionId === mission.id)
        .map((event) => event.payload.hintId)
        .filter((id): id is string => !!id),
    );
  }

  startMission(mission: Mission): void {
    if (this.isCompleted(mission)) return;
    const first = [...mission.steps].sort((a, b) => a.order - b.order)[0];
    this.session.set({
      missionId: mission.id,
      contentVersion: this.content.pack()?.contentVersion ?? '',
      startedAt: new Date().toISOString(),
      currentStepId: first?.id,
      verified: false,
      safetySeen: false,
    });
    this.persistSession();
    this.record('missionOpened', { missionId: mission.id });
  }

  verifyPresence(mission: Mission, method: string): void {
    const current = this.session();
    if (!current || current.missionId !== mission.id) return;
    this.session.set({ ...current, verified: true });
    this.persistSession();
    this.record('presenceVerified', { missionId: mission.id, presenceMethod: method });
  }

  markSafetySeen(): void {
    const current = this.session();
    if (!current) return;
    this.session.set({ ...current, safetySeen: true });
    this.persistSession();
  }

  viewStep(mission: Mission, step: MissionStep): void {
    const current = this.session();
    if (current?.missionId === mission.id) {
      this.session.set({ ...current, currentStepId: step.id });
      this.persistSession();
    }
    this.record('stepViewed', { missionId: mission.id, stepId: step.id });
  }

  submit(input: string, mission: Mission, step: MissionStep): AnswerOutcome {
    const outcome = evaluateAnswer(input, step);
    if (outcome.kind !== 'malformed') {
      this.record('answerSubmitted', {
        missionId: mission.id,
        stepId: step.id,
        answer: outcome.normalized,
        outcome: outcome.kind,
      });
    }
    return outcome;
  }

  revealHint(mission: Mission, hint: Hint): void {
    const ordered = [...mission.hints].sort((a, b) => a.order - b.order);
    const index = ordered.findIndex((item) => item.id === hint.id);
    const revealed = this.revealedHintIds(mission);
    if (index > 0 && !revealed.has(ordered[index - 1].id)) return;
    if (!revealed.has(hint.id)) this.record('hintUsed', { missionId: mission.id, hintId: hint.id });
  }

  complete(mission: Mission): void {
    if (!this.isCompleted(mission)) this.record('missionCompleted', { missionId: mission.id });
    this.session.set(null);
    this.persistSession();
  }

  pointsFor(mission: Mission): number {
    return this.transactionsFor(mission).reduce((sum, item) => sum + item.points, 0);
  }
  transactionsFor(mission: Mission): ScoreTransaction[] {
    return this.allTransactions().filter((item) => item.missionId === mission.id);
  }

  resetProgress(): void {
    this.events.set([]);
    this.session.set(null);
    globalThis.window?.localStorage?.removeItem(eventsKey);
    globalThis.window?.localStorage?.removeItem(sessionKey);
  }

  private foldTransactions(): ScoreTransaction[] {
    const pack = this.content.pack();
    if (!pack) return [];
    const result: ScoreTransaction[] = [];
    for (const mission of pack.missions) {
      const missionEvents = this.events().filter((event) => event.payload.missionId === mission.id);
      const completion = missionEvents.find((event) => event.kind === 'missionCompleted');
      if (!completion) continue;
      const hints = missionEvents
        .filter((event) => event.kind === 'hintUsed')
        .flatMap((event) => {
          const hint = mission.hints.find((item) => item.id === event.payload.hintId);
          return hint
            ? [{ id: hint.id, order: hint.order, percent: hint.penaltyPercent, eventId: event.id }]
            : [];
        });
      const wrongAnswers = missionEvents
        .filter(
          (event) =>
            event.kind === 'answerSubmitted' &&
            (event.payload.outcome === 'incorrect' || event.payload.outcome === 'nearMiss'),
        )
        .flatMap((event) => {
          const step = mission.steps.find((item) => item.id === event.payload.stepId);
          return step
            ? [
                {
                  stepId: step.id,
                  answer: normalizeAnswer(event.payload.answer ?? event.id, step.answerRule?.kind),
                  percent: wrongAnswerPercent(step),
                  eventId: event.id,
                },
              ]
            : [];
        });
      result.push(
        ...transactions(mission, { completionEventId: completion.id, hints, wrongAnswers }),
      );
    }
    return result;
  }

  private record(kind: GameEvent['kind'], payload: GameEvent['payload']): void {
    const current = this.events();
    const event: GameEvent = {
      id: globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random()}`,
      sequence: (current.at(-1)?.sequence ?? 0) + 1,
      occurredAt: new Date().toISOString(),
      contentVersion: this.session()?.contentVersion ?? this.content.pack()?.contentVersion ?? '',
      kind,
      payload,
    };
    this.events.set([...current, event]);
    globalThis.window?.localStorage?.setItem(eventsKey, JSON.stringify(this.events()));
  }

  private persistSession(): void {
    const storage = globalThis.window?.localStorage;
    if (this.session()) storage?.setItem(sessionKey, JSON.stringify(this.session()));
    else storage?.removeItem(sessionKey);
  }

  private read<T>(key: string, fallback: T): T {
    try {
      return JSON.parse(globalThis.window?.localStorage?.getItem(key) ?? '') as T;
    } catch {
      return fallback;
    }
  }
}
