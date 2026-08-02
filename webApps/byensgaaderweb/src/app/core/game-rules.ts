import { AnswerOutcome, Mission, MissionStep, ScoreTransaction } from './models';

export function normalizeAnswer(input: string, kind = 'exact'): string {
  const value = input
    .trim()
    .toLocaleLowerCase('da-DK')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '');
  if (kind === 'digitsOnly') return value.replace(/\D/g, '');
  return value
    .replace(/[.,!?;:'"`()\[\]{}]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

export function evaluateAnswer(input: string, step: MissionStep): AnswerOutcome {
  const rule = step.answerRule;
  if (!rule)
    return { kind: 'malformed', feedback: 'Dette trin kan ikke besvares.', normalized: '' };
  const candidate = normalizeAnswer(input, rule.kind);
  if (!candidate)
    return { kind: 'malformed', feedback: 'Skriv et svar, før du sender.', normalized: '' };
  if (
    rule.acceptedAnswers.map((answer) => normalizeAnswer(answer, rule.kind)).includes(candidate)
  ) {
    return { kind: 'correct', normalized: candidate };
  }
  const nearMiss = rule.nearMissResponses.find(
    (item) => normalizeAnswer(item.answer, rule.kind) === candidate,
  );
  if (nearMiss) return { kind: 'nearMiss', feedback: nearMiss.feedback, normalized: candidate };
  if (step.kind === 'numericCode' && step.length && candidate.length !== step.length) {
    return {
      kind: 'malformed',
      feedback:
        candidate.length < step.length
          ? `Koden er på ${step.length} cifre. Du mangler et par endnu.`
          : `Koden er på ${step.length} cifre. Der er et ciffer for meget.`,
      normalized: candidate,
    };
  }
  return {
    kind: 'incorrect',
    feedback: 'Det er ikke rigtigt. Kig en gang til på stedet — svaret er der.',
    normalized: candidate,
  };
}

export function penalty(base: number, percent: number): number {
  return Math.round((base * percent) / 100);
}

export function wrongAnswerPercent(step: MissionStep): number {
  if (step.kind === 'singleChoice') return 12 / Math.max(1, (step.options?.length ?? 2) - 1);
  if (step.kind === 'numericCode' || step.kind === 'freeText') return 2;
  return 0;
}

export interface LedgerFacts {
  completionEventId: string;
  hints: { id: string; order: number; percent: number; eventId: string }[];
  wrongAnswers: { stepId: string; answer: string; percent: number; eventId: string }[];
}

export function transactions(mission: Mission, facts: LedgerFacts): ScoreTransaction[] {
  const result: ScoreTransaction[] = [
    {
      id: `${facts.completionEventId}:missionCompleted`,
      missionId: mission.id,
      points: mission.basePoints,
      explanation: 'Opgave løst',
      reason: 'missionCompleted',
    },
  ];
  const seenHints = new Set<string>();
  for (const hint of facts.hints) {
    if (seenHints.has(hint.id)) continue;
    seenHints.add(hint.id);
    result.push({
      id: `${hint.eventId}:hintUsed`,
      missionId: mission.id,
      points: -penalty(mission.basePoints, hint.percent),
      explanation: `Hint ${hint.order}`,
      reason: 'hintUsed',
    });
  }
  let spent = 0;
  const seenAnswers = new Set<string>();
  for (const wrong of facts.wrongAnswers) {
    const key = `${wrong.stepId}|${wrong.answer}`;
    if (seenAnswers.has(key)) continue;
    seenAnswers.add(key);
    const percent = Math.min(wrong.percent, 12 - spent);
    if (percent <= 0) break;
    spent += percent;
    result.push({
      id: `${wrong.eventId}:wrongAnswer`,
      missionId: mission.id,
      points: -penalty(mission.basePoints, percent),
      explanation: 'Forkert svar',
      reason: 'wrongAnswer',
    });
  }
  return result;
}

export function distanceMetres(
  a: { latitude: number; longitude: number },
  b: { latitude: number; longitude: number },
): number {
  const radians = (value: number) => (value * Math.PI) / 180;
  const dLat = radians(b.latitude - a.latitude);
  const dLon = radians(b.longitude - a.longitude);
  const lat1 = radians(a.latitude);
  const lat2 = radians(b.latitude);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return 6_371_000 * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

export function bearingDegrees(
  a: { latitude: number; longitude: number },
  b: { latitude: number; longitude: number },
): number {
  const radians = (value: number) => (value * Math.PI) / 180;
  const lat1 = radians(a.latitude);
  const lat2 = radians(b.latitude);
  const dLon = radians(b.longitude - a.longitude);
  const y = Math.sin(dLon) * Math.cos(lat2);
  const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
  return ((Math.atan2(y, x) * 180) / Math.PI + 360) % 360;
}
