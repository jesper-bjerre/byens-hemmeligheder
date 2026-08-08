# Tasks: Authentication og roller

**Input**: Design documents from `specs/004-authentication-og-roller/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md),
[research.md](./research.md), [data-model.md](./data-model.md),
[contracts/auth-api.yaml](./contracts/auth-api.yaml)

**Tests**: Sikkerhedslogik udvikles test-first. Negative tests er en del af
featurekravene og ikke valgfri.

## Phase 1: Setup

**Purpose**: Sikker konfiguration og projektstruktur uden hemmeligheder.

- [x] T001 Verificer at `.gitignore` dækker `.p8`, miljøfiler, lokale appsettings og credentials i `.gitignore`
- [x] T002 Tilføj disabled-by-default authenticationkonfiguration og validering i `backend/src/ByensGaader.Api/Features/Authentication/AuthenticationOptions.cs` og `backend/src/ByensGaader.Api/appsettings.json`
- [x] T003 Tilføj authentication- og account-mapper til backendprojektet i `backend/src/ByensGaader.Api/Features/Authentication/` og `backend/src/ByensGaader.Api/Features/Accounts/`
- [x] T004 [P] Tilføj fælles Swift-target `BHAuthenticationKit` i `iOS/Packages/BHKit/Package.swift`
- [ ] T005 [P] Opret Angular auth-struktur i `webApps/webadmin/src/app/auth/` og `webApps/byensgaaderweb/src/app/auth/`

---

## Phase 2: Foundational

**Purpose**: Konto-, session- og authorizationfundament, der blokerer alle
brugerhistorier.

- [x] T006 Skriv domænetests for roller, kontotilstand, tokenhash og sessionrotation i `backend/tests/ByensGaader.Api.Tests/AuthenticationDomainTests.cs`
- [x] T007 Implementer Account, ExternalIdentity, Session og OneTimeGrant i `backend/src/ByensGaader.Api/Features/Authentication/AuthenticationModels.cs`
- [x] T008 Skriv repository-kontrakttests for unik Apple-identitet, betinget bootstrap og atomisk refreshrotation i `backend/tests/ByensGaader.Api.Tests/AuthenticationRepositoryContractTests.cs`
- [x] T009 Implementer `IAuthenticationRepository` og isoleret in-memory-version i `backend/src/ByensGaader.Api/Features/Authentication/AuthenticationRepository.cs`
- [x] T010 Implementer Azure Table Storage-repository med managed identity i `backend/src/ByensGaader.Api/Features/Authentication/TableAuthenticationRepository.cs`
- [x] T011 Implementer opaque tokenformat, hashing og konstanttidssammenligning i `backend/src/ByensGaader.Api/Security/OpaqueTokenService.cs`
- [x] T012 Skriv HTTP-tests for manglende, ugyldig, udløbet, blokeret og degraderet session i `backend/tests/ByensGaader.Api.Tests/AuthenticationHandlerTests.cs`
- [x] T013 Implementer bearer authentication-handler med aktuelt konto-/rollelookup i `backend/src/ByensGaader.Api/Security/OpaqueBearerHandler.cs`
- [x] T014 Registrer schemes, policies, storage og korrekt middlewareorden i `backend/src/ByensGaader.Api/Program.cs`
- [x] T015 Dokumenter `User`, `DesignerOrAdmin` og `AdminOnly` i genereret OpenAPI fra `backend/src/ByensGaader.Api/Program.cs`

**Checkpoint**: API'et kan validere egne test-sessioner og fejler lukket, når
authentication er slået til uden komplet konfiguration.

---

## Phase 3: User Story 1 - Beskyt redaktionelt indhold (Priority: P1) 🎯 MVP

**Goal**: Luk det anonyme authoring-API og auditér den verificerede konto.

**Independent Test**: Alle authoring-endpoints giver 401/403/2xx for henholdsvis
gæst, User og Designer/Admin uden ændring ved afvisning.

- [x] T016 [US1] Udvid endpointmatricetests for alle authoring-ruter og roller i `backend/tests/ByensGaader.Api.Tests/AuthorizationTests.cs`
- [x] T017 [US1] Kræv `DesignerOrAdmin` på mission-, media-, source-, narration-, audit- og legacy pack-endpoints i `backend/src/ByensGaader.Api/Features/Content/`
- [x] T018 [US1] Erstat `X-Quizmaster` med verificeret konto i `backend/src/ByensGaader.Api/Features/Content/AuditTrail.cs` og kaldende endpoints
- [x] T019 [US1] Tilføj beskyttet previewpakke for `fieldTestReady` + `published` i `backend/src/ByensGaader.Api/Features/Content/GetPreviewPackEndpoint.cs`
- [x] T020 [US1] Bevis at offentlig pakke aldrig indeholder draft/fieldTestReady i `backend/tests/ByensGaader.Api.Tests/PublishedPackBuilderTests.cs`

**Checkpoint**: Det åbne skrivehul er lukket server-side.

---

## Phase 4: User Story 2 - Spil som gæst eller Apple-bruger (Priority: P1)

**Goal**: Gyldigt Apple-login giver en intern konto/session, mens gæstespil
forbliver uændret.

**Independent Test**: Apple-validatoren afviser alle negative tokenvarianter,
opretter én konto ved samtidighed og udsteder en roterbar native session.

- [x] T021 [P] [US2] Skriv Apple JWT-tests for signatur, issuer, audience, exp, nonce og nøglerotation i `backend/tests/ByensGaader.Api.Tests/AppleIdentityValidatorTests.cs`
- [x] T022 [P] [US2] Skriv Apple authorization-code-klienttests med simuleret Apple HTTP-server i `backend/tests/ByensGaader.Api.Tests/AppleTokenClientTests.cs`
- [x] T023 [US2] Implementer Apple JWKS-cache og identity-tokenvalidering i `backend/src/ByensGaader.Api/Features/Authentication/AppleIdentityValidator.cs`
- [x] T024 [US2] Implementer ES256 client-secret og authorization-code-veksling i `backend/src/ByensGaader.Api/Features/Authentication/AppleTokenClient.cs`
- [x] T025 [US2] Implementer atomisk konto-/identity-oprettelse og første-Admin-bootstrap i `backend/src/ByensGaader.Api/Features/Authentication/AccountService.cs`
- [x] T026 [US2] Implementer native exchange, refresh, logout og `/me` i `backend/src/ByensGaader.Api/Features/Authentication/AuthenticationEndpoints.cs`
- [x] T027 [US2] Tilføj concurrency- og replay-integrationstests i `backend/tests/ByensGaader.Api.Tests/AuthenticationEndpointTests.cs`
- [x] T028 [P] [US2] Implementer session- og Keychain-lag i `iOS/Packages/BHKit/Sources/BHAuthenticationKit/`
- [x] T029 [P] [US2] Test Keychain, refresh og logout i `iOS/Packages/BHKit/Tests/BHAuthenticationKitTests/`
- [x] T030 [US2] Tilføj valgfrit Log ind med Apple, profil og kontosletning i `iOS/App/Authentication/`
- [ ] T031 [US2] Tilføj spillerweb-login uden permanent tokenlager i `webApps/byensgaaderweb/src/app/auth/`

**Checkpoint**: Spilleren kan være gæst eller autentificeret User.

---

## Phase 5: User Story 3 - Log ind i admin-apps (Priority: P1)

**Goal**: Begge admin-apps kræver Apple-login og bearer-token.

**Independent Test**: Gæst/User ser ingen authoringdata; Designer/Admin kan
læse og gemme i både iOS-admin og web-admin.

- [x] T032 [P] [US3] Tilføj Sign in with Apple capability og loginstate i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/Authentication/`
- [x] T033 [US3] Send bearer-token og håndter 401/403 uden tab af kladde i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/APIClient.swift`
- [x] T034 [P] [US3] Implementer web exchange med state og nonce i `backend/src/ByensGaader.Api/Features/Authentication/AuthenticationEndpoints.cs`
- [x] T035 [US3] Implementer in-memory sessionservice, popup-callback og adgangsgate i `webApps/webadmin/src/app/auth/`
- [x] T036 [US3] Send bearer-token og håndter sessionudløb i `webApps/webadmin/src/app/auth/auth.interceptor.ts`
- [x] T037 [P] [US3] Tilføj negative login- og adgangstests i `webApps/webadmin/src/app/auth/`
- [x] T038 [P] [US3] Tilføj iOS-admin authenticationtests i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdminTests/AuthenticationTests.swift`

