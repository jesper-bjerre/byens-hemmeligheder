# Implementation Plan: Authentication og roller

**Branch**: `main` | **Date**: 6. august 2026 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/004-authentication-og-roller/spec.md`

## Summary

Authentication bygges direkte mod Log ind med Apple. API'et validerer Apples
engangslegitimation og identitet, udsteder egne korte opaque sessions og slår
kontoens aktuelle rolle op på hver beskyttet request. Konto-, identitets- og
sessionsrækker gemmes billigt i Azure Table Storage i hvert miljøs eksisterende
Storage Account. Offentlig spillerlæsning forbliver anonym; alt authoring
kræver Designer eller Admin, og kun Admin kan vedligeholde Designers.

Leverancen opdeles i korte, testbare snit: fail-closed backendfundament,
Apple-login og sessions-API, admin-klienterne, spillerlogin og til sidst
brugeradministration. Ingen aktivitet afhænger af partner- eller
quizmasterkommunikation.

## Technical Context

**Language/Version**: C#/.NET 10, Swift 6/SwiftUI, TypeScript/Angular 20

**Primary Dependencies**: ASP.NET Core authentication/authorization,
FastEndpoints 5.35, Azure.Data.Tables 12.10, Azure.Identity 1.13,
AuthenticationServices, Angular signals og HttpClient

**Storage**: Azure Table Storage til konti, eksterne identiteter,
engangsbeviser og sessions; eksisterende Blob Storage til indhold og media;
Keychain til native refresh-token; kun hukommelse til web access-token

**Testing**: xUnit v3 + FastEndpoints.Testing, Swift Testing/XCTest, Angular
Vitest samt end-to-end API-smoke i DEV

**Target Platform**: Azure App Service, iOS/iPadOS 18+, Azure Static Web Apps

**Project Type**: Modulær monolit med API, to iOS-apps og to Angular-apps

**Performance Goals**: Login under 3 sekunder eksklusive Apples UI; beskyttede
API-kald under 300 ms p95; rolleændring synlig på næste request

**Constraints**: Offentlig repo uden hemmeligheder; lav pilotpris; ingen
langlivet webtoken; fail closed ved lager- eller authkonfigurationsfejl;
eksisterende gæstespil må ikke kræve login

**Scale/Scope**: Pilot til under 50.000 konti, få samtidige Designers og langt
flere anonyme indholdslæsninger end login- eller skrivekald

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Regel | Før design | Efter design |
|---|---|---|
| I–II Sted og facit | Bestået; featuret ændrer ikke opgaveindhold | Bestået |
| III Mennesker udgiver | Bestået for kode og test; PROD-release kræver menneskelig review | Bestået med releasegate |
| IV Serverstyret adgang | Bestået; serveren bliver eneste autoritet | Bestået |
| V Serverbåret afvikling | Bestået; offentlig pakke bevares | Bestået |
| VI Privatliv og identitet | Blokerede oprindeligt: e-mail + engangskode dækkede ikke Apple-subject/session | **Bestået 2026-08-06**; forfatning 4.0.0 godkender den dataminimerede identitets- og sessionsmodel med slettefrister |
| VII Familieoplevelse | Bestået; gæstespil bevares | Bestået |
| API-first/OpenAPI | Bestået; nye endpoints beskrives i kontrakten | Bestået |
| Lavt budget | Bestået; eksisterende Storage Accounts genbruges | Bestået |

Forfatningsgaten blev godkendt af product owner den 6. august 2026 og gennemført
i forfatning 4.0.0. Authentication må implementeres og aktiveres i DEV. PROD
kræver fortsat menneskelig kode-/releasegodkendelse samt review af den konkrete
privatlivstekst og interesseafvejning; det følger princip III og VI og er ikke
en partner- eller quizmasterafhængighed.

## Project Structure

### Documentation (this feature)

```text
specs/004-authentication-og-roller/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── auth-api.yaml
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
backend/src/ByensGaader.Api/
├── Features/Authentication/
├── Features/Accounts/
├── Features/Content/
├── Security/
└── Program.cs

backend/tests/ByensGaader.Api.Tests/
├── AuthenticationTests.cs
├── AuthorizationTests.cs
├── AccountAdministrationTests.cs
└── TestAuthentication.cs

iOS/Packages/BHKit/Sources/BHAuthenticationKit/
iOS/Packages/BHKit/Tests/BHAuthenticationKitTests/
iOS/App/Authentication/

iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/Authentication/

webApps/byensgaaderweb/src/app/auth/
webApps/webadmin/src/app/auth/
webApps/webadmin/src/app/users/
```

**Structure Decision**: Authentication bliver et modul i den eksisterende
modulære monolit. En fælles Swift-package target bærer native sessionlogik;
hver app ejer sit UI. Angular-apps deler wire-kontrakten semantisk, men får ikke
et nyt publiceret npm-package i version 1.

## Complexity Tracking

Ingen fravigelser kan godkendes endnu. Den identificerede konflikt med princip
VI er en aktiveringsblokering og kræver en særskilt forfatningsændring.
