---

description: "Opgaveliste for feature 001 — Fundament og lodret snit"
---

# Tasks: Fundament og lodret snit

**Input**: Designdokumenter fra `/specs/001-fundament-og-lodret-snit/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Testopgaver er **inkluderet**. Forfatningens afsnit *Udviklings- og
redaktionelt workflow* kræver automatiserede tests for ny forretningslogik, og
User Story 5 er i sin helhed en testleverance. Tests er derfor ikke valgfri her.

**Organisation**: Opgaver er grupperet efter brugerhistorie, så hver historie kan
implementeres og verificeres selvstændigt.

## Format: `[ID] [P?] [Story] Beskrivelse`

- **[P]**: Kan køre parallelt (andre filer, ingen afhængigheder)
- **[Story]**: Hvilken brugerhistorie opgaven hører til (US1–US5)
- Alle stier er repo-relative

## Stikonventioner

- **iOS-app**: `iOS/App/`
- **Moduler**: `iOS/Packages/BHKit/Sources/<Target>/`
- **Tests**: `iOS/Packages/BHKit/Tests/<Target>Tests/`
- **Kontrakt og indhold**: `contracts/`

---

## Phase 1: Setup

**Formål**: Projektstruktur, der kan bygge og køre en tom app.

- [ ] T001 Opret Xcode-projekt `ByensHemmeligheder` i `iOS/ByensHemmeligheder.xcodeproj` efter Apple-standard: iPhone only, portrait, deployment target iOS 18.0, `TARGETED_DEVICE_FAMILY = 1`, bundle-ID `dk.hyldenbrandt.byenshemmeligheder`
- [ ] T002 Opret lokal Swift Package i `iOS/Packages/BHKit/Package.swift` med targets `BHContracts`, `BHGameCore`, `BHContentKit`, `BHPersistence`, `BHLocationKit`, `BHDesignSystem` og deres afhængigheder jf. plan.md
- [ ] T003 Tilknyt `BHKit` som lokal pakkeafhængighed til app-targetet i `iOS/ByensHemmeligheder.xcodeproj`
- [ ] T004 [P] Opret mappestrukturen `contracts/content/da-DK/media/`, `contracts/golden/` og `contracts/spec/`
- [ ] T005 [P] Tilføj danske purpose strings i `iOS/App/Info.plist`: `NSLocationWhenInUseUsageDescription` og `NSLocationTemporaryUsageDescriptionDictionary`, samt `ITSAppUsesNonExemptEncryption = false` og `CFBundleLocalizations = ["da"]`
- [ ] T006 [P] Opret privacy-manifest `iOS/App/PrivacyInfo.xcprivacy` med `NSPrivacyTracking = false`, tomt `NSPrivacyCollectedDataTypes` og `UserDefaults` med reason `CA92.1`
- [ ] T007 Opret byggekonfigurationer og `BH_DEV_TOOLS`-compile-flag i `iOS/ByensHemmeligheder.xcodeproj`, så flaget kun sættes i Debug

---

## Phase 2: Foundational (blokerende forudsætninger)

**Formål**: Kontraktlaget og de fælles tjenester, alle brugerhistorier hviler på.

**⚠️ Ingen brugerhistorie kan begynde, før denne fase er færdig.**

- [ ] T008 [P] Definér `ContentPack`, `Area`, `Location`, `VantagePoint`, `Safety` og `Accessibility` som immutable `Codable` structs i `iOS/Packages/BHKit/Sources/BHContracts/Content.swift` jf. data-model.md
- [ ] T009 [P] Definér `Mission`, `Step`, `AnswerRule`, `NearMissResponse`, `Hint`, `EvidenceCard` og `Completion` i `iOS/Packages/BHKit/Sources/BHContracts/Mission.swift`
- [ ] T010 [P] Definér `MediaAsset` og `Source` i `iOS/Packages/BHKit/Sources/BHContracts/Media.swift`
- [ ] T011 Implementér ukendt-tolerant enum-wrapper i `iOS/Packages/BHKit/Sources/BHContracts/Tolerant.swift`, så en ukendt `Step.kind` afkodes til `.unknown(String)` frem for at kaste (FR-003)
- [ ] T012 Implementér delt `BHJSON`-encoder/decoder i `iOS/Packages/BHKit/Sources/BHContracts/BHJSON.swift` med camelCase uden key-konvertering og ISO 8601-datoer der **også** accepterer fraktionelle sekunder
- [ ] T013 Skriv golden-serialiseringstest i `iOS/Packages/BHKit/Tests/BHContractsTests/GoldenTests.swift` mod fixtures i `contracts/golden/`, så enhver feltomdøbning fejler med "dette er en API-ændring"
- [ ] T014 Kopiér skemaet fra `specs/001-fundament-og-lodret-snit/contracts/bh-content-v1.schema.json` til `contracts/bh-content-v1.schema.json` som implementeringens kilde
- [ ] T015 Implementér `ContentPackSource`-protokol, `BundledContentPackSource` og `ContentRepository`-actor i `iOS/Packages/BHKit/Sources/BHContentKit/`, inkl. `ifNoneMatch`/`.notModified`-formen selvom den bundlede kilde altid returnerer `.pack` (R-003)
- [ ] T016 Implementér `EventStore`-actor i `iOS/Packages/BHKit/Sources/BHPersistence/EventStore.swift` der skriver JSON Lines atomisk til `Application Support/BH/events-v1.jsonl`
- [ ] T017 Opret minimal `BHDesignSystem` i `iOS/Packages/BHKit/Sources/BHDesignSystem/` med semantiske farver (Any/Dark/High Contrast), typografi og primær knapstil på ≥56 pt
- [ ] T018 Implementér `@Observable Router` med typesikker route-enum i `iOS/App/Navigation/Router.swift` drevet af `NavigationStack(path:)`

**Checkpoint**: Pakken kan indlæses og afkodes; app'en kan navigere. Brugerhistorierne kan begynde.

---

## Phase 3: User Story 1 — Løs en opgave på stedet (Priority: P1) 🎯 MVP

**Mål**: En familie ved Bølgen kan gennemføre hele rejsen fra kort til belønningsskærm.

**Independent Test**: Stil en person ved Bølgen uden forklaring. Personen skal
kunne gennemføre fra kort til belønning. Med simuleret position kan hele
gennemløbet verificeres indendørs (quickstart.md, lag 2).

### Indhold

- [ ] T019 [US1] Forfat Bølgen-missionen i `contracts/content/da-DK/content-pack.json` ud fra `docs/design af opgaver/opgaver/7100/Boelgen_Opgave.md`: facit `592`, accepterede former `592`/`5 9 2`/`5-9-2`, fem near-miss-svar, tre hints med 3/4/5 %, status `fieldTestReady`, koordinater `null`
- [ ] T020 [P] [US1] Tilføj hero-medie til `contracts/content/da-DK/media/` med udfyldt `altText`, `owner`, `licence`, `credit` og `kind`

### Svarmotor

- [ ] T021 [P] [US1] Implementér `DanishTextNormalizer` i `iOS/Packages/BHKit/Sources/BHGameCore/DanishTextNormalizer.swift` — NFC → lowercase `da_DK` → typografiske look-alikes → eksplicit `æ→ae, ø→oe, å→aa` → trim. Brug **ikke** `folding(options: .diacriticInsensitive)` (R-006)
- [ ] T022 [P] [US1] Skriv `contracts/spec/answer-normalization.md` og `contracts/spec/answer-testvectors.json` med vektorer for mellemrum, bindestreger, foranstillede nuller og danske tegn
- [ ] T023 [US1] Skriv tabeldrevet test i `iOS/Packages/BHKit/Tests/BHGameCoreTests/DanishTextNormalizerTests.swift` med `arguments:` fra `contracts/spec/answer-testvectors.json`
- [ ] T024 [US1] Implementér `AnswerEvaluator` i `iOS/Packages/BHKit/Sources/BHGameCore/AnswerEvaluator.swift` med udfaldene `.correct` / `.nearMiss(id, feedback)` / `.incorrect` / `.malformed(reason)`. Cifferkoder sammenlignes som string, aldrig som integer
- [ ] T025 [US1] Skriv `iOS/Packages/BHKit/Tests/BHGameCoreTests/AnswerEvaluatorTests.swift` der dækker `592`, `5 9 2`, `529` som near-miss og `59` som `.malformed` — sidstnævnte må ikke tælle som fejlforsøg (FR-014)

### Point

- [ ] T026 [P] [US1] Skriv `contracts/spec/scoring.md` og `contracts/spec/scoring-testvectors.json` med afrundingsreglen `round(base × pct / 100)` half-away-from-zero
- [ ] T027 [US1] Implementér `ScoreLedger` i `iOS/Packages/BHKit/Sources/BHGameCore/ScoreLedger.swift` der producerer én transaktion pr. hændelse med begrundelse
- [ ] T028 [US1] Skriv `iOS/Packages/BHKit/Tests/BHGameCoreTests/ScoreLedgerTests.swift`: 0/1/2/3 hints giver 100/97/93/88 point, og tid påvirker intet (SC-005)

### Position

- [ ] T029 [P] [US1] Implementér `GeoMath` i `iOS/Packages/BHKit/Sources/BHGameCore/GeoMath.swift` med afstand og pejling
- [ ] T030 [US1] Implementér `PresenceGate` som ren struct i `iOS/Packages/BHKit/Sources/BHGameCore/PresenceGate.swift` med `mutating func ingest(_:) -> PresenceState` og injiceret ur — aldrig `Date()` internt (R-007)
- [ ] T031 [US1] Skriv `iOS/Packages/BHKit/Tests/BHGameCoreTests/PresenceGateTests.swift` for grundtilstandene med injiceret ur og nul GPS
- [ ] T032 [US1] Implementér `CoreLocationProvider` i `iOS/Packages/BHKit/Sources/BHLocationKit/CoreLocationProvider.swift` med kun `requestWhenInUseAuthorization()`
- [ ] T033 [US1] Implementér `ScriptedLocationProvider` bag `#if BH_DEV_TOOLS` i `iOS/Packages/BHKit/Sources/BHLocationKit/ScriptedLocationProvider.swift`, styret af launch-argument

