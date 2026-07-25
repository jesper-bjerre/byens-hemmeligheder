# Fase 1 — Byens Hemmeligheder: iOS-konceptvalidering med Spec Kit

## Kontekst

`docs/foranalyse/Byens_Hemmeligheder_Projektgrundlag.md` beskriver en fuld platform (iOS + web + ASP.NET Core-backend + quizmasterportal). Projektgrundlaget siger selv (§19): *"Den rigtige første milepæl er ikke en App Store-release. Det er at bevise, at 10–15 stedsspecifikke gåder i Vejle er så gode, at børn og familier aktivt ønsker at spille videre."*

Fase 1 er derfor ikke en nedskaleret MVP — det er et **måleinstrument** for fire spørgsmål:

1. **Er konceptet interessant?** Vil testpersoner spille en mere?
2. **Kan vi teknisk sikre, at spilleren er på stedet** og ikke løser opgaven hjemmefra?
3. **Kan vi skabe den rette stemning?**
4. **Kan alle forstå flowet uden vejledning?**

Alt i planen herunder er valgt, fordi det tjener et af de fire spørgsmål — eller fordi Apple kræver det.

Repoet indeholder i dag kun dokumenter. Der er ingen kode, ingen `.specify/`-scaffolding, ingen `.claude/`-kommandoer.

---

## Scope: hvad er inde, og hvad er ude

**Inde:** iPhone-only native app (Swift/SwiftUI). Indhold hardkodet som bundlet JSON. Lokal progression. GPS-baseret stedsverifikation. TestFlight til 8–12 testere. Bygget til fuld App Store-standard.

**Ude:** Backend, database, web-frontend, quizmasterportal, login/konti, highscore-server, iPad, Android, AR, kamera-/lyd-opgaver, kompasopgaver.

**Indhold — 4 lokationer i 2 områder** (testpersoner kommer fra både Vejle og Bredballe):

| Område | Lokation | Status |
|---|---|---|
| Vejle Havn | Bølgen (facit 592) | Færdigdesignet i `docs/retningslinjer/` — men se C7 |
| Vejle Havn | Fjordenhus (facit 428) | Færdigdesignet — men se C7 |
| Bredballe | 2 nye lokationer | **Kræver fuldt indholdsarbejde + feltbesøg fra nul** |

> **Antagelse der bør bekræftes:** Jeg har læst "2 lokationer er fint" som *2 pr. område* = 4 i alt. Hvis Bredballe-indholdsproduktionen bliver flaskehalsen, er den rene nedskalering 1 lokation i Bredballe (increment 008 bliver mindre) — ikke at droppe området, da testpersonerne bor der.

**Bredballe-indhold er planens længste leadtime — ikke koden.** Det skal startes parallelt med increment 001, ikke når koden er klar.

---

## Konflikter i grundlaget, der skal løses først

Fem er trivielle at løse; **C7 skal rettes før der bygges skærme.**

| # | Konflikt | Løsning |
|---|---|---|
| **C7** | **Indholdsdefekt i begge referenceopgaver.** Bølgen: ciffer 3 ("2 bølger færdige før pausen") kan ikke observeres på stedet. Fjordenhus: ciffer 3 ("sidste ciffer i 28 m højde") kan ikke observeres. Ingen af tallene står i fortællingen. | Begge bryder retningslinjernes egen regel *"hvis facit ikke kan bevises på papir, kan det ikke publiceres"*. **Ret i indhold:** fortællingen skal oplyse fakta ("De to første bølger stod færdige, før byggeriet gik i stå" / "Huset er 28 meter højt"). Så bliver begge til den sanktionerede *Observation + faktatekst*-model. |
| C1 | §14.6 lover offline kortdata, men MapKit-vilkår forbyder at cache Apple Maps-tiles | Kortet er en **bekvemmelighed, aldrig en afhængighed**. Approach, kapitel, opgave, hints og belønning fungerer med nul tiles (retningspil + afstand + bundlet illustration). |
| C2 | Mørk, stemningsfuld æstetik vs. læses udendørs i sollys under bevægelse | Delte flader: *narrative* flader mørke og filmiske; *funktionelle* flader (afstand, opgavetekst, svarfelt, hints) høj kontrast + eksplicit **"Sollys"-toggle**. Afgøres kun ved feltest ved middagstid. |
| C3 | "Sikre at spilleren er på stedet" vs. "aldrig afvise en ægte spiller" vs. §6.9 "ingen antisnyd" | Man kan ikke garantere det. Omformulér til: **producér et troværdigt, forklarligt, stemplet tilstedeværelsessignal med næsten nul falske afvisninger.** Hver gennemførsel bærer `verificationMethod ∈ {gps, gpsLowConfidence, softOverride, demo, simulated}`. Intet blokerer nogensinde; alt registreres. |
| C4 | Fuld guideline-compliance vs. GPS-bypass til indendørs demo | Udvikler-bypass bag **compile-time flag** (findes ikke i App Store-binæren). Derudover en **synlig, ærlig "Demotilstand"** der *shipper* — den er både skole-/SFO-feature, tilgængelighedsfeature og **et review-krav**: en reviewer i Cupertino kan ikke komme til Vejle (Guideline 4.2-risiko). |
| C5 | "Ingen brugerdata forlader enheden" vs. TestFlight | TestFlight sender selv crash-logs og tester-feedback til Apple. Oplys det til testerne på dansk. Formuleringen skal være præcis. |
| C6 | §14.3 "lokal krypteret caching" vs. fase 1 uden hemmeligheder eller persondata | Udskyd app-niveau-kryptering. iOS' egen data protection er nok. Genbesøg når der findes en session-token eller e-mail. |
| C8 | Målgruppe 10–15 år → ofte arvede iPhones | Driver deployment target iOS 18 (ikke 26). Skal også håndtere `.restricted` autorisation — Skærmtid kan blokere Location Services helt på et barns telefon. |

