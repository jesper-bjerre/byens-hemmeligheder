import { ContentPack, LocationRecord, MergeResult, Mission, MissionStep } from './models';

export const standardFictionLabel = 'Opgavens historie er opdigtet.';

const standardSafetyNotes =
  'Bliv på offentligt tilgængelige arealer, og gå ikke ind på privat grund. ' +
  'Hold øje med trafik og cyklister, og stil jer et sted, hvor I ikke er i vejen. ' +
  'Kig op fra telefonen, når I flytter jer. Stedet er ikke særskilt sikkerhedsvurderet.';

export function clone<T>(value: T): T {
  return structuredClone(value);
}

export function equal(left: unknown, right: unknown): boolean {
  if (Object.is(left, right)) return true;
  if (typeof left !== typeof right || left === null || right === null) return false;
  if (Array.isArray(left) && Array.isArray(right)) {
    return left.length === right.length && left.every((item, index) => equal(item, right[index]));
  }
  if (isObject(left) && isObject(right)) {
    const leftKeys = Object.keys(left).sort();
    const rightKeys = Object.keys(right).sort();
    return equal(leftKeys, rightKeys) && leftKeys.every((key) => equal(left[key], right[key]));
  }
  return false;
}

export function packSlug(value: string): string {
  const slug = value
    .toLocaleLowerCase('da-DK')
    .replaceAll('æ', 'ae')
    .replaceAll('ø', 'oe')
    .replaceAll('å', 'aa')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return slug || 'uden-navn';
}

export function createMission(pack: ContentPack): Mission {
  const base = uniqueSlug(pack, 'ny-opgave');
  const locationId = `loc.${base}`;
  const postalCode = pack.locations.at(-1)?.postalCode ?? '';

  const location: LocationRecord = {
    id: locationId,
    postalCode,
    name: 'Nyt sted',
    address: postalCode ? 'Danmark' : 'Danmark',
    latitude: null,
    longitude: null,
    activationRadiusMetres: 45,
    maxAcceptableAccuracyMetres: 40,
    dwellSeconds: 20,
    accuracyProfile: 'standard',
    publicAccess: true,
    safety: { flags: [], notes: standardSafetyNotes },
    accessibility: {
      surface: 'Ikke opmålt',
      incline: 'Ikke opmålt',
      steps: false,
      wheelchair: 'unknown',
      stroller: 'unknown',
      distanceFromAccessMetres: null,
      notes: 'Tilgængeligheden skal registreres ved feltbesøget.',
    },
    fieldVerified: false,
    lastPhysicallyVerified: null,
  };

  const hints = [1, 2, 3].map((order) => ({
    id: `hint.${base}.${order}`,
    order,
    penaltyPercent: order + 2,
    title: hintTitle(order),
    text: 'Hintet mangler.',
  }));

  const mission: Mission = {
    id: `mission.${base}`,
    slug: base,
    locationId,
    title: '',
    shortTitle: '',
    description: 'Beskrivelsen mangler.',
    status: 'draft',
    difficulty: 3,
    estimatedMinutes: 15,
    basePoints: 100,
    tags: [],
    fictionLabel: standardFictionLabel,
    heroMediaId: null,
    thumbnailMediaId: null,
    placeMediaId: null,
    moodMediaId: null,
    narrationMediaId: null,
    sourceIds: [],
    steps: [newStep(base)],
    hints,
    completion: {
      headline: 'Gåden er løst',
      subheadline: 'Du fandt svaret dér, hvor det står',
      messageLabel: 'Det, du fandt',
      message:
        'Svaret lå på stedet hele tiden — i en form, et tal eller en retning, der har været der længe før jer, og som bliver stående, når I går videre.',
      historyFact:
        'Hvert sted i byen bærer spor af dem, der byggede det. Kig op næste gang I går forbi.',
    },
    cards: [],
    storyId: null,
    chapterId: null,
    nextChapterId: null,
  };

  pack.locations.push(location);
  pack.missions.push(mission);
  return mission;
}

export function deleteMission(pack: ContentPack, missionId: string): void {
  const index = pack.missions.findIndex((mission) => mission.id === missionId);
  if (index < 0) return;
  const locationId = pack.missions[index].locationId;
  pack.missions.splice(index, 1);
  if (!pack.missions.some((mission) => mission.locationId === locationId)) {
    const locationIndex = pack.locations.findIndex((location) => location.id === locationId);
    if (locationIndex >= 0) pack.locations.splice(locationIndex, 1);
  }
}

export function normaliseBeforeSave(pack: ContentPack, base: ContentPack): void {
  finaliseNewMissionIds(pack, base);
  for (const mission of pack.missions) {
    mission.shortTitle = mission.shortTitle || mission.title;
    const firstCardMedia = [...mission.cards]
      .sort((a, b) => a.order - b.order)
      .find((card) => card.mediaId)?.mediaId;
    if (!mission.thumbnailMediaId && firstCardMedia) mission.thumbnailMediaId = firstCardMedia;

    mission.steps.forEach((step) => normaliseStep(step, mission.title));
    mission.hints.forEach((hint) => {
      hint.title ||= hintTitle(hint.order);
      if (!hint.text.trim()) hint.text = 'Hintet er ikke skrevet endnu.';
    });
  }
  pack.media.forEach((media) => {
    if (!media.altText.trim()) media.altText = 'Beskrivelsen er ikke skrevet endnu.';
  });
}