### Skærme

- [ ] T034 [P] [US1] Implementér `iOS/App/Screens/ExploreMapView.swift` med MapKit-markører, status uden farveafhængighed og ingen flise-caching (R-008)
- [ ] T035 [P] [US1] Implementér `iOS/App/Screens/MissionSheet.swift` med titel, teaser, sværhedsgrad, varighed, afstand, **sikkerhedsnoter**, tilgængelighedsnoter og fiktionsmarkering (FR-006)
- [ ] T036 [P] [US1] Implementér `iOS/App/Screens/ApproachView.swift` med afstand, retningspil fra `bearingDegrees` og standpunktsinstruktion
- [ ] T037 [P] [US1] Implementér `iOS/App/Screens/NarrativeStepView.swift` med synlig fiktionsmarkering (FR-007)
- [ ] T038 [US1] Implementér `iOS/App/Screens/ChallengeView.swift` der renderer både `singleChoice` og `numericCode` fra indhold — kodefelterne navngives med fortællingens egne ord (FR-011)
- [ ] T039 [US1] Implementér `iOS/App/Screens/HintSheet.swift` med fradraget på knappen, bekræftelsesdialog før åbning og gratis genåbning (FR-018, FR-019)
- [ ] T040 [US1] Implementér `iOS/App/Screens/RewardView.swift` med point, pointopdeling, completion-besked og historisk forklaring — **uden inventory** (FR-020)
- [ ] T041 [P] [US1] Implementér `iOS/App/Screens/SafetyInterstitialView.swift` vist før sessionens første mission (FR-008)
- [ ] T042 [P] [US1] Implementér `iOS/App/Screens/PermissionPrimerView.swift` i spillets stemme, vist umiddelbart før OS-prompten og aldrig ved opstart (FR-030)

