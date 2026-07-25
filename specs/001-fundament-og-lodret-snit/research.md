# Phase 0 — Research: Fundament og lodret snit

**Feature**: 001-fundament-og-lodret-snit
**Dato**: 2026-07-25
**Kilder**: `spec.md`, `.specify/memory/constitution.md`, `docs/plans/fase-1-arkitektur.md`,
`docs/design af opgaver/`, `docs/foranalyse/Byens_Hemmeligheder_Projektgrundlag.md`

Dette dokument fastlægger de tekniske valg, feature 001 hviler på, og registrerer
de antagelser, der stadig skal verificeres empirisk.

---

## R-001 — Deployment target: iOS 18.0

**Beslutning**: iOS 18.0 som minimum, bygget mod nyeste SDK.

**Begrundelse**: Målgruppen er 10–15-årige, som overvejende bærer nedarvede
telefoner. iOS 18 understøtter A12 (iPhone XS/XR); iOS 26 kræver A13. At skære
XS/XR væk for at spare QA er den forkerte byttehandel for en gratis app til
almenvellet. iOS 18 leverer alt det nødvendige: `@Observable`, SwiftUI `Map`,
`PhaseAnimator`, `.sensoryFeedback`, `TextRenderer`,
`AccessibilityNotification.Announcement`.

**Alternativer**: iOS 26 (nyeste API'er, men udelukker en del af målgruppens
enheder). iOS 17 (større rækkevidde, men mister `TextRenderer` og
`@Observable`-modenhed uden reel gevinst i enhedsdækning).

**Verificér**: Den præcise enhedsgrænse for iOS 26 bekræftes, før den bruges som
argument udadtil.

---

## R-002 — Modulstruktur: én lokal SPM-pakke med målrettede targets

**Beslutning**: `iOS/Packages/BHKit` som én lokal Swift Package med separate
targets frem for ét app-target eller seks separate pakker.

| Target | Må importere | Ansvar i feature 001 |
|---|---|---|
| `BHContracts` | Foundation | Wire-typerne. Ingen CoreLocation, ingen SwiftUI |
| `BHGameCore` | BHContracts | `AnswerEvaluator`, `PresenceGate`, `ScoreLedger`, `DanishTextNormalizer`, `GeoMath`. Nul Apple-frameworks |
| `BHContentKit` | BHContracts | `ContentPackSource`-protokol, bundlet kilde, `ContentRepository` |
| `BHPersistence` | BHContracts, BHGameCore | `EventStore`, snapshot-cache |
| `BHLocationKit` | CoreLocation, BHContracts, BHGameCore | Eneste modul der importerer CoreLocation |
| `BHDesignSystem` | SwiftUI | Minimal i 001: farver, typografi, knapstile. Udbygges i increment 005 |

**Begrundelse**: To grunde, begge praktiske. (1) At tilføje en Swift-fil til et
SPM-target rører ikke `project.pbxproj` — den klassiske kilde til flettekonflikter
i branch-per-feature-arbejde, og Spec Kit giver netop én branch pr. feature.
(2) `BHGameCore` uden Apple-frameworks er præcis det, der gør svarmotoren og
tilstedeværelseslogikken testbar uden GPS, uden simulator og fra Windows via CI.

**Alternativer**: Alt i app-targetet (utestbart uden simulator). Seks separate
pakker (ceremoni uden gevinst i denne størrelse).

---

## R-003 — Kontraktlaget: Swift-typerne *er* API-DTO'erne

**Beslutning**: Ingen separat domænemodel. `BHContracts`-typerne er immutable
`Codable` structs, der samtidig er læsemodellen. Adfærd bor i
`BHGameCore`-funktioner.

Kildeabstraktionen findes fra dag 1, selvom der ikke er nogen server:

```swift
public protocol ContentPackSource: Sendable {
    func fetchPack(locale: String, ifNoneMatch etag: String?) async throws -> ContentPackResponse
}
public struct BundledContentPackSource: ContentPackSource { }   // fase 1
```

`ifNoneMatch`/`.notModified`-formen findes allerede, selvom den bundlede kilde
altid returnerer `.pack`. Så kræver ETag-caching senere ingen signaturændring.

**Wire-format-valg, der er dyre at ændre bagefter**:

