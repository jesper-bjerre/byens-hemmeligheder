export const regions = [
  'byenKoebenhavn',
  'koebenhavnsOmegn',
  'nordsjaelland',
  'bornholm',
  'oestsjaelland',
  'vestOgSydsjaelland',
  'fyn',
  'sydjylland',
  'oestjylland',
  'vestjylland',
  'nordjylland',
] as const;

const names: Record<string, string> = {
  draft: 'Kladde',
  researchReady: 'Research på plads',
  fieldTestReady: 'Klar til udgivelse',
  published: 'Frigivet',
  publishReady: 'Frigivet (ældre status)',
  paused: 'På pause',
  byenKoebenhavn: 'Byen København',
  koebenhavnsOmegn: 'Københavns omegn',
  nordsjaelland: 'Nordsjælland',
  bornholm: 'Bornholm',
  oestsjaelland: 'Østsjælland',
  vestOgSydsjaelland: 'Vest- og Sydsjælland',
  fyn: 'Fyn',
  sydjylland: 'Sydjylland',
  oestjylland: 'Østjylland',
  vestjylland: 'Vestjylland',
  nordjylland: 'Nordjylland',
  singleChoice: 'Vælg blandt svar',
  numericCode: 'Talkode',
  freeText: 'Fritekst',
  narrative: 'Fortælling',
  standard: 'Almindeligt',
  urbanCanyon: 'Mellem høje huse',
  yes: 'Ja',
  partial: 'Delvist',
  no: 'Nej',
  unknown: 'Ikke opmålt',
  traffic: 'Trafik',
  water: 'Åbent vand',
  steepSlope: 'Stejl skråning',
  darkness: 'Mørke',
  privateProperty: 'Privat grund',
  cyclePath: 'Cykelsti',
  construction: 'Byggeplads',
  crowding: 'Mange mennesker',
};

export function displayName(value: string): string {
  return names[value] ?? value;
}

export function statusChoices(current: string): string[] {
  const standard = ['draft', 'fieldTestReady', 'published'];
  return standard.includes(current) || !current ? standard : [...standard, current];
}

export function auditChangeName(value: string): string {
  const changes: Record<string, string> = {
    status: 'flyttede status for',
    created: 'oprettede',
    removed: 'fjernede',
    content: 'rettede indhold i',
  };
  return changes[value] ?? value;
}

export const safetyFlags = [
  'traffic',
  'water',
  'steepSlope',
  'darkness',
  'privateProperty',
  'cyclePath',
  'construction',
  'crowding',
];