### Sammenkobling

- [ ] T043 [US1] Tilføj tilgængelighed i alle skærme under `iOS/App/Screens/`: Dynamic Type uden faste teksthøjder, VoiceOver-labels fra `altText`, container-label på kodefeltet, trykflader ≥44 pt (FR-037 til FR-041)
- [ ] T044 [US1] Kobl flowet sammen i `iOS/App/ByensHemmeligheder App.swift` og skriv XCUITest for det fulde gennemløb i `iOS/ByensHemmeligheder UITests/BoelgenFlowTests.swift`

**Checkpoint**: Bølgen kan gennemføres ende til ende. Feature 001 har MVP-værdi her.

---

## Phase 4: User Story 2 — Anden opgave uden ny kode (Priority: P2)

**Mål**: Fjordenhus tilføjes udelukkende som indhold.

**Independent Test**: Gennemgå ændringssættet. Består det af indholds- og
mediefiler alene, er historien bestået. Fjordenhus skal kunne spilles uden Bølgen.

- [ ] T045 [US2] Forfat Fjordenhus-missionen i `contracts/content/da-DK/content-pack.json` ud fra `docs/design af opgaver/opgaver/7100/Fjordenhus_Opgave.md`: facit `428`, kodefelter `form`/`vand`/`højde`, tre hints, status `fieldTestReady`
- [ ] T046 [P] [US2] Tilføj Fjordenhus hero-medie til `contracts/content/da-DK/media/` med fulde rettighedsfelter
- [ ] T047 [US2] Verificér og dokumentér i `specs/001-fundament-og-lodret-snit/quickstart.md`, at T045–T046 ikke krævede ændringer i `iOS/Packages/BHKit/Sources/` eller `iOS/App/Screens/` (SC-002)
- [ ] T048 [US2] Skriv XCUITest for Fjordenhus-gennemløbet med facit `428` i `iOS/ByensHemmeligheder UITests/FjordenhusFlowTests.swift`

