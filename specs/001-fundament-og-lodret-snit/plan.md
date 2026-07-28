# Implementation Plan: Fundament og lodret snit

**Branch**: `001-fundament-og-lodret-snit` | **Date**: 2026-07-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-fundament-og-lodret-snit/spec.md`

## Summary

Feature 001 leverer et lodret snit gennem hele spilleroplevelsen: en iPhone-app
der kan afvikle **to** fritstående, stedsbaserede opgaver — Bølgen (facit `592`)
og Fjordenhus (facit `428`) — fra kort til belønningsskærm, uden
konti og uden backend.

Den bærende tekniske beslutning er, at **indhold er data, ikke kode**. Begge
opgaver drives af den samme motor ud fra én valideret indholdspakke, hvis
Swift-typer samtidig *er* den fremtidige API-kontrakt. Den anden opgave er
derfor beviset for, at motoren er generisk — hvis Fjordenhus koster mere end en
indholdsfil, har feature 001 fejlet, og det skal opdages her frem for tre
increments senere.

Uden quizmasterportal er automatisk indholdsvalidering den eneste
publiceringsport, der findes. Den håndhæver forfatningens princip II og IV og
bliver senere fundamentet for portalen.

## Technical Context

**Language/Version**: Swift 6, SwiftUI. Deployment target iOS 18.0, bygget mod
nyeste SDK (se [research.md](./research.md) R-001)

**Primary Dependencies**: Kun Apples egne frameworks — SwiftUI, MapKit,
CoreLocation, Foundation. **Nul tredjeparts-SDK'er** (R-009)

**Storage**: Append-only hændelseslog som JSON Lines i
`Application Support/BH/events-v1.jsonl` plus genopbygbart snapshot. Ingen
database, ingen SwiftData (R-005)

**Testing**: Swift Testing til logik, XCUITest til flow og
`performAccessibilityAudit`. Testvektorer som delt JSON, så de senere kan køre i
xUnit mod ASP.NET (R-010)

**Target Platform**: iPhone, portrait only, `TARGETED_DEVICE_FAMILY = 1`. Ingen
iPad, ingen web, ingen Android

**Project Type**: Native mobilapp med bundlet indhold. Ingen server-komponent i
denne feature

**Performance Goals**: Indhold hentes fra tjenesten (ADR 0004). Et kortvarigt
udfald koster ventetid, ikke progression.
Positionsbekræftelse ved standpunktet inden for 30 s under normale forhold.
Ingen mærkbar forsinkelse ved indlæsning af indholdspakken

**Constraints**: Indhold hentes fra tjenesten; progression skrives lokalt først. Ingen
personoplysninger indsamles. Kortfliser må ikke caches (R-008). Udviklerværktøjer
må ikke findes i en udgivelsesbygning (FR-051)

**Scale/Scope**: 2 opgaver, 1 område, ca. 8 skærme, 6 SPM-targets. 8–12
testpersoner i felttest

## Constitution Check

*GATE: Skal bestås før Phase 0 research. Genvurderet efter Phase 1 design.*

| Princip | Gate | Status | Hvordan planen opfylder den |
|---|---|---|---|
| **I. Stedet er spillet** (NON-NEG.) | Opgaven må ikke kunne løses hjemmefra; standpunkt registreret; lokationsrelevans ≥ 4 | ✅ | `PresenceGate` låser indhold op først ved stedet (R-007). Bølgens ciffer 1 kræver fysisk observation. Standpunkt er et felt i kontrakten |
| **II. Entydigt og bevisbart facit** (NON-NEG.) | Ét kanonisk facit, eksplicitte alternativer, løsningsbevis | ✅ | `AnswerEvaluator` med fire udfald (R-006). Selvkonsistenstesten kræver, at facit bedømmes korrekt af sin egen regel, og at ingen near-miss accepteres (R-010) |
| **III. AI assisterer, mennesker udgiver** (NON-NEG.) | Ingen automatisk publicering; medier mærket | ✅ | Opgavedokumenterne er kilden til sandhed; pakken er afledt. `aiGenerated` er obligatorisk felt, håndhævet af skemaet |
| **IV. Sikkerhed, adgang, rettigheder** (NON-NEG.) | Sikkerhedsreview, rettighedslog, pausefunktion | ⚠️ | Sikkerheds- og rettighedsfelter er obligatoriske og skema-håndhævede. **Pausefunktion er udskudt** — se Complexity Tracking |
| **V. Serverbåret og versionsfastholdt** | Indhold fra tjenesten; idempotent; session bundet til indholdsversion | ✅ | Bundlet pakke, append-only log med klientgenererede UUID'er (R-005). App-versionen *er* indholdsversionen i 001 |
| **VI. Privatliv og dataminimering** (NON-NEG.) | Ingen konti, ingen rutehistorik, ingen tredjepart | ✅ | Ingen backend, ingen SDK'er (R-009). Kun `requestWhenInUseAuthorization`. Privacy-manifest med tomt `NSPrivacyCollectedDataTypes` |
| **VII. Tilgængelig familieoplevelse** | Ingen tidspres; små hintfradrag; VoiceOver; Dynamic Type | ✅ | Tid registreres ikke i point. Fradrag kommer fra indhold (FR-021). `performAccessibilityAudit` på hver skærm (R-010) |

**Resultat før Phase 0**: Bestået med én registreret afvigelse (princip IV,
pausefunktion). Ingen NON-NEGOTIABLE-regel fraviges i sit indhold.

**Genvurdering efter Phase 1**: Uændret. Datamodellen indfører ingen nye
afvigelser. `contracts/bh-content-v1.schema.json` gør princip II's og IV's
obligatoriske felter til en maskinel gate frem for en aftale, hvilket styrker
efterlevelsen i forhold til før designet.

## Project Structure

### Documentation (this feature)

```text
specs/001-fundament-og-lodret-snit/
├── plan.md              # Denne fil
├── spec.md              # Feature-specifikation
├── research.md          # Phase 0 — tekniske valg og begrundelser
├── data-model.md        # Phase 1 — entiteter og regler
├── quickstart.md        # Phase 1 — sådan verificeres featuren
├── contracts/           # Phase 1 — kontraktdefinition
│   ├── bh-content-v1.schema.json
│   └── kontrakt.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 — genereres af /speckit-tasks
```

### Source Code (repository root)

```text
iOS/                                   # Alt Apple-specifikt
  ByensHemmeligheder.xcodeproj
  App/                                 # App-target: entrypoint, Info.plist,
                                       # PrivacyInfo.xcprivacy, assets, skærme
  Packages/BHKit/
    Package.swift
    Sources/
      BHContracts/                     # Wire-typerne. Foundation only
      BHGameCore/                      # AnswerEvaluator, PresenceGate,
                                       # ScoreLedger, DanishTextNormalizer, GeoMath
      BHContentKit/                    # ContentPackSource, ContentRepository
      BHPersistence/                   # EventStore, snapshot
      BHLocationKit/                   # Eneste modul med CoreLocation
      BHDesignSystem/                  # Minimal i 001; udbygges i increment 005
    Tests/
      BHContractsTests/                # Golden-serialisering
      BHGameCoreTests/                 # Tabeldrevet fra testvektorer
      BHContentKitTests/               # Selvkonsistens på den shippende pakke
      BHPersistenceTests/
      BHLocationKitTests/
  TestSupport/
    GPX/                               # Simulerede ruter til Xcode