function normaliseStep(step: MissionStep, missionTitle: string): void {
  step.title ||= missionTitle;
  if (step.question !== undefined && !step.question.trim()) {
    step.question = 'Spørgsmålet er ikke skrevet endnu.';
  }
  step.answerRule.acceptedAnswers = step.answerRule.acceptedAnswers
    .map((answer) => answer.trim())
    .filter(Boolean);
  const first = step.answerRule.acceptedAnswers[0];
  if (first) step.answerRule.canonicalAnswer = first;
  step.answerRule.kind = step.kind === 'numericCode' ? 'digitsOnly' : 'exact';
  if (step.kind === 'numericCode' && first) {
    const digits = [...first].filter((character) => /\p{Number}/u.test(character)).length;
    if (digits > 0) step.length = digits;
  }
}

function finaliseNewMissionIds(pack: ContentPack, base: ContentPack): void {
  const saved = new Set(base.missions.map((mission) => mission.id));
  for (const mission of [...pack.missions].reverse()) {
    if (
      saved.has(mission.id) ||
      !mission.id.startsWith('mission.ny-opgave') ||
      !mission.title.trim()
    ) {
      continue;
    }
    const slug = uniqueSlug(pack, packSlug(mission.title), mission.id);
    const oldLocationId = mission.locationId;
    const locationId = `loc.${slug}`;
    const location = pack.locations.find((item) => item.id === oldLocationId);
    if (location) {
      location.id = locationId;
      if (location.name === 'Nyt sted') location.name = mission.title.trim();
    }
    mission.id = `mission.${slug}`;
    mission.slug = slug;
    mission.locationId = locationId;
    mission.hints.forEach((hint, index) => (hint.id = `hint.${slug}.${hint.order || index + 1}`));
    const hintIds = mission.hints.map((hint) => hint.id);
    mission.steps.forEach((step) => {
      step.id = `step.${slug}.opgaven`;
      step.hintIds = hintIds;
    });
    mission.cards.forEach((card, index) => (card.id = `card.${slug}.${card.order || index + 1}`));
  }
}

function newStep(slug: string): MissionStep {
  return {
    id: `step.${slug}.opgaven`,
    order: 1,
    kind: 'freeText',
    title: 'Opgaven',
    question: 'Hvad skal spilleren finde?',
    placeholder: 'Skriv svaret',
    answerRule: {
      kind: 'exact',
      canonicalAnswer: 'facit',
      acceptedAnswers: ['facit'],
      nearMissResponses: [],
    },
    hintIds: [1, 2, 3].map((order) => `hint.${slug}.${order}`),
  };
}

export function hintTitle(order: number): string {
  return order === 1 ? 'Hvor' : order === 2 ? 'Hvordan' : 'Næsten løsningen';
}

function uniqueSlug(pack: ContentPack, base: string, excludingId?: string): string {
  const taken = new Set(pack.missions.filter((m) => m.id !== excludingId).map((m) => m.id));
  let candidate = base;
  let counter = 2;
  while (taken.has(`mission.${candidate}`)) candidate = `${base}-${counter++}`;
  return candidate;
}

export function mergePacks(base: ContentPack, ours: ContentPack, theirs: ContentPack): MergeResult {
  const conflicts: string[] = [];
  const root = mergeValue(base, ours, theirs, '', conflicts) as ContentPack;
  return { root, conflicts };
}

function mergeValue(
  base: unknown,
  ours: unknown,
  theirs: unknown,
  path: string,
  conflicts: string[],
): unknown {
  if (equal(ours, theirs)) return clone(ours);
  if (equal(ours, base)) return clone(theirs);
  if (equal(theirs, base)) return clone(ours);

  if (isObject(base) && isObject(ours) && isObject(theirs)) {
    const result: Record<string, unknown> = {};
    const keys = new Set([...Object.keys(base), ...Object.keys(ours), ...Object.keys(theirs)]);
    for (const key of [...keys].sort()) {
      const childPath = path ? `${path}.${key}` : key;
      if (!(key in ours) && equal(theirs[key], base[key])) continue;
      if (!(key in theirs) && equal(ours[key], base[key])) continue;
      const value = mergeValue(base[key], ours[key], theirs[key], childPath, conflicts);
      if (value !== undefined) result[key] = value;
    }
    return result;
  }

  if (
    Array.isArray(base) &&
    Array.isArray(ours) &&
    Array.isArray(theirs) &&
    isIdentified(base, ours)
  ) {
    return mergeIdentifiedArrays(base, ours, theirs, path, conflicts);
  }

  conflicts.push(path || 'pakken');
  return clone(ours);
}

function mergeIdentifiedArrays(
  base: unknown[],
  ours: unknown[],
  theirs: unknown[],
  path: string,
  conflicts: string[],
): unknown[] {
  const baseById = byId(base);
  const oursById = byId(ours);
  const merged: unknown[] = [];
  const taken = new Set<string>();

  for (const element of theirs) {
    const id = identifier(element);
    if (!id) continue;
    taken.add(id);
    const inBase = baseById.get(id);
    const inOurs = oursById.get(id);
    if (inOurs === undefined && inBase !== undefined && equal(element, inBase)) continue;
    merged.push(mergeValue(inBase, inOurs ?? element, element, `${path}[${id}]`, conflicts));
  }

  for (const element of ours) {
    const id = identifier(element);
    if (!id || taken.has(id)) continue;
    const inBase = baseById.get(id);
    if (inBase !== undefined) {
      if (equal(element, inBase)) continue;
      conflicts.push(`${path}[${id}] — slettet af en anden, men rettet af dig`);
    }
    merged.push(clone(element));
  }
  return merged;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function identifier(value: unknown): string | undefined {
  return isObject(value) && typeof value['id'] === 'string' ? value['id'] : undefined;
}

function isIdentified(...arrays: unknown[][]): boolean {
  return arrays.some((array) => array.length > 0 && array.every((value) => identifier(value)));
}

function byId(values: unknown[]): Map<string, unknown> {
  return new Map(
    values.flatMap((value) => (identifier(value) ? [[identifier(value)!, value]] : [])),
  );
}
