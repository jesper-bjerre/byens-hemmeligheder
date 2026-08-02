import { describe, expect, it } from 'vitest';
import {
  evaluateAnswer,
  normalizeAnswer,
  penalty,
  transactions,
  wrongAnswerPercent,
} from './game-rules';
import { Mission, MissionStep } from './models';

const numeric: MissionStep = {
  id: 'step.kode',
  order: 1,
  kind: 'numericCode',
  title: 'Kode',
  question: 'Kode?',
  length: 3,
  hintIds: [],
  answerRule: {
    kind: 'digitsOnly',
    canonicalAnswer: '592',
    acceptedAnswers: ['592', '5-9-2'],
    nearMissResponses: [{ answer: '529', feedback: 'Rækkefølgen er forkert.' }],
  },
};
const mission = {
  id: 'mission.test',
  locationId: 'loc.test',
  title: 'Test',
  status: 'fieldTestReady',
  difficulty: 2,
  estimatedMinutes: 5,
  basePoints: 100,
  fictionLabel: 'Fiktion',
  cards: [],
  steps: [numeric],
  hints: [{ id: 'hint.1', order: 1, penaltyPercent: 3, text: 'Se op.' }],
} as Mission;

describe('svarregler', () => {
  it('normaliserer danske tekstsvar og talkoder', () => {
    expect(normalizeAnswer('  MÓD   NORD! ')).toBe('mod nord');
    expect(normalizeAnswer('5-9-2', 'digitsOnly')).toBe('592');
  });
  it('skelner korrekt, kendt fejlsvar og ufærdig kode', () => {
    expect(evaluateAnswer('5 9 2', numeric).kind).toBe('correct');
    expect(evaluateAnswer('529', numeric)).toMatchObject({
      kind: 'nearMiss',
      feedback: 'Rækkefølgen er forkert.',
    });
    expect(evaluateAnswer('59', numeric).kind).toBe('malformed');
  });
});

describe('point', () => {
  it('afrunder som kontrakten og prissætter forkerte koder til to procent', () => {
    expect(penalty(50, 5)).toBe(3);
    expect(wrongAnswerPercent(numeric)).toBe(2);
  });
  it('tæller samme hint og fejlsvar højst én gang', () => {
    const ledger = transactions(mission, {
      completionEventId: 'done',
      hints: [
        { id: 'hint.1', order: 1, percent: 3, eventId: 'h1' },
        { id: 'hint.1', order: 1, percent: 3, eventId: 'h2' },
      ],
      wrongAnswers: [
        { stepId: 'step.kode', answer: '111', percent: 2, eventId: 'w1' },
        { stepId: 'step.kode', answer: '111', percent: 2, eventId: 'w2' },
      ],
    });
    expect(ledger.map((item) => item.points)).toEqual([100, -3, -2]);
  });
});
