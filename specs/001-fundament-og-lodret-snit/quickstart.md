# Quickstart — verificér feature 001

**Feature**: 001-fundament-og-lodret-snit
**Formål**: Bevise at featuren virker, uden at læse kildekoden.

Verifikationen falder i tre lag. De to første kræver ingen rejse til Vejle.

---

## Forudsætninger

**Mac** (al Swift-kompilering):

```bash
xcode-select --install          # eller fuld Xcode fra App Store
brew install --cask powershell  # spec kit er initialiseret med "script": "ps"
git clone <repo> && cd byens-hemmeligheder
```

Bekræft at spec kit kan køre:

```bash
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
swift test --filter BHContentKitTests
swift test --filter BHGameCoreTests
swift test --filter BHContractsTests
```

**Forventet**: alle grønne.

Bevis derefter, at gaten faktisk bider. Indfør én defekt ad gangen i en kopi af
`contracts/content/da-DK/content-pack.json` og bekræft, at hver enkelt afvises:

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

```bash
open iOS/ByensHemmeligheder.xcodeproj
```

I Xcode: vælg en iPhone-simulator → **Debug ▸ Simulate Location** → vælg
`iOS/TestSupport/GPX/boelgen-standpunkt.gpx` → kør.

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

**Offline** (SC-003): sæt simulatoren i flytilstand og gennemfør hele missionen.

**Anden opgave** (SC-002): gentag med Fjordenhus og facit `428`. Den skal fungere
uden nogen kodeændring. Kontrollér ændringssættet — hvis Fjordenhus krævede
programlogik, er User Story 2 ikke bestået.

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
xcodebuild test -scheme ByensHemmeligheder -destination 'platform=iOS Simulator,name=iPhone 16'
```

`performAccessibilityAudit` skal være grøn på hver nøgleskærm.

---

## Lag 4 — Felten (gater ikke feature 001)

Kræver rejse til Vejle Havn og hører formelt til increment 003, men er den eneste
måde at afgøre SC-001.

Ved Bølgens standpunkt: bekræft at alle fem bølgetoppe er synlige fra ét sikkert
sted, at gaten verificerer inden for 30 s, og at et gå-forbi ikke verificerer.
Optag 2–3 minutters rå positionsdata på fire punkter — standpunktet, klods op ad
facaden, tilstigningen og gå-forbi — og gem dem som regressionsdata.

Disse målinger leverer de foreløbige koordinater, radius og standpunkter, som
indholdspakken mangler, og som blokerer `publishReady` (V-10).

---

## Hvad "færdig" betyder

| Kriterium | Lag |
|---|---|
| SC-002 Fjordenhus uden ny kode | 2 |
| SC-003 Fuld offline | 2 |
| SC-004 Nul blindgyder | 3 |
| SC-005 88 point med alle hints | 2 |
| SC-006 Genoptagelse efter afbrydelse | 2 |
| SC-007 Alle indholdsdefekter afvises | 1 |
| SC-008 `541` findes intet sted | 1 |
| SC-009 Gennemførsel kun med skærmlæser | 3 |
| SC-010 Forbipasserende låser ikke op | 3 |
| SC-001 Testperson gennemfører uden instruktion | 4 |

Lag 1–3 kan alle køres uden at forlade skrivebordet. Kun SC-001 kræver felten.
