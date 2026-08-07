# Phase 1 — Datamodel: Fundament og lodret snit

**Feature**: 001-fundament-og-lodret-snit
**Dato**: 2026-07-25

Modellen falder i to adskilte dele, og adskillelsen er bevidst:

- **Indholdsmodellen** er den udgivne kontrakt. Den er immutable, sprogneutral og
  byte-identisk med et fremtidigt API-svar. Den ejes af `contracts/`.
- **Kørselsmodellen** er spillerens lokale tilstand. Den forlader aldrig enheden i
  feature 001, men er formet, så den kan synkroniseres idempotent senere.

Felter markeret **(fremtid)** findes i skemaet, men har ingen adfærd i 001. De
står der, fordi forfatningens kontraktregel kun tillader additive ændringer —
at tilføje dem senere ville være et brud.

---

## Del 1 — Indholdsmodellen

### ContentPack

Rodobjektet. Én pakke pr. sprog.

| Felt | Type | Krav | Note |
|---|---|---|---|
| `schemaVersion` | string | ✅ | `"1.0"` |
| `contentVersion` | string | ✅ | Fx `"2026-07-25.1"`. En `GameSession` bindes til denne værdi (FR-035) |
| `locale` | string | ✅ | `"da-DK"` |
| `locations` | Location[] | ✅ | Mindst 1 |
| `missions` | Mission[] | ✅ | Mindst 1 |
| `media` | MediaAsset[] | ✅ | Kan være tom |
| `sources` | Source[] | ✅ | Kan være tom, men se FR-042 |

### Area — fjernet i feature 002

Kvartererne var en liste, nogen skulle vedligeholde: id, navn, landsdel og
postnummer. Postnummeret bestemmer alligevel de to sidste, og to kopier af det
samme kan drive fra hinanden. `Location` bærer nu selv `postalCode`, og by og
landsdel slås op i quizmasterappens genererede tabel over Danmarks 1089
postnumre.

### Location

Stedet. Bærer alt, der gør princip I og IV håndhævelige.

| Felt | Type | Krav | Note |
|---|---|---|---|
| `id` | string | ✅ | Fx `loc.vejle-havn.boelgen` |
| `postalCode` | string | ✅ | Fire cifre. By og landsdel slås op i quizmasterappens tabel (002) |
| `name`, `address` | string | ✅ | |
| `latitude`, `longitude` | number \| null | ✅ | **Foreløbige i 001.** `null` er tilladt af skemaet, men blokerer status `published` |
| `activationRadiusMetres` | number \| null | ✅ | Projektgrundlagets interval er 20–60 m |
| `maxAcceptableAccuracyMetres` | number \| null | ✅ | Skal være `≤ activationRadiusMetres` (R-010) |
| `dwellSeconds` | number | ✅ | Hvor længe spilleren skal opholde sig. Forhindrer at en forbipasserende låser op (FR-025, SC-010) |
| `accuracyProfile` | enum | ✅ | `standard` \| `urbanCanyon`. Begge lokationer i 001 er `urbanCanyon` — høje konstruktioner ved vand |
| `publicAccess` | bool | ✅ | |
| `safety` | Safety | ✅ | Obligatorisk (FR-042) |
| `accessibility` | Accessibility | ✅ | Obligatorisk (FR-042) |
| `fieldVerified` | bool | ✅ | `false` i 001 |
| `lastPhysicallyVerified` | date \| null | ✅ | `null` indtil feltbesøg |

**Startstedet** er `latitude`/`longitude` på lokationen selv, og det er
gate-centrum (R-007, mitigering 1).

Der var indtil feature 002 et separat `vantagePoint` med sit eget koordinat, sin
egen kigretning og en ståvejledning. To koordinater for det samme sted kan pege
hver sin vej uden at nogen opdager det, og den faste kigretning kunne stå og pege
forkert, længe efter at koordinatet var rettet. Retningspilen regnes nu ud af
spillerens position og opgavens koordinat.

**Safety**: `flags[]` (enum: `traffic`, `water`, `steepSlope`, `darkness`,
`privateProperty`, `cyclePath`, `construction`, `crowding`) og `notes` (dansk
tekst vist på missionsark og approach-skærm, FR-006).

**Accessibility**: `surface`, `incline`, `steps` (bool), `wheelchair`,
`stroller`, `distanceFromAccessMetres`, `notes`.

### Mission

