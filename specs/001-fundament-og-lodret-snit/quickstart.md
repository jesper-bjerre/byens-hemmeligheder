# Quickstart — verificér feature 001

**Feature**: 001-fundament-og-lodret-snit
**Formål**: Bevise at featuren virker, uden at læse kildekoden.

Verifikationen falder i tre lag. De to første kræver ingen rejse til Vejle.

---

## Forudsætninger

**Mac** (al Swift-kompilering):

```bash
git clone <repo> && cd byens-hemmeligheder
```

Fuld Xcode kræves — Command Line Tools alene er ikke nok, fordi de ikke
indeholder Swift Testing. Peger `xcode-select` på Command Line Tools, fejler
`swift test` med `no such module 'Testing'`. Ret det én gang:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Alternativt kan hver kommando præfikses med
`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

Verificeret med Xcode 26.6, Swift 6, iOS 26.5-simulator.

Spec kit er initialiseret med `"script": "ps"` og kalder PowerShell-scripts. De
er ikke nødvendige for at bygge eller teste — kun til `/speckit-*`-kommandoerne:

```bash
brew install --cask powershell
pwsh .specify/scripts/powershell/check-prerequisites.ps1 -Json
```

**Windows** (indhold, testvektorer, specs): intet ud over git. `BHGameCore` og
`BHContracts` er bevidst uden Apple-frameworks, så deres logik og testvektorer
kan skrives herfra — men ikke kompileres.

---

## Lag 1 — Indholdet holder (kræver ingen simulator)

Dette er publiceringsporten. Den skal være grøn, før noget andet betyder noget.

```bash
cd iOS/Packages/BHKit
swift test
```

**Forventet**: `Test run with 116 tests in 13 suites passed`.

Suiterne, der udgør porten:

| Suite | Hvad den vogter |
|---|---|
| `Skemavalidering` | Pakken mod `bh-content-v1.schema.json` + de syv defekter |
| `Indholdets selvkonsistens` | V-01 til V-10 fra data-model.md |
| `Forbudte koder` | `541` findes ingen steder — inkl. en positiv kontrol af detektoren |
| `Golden-serialisering` | Enhver feltomdøbning er en API-ændring |
| `Motoren er indholdsdrevet` | Ingen opgavespecifikke navne i produktionskoden (SC-002) |
| `GPX-scenarier` | Standpunkt verificerer, gå-forbi gør aldrig (SC-010) |

De syv defekter fra tabellen nedenfor **køres automatisk** af
`SchemaValidationTests.defectIsRejected`. Fixturerne bygges i hukommelsen ud fra
den rigtige pakke, så de ikke kan nå at drive fra den. Tabellen står her som
dokumentation af, hvad porten dækker:

| Defekt | Forventet afvisning |
|---|---|
| Fjern `safety.notes` fra en lokation | Skema: manglende obligatorisk felt |
| Ændr et facit, så svarreglen ikke accepterer det | `evaluate(canonicalAnswer) != .correct` |
| Tilføj `"592"` som near-miss på Bølgen | En near-miss evaluerer korrekt |
| Ændr et hintfradrag fra 4 til 5 | Hintsum er 13, ikke 12 |
| Peg `heroMediaId` på et ikke-eksisterende medie | Reference resolver ikke |
| Skriv `541` et vilkårligt sted i pakken | Forbudt kode fundet |
| Fjern `kind` fra et medie | Medie mangler mærkning |

En defekt, der **ikke** afvises, er en fejl i valideringen — ikke i indholdet.
Det opfylder SC-007.

---

## Lag 2 — Missionen kan gennemføres indendørs

Kør på simulator med simuleret position ved Bølgens standpunkt.

Automatiseret — hele lag 2 køres af UI-testene:

```bash
cd iOS
xcodebuild -project ByensHemmeligheder.xcodeproj -scheme ByensHemmeligheder \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test CODE_SIGNING_ALLOWED=NO
```

**Forventet**: 12 UI-tests grønne. De tager ca. 7 minutter, fordi dwell-tiden er
ægte — se `FlowTestCase` for hvorfor uret ikke komprimeres.

Manuelt, hvis du vil se det med egne øjne:

```bash
open iOS/ByensHemmeligheder.xcodeproj
```

I simulatoren kører appen på en **simuleret position, du selv styrer**. Tryk på
hammer-knappen øverst til højre for at åbne udviklerpanelet: sæt dig 200 m væk,
gå hen til standpunktet i valgt tempo, gå forbi uden at standse, eller slå
dårligt signal til. Panelet findes kun i Debug (FR-051).

Alternativt Xcodes egen afspilning: **Debug ▸ Simulate Location** → vælg
`iOS/TestSupport/GPX/boelgen-standpunkt.gpx`. De samme GPX-spor køres i CI af
`GPX-scenarier`-suiten, så de ikke kan nå at blive forældede.

**Gennemløb, der skal lykkes:**

1. Kortet viser to markører — Bølgen og Fjordenhus — begge åbne, ingen rækkefølge påkrævet
2. Åbn Bølgen. Missionsarket viser varighed, sværhedsgrad, **sikkerhedsnoter**, tilgængelighedsnoter og fiktionsmarkering
3. Positionen bekræftes inden for ca. 30 s. Den narrative intro åbner med synlig fiktionsmarkering
4. Vælg `5` på observationstrinnet → bekræftet, næste trin låses op
5. Svar på de to faktaspørgsmål → `9` og `2`
6. Indtast `529` → feedbacken forklarer, at rækkefølgen er forkert. **Ingen point trukket**
7. Indtast `59` → behandles som ufærdigt, ikke som fejlforsøg
8. Indtast `5 9 2` → accepteret som `592`
9. Belønningsskærmen viser 100 point, beskeden og den historiske forklaring

**Pointkontrol** (SC-005): gentag med alle tre hints brugt → **præcis 88 point**,
og skærmen forklarer fradraget.

**Genoptagelse** (SC-006): dræb appen mellem trin 5 og 6, start igen → samme
trin, samme hintstatus, samme forsøgshistorik.

**Netværksudfald** (SC-003): sæt simulatoren i flytilstand **midt** i en opgave.
Appen skal sige tydeligt, at forbindelsen mangler — ikke lade det ligne, at
opgaven er i stykker. Slå netværket til igen: turen genoptages på samme trin.

**Anden opgave** (SC-002): gentag med Fjordenhus og facit `428`.

Kravet om "ingen ny kode" er gjort maskinelt frem for at hvile på et review.
`EngineIsContentDrivenTests` scanner `iOS/Packages/BHKit/Sources` og `iOS/App`
for opgavespecifikke navne — `boelgen`, `fjordenhus`, `592`, `428`,
`bølgetop`, `cylinder` — uden for kommentarer. Findes ét af dem i
produktionskode, fejler testen.

Den kontrollerer også, at begge missioner har **samme trinstruktur**. Havde de
forskellig form, ville den ene ikke være bevis for den anden.

Skriver nogen `if mission.id == …` for at få en enkelt opgave til at opføre sig
anderledes, siger porten fra med det samme — ikke tre increments senere.

---

## Lag 3 — Tilstedeværelse og tilgængelighed

**Ingen blindgyder** (SC-004). Gennemgå hver `PresenceState` og bekræft, at den
viser en forklaring på almindeligt dansk og mindst én handling:

`acquiring`, `tooFar`, `approaching`, `accuracyInsufficient`, `dwelling`,
`authorizationNeeded(.denied)`, `authorizationNeeded(.restricted)`,
`authorizationNeeded(.reducedAccuracy)`, `softOverrideOffered`.

`.restricted` er den, der glemmes — Skærmtid kan blokere Location Services helt
på et barns telefon.

**Forbipasserende låser ikke op** (SC-010): brug
`iOS/TestSupport/GPX/boelgen-gaa-forbi.gpx`, der passerer radius på under
dwell-tiden. Missionen må **ikke** åbne.

**Skærmlæser** (SC-009): slå VoiceOver til og gennemfør en hel mission uden at se
på skærmen. Kodefeltet skal annonceres som ét felt med navngivne positioner.

**Tekststørrelse**: sæt Dynamic Type til største tilgængelighedsstørrelse. Intet
må klippes.

**Automatiseret tilgængelighedsaudit**:

```bash
cd iOS
xcodebuild -project ByensHemmeligheder.xcodeproj -scheme ByensHemmeligheder \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:ByensHemmelighederUITests/AccessibilityAuditTests \
  test CODE_SIGNING_ALLOWED=NO