**Checkpoint**: Begge opgaver spilbare, uafhængigt og i vilkårlig rækkefølge.

---

## Phase 5: User Story 3 — GPS-problemer ender aldrig i en blindgyde (Priority: P3)

**Mål**: Hver positionstilstand har en forklaring på almindeligt dansk og mindst én handling.

**Independent Test**: Gennemgå samtlige `PresenceState`-værdier og bekræft nul blindgyder.

- [ ] T049 [US3] Definér afbildningen fra hver `PresenceState` til dansk besked og konkret handling i `iOS/App/Screens/PresenceProblemContent.swift`
- [ ] T050 [US3] Implementér `iOS/App/Screens/PresenceProblemSheet.swift` der dækker `acquiring`, `tooFar`, `approaching`, `accuracyInsufficient`, `dwelling` og `softOverrideOffered`
- [ ] T051 [US3] Håndtér alle fem autorisationsudfald i `iOS/Packages/BHKit/Sources/BHLocationKit/CoreLocationProvider.swift`, inkl. `.restricted` fra Skærmtid (FR-030)
- [ ] T052 [US3] Implementér `.reducedAccuracy` → `requestTemporaryFullAccuracyAuthorization` i `iOS/Packages/BHKit/Sources/BHLocationKit/CoreLocationProvider.swift`
- [ ] T053 [US3] Implementér soft override efter fastsat tidsrum uden bekræftelse i `iOS/Packages/BHKit/Sources/BHGameCore/PresenceGate.swift` (FR-027)
- [ ] T054 [US3] Implementér usikkerhedsbevidst afstand (`optimistic`/`pessimistic`) i `iOS/Packages/BHKit/Sources/BHGameCore/PresenceGate.swift`, så dårlig præcision giver bredere accept-vindue frem for afvisning (FR-026)
- [ ] T055 [US3] Implementér robust konsensus-centrum som komponentvis median over sidste 10 fixes i `iOS/Packages/BHKit/Sources/BHGameCore/PresenceGate.swift`
- [ ] T056 [US3] Implementér dwell som henfaldende kredit-akkumulator i `iOS/Packages/BHKit/Sources/BHGameCore/PresenceGate.swift` — et dårligt fix trækker fra, men **nulstiller aldrig**
- [ ] T057 [US3] Implementér afvisning af stale, upræcise og teleporterende fixes i `iOS/Packages/BHKit/Sources/BHGameCore/PresenceGate.swift` — herunder det timer gamle første callback fra CoreLocation
- [ ] T058 [US3] Implementér simulationsdetektion via `CLLocation.sourceInformation` i `iOS/Packages/BHKit/Sources/BHLocationKit/CoreLocationProvider.swift`; verifikation lykkes stadig, men stemples med `method = .simulated` (FR-028)
- [ ] T059 [P] [US3] Opret GPX-fixtures i `iOS/TestSupport/GPX/`: `boelgen-standpunkt.gpx`, `boelgen-gaa-forbi.gpx`, `boelgen-facade.gpx`
- [ ] T060 [US3] Udvid `iOS/Packages/BHKit/Tests/BHGameCoreTests/PresenceGateTests.swift` med scenarierne: stale first fix afvises, accuracy 60 m ved 10 m giver `dwelling`, ét dårligt fix henfalder men nulstiller ikke, teleport afvises, og **gå-forbi verificerer aldrig** (SC-010)