Den fritstående opgave. Én mission hører til én lokation.

| Felt | Type | Krav | Note |
|---|---|---|---|
| `id`, `slug` | string | ✅ | |
| `locationId` | string | ✅ | Skal resolve (FR-046) |
| `title`, `shortTitle`, `description` | string | ✅ | `description` hed `teaser` indtil feature 002 |
| `status` | enum | ✅ | `draft` \| `researchReady` \| `fieldTestReady` \| `published` \| `paused`, plus den midlertidige legacy-værdi `publishReady`. Begge missioner i 001 er `fieldTestReady` |
| `releasedAt` | ISO 8601 string \| null | valgfri | API-styret tidspunkt for seneste skift fra ikke-frigivet til frigivet; driver "Nye oplevelser" |
| `difficulty` | int 1–5 | ✅ | Mental udfordring. Aldrig fysisk risiko (princip VII) |
| `estimatedMinutes` | int | ✅ | |
| `basePoints` | int | ✅ | 100 for begge |
| `tags` | string[] | ✅ | |
| `fictionLabel` | string | ✅ | Vises på intro og i infovisning (FR-007) |
| `heroMediaId` | string \| null | ✅ | Skal resolve hvis sat |
| `sourceIds` | string[] | ✅ | Må være tom siden 002 — en lille gåde på vejen hviler ikke på en kilde |
| `steps` | Step[] | ✅ | Ordnet, mindst 1 |
| `hints` | Hint[] | ✅ | **Præcis 3** (FR-017) |
| `completion` | Completion | ✅ | |
| `storyId`, `chapterId`, `nextChapterId` | string \| null | **(fremtid)** | Altid `null` i 001. Ingen adfærd — ingen rute, ingen kapitelprogression |

### Step

Ét skridt. Diskrimineret på `kind`, og ukendte værdier skal degradere pænt
(FR-003).

Fælles: `id`, `order`, `kind`.

**`kind: "narrative"`** — `title`, `body`, `continueLabel`.

**`kind: "singleChoice"`** — `eyebrow` (fx `"SPOR 1 AF 3"`), `title`, `question`,
`instruction` (afgrænsningen: hvad skal ignoreres, FR-009), `options[]`
(`{id, label}`), `answerRule`, `correctFeedback`, `hintIds[]`.

**`kind: "numericCode"`** — `eyebrow`, `title`, `instruction`, `length`,
`evidenceCards[]`, `answerRule`, `hintIds[]`.

**EvidenceCard** opfylder FR-010: tidligere fundne deltal vises igen, så spilleren
ikke skal huske dem. Felter: `id`, `symbol`, `label`, `title`, `description`,
`supportingText`, `displayValue`.

> Kodefelterne navngives med fortællingens egne ord — `Øjet`/`Etagerne`/`Pausen`
> for Bølgen, `form`/`vand`/`højde` for Fjordenhus. Formularen underviser dermed
> i reglen, og ingen hjælpetekst er nødvendig (FR-011).

### AnswerRule

| Felt | Type | Krav | Note |
|---|---|---|---|
| `kind` | enum | ✅ | `exact` \| `digitsOnly` |
| `canonicalAnswer` | string | ✅ | **Altid string.** Foranstillede nuller er betydende (R-006). Skrives af det første `acceptedAnswers` og redigeres ikke i quizmasterappen (002) |
| `acceptedAnswers` | string[] | ✅ | Bølgen: `["592", "5 9 2", "5-9-2"]` |
| `nearMissResponses` | NearMiss[] | ✅ | `{answer, feedback}`. Bølgen har fem registrerede |

### Hint

`id`, `order` (1–3), `penaltyPercent`, `title`, `text`.

Fradragene kommer fra indholdet, ikke fra koden (FR-021). Summen skal være
præcis 12 (3 + 4 + 5), håndhævet af selvkonsistenstesten (FR-045).

### Completion

`headline`, `subheadline`, `messageLabel`, `message`, `historyFact`.

> **Ingen `inventoryRewards`.** Inventory er ude af fase 1. Opgavedokumenternes
> afsluttende linjer om Det femte signal og Fjordseglet omskrives til ren
> fortælling (spec.md, Assumptions). Belønningen er beskeden, pointene og den
> historiske forklaring.

### MediaAsset

Alle felter obligatoriske — det er sådan princip IV bliver umulig at glemme
(FR-042, FR-048, FR-038).

