import { ContentPack } from './models';
import { clone, createMission, mergePacks, normaliseBeforeSave, packSlug } from './pack-utils';

describe('pack-utils', () => {
  it('laver kontraktgyldige danske id-stammer', () => {
    expect(packSlug('Bølgen – Æbleøen')).toBe('boelgen-aebleoeen');
  });

  it('opretter en opgave med sted, trin og præcis tre hints', () => {
    const pack = emptyPack();
    const mission = createMission(pack);

    expect(pack.locations).toHaveLength(1);
    expect(pack.missions).toHaveLength(1);
    expect(mission.steps).toHaveLength(1);
    expect(mission.hints.map((hint) => hint.penaltyPercent)).toEqual([3, 4, 5]);
  });

  it('færdiggør foreløbige id-er og facit før gemning', () => {
    const pack = emptyPack();
    const base = clone(pack);
    const mission = createMission(pack);
    mission.title = 'Gåden på Øen';
    mission.steps[0].answerRule.acceptedAnswers = [' 42 ', '4 2'];

    normaliseBeforeSave(pack, base);

    expect(mission.id).toBe('mission.gaaden-paa-oeen');
    expect(mission.locationId).toBe('loc.gaaden-paa-oeen');
    expect(mission.steps[0].answerRule.canonicalAnswer).toBe('42');
    expect(mission.steps[0].answerRule.acceptedAnswers).toEqual(['42', '4 2']);
  });

  it('bevarer quizmasterens valgte antal cifre for en talkode', () => {
    const pack = emptyPack();
    const base = clone(pack);
    const mission = createMission(pack);
    const step = mission.steps[0];
    step.kind = 'numericCode';
    step.length = 6;
    step.answerRule.acceptedAnswers = ['42'];

    normaliseBeforeSave(pack, base);

    expect(step.length).toBe(6);
    expect(step.answerRule.kind).toBe('digitsOnly');
  });

  it('fletter rettelser i forskellige felter uden konflikt', () => {
    const base = emptyPack();
    const mission = createMission(base);
    mission.title = 'Før';
    const ours = clone(base);
    const theirs = clone(base);
    ours.missions[0].title = 'Vores titel';
    theirs.missions[0].description = 'Deres beskrivelse';

    const result = mergePacks(base, ours, theirs);

    expect(result.root.missions[0].title).toBe('Vores titel');
    expect(result.root.missions[0].description).toBe('Deres beskrivelse');
    expect(result.conflicts).toEqual([]);
  });

  it('beholder vores værdi og viser stien ved en ægte konflikt', () => {
    const base = emptyPack();
    const mission = createMission(base);
    mission.title = 'Før';
    const ours = clone(base);
    const theirs = clone(base);
    ours.missions[0].title = 'Vores';
    theirs.missions[0].title = 'Deres';

    const result = mergePacks(base, ours, theirs);

    expect(result.root.missions[0].title).toBe('Vores');
    expect(result.conflicts).toContain(`missions[${mission.id}].title`);
  });
});

function emptyPack(): ContentPack {
  return {
    schemaVersion: '1.0',
    locale: 'da-DK',
    contentVersion: 'test',
    locations: [],
    missions: [],
    media: [],
    sources: [],
  };
}