---

## Arkitektur

### Repo- og modulstruktur (følger §14.7)

```
/src
  /SharedContracts                        ← sprogneutral, ER den fremtidige API-kontrakt
    /Content/da-DK/content-pack.json      ← indholdet der shipper, byte-identisk med fremtidigt API-svar
    /Content/da-DK/media/*.jpg
    /Schema/bh-content-v1.schema.json     ← JSON Schema 2020-12
    /Schema/bh-events-v1.schema.json
    /Golden/*.json                        ← golden-serialiseringer af hver kontrakttype
    /Spec/answer-normalization.md + answer-testvectors.json
    /Spec/scoring.md + scoring-testvectors.json
  /iOS
    ByensHemmeligheder.xcodeproj
    /App                                  ← file-system-synchronized folder (ingen pbxproj-redigering)
    /Packages/BHKit/Package.swift         ← ÉN lokal SPM-pakke, seks targets
    /TestSupport/GPX/*.gpx
    /TestSupport/Traces/*.json            ← rigtige optagne feltspor fra Vejle
    /fastlane/
/docs                                     ← findes; tilføj /ADR
/infrastructure/Pipelines                  ← GitHub Actions
```

**Seks targets i `BHKit`** — ikke seks pakker (ceremoni), ikke ét app-target (utestbart):

| Target | Må importere | Formål |
|---|---|---|
| `BHContracts` | Foundation | **Wire-kontrakten.** `Area`, `Location`, `Story`, `Chapter`, `Challenge`, `Hint`, `AnswerRule`, `InventoryItem`, `MediaAsset`, `ContentPack`, `GameEvent`. Ingen CoreLocation, ingen SwiftUI. |
| `BHGameCore` | BHContracts | `AnswerEvaluator`, `PresenceGate`, `ScoreLedger`, `DanishTextNormalizer`, `GeoMath`. **Ren, deterministisk, nul Apple-frameworks.** |
| `BHContentKit` | BHContracts | `ContentPackSource`-protokol + `BundledContentPackSource` + `ContentRepository`. |
| `BHPersistence` | BHContracts, BHGameCore | `EventStore`-actor, snapshot-cache. |
| `BHLocationKit` | CoreLocation, BHContracts, BHGameCore | **Det eneste modul der importerer CoreLocation.** |
| `BHDesignSystem` | SwiftUI, CoreHaptics | Palette, typografi, `SealRevealView`, haptik. |

To grunde: (1) at tilføje en Swift-fil til et SPM-target rører ikke `project.pbxproj` — det er den klassiske dræber for branch-per-feature iOS-arbejde, og Spec Kit giver netop én branch pr. feature. (2) `BHGameCore` uden Apple-frameworks er præcis det, der gør svarmotoren og stedsverifikationen testbar **uden GPS, uden simulator, fra Windows via CI**.

**Deployment target iOS 18.0**, bygget med nyeste SDK. iOS 18 understøtter A12 (iPhone XS/XR); iOS 26 kræver A13. Målgruppen bærer arvede telefoner — at skære XR/XS væk for at spare QA er den forkerte byttehandel for en gratis app til almenvellet. iOS 18 giver alt det nødvendige: SwiftData, `@Observable`, SwiftUI `Map`, `PhaseAnimator`, `.sensoryFeedback`, `TextRenderer`, `AccessibilityNotification.Announcement`.

**Nul tredjeparts-SDK'er.** Ingen Firebase, ingen analytics, ingen crash-SDK. Det holder privacy-manifestet trivielt, undgår tredjeparts-signaturfejl ved build, og er den ærlige holdning for en børnenær app.

### Kontraktlaget — den bærende beslutning

Reglen der gør backend-skiftet til én ny fil:

```swift
public protocol ContentPackSource: Sendable {
    func fetchPack(locale: String, ifNoneMatch etag: String?) async throws -> ContentPackResponse
}
public struct BundledContentPackSource: ContentPackSource { /* fase 1 */ }
public struct HTTPContentPackSource: ContentPackSource { /* fase 2 — DEN nye fil */ }
public struct CompositeContentPackSource: ContentPackSource { /* remote med bundlet seed som fallback */ }

public actor ContentRepository { /* uændret på tværs af faser */ }
```

`ifNoneMatch`/`.notModified`-formen findes **fra dag 1**, selvom den bundlede kilde altid returnerer `.pack`. Så kræver ETag-caching og offline-seed-mønsteret ingen signaturændring senere.

**Byg ikke en separat domænemodel.** `BHContracts`-typerne *er* læsemodellen — immutable `Codable` structs; adfærd bor i `BHGameCore`-funktioner. DTO→domæne→viewmodel-tredobbelt-mapping i denne størrelse er ren omkostning og ville bryde egenskaben "Swift-typerne *er* API-DTO'erne".

Wire-format-valg der er dyre at ændre senere:

| Valg | Beslutning | Hvorfor |
|---|---|---|
| Casing | **camelCase**, ingen key-conversion-strategy | ASP.NET Cores default er camelCase. Uden konvertering er Swift-navne == wire-navne, så golden-file-testen faktisk vagter kontrakten. |
| ID'er | Opake strings, phantom-typede: `ContentID<Story>` | Serveren kan have `Guid` PK *og* slug og eksponere hvad som helst. Fase-1-indhold forfattes som læsbare slugs (`loc.vejle-havn.boelgen`) — nødvendigt for håndskrevet JSON og læsbare diffs. |
| Datoer | ISO 8601 med offset, via én delt `BHJSON.decoder` | **Fælde:** ASP.NET Core udsender fraktionelle sekunder, og Foundations `.iso8601`-strategi *fejler* på dem. Ét sted, én test. |
| Enums | **Aldrig** bar `String`-raw enum. Ukendte værdier → `.unknown(String)` | Vigtigste forward-compat-egenskab: når API'et senere tilføjer `challengeKind: "compass"`, skal den shippede app degradere pænt — ikke kaste og mure indholdspakken. |
| Optionalitet | Kun additive ændringer; nye felter altid optional | Skrives som ADR. Golden-testen gør brud højlydte. |