contracts/                             # Sprogneutralt — deles med backend senere
  bh-content-v1.schema.json
  content/da-DK/content-pack.json      # Den pakke der shipper
  content/da-DK/media/
  golden/                              # Golden-serialiseringer pr. kontrakttype
  spec/
    answer-normalization.md
    answer-testvectors.json
    scoring.md
    scoring-testvectors.json

docs/                                  # Findes
  design af opgaver/opgaver/           # Kilden til sandhed for indhold
  plans/fase-1-arkitektur.md
  ADR/                                 # Oprettes ved første arkitekturbeslutning

backend/                               # Tom i fase 1. Reserveret til ASP.NET Core
```

**Structure Decision**: `iOS/` og `backend/` er sidestillede rodmapper, der
skiller klient fra server. `contracts/` er den tredje søster, netop fordi
kontrakten skal deles mellem dem — den er sprogneutral og indeholder skema,
indholdspakke, golden-filer og testvektorer. Det er R-003's bærende egenskab
gjort til mappestruktur: kontrakten ejes ikke af iOS-appen, den bruges bare af
den først.

`iOS/Packages/BHKit` er én lokal Swift Package med seks targets frem for seks
pakker eller ét app-target (R-002). Kildefiler tilføjes i SPM-targets, ikke i
app-targetet, så `project.pbxproj` ikke bliver en flettekonflikt-magnet i et
branch-per-feature-flow.

## Complexity Tracking

> Udfyldes kun, når Constitution Check har afvigelser, der skal begrundes.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| **Princip IV: pausefunktion for publiceret indhold er ikke implementeret** | Forfatningen gør øjeblikkelig pause til en P0-kapabilitet for indhold i drift. Feature 001 distribuerer ikke offentligt indhold — pakken er bundlet i en udviklingsbygning med foreløbige koordinater og er eksplicit ikke publiceringsklar (spec.md, Assumptions) | At bygge den nu ville kræve en server, altså hele den backend feature 001 bevidst udelader. Uden server ville pausefunktionen være en lokal boolean, der ikke kan aktiveres udefra — sikkerhedsteater. Kravet flyttes til det increment, der forbereder ekstern distribution |
| **Princip IV/drift: "Meld fejl" direkte fra opgaven er ikke implementeret** | Samme begrundelse. Uden backend har en fejlmelding ingen modtager. Feltdata opsamles i 001 gennem den lokale hændelseslog, som kan eksporteres | En fejlmeldingsknap uden afsendelseskanal giver spilleren indtryk af, at nogen lytter. Det er værre end ingen knap |

Begge afvigelser **skal være på plads før nogen form for ekstern distribution** —
ikke før felttest med kendte testpersoner. De er også registreret i
`checklists/requirements.md`.
