export interface ContentPack {
  schemaVersion: string;
  locale: string;
  contentVersion: string;
  locations: LocationRecord[];
  missions: Mission[];
  media: MediaAsset[];
  sources: Source[];
  [key: string]: unknown;
}

export interface LocationRecord {
  id: string;
  name: string;
  address: string;
  postalCode: string;
  latitude: number | null;
  longitude: number | null;
  activationRadiusMetres?: number | null;
  maxAcceptableAccuracyMetres?: number | null;
  dwellSeconds: number;
  accuracyProfile: string;
  publicAccess: boolean;
  safety: { flags: string[]; notes: string };
  accessibility: {
    surface: string;
    incline: string;
    steps: boolean;
    wheelchair: string;
    stroller: string;
    notes: string;
  };
  [key: string]: unknown;
}

export interface Mission {
  id: string;
  slug?: string;
  locationId: string;
  title: string;
  shortTitle?: string;
  description?: string;
  status: string;
  difficulty: number;
  estimatedMinutes: number;
  basePoints: number;
  fictionLabel: string;
  cards: MissionCard[];
  steps: MissionStep[];
  hints: Hint[];
  completion?: Completion;
  thumbnailMediaId?: string | null;
  heroMediaId?: string | null;
  narrationMediaId?: string | null;
  sourceIds?: string[];
  [key: string]: unknown;
}

export interface MissionCard {
  id: string;
  order: number;
  mediaId: string | null;
  text: string;
}
export interface MissionStep {
  id: string;
  order: number;
  kind: string;
  title: string;
  body?: string;
  continueLabel?: string;
  question?: string;
  placeholder?: string;
  length?: number;
  options?: ChoiceOption[];
  answerRule?: AnswerRule;
  hintIds: string[];
  mediaId?: string | null;
}
export interface ChoiceOption {
  id: string;
  label: string;
}
export interface AnswerRule {
  kind: string;
  canonicalAnswer: string;
  acceptedAnswers: string[];
  nearMissResponses: { answer: string; feedback: string }[];
}
export interface Hint {
  id: string;
  order: number;
  penaltyPercent: number;
  title?: string;
  text: string;
}
export interface Completion {
  headline: string;
  subheadline: string;
  messageLabel: string;
  message: string;
  historyFact: string;
}
export interface MediaAsset {
  id: string;
  filename: string;
  altText: string;
  owner: string;
  licence: string;
  credit: string;
  creditLine?: string | null;
  mediaType?: string;
  kind: string;
}
export interface Source {
  id: string;
  title: string;
  publisher: string;
  url: string;
  kind: string;
}

export interface PositionFix {
  latitude: number;
  longitude: number;
  accuracy: number;
  timestamp: number;
  simulated?: boolean;
}

export type EventKind =
  | 'missionOpened'
  | 'presenceVerified'
  | 'stepViewed'
  | 'answerSubmitted'
  | 'hintUsed'
  | 'missionCompleted';
export type AnswerOutcomeKind = 'correct' | 'nearMiss' | 'incorrect' | 'malformed';

export interface GameEvent {
  id: string;
  sequence: number;
  occurredAt: string;
  contentVersion: string;
  kind: EventKind;
  payload: {
    missionId?: string;
    stepId?: string;
    hintId?: string;
    answer?: string;
    outcome?: AnswerOutcomeKind;
    presenceMethod?: string;
  };
}

export interface GameSession {
  missionId: string;
  contentVersion: string;
  startedAt: string;
  currentStepId?: string;
  verified: boolean;
  safetySeen: boolean;
}

export interface AnswerOutcome {
  kind: AnswerOutcomeKind;
  feedback?: string;
  normalized: string;
}
export interface ScoreTransaction {
  id: string;
  missionId: string;
  points: number;
  explanation: string;
  reason: 'missionCompleted' | 'hintUsed' | 'wrongAnswer';
}