`id`, `filename`, `altText` (forfattet, ikke opdigtet), `owner`, `licence`,
`credit`, `kind` (`historical` \| `contemporary` \| `aiGenerated`),
`restrictions`, `expiresAt`.

### Source

`id`, `title`, `publisher`, `url`, `kind` (`officialTourism` \|
`architectPrimary` \| `archive` \| `press` \| `municipal` \| `other`).

---

## Del 2 — Kørselsmodellen

Lever i `BHPersistence`. Forlader aldrig enheden i feature 001.

### GameEvent

Den eneste skrivbare tilstand. Append-only, én JSON pr. linje.

| Felt | Type | Note |
|---|---|---|
| `id` | UUID | Klientgenereret idempotensnøgle. En server kan senere deduplikere på den (FR-033) |
| `sequence` | int | Monotont pr. enhed |
| `occurredAt` | date | |
| `contentVersion` | string | Hvilken pakkeversion hændelsen skete under |
| `kind` | enum | `missionOpened`, `presenceVerified`, `stepViewed`, `answerSubmitted`, `hintUsed`, `missionCompleted`. Ukendt-tolerant |
| `payload` | objekt | Kind-specifikt |

### Afledt tilstand

Score, gennemførte missioner og brugte hints er en **ren fold over loggen** —
ingen selvstændig sandhed, ingen skrivbar kopi (FR-034). `snapshot.json` er en
cache, der altid kan kasseres og genopbygges.

Det er også forklaringen på belønningsskærmen: pointopdelingen *er* ledgeren
filtreret på missionen (FR-020).

### GameSession

`id`, `missionId`, **`contentVersion`** (bundet ved start, FR-035), `startedAt`,
`currentStepId`, `presenceEvidence`.

### PresenceEvidence

`method` (`gps` \| `gpsLowConfidence` \| `softOverride` \| `demo` \| `simulated`),
`accuracyMetres`, `dwellSeconds`, `verifiedAt`.

Stemples på gennemførelsen (FR-028). Blokerer aldrig — den registrerer kun,
hvordan opgaven blev åbnet, så en fremtidig server kan holde en highscore ærlig
uden nogensinde at have straffet nogen.

### ScoreTransaction

`id`, `missionId`, `reason` (`missionCompleted` \| `hintUsed`), `points`,
`hintId`. Udledt af loggen, aldrig lagret selvstændigt.

Beregning: `round(base × pct / 100)` half-away-from-zero, hver som sin egen
transaktion. `100 → −3 → −4 → −5 → 88` (SC-005).

---

## Valideringsregler

Håndhæves af skema plus selvkonsistenstest. Hver regel svarer til et krav.

| # | Regel | Krav |
|---|---|---|
| V-01 | Obligatoriske felter findes: facit, 3 hints, `safety`, `accessibility`, `sourceIds`, samt `owner`/`licence`/`credit` på hvert medie | FR-042 |
| V-02 | `evaluate(canonicalAnswer) == .correct` for hver svarregel. Svækket for indhold skrevet i quizmasterappen — se `contracts/spec/answer-normalization.md` | FR-043 |
| V-03 | Ingen `nearMissResponses.answer` evaluerer til `.correct` | FR-044 |
| V-04 | Hintfradrag summer til præcis 12 % | FR-045 |
| V-05 | Alle id-referencer resolver: `locationId`, `heroMediaId`, `sourceIds`, `hintIds`, `evidenceCards` | FR-046 |
| V-06 | Ugyldige koder registreret i opgavedokumentet forekommer ingen steder i pakken — for Bølgen `541` | FR-047, SC-008 |
| V-07 | Hvert medie har `kind` sat | FR-048 |
| V-08 | `maxAcceptableAccuracyMetres ≤ activationRadiusMetres` | R-010 |
| V-09 | `hints` har præcis 3 elementer med `order` 1, 2, 3 | FR-017 |
| V-10 | `status: "published"` kræver `fieldVerified == true`, koordinat, radius og `lastPhysicallyVerified`. Samme gate gælder legacy-værdien `publishReady`. **Blokerer begge missioner i 001** — de er `fieldTestReady` | Princip IV |

V-10 er den regel, der gør spec.md's antagelse om foreløbige koordinater til en
maskinel sandhed frem for en note: pakken kan bygges og spilles, men den kan ikke
erklæres publiceringsklar, før felten er besøgt.