**Checkpoint**: Backendens authoringbeskyttelse kan aktiveres uden at låse
Designers/Admin ude.

---

## Phase 6: User Story 4 - Administrer Designers (Priority: P2)

**Goal**: Admin vedligeholder Designer-listen; ingen kan tildele Admin i UI.

**Independent Test**: Admin kan skifte User ↔ Designer med audit; Designer får
403 og sidste Admin beskyttes.

- [x] T039 [P] [US4] Skriv rolle- og sidste-Admin-tests i `backend/tests/ByensGaader.Api.Tests/AccountAdministrationTests.cs`
- [x] T040 [US4] Implementer kontosøgning og User/Designer-rolleskift i `backend/src/ByensGaader.Api/Features/Accounts/AccountAdministrationEndpoints.cs`
- [x] T041 [US4] Implementer rolleændringsaudit i `backend/src/ByensGaader.Api/Features/Accounts/AccountAuditTrail.cs`
- [x] T042 [US4] Implementer Admin-brugerside med søgning og bekræftelse i `webApps/webadmin/src/app/users/`
- [x] T043 [P] [US4] Test rolle-UI og 403-forløb i `webApps/webadmin/src/app/users/`

---

## Phase 7: User Story 5 - Afslut og slet en konto (Priority: P2)

**Goal**: Logout og sletning tilbagekalder data og sessions korrekt.