| Valg | Beslutning | Hvorfor |
|---|---|---|
| Casing | camelCase, ingen key-conversion | ASP.NET Cores default er camelCase. Uden konvertering er Swift-navne == wire-navne, så golden-testen faktisk vagter kontrakten |
| ID'er | Opake strings, læsbare slugs (`loc.vejle-havn.boelgen`) | Nødvendigt for håndskrevet JSON og læsbare diffs; serveren kan senere have Guid PK og eksponere hvad som helst |
| Datoer | ISO 8601 med offset via én delt decoder | ASP.NET Core udsender fraktionelle sekunder, som Foundations `.iso8601`-strategi fejler på. Ét sted, én test |
| Enums | Aldrig bar `String`-raw enum. Ukendt → `.unknown(String)` | Når API'et senere tilføjer `challengeKind: "compass"`, skal en shippet app degradere pænt frem for at mure indholdspakken (FR-003) |
| Optionalitet | Kun additive ændringer; nye felter altid optional | Skrives som ADR. Golden-testen gør brud højlydte |

**Alternativer**: DTO → domæne → viewmodel-mapping. Afvist: tredobbelt
repræsentation i denne størrelse er ren omkostning og ville ødelægge egenskaben
om, at Swift-typerne er kontrakten.

---

## R-004 — Indholdspakken: én fil, ikke én fil pr. opgave

**Beslutning**: Feature 001 shipper **én** `content-pack.json` med begge opgaver,
håndskrevet ud fra opgavedokumenterne i `docs/design af opgaver/opgaver/`.

**Begrundelse**: Pakken skal være byte-identisk med et fremtidigt API-svar — det
er hele pointen med R-003. En samlet fil bevarer den egenskab uden et byggetrin.
To opgaver retfærdiggør ikke en assembler.

**Trigger for at dele op**: Når antallet af opgaver overstiger ca. seks, eller når
en ikke-udvikler skal redigere indhold via pull request, deles pakken i
`opgaver/<postnr>/<slug>.json` med et samlingstrin. Det er increment 008's
problem, ikke 001's.

**Sporbarhed**: Opgavedokumenterne er kilden til sandhed (spec.md, Assumptions).
Pakken er et afledt artefakt. Uoverensstemmelse er en fejl i pakken.

**Alternativer**: Én fil pr. opgave med byggetrin (bedre diffs, men kræver et
værktøj på både Windows og macOS og bryder byte-identiteten uden ekstra arbejde).

---

## R-005 — Persistens: append-only hændelseslog, ikke SwiftData

**Beslutning**: `EventStore`-actor der skriver JSON Lines til
`Application Support/BH/events-v1.jsonl` plus et genopbygbart `snapshot.json`.
Skrives atomisk. `@AppStorage` bruges udelukkende til præferencer, aldrig til
progression.

**Begrundelse**: Domænet *er* en ledger. Projektgrundlaget navngiver allerede
`Attempt`, `Completion` og `ScoreTransaction`, og forfatningens princip V kræver
idempotent synkronisering. En append-only log med klientgenererede UUID'er er
lærebogssvaret: sync bliver senere en `POST` af det ubekræftede suffiks, og
serveren deduplikerer på `id`. Princip V's krav om forklarlige pointtransaktioner
bliver gratis — ledgeren *er* forklaringen på belønningsskærmen — og afledt
tilstand er en ren fold over loggen, replayerbar og testbar uden persistens
overhovedet (FR-034).

**Alternativer**: SwiftData. Afvist for 001, fordi det ville tilføje en tredje
repræsentation (DTO ↔ `@Model` ↔ afledt tilstand) stik imod R-003. Ikke en
blindgyde: SwiftData kan senere indføres som en projektion af loggen.

---

## R-006 — Dansk svarnormalisering

**Beslutning**: En eksplicit, unit-testet `DanishTextNormalizer`. Rækkefølge:
NFC → lowercase med `da_DK` → typografiske look-alikes (`’→'`, `–→-`, NBSP,
fuldbredde-cifre) → eksplicit `æ→ae, ø→oe, å→aa` når slået til → fjern ignorerede
tegn → trim.

**Begrundelse**: `folding(options: .diacriticInsensitive)` må **ikke** bruges.
`å` folder til `a`, mens `ø` og `æ` opfører sig inkonsistent på tværs af
ICU-versioner — en fejl der først viser sig på en brugers telefon med en anden
iOS-version end udviklerens.

**Cifferkoder**: sammenlignes som **string, ikke integer**. Foranstillede nuller
er betydende i en kode (spec.md, Edge Cases). Bølgens accepterede former er
`592`, `5 9 2` og `5-9-2` — normalisering fjerner mellemrum og bindestreger.