`presence`-tolerancer (radius, accuracy-loft, dwell-tid) er **indhold, ikke kode** — så felttuning ved Bølgen er en JSON-redigering, og senere en serverredigering uden app-release. Samme for `altText`, `credit`, `aiGenerated` (§15.7-compliance bliver umulig at glemme, fordi pakken ikke validerer uden dem) og `safety.flags`.

**Dansk normalisering — fælden.** Brug **ikke** `folding(options: .diacriticInsensitive)`: `å` folder til `a`, men `ø` og `æ` opfører sig inkonsistent på tværs af ICU-versioner. Implementér en eksplicit, unit-testet `DanishTextNormalizer`: NFC → lowercase med `da_DK` → map typografiske look-alikes (`’→'`, `–→-`, NBSP, fuldbredde-cifre) → eksplicit `æ→ae, ø→oe, å→aa` når slået til → fjern ignorerede tegn → trim. Ved `digitsOnly`: **sammenlign som string, ikke integer** — foranstillede nuller er betydende i en kode.

`AnswerEvaluator` returnerer `.correct` / `.nearMiss(id, feedback)` / `.incorrect` / `.malformed(reason)`. `.malformed` er UX-kritisk: "Koden er tre cifre" er ikke et forkert svar, det er et ufærdigt — det må ikke tælle som fejlforsøg.

### Stedsverifikation — detektér, stempl, blokér aldrig

`PresenceGate` er en **ren struct i `BHGameCore`**: `mutating func ingest(_ snapshot: LocationSnapshot) -> PresenceState`. Tid kommer fra `CLLocation.timestamp`-deltaer og en injiceret `now` — aldrig `Date()` internt. Det gør den deterministisk i test *og* undgår `SystemBootTime`-kategorien i privacy-manifestet.

Tilstande: `idle → authorizationNeeded → acquiring → tooFar → approaching → accuracyInsufficient → dwelling → verified` + `softOverrideOffered`.

Kun **`requestWhenInUseAuthorization()`**. Intet `NSLocationAlwaysAndWhenInUse`, intet `UIBackgroundModes: location`. Alle fem autorisationsudfald håndteres, inkl. `.restricted` (Skærmtid) og `.reducedAccuracy` → `requestTemporaryFullAccuracyAuthorization`, hvilket kræver `NSLocationTemporaryUsageDescriptionDictionary` i Info.plist — **den oftest glemte nøgle i GPS-gatede apps.**

Fem konkrete mitigeringer mod GPS-drift (Bølgen og Fjordenhus er begge høje bygninger ved vandet — multipath er en reel risiko):

1. **Standpunktet er gate-centrum, ikke bygningen.** Retningslinjerne giver allerede referencepunkter: Bølgen `55.710400, 9.560430`, Fjordenhus `55.706374, 9.554946` — 30–80 m fra facaderne, hvor gåden faktisk kan løses og himlen er fri. Dette er værd mere end al filtrering tilsammen.
2. **Usikkerhedsbevidst afstand.** `optimistic = max(0, d − acc)`, `pessimistic = d + acc`. Sikkert indenfor → kort dwell. Muligvis indenfor → fuld dwell. Vis aldrig større præcision end `acc` tillader ("ca. 120 m"). Denne ene regel forvandler dårlig nøjagtighed fra blokering til et bredere accept-vindue.
3. **Robust konsensus-centrum.** Ringbuffer af sidste 10 fixes inden for 30 s, komponentvis median. Multipath-jitter er højfrekvent; en median dræber den.
4. **Dwell som henfaldende kredit-akkumulator, ikke wall-clock-timer.** Hvert accepteret fix lægger `min(Δt, 2s)` til; et afvist fix trækker 1 s fra, gulvet ved 0 — **nulstiller aldrig**. "Næsten verificeret, ét dårligt fix, start forfra" er den mest demoraliserende fejltilstand der findes.
5. **`accuracyProfile: "urbanCanyon"` pr. lokation** — felttunet i indhold.

Hygiejne der fanger rigtige bugs: forkast fixes med `horizontalAccuracy < 0`, `> 100 m`, eller `abs(timestamp.timeIntervalSinceNow) > 15 s` — **den klassiske stale-cached-first-fix-bug**; CoreLocations første callback er ofte timer gammel.

**Aldrig kompas/heading som gate.** `CLHeading` kræver kalibrering og er upålideligt nær stål og store konstruktioner. Retningspilen bruger `viewingBearingDegrees` fra indhold som blødt hint.

Simuleret lokation: `isSimulatedBySoftware` og `isProducedByAccessory` fra `CLLocation.sourceInformation` (iOS 15+), plus implausibel hastighed og "for perfekt" signatur (nul jitter). **Politik: verifikation lykkes stadig.** `method = .simulated`, flag registreres i ledgeren, resultatskærmen viser et neutralt "Ikke GPS-verificeret"-badge, point gives. Det opfylder både "aldrig afvis en ægte spiller" og §6.9 — og giver den fremtidige server alt til at holde en highscore ærlig uden nogensinde at have straffet nogen.

*Ærlig begrænsning: `isSimulatedBySoftware` fanger Xcode/Simulator/GPX og desktop-værktøjer. Den fanger **ikke** jailbreak-tweaks eller RF-spoofere.*