**Independent Test**: To sessions tilbagekaldes ved sletning; User anonymiseres,
mens Designer/Admin afvises indtil administrativ håndtering.

- [x] T044 [P] [US5] Skriv logout-, blokering-, revocation- og sletningstests i `backend/tests/ByensGaader.Api.Tests/AccountLifecycleTests.cs`
- [x] T045 [US5] Implementer kontoanonymisering og global sessionrevocation i `backend/src/ByensGaader.Api/Features/Accounts/AccountLifecycleService.cs`
- [x] T046 [US5] Implementer Apple server-to-server revocation endpoint i `backend/src/ByensGaader.Api/Features/Authentication/AppleNotificationEndpoint.cs`
- [ ] T047 [US5] Tilføj sletteflow og forklaring i spillerklienterne i `iOS/App/Authentication/` og `webApps/byensgaaderweb/src/app/auth/`

---

## Phase 8: Release og tværgående sikkerhed

**Purpose**: Aktivér kun efter governance, ekstern Apple-konfiguration og
menneskelig releasegodkendelse.

- [x] T048 Få eksplicit godkendelse og gennemfør forfatningsændring for Apple-subject, sessioner, formål, behandlingsgrundlag og slettefrister i `.specify/memory/constitution.md`
- [x] T049 Dokumenter arkitekturvalget og dets pris i `docs/ADR/0010-direkte-apple-login-og-egne-sessioner.md`
- [ ] T050 [P] Tilføj sikre placeholder-indstillinger og managed-identity/Table-RBAC i `infra/` og `.github/workflows/` uden hemmeligheder eller konkrete persondata
- [ ] T051 [P] Slå HTTPS-only til gennem godkendt Azure-konfiguration og dokumentér kontrollen i `docs/drift/udrulning.md`
- [x] T052 [P] Slå `BH_DEV_TOOLS` fra i Release i `iOS/ByensHemmeligheder.xcodeproj/project.pbxproj`
- [ ] T053 Kør hele [quickstart.md](./quickstart.md), secret-scan, dependency-scan og DEV API-end-to-end-tests
- [ ] T054 Konfigurer Apple App IDs, Services ID, grupper, return URLs og Key Vault/App Service-settings uden for repoet
- [ ] T055 Indhent menneskelig review og releasegodkendelse; aktivér først DEV og derefter PROD efter grøn gate