**Checkpoint**: Ingen tilstand er en blindgyde. En forbipasserende låser ikke op.

---

## Phase 6: User Story 4 — Turen overlever afbrydelse (Priority: P4)

**Mål**: Progression overlever afbrydelse, appgenstart og manglende netværk.

**Independent Test**: Afbryd på hvert trin, genstart, bekræft intakt tilstand. Gennemfør derefter i flytilstand.

- [ ] T061 [US4] Definér `GameEvent`, `GameEventKind` og `GameEventPayload` i `iOS/Packages/BHKit/Sources/BHContracts/Events.swift` med klientgenereret UUID og monotont `sequence`
- [ ] T062 [US4] Implementér append-only skrivning og genindlæsning i `iOS/Packages/BHKit/Sources/BHPersistence/EventStore.swift`
- [ ] T063 [US4] Implementér afledt tilstand som ren fold over loggen i `iOS/Packages/BHKit/Sources/BHPersistence/StateProjection.swift` (FR-034)
- [ ] T064 [US4] Implementér idempotens i `iOS/Packages/BHKit/Sources/BHPersistence/EventStore.swift`, så samme hændelses-id aldrig giver dubletter eller dobbeltpoint (FR-033, FR-023)
- [ ] T065 [US4] Bind `GameSession` til `contentVersion` ved start i `iOS/Packages/BHKit/Sources/BHPersistence/GameSession.swift` (FR-035)
- [ ] T066 [US4] Gør navigationen restorerbar i `iOS/App/Navigation/Router.swift`, så appen genoptager på samme trin efter fuld terminering (FR-036)
- [ ] T067 [US4] Skriv `iOS/Packages/BHKit/Tests/BHPersistenceTests/StateProjectionTests.swift`: folden giver samme tilstand efter genindlæsning, og gentagne hændelser er idempotente
- [ ] T068 [US4] Skriv XCUITest for offline gennemløb og genoptagelse i `iOS/ByensHemmeligheder UITests/ResumeAndOfflineTests.swift` (SC-003, SC-006)

**Checkpoint**: Ingen tur kan gå tabt. Hele missionen kører uden netværk.

---

## Phase 7: User Story 5 — Defekt indhold når aldrig frem (Priority: P5)

**Mål**: Den automatiske validering er publiceringsporten.

**Independent Test**: Indfør hver defekt enkeltvis og bekræft, at hver enkelt afvises.

- [ ] T069 [US5] Implementér JSON Schema-validering af `contracts/content/da-DK/content-pack.json` mod `contracts/bh-content-v1.schema.json` i `iOS/Packages/BHKit/Tests/BHContentKitTests/SchemaValidationTests.swift`
- [ ] T070 [US5] Implementér selvkonsistenstest i `iOS/Packages/BHKit/Tests/BHContentKitTests/ContentConsistencyTests.swift` der håndhæver V-01 til V-10 fra data-model.md — herunder at hvert kanonisk facit bedømmes korrekt af sin egen regel, og at **ingen near-miss evaluerer til `.correct`** (FR-043, FR-044)
- [ ] T071 [US5] Implementér kontrol for forbudte koder i `iOS/Packages/BHKit/Tests/BHContentKitTests/ForbiddenCodeTests.swift`, så `541` ingen steder må forekomme i pakken (FR-047, SC-008)
- [ ] T072 [US5] Opret negative fixtures i `iOS/Packages/BHKit/Tests/BHContentKitTests/Fixtures/` for de syv defekter i quickstart.md lag 1 og bekræft, at hver enkelt afvises med en forståelig fejl (SC-007)