**Bevægelseskontrol (`CMPedometer`): byg sømmen, slå den fra.** Den kræver en ekstra permission-prompt, som direkte skader spørgsmål #4. Implementér `MotionCorroborating` med en `NullMotionCorroborator` som default; slå den til hvis feltdata viser at spoofing faktisk betyder noget. Ved 12 testere gør den ikke.

### Testtilstand — tre niveauer

| Niveau | Hvem | Mekanisme | I App Store-binæren? |
|---|---|---|---|
| A. GPX | Udvikler | Xcode "Simulate Location" + checked-in GPX. Nul app-kode. | n/a |
| B. Scripted provider | Udvikler + automatiserede tests | `ScriptedLocationProvider` via launch-argument. Bag `#if BH_DEV_TOOLS`. | **Nej** |
| C. **Demotilstand** | Testere, skoler, indendørs demo, **App Review** | Synlig, opt-in, ærlig indstilling. Auto-verificerer med `method = .demo`. Resultatskærme bærer permanent "Demotur"-badge. | **Ja** |

Niveau C er ikke et kompromis. Den er samtidig (a) soft-override-sikkerhedsventilen — samme kodesti når en ægte spillers GPS aldrig konvergerer, (b) en reel tilgængelighedsfeature, (c) en reel skolefeature (§4.3), og (d) **påkrævet for App Review**. Skriv trin-for-trin-instruktioner til Demotilstand i App Review Notes.

Anti-footgun: en unit-test der asserter `DevTools.isCompiled == false` i `Release`, og et CI-tjek at det arkiverede binære ikke indeholder `ScriptedLocationProvider`-symbolet.

### Feltmålingsværktøjet — planens højeste gearing

Et `#if BH_DEV_TOOLS` **"Feltmåling"**-skærmbillede der logger rå fixes (lat, lon, accuracy, timestamp, speed, source-flags) ved 1 Hz og eksporterer JSON/GPX via `ShareLink`.

Hvorfor det betyder mest: **det forvandler én tur til Vejle til en permanent, replayerbar regressionssuite.** Stå ved standpunktet i 3 min; stå klods op ad facaden i 3 min; gå tilstigningen; gå forbi uden at stoppe. De fire spor lander i `/src/iOS/TestSupport/Traces/`, og derefter sker **al gate-tuning på Windows via CI** med rigtig Vejle-GPS-adfærd, uden endnu en feltrejse. **Byg det i increment 003, før første feltbesøg.**

Plus: en tester-vendt diagnostik-eksport efter hver mission ("Send feltnotat") som testeren selv læser før afsendelse. Det er sådan man får data til at svare på spørgsmål #2 med nul telemetri og nul SDK'er.

### Stemning — seks teknikker, ikke flere

1. **Palette + Sollys-tilstand.** Asset-catalog semantiske farver med Any/Dark **og High Contrast**-varianter (gratis tilgængelighedsgevinst). Narrative flader mørke og vignetterede; funktionelle flader høj kontrast. Plus eksplicit "Sollys"-toggle. **Afgøres udendørs ved middagstid — feltest-punkt, ikke design-review-punkt.**
2. **Typografi: system-serif, ikke custom font.** `Font.system(.largeTitle, design: .serif)` (New York) til fortælling; SF Pro til funktionel tekst. Nul licensarbejde, perfekt Dynamic Type og VoiceOver. Kun hvis stemningstesten fejler, tilføj en licenseret display-font — og da via `Font.custom(_:size:relativeTo:)` så den stadig skalerer.
3. **Én hero-illustration pr. kapitel** med DTO-drevet kreditering og "Illustration — AI-genereret"-mærkning (§15.7 opfyldt konstruktionsmæssigt). Langsom Ken Burns, slået fra under `accessibilityReduceMotion`.
4. **Præcis én signatur-reveal, genbrugt overalt: `SealRevealView`.** Et voksseglt der brydes, drevet af `PhaseAnimator` + en håndlavet `SealReveal.ahap` gennem `CHHapticEngine`. Bruges til kapitel-oplåsning og inventory-fund. Én custom animation gjort godt slår fem gjort nogenlunde — og bliver appens visuelle signatur.
5. **Narrativ tekst-reveal via custom `TextRenderer`** (iOS 18+). Meget stemning pr. kodelinje. Skal kunne springes over ved tap, slås fra under Reduce Motion, og må ikke forsinke VoiceOver.
6. **Haptik: `.sensoryFeedback` til alt**, CoreHaptics kun til seglet. Haptik er lydløst — ideelt udendørs.

**Lyd: oplæsning ja (eksperimentelt), ambient nej.** Ambient loops er uhørlige udendørs uden høretelefoner og brænder batteri — skæres. Dansk oplæsning pr. kapitel tjener direkte 10-årige og svage læsere. Pragmatisk genvej til fase 1: prøv `AVSpeechSynthesizer` med en `da-DK`-stemme på 1–2 kapitler — nul indspilningsarbejde. Indspil et menneske til det endelige indhold hvis det føles fladt.

### UI-flow: 5 faner → 2

**Behold:** Udforsk (kort + liste). **Behold, omdøbt til "Samling":** Inventory + statistik + rutejournal — inventory er escape room-identiteten (§6.7). **Skær:** Mine historier (4 lokationer gør en fane til tom ceremoni — vis aktiv mission som "Fortsæt"-kort øverst på Udforsk), Resultater (ingen backend = ingen highscore), Profil (intet login, intet at vise — de 3 reelle indstillinger flytter til et tandhjul).

Behold `TabView` selv ved to faner: det etablerer den mentale model og kan vokse tilbage til fem uden IA-omskrivning.

`NavigationStack(path:)` drevet af en `@Observable Router` med typesikker route-enum. Gevinst: deep-linkbar, **restorerbar** (en spiller der baggrunder appen midt i en gåde i Vejle genoptager præcis hvor hun var — ikke til diskussion udendørs), og drivbar fra XCUITest.