```

`performAccessibilityAudit` er grøn på kort, missionsark, narrativ intro,
valgspørgsmål, talkode, hints og belønning.

Auditten kører med `.contrast` fravalgt: fiktions- og sikkerhedsmærkaterne er
bevidst dæmpet mod deres egen tonede baggrund, og auditten måler mod sidens
baggrund. Kontrasten er i stedet kontrolleret i `BHDesignSystem`, hvor hver
semantisk farve har en variant til forøget kontrast.

**Fundet undervejs og rettet**: værktøjslinjeknapper i SwiftUI arver en fast
fontstørrelse, der ikke følger Dynamic Type. Derfor ligger hintarkets "Luk"-knap
i indholdet frem for i værktøjslinjen.

---

## Lag 4 — Felten (gater ikke feature 001)

Kræver rejse til Vejle Havn og hører formelt til increment 003, men er den eneste
måde at afgøre SC-001.

Ved Bølgens standpunkt: bekræft at alle fem bølgetoppe er synlige fra ét sikkert
sted, at gaten verificerer inden for 30 s, og at et gå-forbi ikke verificerer.
Optag 2–3 minutters rå positionsdata på fire punkter — standpunktet, klods op ad
facaden, tilstigningen og gå-forbi — og gem dem som regressionsdata.

Disse målinger leverer de foreløbige koordinater, radius og standpunkter, som
indholdspakken mangler, og som blokerer `published` (V-10).

---

## Hvad "færdig" betyder

| Kriterium | Lag |
|---|---|
| SC-002 Fjordenhus uden ny kode | 2 |
| SC-003 Udfald koster ikke progression | 2 |
| SC-004 Nul blindgyder | 3 |
| SC-005 88 point med alle hints | 2 |
| SC-006 Genoptagelse efter afbrydelse | 2 |
| SC-007 Alle indholdsdefekter afvises | 1 |
| SC-008 `541` findes intet sted | 1 |
| SC-009 Gennemførsel kun med skærmlæser | 3 |
| SC-010 Forbipasserende låser ikke op | 3 |
| SC-001 Testperson gennemfører uden instruktion | 4 |

Lag 1–3 kan alle køres uden at forlade skrivebordet. Kun SC-001 kræver felten.

## Hvad der er automatiseret, og hvad der ikke er

| Kriterium | Automatiseret |
|---|---|
| SC-002 Fjordenhus uden ny kode | ✅ `EngineIsContentDrivenTests` |
| SC-003 Udfald koster ikke progression | ❌ **Endnu ikke.** Kræver netværkskilden. `testFullFlowMakesNoNetworkRequests` hævder i dag det modsatte og skal vendes, når indholdet hentes fra tjenesten (ADR 0004) |
| SC-004 Nul blindgyder | ✅ `PresenceProblemContent` er en totalfunktion; `GPX-scenarier` hævder handlingsmulighed |
| SC-005 88 point med alle hints | ✅ Både unit test og UI-test |
| SC-006 Genoptagelse | ✅ `ResumeAndOfflineTests` |
| SC-007 Alle defekter afvises | ✅ `SchemaValidationTests` — alle syv |
| SC-008 `541` findes intet sted | ✅ `ForbiddenCodeTests`, med positiv kontrol |
| SC-009 Kun med skærmlæser | ❌ **Manuel.** `performAccessibilityAudit` fanger etiketter, trykflader og afskåret tekst — men en skærm kan bestå auditten og stadig være ubrugelig at navigere i blinde |
| SC-010 Forbipasserende låser ikke op | ✅ `PresenceGateTests` og `GPX-scenarier` |
| SC-001 Testperson uden instruktion | ❌ Kræver felten |

De to manuelle er ikke forglemmelser. SC-009 kræver et menneske med VoiceOver
slået til, og SC-001 kræver en person, der ikke har set appen før.