**Resultattype**: `AnswerEvaluator` returnerer `.correct` / `.nearMiss(id, feedback)`
/ `.incorrect` / `.malformed(reason)`. `.malformed` er UX-kritisk og opfylder
FR-014: "koden er tre cifre" er ikke et forkert svar, det er et ufærdigt, og må
ikke tælle som fejlforsøg.

---

## R-007 — Tilstedeværelse: detektér, stempl, blokér aldrig

**Beslutning**: `PresenceGate` som en ren struct i `BHGameCore`:
`mutating func ingest(_ snapshot: LocationSnapshot) -> PresenceState`. Tid kommer
fra `CLLocation.timestamp`-deltaer og et injiceret `now` — aldrig `Date()`
internt. Det gør den deterministisk i test og undgår `SystemBootTime`-kategorien
i privacy-manifestet.

**Tilstande**: `idle → authorizationNeeded → acquiring → tooFar → approaching →
accuracyInsufficient → dwelling → verified`, plus `softOverrideOffered`.

**Fem mitigeringer mod GPS-drift** (Bølgen og Fjordenhus er begge høje
konstruktioner ved vand — multipath er en reel risiko):

1. **Standpunktet er gate-centrum, ikke bygningen.** 30–80 m fra facaden, hvor
   gåden kan løses og himlen er fri. Dette er værd mere end al filtrering tilsammen.
2. **Usikkerhedsbevidst afstand**: `optimistic = max(0, d − acc)`,
   `pessimistic = d + acc`. Dårlig nøjagtighed giver et bredere accept-vindue
   frem for en afvisning (FR-026). Vis aldrig større præcision end `acc` tillader.
3. **Robust konsensus-centrum**: median over sidste 10 fixes inden for 30 s.
   Multipath-jitter er højfrekvent; en median dræber den.
4. **Dwell som henfaldende kredit-akkumulator, ikke wall-clock-timer.** Hvert
   accepteret fix lægger `min(Δt, 2s)` til; et afvist trækker 1 s fra, gulv ved 0
   — **nulstiller aldrig**. "Næsten verificeret, ét dårligt fix, start forfra" er
   den mest demoraliserende fejltilstand der findes.
5. **`accuracyProfile` pr. lokation** i indhold, felttunet.

**Hygiejne**: forkast fixes med `horizontalAccuracy < 0`, `> 100 m`, eller
`abs(timestamp.timeIntervalSinceNow) > 15 s` — den klassiske
stale-cached-first-fix-bug; CoreLocations første callback er ofte timer gammel.

**Autorisation**: kun `requestWhenInUseAuthorization()`. Intet
`NSLocationAlwaysAndWhenInUse`, intet `UIBackgroundModes: location`. Alle fem
udfald håndteres, inkl. `.restricted` (Skærmtid kan blokere Location Services på
et barns telefon) og `.reducedAccuracy` → `requestTemporaryFullAccuracyAuthorization`,
hvilket kræver `NSLocationTemporaryUsageDescriptionDictionary` i Info.plist —
den oftest glemte nøgle i GPS-gatede apps.

**Aldrig kompas som gate**: `CLHeading` kræver kalibrering og er upålideligt nær
stål og store konstruktioner. Retningspilen bruger `viewingBearingDegrees` fra
indhold som blødt hint.

**Simuleret position**: `isSimulatedBySoftware` fra `CLLocation.sourceInformation`.
Politik: **verifikation lykkes stadig**, `method = .simulated`, flaget registreres
i ledgeren (FR-028), resultatskærmen viser et neutralt badge, point gives. Det
opfylder både "afvis aldrig en ægte spiller" og projektgrundlagets §6.9 om minimal
antisnyd.

**Ærlig begrænsning**: `isSimulatedBySoftware` fanger Xcode/Simulator/GPX og
desktopværktøjer. Den fanger **ikke** jailbreak-tweaks eller RF-spoofere.

**Afgrænsning mod increment 003**: 001 implementerer tilstandsmaskinen, de
venlige beskeder og soft override. Median-konsensus, henfaldende dwell-kredit og
feltmålingsværktøjet hærdes i 003 mod optagne feltspor.

---

## R-008 — Kort: bekvemmelighed, aldrig afhængighed

**Beslutning**: MapKit via SwiftUI `Map`. Kortfliser caches eller persisteres
**ikke**. Missionen skal kunne gennemføres med nul fliser: approach, kapitel,
opgave, hints og belønning fungerer med retningspil, afstand og bundlet
illustration.