12 skærme: `ExploreMapView`, `MissionSheet`, `ApproachView`, `ChapterStoryView`, `ChallengeView`, `HintSheet`, `RewardView`, `RouteProgressView`/`RouteSummaryView`, `PresenceProblemSheet`, `CollectionView`, `SettingsSheet`, `PermissionPrimerView`.

**`PresenceProblemSheet` er hvor produktet enten føles venligt eller føles i stykker.** Hver `PresenceState` mapper til en forklaring i almindeligt dansk, en konkret næste handling, og **aldrig en blindgyde**:

| Tilstand | Besked | Handling |
|---|---|---|
| `acquiring` | "Finder din position… Det kan tage et øjeblik under høje bygninger." | spinner |
| `tooFar` | "Du er ca. 180 m fra Bølgen. Gå ned mod promenaden." | Vis på kort |
| `accuracyInsufficient` | "GPS'en er lidt usikker her. Prøv at stå frit, væk fra facaden." | Prøv igen |
| `dwelling` | "Bliv stående et øjeblik…" | progress-ring |
| `authorizationNeeded(.reducedAccuracy)` | "Spillet må kun se din omtrentlige position. Det er ikke præcist nok til at åbne gåden." | Tillad præcis position |
| `softOverrideOffered` | "Vi kan ikke bekræfte din position lige nu — men du skal ikke gå glip af historien." | **Fortsæt uden GPS-verifikation** |

