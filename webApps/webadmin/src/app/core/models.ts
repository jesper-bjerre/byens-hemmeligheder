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
  postalCode: string;
  name: string;
  address: string;
  latitude: number | null;
  longitude: number | null;
  activationRadiusMetres: number;
  maxAcceptableAccuracyMetres: number;
  dwellSeconds: number;
  accuracyProfile: string;
  publicAccess: boolean;
  safety: {
    flags: string[];
    notes: string;
    [key: string]: unknown;
  };
  accessibility: {
    surface: string;
    incline: string;
    steps: boolean;
    wheelchair: string;
    stroller: string;
    distanceFromAccessMetres: number | null;
    notes: string;
    [key: string]: unknown;
  };
  fieldVerified: boolean;
  lastPhysicallyVerified: string | null;
  [key: string]: unknown;
}

export interface Mission {
  id: string;
  slug: string;
  locationId: string;
  title: string;
  shortTitle: string;
  description: string;
  status: string;
  difficulty: number;
  estimatedMinutes: number;
  basePoints: number;
  fictionLabel: string;
  cards: MissionCard[];
  steps: MissionStep[];
  hints: Hint[];
  completion: Completion;
  thumbnailMediaId: string | null;
  narrationMediaId: string | null;
  [key: string]: unknown;
}

export interface MissionCard {
  id: string;
  order: number;
  mediaId: string | null;
  text: string;
  [key: string]: unknown;
}

export interface MissionStep {
  id: string;
  order: number;
  kind: string;
  title: string;
  question?: string;
  placeholder?: string;
  length?: number;
  options?: ChoiceOption[];
  answerRule: AnswerRule;
  hintIds: string[];
  [key: string]: unknown;
}

export interface ChoiceOption {
  id: string;
  label: string;
  [key: string]: unknown;
}

export interface AnswerRule {
  kind: string;
  canonicalAnswer: string;
  acceptedAnswers: string[];
  nearMissResponses: NearMiss[];
  [key: string]: unknown;
}

export interface NearMiss {
  answer: string;
  feedback: string;
  [key: string]: unknown;
}

export interface Hint {
  id: string;
  order: number;
  penaltyPercent: number;
  title: string;
  text: string;
  [key: string]: unknown;
}

export interface Completion {
  headline: string;
  subheadline: string;
  messageLabel: string;
  message: string;
  historyFact: string;
  [key: string]: unknown;
}

export interface MediaAsset {
  id: string;
  filename: string;
  altText: string;
  owner: string;
  licence: string;
  credit: string;
  mediaType: string;
  kind: string;
  [key: string]: unknown;
}

export interface Source {
  id: string;
  title: string;
  publisher: string;
  url: string;
  kind: string;
  [key: string]: unknown;
}

export interface AuditEntry {
  at: string;
  by: string;
  change: string;
  missionId?: string;
  from?: string;
  to?: string;
  contentVersion: string;
}

export interface Draft {
  root: ContentPack;
  base: ContentPack;
  etag: string | null;
  backend: BackendKind;
  savedAt: string;
}

export type BackendKind = 'lokal' | 'drift';

export interface MergeResult {
  root: ContentPack;
  conflicts: string[];
}