**Begrundelse**: Projektgrundlagets §14.6 lover offline kortdata, men Apples
vilkår forbyder at cache Apple Maps-fliser. Konflikten løses ved at gøre kortet
ikke-kritisk frem for at bryde vilkårene. Apple Maps-attribution må ikke dækkes
af bundark eller CTA'er.

**Verificér**: MapKits aktuelle vilkår om flise-caching genlæses før udgivelse.

---

## R-009 — Nul tredjeparts-SDK'er

**Beslutning**: Ingen Firebase, ingen analytics-SDK, ingen crash-SDK, ingen
afhængigheder ud over Apples egne frameworks.

**Begrundelse**: Det holder privacy-manifestet trivielt (`NSPrivacyTracking = false`,
`NSPrivacyCollectedDataTypes = []`), undgår tredjeparts-signaturfejl ved build, og
er den ærlige holdning for en app rettet mod børn. Forfatningens princip VI og
FR-049 gør det til et krav, ikke en præference.

---

## R-010 — Test: Swift Testing og delte testvektorer

**Beslutning**: Swift Testing (`@Test`, `#expect`, parameteriseret `arguments:`)
til al logik. `AnswerEvaluatorTests` og `ScoreLedgerTests` er tabeldrevne fra
JSON-testvektorer i `contracts/spec/`, så **de samme vektorer senere kan køre i
xUnit mod ASP.NET-implementeringen**.

**Tre kontraktvagter**:

1. **Golden-serialiseringstest** — enhver omdøbning fejler CI med "dette er en
   API-ændring".
2. **JSON Schema-validering** af den shippende pakke.
3. **Indholds-selvkonsistenstest** på den rigtige pakke: alle referencer
   resolver, præcis 3 hints med fradrag der summer til 12 %,
   `maxAcceptableAccuracyMetres ≤ activationRadiusMetres`,
   `evaluate(canonicalAnswer) == .correct`, og **hver registreret near-miss
   evaluerer til `.nearMiss`, aldrig `.correct`**. Sidstnævnte fanger den
   klassiske forfatterbug, hvor en distraktor også accepteres (FR-044).

**Afrundingsregel** specificeres eksplicit med testvektorer, fordi klient og
fremtidig server skal være enige til pointet: `round(base × pct / 100)`
half-away-from-zero, hver som sin egen transaktion. Base 100 → −3/−4/−5 → 88.

---

## R-011 — Udvikling fra Windows med Mac som byggemaskine

**Beslutning**: Al Swift-kompilering sker på Mac. Windows bruges til
indholdsforfatning, testvektorer, GPX-forfatning, specs og PR-review.

**Konsekvens for feature 001**: `BHGameCore` og `BHContracts` er bevidst uden
Apple-frameworks, så deres logik kan gennemtænkes og deres testvektorer skrives
uden en Mac. Selve kompileringen kræver Mac.

**Bemærkning**: Spec Kit er initialiseret med `"script": "ps"`, og skill-filerne
kalder `.specify/scripts/powershell/*.ps1` med hardcodede stier. På macOS kræver
det `brew install --cask powershell`. Scriptene er skrevet cross-platform (de
tjekker `$IsWindows`), så de kører under `pwsh` 7.

**Udskudt til increment 002**: self-hosted GitHub Actions-runner på Macen og
fastlane `pilot` til TestFlight fra et git-tag.

---

## Antagelser der skal verificeres empirisk

| # | Antagelse | Påvirker | Hvornår |
|---|---|---|---|
| A-1 | Sætter GPX-simulering i iOS Simulator `isSimulatedBySoftware`? | Om hvert dev-run ser "simuleret" ud | Dag 1, tjekbart på en time |
| A-2 | iOS 26's præcise enhedsgrænse | Argumentet bag R-001 | Før ekstern kommunikation |
| A-3 | MapKit-vilkår om flise-caching | R-008 | Før udgivelse |
| A-4 | Apples aktuelle ordlyd om "collected" i privacy-manifestet | Privacy-manifest og App Privacy-svar | Før første distribution |
| A-5 | Koordinater, aktiveringsradius og standpunkt for begge lokationer | Indholdspakkens geodata | Feltbesøg — gater publicering, ikke feature 001 |

A-5 er allerede registreret i spec.md's Assumptions: feature 001 arbejder med
foreløbige værdier, og indholdet er derfor ikke publiceringsklart.