**Nul-onboarding-mønstre (spørgsmål #4):**

- **Ingen tutorial ved launch, aldrig.** Første skærm er kortet med én tydelig markør og én primær knap.
- **Én primær handling pr. skærm**, bundforankret, fuld bredde, ≥56 pt, imperativt dansk verbum: "Gå til Bølgen", "Åbn opgaven", "Indtast koden".
- **Diegetisk instruktion — det stærkeste mønster her, og det ligger allerede i indholdet.** Bølgen-fortællingen siger *"Læs huset som hav, højde og historie."* Opgaveskærmen viser derfor **tre navngivne felter: `hav` `højde` `historie`**. Formularen underviser i reglen; ingen hjælpetekst nødvendig. Samme for Fjordenhus (`form` `vand` `højde`). **Gør det til et indholdskrav:** flerfeltskoder skal navngive deres felter med fortællingens egne ord.
- **Tilstand altid synlig.** Hint-pris står *på* knappen: "Hint 1 — koster 3 %".
- **Kontekstuel permission-priming** i spillets stemme, umiddelbart før OS-prompten — aldrig ved launch.
- **Én enkelt tutorial-gestus:** nærmeste tilgængelige markør pulserer én gang ved første launch. Det er alt.
- **Sådan måles det:** en **tavs observationsprotokol**. Ræk telefonen til en tester og sig ingenting. Log hver tøven > 5 s og hvert forkert første tap. Det er det faktiske instrument for spørgsmål #4 og hører i planen som en leverance.

### Persistens: append-only event-log, ikke SwiftData

```swift
public struct GameEvent: Codable, Sendable, Identifiable {
    public let id: UUID          // klient-genereret idempotensnøgle
    public let sequence: Int      // monotont, pr. enhed
    public let occurredAt: Date
    public let contentVersion: String
    public let kind: GameEventKind   // unknown-tolerant
    public let payload: GameEventPayload
}
```

`EventStore`-actor → `Application Support/BH/events-v1.jsonl` + et genopbygbart `snapshot.json`. Skriv med `.atomic`.

Hvorfor ikke SwiftData: **domænet *er* en ledger.** §14.5 navngiver allerede `Attempt`, `Completion`, `ScoreTransaction`; §14.6 kræver allerede **idempotent** sync. En append-only log med klient-genererede UUID'er er lærebogssvaret — sync bliver `POST` af det ubekræftede suffiks, serveren deduplikerer på `id`. §6.5's "forklarlige pointtransaktioner" bliver gratis: **ledgeren *er* forklaringen** på belønningsskærmen, og afledt tilstand (score, oplåste kapitler, inventory) er en **ren fold** over loggen — replayerbar og unit-testbar uden persistens involveret. SwiftData ville tilføje en tredje repræsentation (DTO ↔ `@Model` ↔ afledt tilstand), direkte imod målet om at Swift-typerne *er* DTO'erne.

Ikke en blindgyde: SwiftData kan senere indføres som en *projektion* af loggen.

`@AppStorage` **kun til præferencer** (`sunlightMode`, `demoMode`, `narrationEnabled`, …) — aldrig til progression. **Specificér afrundingsreglen eksplicit** i `/src/SharedContracts/Spec/scoring.md` med testvektorer, fordi klient og fremtidig server skal være enige til pointet: `round(base × pct / 100)` half-away-from-zero, hver som sin egen transaktion. Base 100 → −3/−4/−5 → 88.

### Apple-compliance

**Info.plist:** `NSLocationWhenInUseUsageDescription` (dansk, forklarer både nærhedsvisning og stedsbekræftelse, og at positionen kun bruges på telefonen), `NSLocationTemporaryUsageDescriptionDictionary`, `ITSAppUsesNonExemptEncryption = false` (fjerner export-compliance-spørgsmålet ved hver upload), `CFBundleLocalizations = ["da"]`, portrait only, `TARGETED_DEVICE_FAMILY = 1`. **Fraværende:** `NSLocationAlwaysAndWhenInUse`, `UIBackgroundModes`, `NSMotionUsageDescription`, kamera/fotos/mikrofon.

**PrivacyInfo.xcprivacy:** `NSPrivacyTracking = false`, `NSPrivacyCollectedDataTypes = []` (korrekt, fordi "collected" betyder *transmitteret fra enheden* — ren on-device-brug af lokation er ikke indsamling), `NSPrivacyAccessedAPITypes` = kun `UserDefaults` med reason `CA92.1`. App Store Connects App Privacy-svar ("Data Not Collected") skal matche manifestet præcist. **Genbesøg i det øjeblik backenden findes.** Bemærk: privacy-manifestet er nu #2-årsag til afvisning, og siden april 2026 er der krav om build med Xcode 26-SDK.

**Ikke Kids Category.** Sæt aldersvurdering ærligt (4+) og beskriv appen som til børn og familier med voksendeltagelse. Fire grunde: (1) båndene passer ikke — Kids Category er 5-og-under / 6–8 / 9–11, målgruppen er 10–15; (2) det er en envejsdør ind i begrænsninger, roadmappet allerede planlægger at bryde (e-mail-login, **offentligt profilnavn på highscore**, brugergenereret quizmaster-indhold); (3) ekstra granskning af en app, der sender børn til fysiske steder, er en unødvendig afvisningsflade; (4) det begrænser fremtidige partneroptioner. **Men vigtig asymmetri: Guideline 5.1.4 gælder apps *rettet mod* børn, uanset om man tilmelder sig kategorien.** Behold reglerne alligevel — ingen tredjeparts-analytics, ingen PII fra børn, nogensinde.

**Fysisk sikkerhed (Guideline 1.4 — apps *er* blevet afvist for at opmuntre usikker adfærd):**
- **Sikkerhedsinterstitial** før første mission pr. session: *"Se dig for i trafikken. Læg telefonen væk, når du går. Gå ikke ud på private områder eller tæt på vandkanten."*
- **Sikkerhedsdata pr. lokation i indhold** — `safety.flags: ["water","traffic",…]` + danske noter, vist på både missionsark og approach-skærm. Bølgen og Fjordenhus behøver begge `water`; Fjordenhus' broadgang prominent.
- **Ingen tidspres nogensinde** — allerede en produktbeslutning (§5.3). **Skriv det eksplicit i App Review Notes; det er det stærkeste 1.4-forsvar.**
- **Strukturel sikkerhed by design:** kapiteltekst låses først op *efter* tilstedeværelse er verificeret, dvs. efter spilleren er ankommet og standset. Appen beder aldrig nogen læse under gang. Skriv også det i reviewer-noterne.
- In-app **"Meld fejl"** pr. §16.4.

**Tilgængelighed — funktionelt krav, ikke compliance-teater**, fordi indholdet læses udendørs i sollys under bevægelse: Dynamic Type til AX5 (ingen faste teksthøjder; `ScrollView` + `ViewThatFits` overalt); VoiceOver-labels fra DTO'ens `altText` (forfattet, ikke opdigtet); container-label på flerfeltskoden ("Kode: tre felter — hav, højde, historie"); `AccessibilityNotification.Announcement` ved ankomst; WCAG 2.2 AA-kontrast med High Contrast-varianter; `differentiateWithoutColor` → kortmarkør-status må ikke være farve-alene, par hver status med et distinkt SF Symbol; `accessibilityReduceMotion` honoreres; tap-mål ≥44×44 pt, primære CTA'er 56 pt i tommelzonen. **Automatisér:** `try app.performAccessibilityAudit()` i XCUITest på hver nøgleskærm — én linje pr. skærm, fanger kontrast, manglende labels, hit-target og klippet tekst.

**MapKit:** Apple Maps-attribution må ikke dækkes af bundark eller CTA'er. Cache eller persistér ikke tiles.

**App Store Connect kræver — uanset at der ikke indsamles data — en privatlivspolitik-URL og en support-URL.** Publicér en dansk privatlivspolitik som statisk side (GitHub Pages er fint) før første eksterne distribution.

### Test på et Windows-primært / Mac-sekundært setup

| Windows (daglig) | Mac (eller macOS-CI) |
|---|---|
| Indholdsforfatning + JSON Schema-validering | Al Swift-kompilering |
| Svar-/scoring-**testvektorer** | Unit-tests, XCUITest |
| GPX-forfatning (ren XML) | Instruments (batteri, location energy) |
| Spec Kit-specs, PR-review, ADR'er | Archive + TestFlight-upload |
| Gate-tuning mod optagne feltspor (via CI) | Interaktiv debugging |

**Nøgle-enabler: en self-hosted GitHub Actions-runner på Macen.** Macen bliver en byggeserver, du trigger fra Windows med `git push`; gratis, hurtig, og du åbner aldrig Xcode til rutineverifikation. Plus **fastlane `pilot`** med en App Store Connect API-nøgle i GitHub secrets, så et git-tag producerer et TestFlight-build med **nul Mac-interaktion**. For en Windows-primær udvikler ændrer denne ene beslutning ergonomien i hele projektet. (`gh` CLI er ikke installeret — fastlane + API-nøgle er alligevel den rigtige vej.)

**Swift Testing** (`@Test`, `#expect`, parameteriseret `arguments:`) til logik. `AnswerEvaluatorTests` tabeldrevet fra den delte `answer-testvectors.json`, så samme vektorer senere kører i xUnit mod ASP.NET-implementeringen.

`PresenceGateTests` med injiceret provider og injiceret ur, **nul GPS** — 11 scenarier, hvoraf de vigtigste er: stale cached first fix forkastes; accuracy 60 m ved 10 m → `dwelling` (usikkerhedsreglen); ét dårligt fix midt i dwell → kredit henfalder men **nulstiller ikke**; 2 km teleport på 1 s → outlier afvist; `isSimulatedBySoftware` → `verified` med flag og `method == .simulated`; konvergerer aldrig → `softOverrideOffered` ved 120 s; **drive-by** (passerer radius i 3 s) → **verificerer aldrig** (det er dwell-timerens egentlige job og testen der beviser det).

**Tre kontraktvagter:** (1) golden-serialiseringstest — enhver omdøbning fejler CI med "dette er en API-ændring"; (2) JSON Schema-validering i CI på Linux, så den gater hver indholds-PR fra Windows; (3) **indholds-selvkonsistenstest** på den rigtige shippende pakke: alle referencer resolver, præcis 3 hints med fradrag der summer til 12 %, `maxAcceptableAccuracyMetres ≤ activationRadiusMetres`, **`evaluate(canonicalAnswer) == .correct`** (reglen skal acceptere sit eget facit), og **hver `nearMissResponses.matches` evaluerer til `.nearMiss`, aldrig `.correct`** — fanger den klassiske forfatterbug hvor en distraktor også accepteres. Dét blok er hvor de fleste indholdsbugs ellers ville nå felten.

**Hvad kræver et faktisk feltbesøg til Vejle:** bekræft standpunkterne med en rigtig iPhone og optag 2–3 min ved 1 Hz på fire punkter pr. lokation (standpunkt, klods op ad facaden, tilstigningen, gå-forbi); mål opnåelig nøjagtighed → sætter radius pr. lokation (Fjordenhus' bro er formentlig værste tilfælde); **verificér at invarianterne faktisk er observerbare** — kan alle fem bølger ses i ét blik, og kan ni etager tælles pålideligt af en 12-årig på den afstand; **sollys-læsbarhedstest ved middagstid** (eneste måde at afgøre C2); sikkerheds- og adgangsvurdering pr. §15.4, inkl. at gaten ikke er centreret på en cykelsti; dækningstjek; referencefotos med rettighedslog; **de to Bredballe-lokationer skal skabes fra nul**; batterimåling på en rigtig 90-minutters rute; og **den tavse observationsprotokol med 2–3 rigtige 10–15-årige**.

Batteribudget som eksplicit fase-1-succeskriterium: **en 90-minutters rute med 4 stop koster < 15 % batteri på en iPhone 12.**

---

## Spec Kit-nedbrydning

Kør **`/constitution`** først (ikke en feature): iOS-only; ingen backend; **kontrakter er API-DTO'er — kun additive ændringer**; offline-first; afvis aldrig hårdt en ægte spiller; tilgængelighed og fysisk sikkerhed er ikke til diskussion; nul tredjeparts-SDK'er; dansk indhold; hvert increment selvstændigt demobart.

Derefter otte `/specify`-features:

| # | Feature | Scope | Demo | Afhænger af |
|---|---|---|---|---|
| **001** | `fundament-og-lodret-snit` | Xcode-projekt + `BHKit`-skelet; `BHContracts` + JSON Schema + **Bølgen-indhold**; `BundledContentPackSource` + `ContentRepository`; `AnswerEvaluator` + `DanishTextNormalizer`; `PresenceGate` v1; `CoreLocationProvider`; minimal `ScriptedLocationProvider`; `EventStore`; 6 skærme; danske purpose strings; privacy-manifest; golden- + selvkonsistenstests | **Én komplet Bølgen-mission, ende til ende** | — |
| **002** | `udgivelsesroerledning` | Self-hosted macOS-runner; build + test + schema-validering ved hvert push; fastlane `pilot` → TestFlight fra git-tag; App Store Connect-app, bundle-ID, navnereservation; tre build-konfigurationer + `BH_DEV_TOOLS`; "ingen dev tools i Release"-assertion | Et tagget commit lander på din telefon **uden at du åbner Xcode** | 001 (parallelt med 003) |
| **003** | `tilstedevaerelse-robusthed` | Median-konsensus; usikkerhedsbevidst afstand; dwell-kreditakkumulator; stale-/outlier-/teleport-afvisning; reduced accuracy → temporary full accuracy; simulationsdetektion + integritetsstempling; `PresenceProblemSheet` med alle otte venlige danske tilstande; soft override; **Feltmålingsværktøj**; GPX-fixtures + trace-replay-suite | Alle 11 gate-scenarier grønne; en drive-by verificerer aldrig; en ægte spiller går aldrig i stå | 001 |
| **004** | `demotilstand-og-testbarhed` | Brugervendt **Demotilstand**; `verificationMethod` stemplet gennem til resultater og ledger; launch-argument-routing til XCUITest; happy-path smoke-test + accessibility-audits; App Review Notes-tekst | Fuld mission gennemført indendørs, resultat badget "Demotur". **Testere kan spille før nogen tager til Vejle** | 001, 003 |
| **005** | `stemning-og-beloenning` | `BHDesignSystem`: palette + High Contrast + **Sollys**; serif/Dynamic Type; hero-billeder med DTO-drevet kreditering og AI-mærkning; `SealRevealView` + `SealReveal.ahap`; `TextRenderer`-reveal; `.sensoryFeedback`; Reduce Motion-stier; oplæsning på ét kapitel | Stemningstest med testere — "føltes det som noget?" | 001 (004 gør den demobar indendørs) |
| **006** | `fjordenhus-og-ruteprogression` | Anden lokation + indhold (**inkl. C7-rettelsen**); Story/Chapter-progression og oplåsningsregler; inventory (Arkitektens Note, Fjordsegl) + "Samling"-fane; ruteopsummering; forklarlig pointtransaktions-UI; pause/genoptag via restorerbar navigation | Tostops-rute med finale, inventory-grid og fuld pointopdeling | 001, 005 |
| **007** | `tilgaengelighed-og-sikkerhed` | VoiceOver-gennemgang; AX5-layouts; differentiate-without-colour-markører; sikkerhedsinterstitial + sikkerhedsflag pr. lokation; Indstillinger/Om/Kilder/Privatliv/Sikkerhed; "Meld fejl"-flow; String Catalog-oprydning; privatlivspolitik + supportside; App Store Connect-metadata og App Privacy-svar | En komplet mission spillet **kun med VoiceOver**; `performAccessibilityAudit` grøn overalt | 005, 006 |
| **008** | `bredballe-omraade` | To nye Bredballe-lokationer (feltarbejde + indhold); områdemysterie-mekanikken (saml symboler → finale); områdeskift på kortet; quizmaster-indholdsguide + schema-validering som PR-gate | Andet område spilbart; **en ikke-udvikler redigerer JSON og CI validerer PR'en** | 006, 007 + feltarbejde |

**Sekvenseringsnoter:**

- **002 tidligt er værd mere end det ser ud.** At få builds på testeres telefoner fra et git-tag, fra Windows, *før* der er meget at teste, fjerner friktion fra hvert senere increment.
- **004 før 005/006**, fordi det er dét, der lader 8–12 testere svare på spørgsmål #1 ("er det overhovedet sjovt") **indendørs, før nogen rejser**. Det er det billigst mulige svar på det vigtigste spørgsmål.
- **001 er bevidst stor** — et lodret snit skal være det. Hvis `/plan` viser over ~2 uger, er det rene delepunkt: 001a = kontrakter + svarmotor + indholdspakke + kapitel/opgave/belønning drevet af en **fast** position; 001b = det rigtige kort, approach-skærm og `CoreLocationProvider`.
- **Feltarbejde gater 008.** Book Vejle-turene under 003 (for at få spor tidligt) og under 006 (Bredballe-indhold). **Feltarbejde er planens lange leadtime, ikke koden.**

---

## Forudsætninger før første `/specify`

1. **Ryd arbejdstræet.** Der ligger uncommittede filflytninger: 4 slettede tracked filer + 3 utrackede tilføjelser (docs reorganiseret til `docs/flyers/` og `docs/retningslinjer/`). Commit dem, så `specify init --here` kører på et rent træ.
2. **`specify init --here --ai claude`** — `specify.exe` 0.12.4.dev0 findes allerede i `C:\Users\jespe\.local\bin\`. Bemærk: det er et dev-build, ikke et tagget release. `uv`/`uvx` er ikke på PATH, men behøves ikke.
3. **Ret C7 i `docs/retningslinjer/`** — opdatér begge referenceopgavers fortællinger, så tredje ciffer oplyses i teksten. Gør dette *før* increment 001 forfatter indholdspakken.
4. **Apple Developer Program-medlemskab** + reservér appnavnet "Byens Hemmeligheder" og et bundle-ID på et domæne du kontrollerer (fx `dk.hyldenbrandt.byenshemmeligheder`) — det er permanent, når det først er i App Store Connect.
5. **Start Bredballe-indholdsresearch nu**, parallelt med increment 001.

---

## Verifikation

**Pr. increment** (kører fra Windows via push til macOS-runner): Swift Testing-suiten grøn; JSON Schema-validering grøn; golden-kontrakttest grøn; indholds-selvkonsistenstest grøn; `performAccessibilityAudit` grøn på alle berørte skærme; `DevTools.isCompiled == false` i Release.

**Ende-til-ende indendørs** (fra increment 004): Slå Demotilstand til → gennemfør Bølgen-missionen fuldt ud → verificér at resultatskærmen bærer "Demotur"-badge, at pointopdelingen matcher `scoring-testvectors.json`, og at event-loggen kan foldes til samme tilstand efter en genstart af appen.

**Ende-til-ende i felten** (fra increment 003): Ved Bølgen-standpunktet — GPS-gaten verificerer inden for 30 s; gå-forbi verificerer ikke; klods op ad facaden ender i `accuracyInsufficient` med den venlige besked, ikke i en blindgyde; feltsporene eksporteres og checkes ind som regressionsdata.

**De fire fase-1-spørgsmål besvares med:** (#1) testerinterview efter increment 004 og 006 — "vil du prøve en mere?"; (#2) de indsamlede `PresenceEvidence`-fordelinger fra feltnotater — mål falsk-afvisningsraten, ikke spoofing-raten; (#3) stemningstest efter 005 plus sollys-læsbarhedstest ved middagstid; (#4) **den tavse observationsprotokol** med 2–3 rigtige 10–15-årige — tøven > 5 s og forkerte første tap logges.

---

## Skal verificeres empirisk dag 1 (usikre antagelser)

1. **Sætter GPX-simulering i iOS Simulator `isSimulatedBySoftware`?** Afgør om hvert dev-run ser "simuleret" ud og om `targetEnvironment(simulator)`-nedgraderingen er nødvendig. Tjekbart på en time; former increment 003.
2. **iOS 26's enhedsgrænse** (formodet A13/iPhone 11+) — den bærende kendsgerning bag iOS 18-deployment target.
3. **App Store Connects interne tester-mekanik** — mindste rolle der giver TestFlight-adgang, og om 8–12 familietestere praktisk kan tilføjes som interne brugere. Afgør om niveau-B-dev-tools kan følge med feltbuildet uden Beta App Review. Fallback: ekstern gruppe + kun niveau C shipper.
4. **Apples aktuelle ordlyd om "collected" i privacy-manifestet** — læsningen (on-device-brug ≠ indsamling) er standard, men genlæs før submission.
5. **MapKit-vilkår om tile-caching** — C1 hænger på det.
6. **Offentlig-sektor-tilgængelighedslovgivning** (WCAG 2.1 AA / EN 301 549 / EAA, i kraft siden 28. juni 2025): gælder den en gratis app fra en privat udvikler med en kommunal partner? Spørg Vejle Kommune direkte. Det styrker kun argumentet for at gøre det ordentligt nu.