---

## Phase 9: Offentlige profilnavne og moderation

**Goal**: Gør version 1-highscore egnet til børn uden at udlevere tekniske
kontoidentifikatorer.

- [x] T056 [P] [US6] Skriv backendtests for normalisering, afviste navne, rate limit, skjult fallback, rapportering og Admin-only moderation i `backend/tests/ByensGaader.Api.Tests/ProfileNameTests.cs`
- [x] T057 [US6] Udvid Account og Table Storage-mapping med navnetidspunkt og moderationstilstand i `backend/src/ByensGaader.Api/Features/Authentication/`
- [x] T058 [US6] Implementer profilnavnsvalidator, eget profilendpoint og serverstyret rate limit i `backend/src/ByensGaader.Api/Features/Accounts/`
- [x] T059 [US6] Implementer navnerapporter med 90 dages retention og Admin-læsning i `backend/src/ByensGaader.Api/Features/Accounts/`
- [x] T060 [US6] Implementer Admin-endpoints til navneskjul og kontoblokering samt neutral highscore-fallback i `backend/src/ByensGaader.Api/Features/Accounts/` og `backend/src/ByensGaader.Api/Features/Scoring/`
- [x] T061 [P] [US6] Skriv Swift-tests for profilopdatering og rapportering i `iOS/Packages/BHKit/Tests/BHAuthenticationKitTests/`
- [x] T062 [US6] Implementer profilnavnsredigering i spillerprofilen og rapporthandling på highscore i `iOS/App/`
- [x] T063 [P] [US6] Udvid webadmin-tests for moderation og blokering i `webApps/webadmin/src/app/users/users-panel.spec.ts`
- [x] T064 [US6] Implementer rapportoversigt, navnemoderation og kontoblokering i `webApps/webadmin/src/app/users/users-panel.ts`
- [x] T065 [US6] Opdater OpenAPI, privacytekst, køreplan og release-status; kør samlet backend-, Swift-, Angular- og Release-buildvalidering

---

## Dependencies & Execution Order

```text
Setup → Foundational → US1
                    ├→ US2 → US3
                    └→ US4
US2 → US5
US1 + US2 + US3 + US4 + US5 → Releasegate
```

- US1 er det første sikkerheds-MVP, men aktiveres sammen med US3, så admin ikke
  låses ude.
- US2 kan udvikles parallelt med US1 efter fundamentet.
- US4 og US5 er uafhængige efter konto-/sessionfundamentet.
- T048 og T055 er menneskelige gates. Ingen teknisk succes kan omgå dem.

## Parallel Opportunities

- T004 og T005 kan forberede klientstrukturen, mens backendfundamentet bygges.
- T021 og T022 tester hver sin Apple-grænseflade.
- T028/T029 og T031 ligger i forskellige klienter.
- T032/T038 og T034/T035 ligger i native og web.

## Implementation Strategy

1. Byg og test fail-closed backendfundament.
2. Luk authoring server-side og gør begge admin-klienter klar i samme release.
3. Tilføj valgfrit spillerlogin uden at ændre gæsteflowet.
4. Tilføj Admin-brugeradministration og kontosletning.
5. Gennemfør governance-/Apple-/Azure-gates, test i DEV og få menneskelig
   godkendelse før PROD.

**Task count**: 65. Alle tasks følger checkbox + id + eventuel `[P]` +
user-story-label + konkret filsti.