**Checkpoint**: Publiceringsporten bider. En defekt, der slipper igennem, er en fejl i valideringen.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T073 [P] Tilføj `try app.performAccessibilityAudit()` for hver nøgleskærm i `iOS/ByensHemmeligheder UITests/AccessibilityAuditTests.swift`
- [ ] T074 [P] Gennemfør og dokumentér en fuld VoiceOver-gennemgang af én mission i `specs/001-fundament-og-lodret-snit/quickstart.md` (SC-009)
- [ ] T075 Tilføj assertion i `iOS/Packages/BHKit/Tests/BHLocationKitTests/DevToolsTests.swift` om at `ScriptedLocationProvider` ikke er kompileret i Release (FR-051)
- [ ] T076 [P] Skriv `docs/ADR/0001-kontrakter-er-api-dtoer.md` og `docs/ADR/0002-haendelseslog-frem-for-swiftdata.md`
- [ ] T077 Opdatér `specs/001-fundament-og-lodret-snit/quickstart.md` med de faktiske kommandoer og skemanavne fra implementeringen

---

## Dependencies & Execution Order

### Faseafhængigheder

- **Setup (Phase 1)**: Ingen afhængigheder
- **Foundational (Phase 2)**: Kræver Setup. **Blokerer alle brugerhistorier**
- **US1 (Phase 3)**: Kræver Foundational. Ingen afhængighed af andre historier
- **US2 (Phase 4)**: Kræver US1 — den genbruger US1's motor og skærme. Det er netop pointen
- **US3 (Phase 5)**: Kræver US1's `PresenceGate` og `CoreLocationProvider`
- **US4 (Phase 6)**: Kræver US1's flow og Foundational `EventStore`
- **US5 (Phase 7)**: Kræver US1's `AnswerEvaluator` og indhold. Kan køre parallelt med US3 og US4
- **Polish (Phase 8)**: Kræver de historier, der skal poleres

### Inden for hver historie

- Indhold og testvektorer før den logik, der forbruger dem
- Motor før skærme
- Skærme før sammenkobling
- Tests skrives sammen med den logik, de dækker

### Parallelle muligheder

- T004, T005, T006 i Setup
- T008, T009, T010 i Foundational — tre forskellige filer i samme target
- T020, T021, T022, T026, T029 i US1 — indhold, normalisering, vektorer og geometri rører hinanden ikke
- T034, T035, T036, T037 i US1 — fire selvstændige skærme
- T041, T042 i US1
- **US3, US4 og US5 kan køre parallelt**, når US1 står. Kun US2 skal ligge umiddelbart efter US1

### Eksempel: parallel start på US1

```bash
Task: "T021 DanishTextNormalizer i BHGameCore/DanishTextNormalizer.swift"
Task: "T022 answer-testvectors.json i contracts/spec/"
Task: "T026 scoring-testvectors.json i contracts/spec/"
Task: "T029 GeoMath i BHGameCore/GeoMath.swift"
```

---

## Implementation Strategy

### MVP først (kun User Story 1)

1. Phase 1 Setup
2. Phase 2 Foundational
3. Phase 3 User Story 1
4. **STOP og verificér**: gennemfør Bølgen indendørs med simuleret position
5. Dette er det tidligste punkt, hvor featuren har værdi

### Anbefalet rækkefølge derefter

**US2 umiddelbart efter US1** — også selvom den er P2. Den er beviset for, at
motoren er indholdsdrevet, og hvis den viser sig at koste programlogik, skal det
opdages, mens US1's design stadig er friskt. Udskydes den til efter US3 og US4,
er der bygget tre historier oven på en antagelse, der ikke er testet.

Derefter US3, US4 og US5 i vilkårlig rækkefølge — de rører forskellige filer.

### Hvad der gater felttesten

Feltbesøget kræver US1 og US3. US3's venlige tilstande er det, der afgør, om en
familie ved havnen kommer videre, når GPS'en driller — og Bølgen og Fjordenhus er
begge høje konstruktioner ved vand.

---

## Notes

- **Alle koordinater er `null` i denne feature.** Datamodellens V-10 blokerer
  bevidst `publishReady`, indtil felten er besøgt. Det er ikke en mangel, det er
  en gate
- **Ingen inventory nogen steder.** Opgavedokumenternes afsluttende linjer om
  Det femte signal og Fjordseglet omskrives til ren fortælling i T019 og T045
- **Ingen rute og ingen kapitelprogression.** `storyId`, `chapterId` og
  `nextChapterId` skrives som `null` og har ingen adfærd
- Commit efter hver opgave eller logisk gruppe
- Filer tilføjes i SPM-targets frem for i app-targetet, så `project.pbxproj`
  ikke bliver en flettekonflikt-magnet
