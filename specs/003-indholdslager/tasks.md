# Opgaver: opgaveblobs og statisk læsemodel

## Fase 1 — Setup

- [X] T001 Tilføj ignoreret lokal authoring-mappe og lagerkonfiguration i `.gitignore` og `backend/src/ByensGaader.Api/appsettings.json`
- [X] T002 Udvid storage-abstraktionen med separate public/authoring-lagre og advisory leases i `backend/src/ByensGaader.Api/Storage/`
- [X] T003 Opdatér testværterne med isoleret authoring-lager i `backend/tests/ByensGaader.Api.Tests/HealthEndpointTests.cs`

## Fase 2 — Fundament

- [X] T004 [P] Tilføj JSON-aggregate-, indeks- og publication-state-modeller i `backend/src/ByensGaader.Api/Features/Content/AuthoringModels.cs`
- [X] T005 [P] Tilføj deterministisk JSON-kanonisering og pakkegenerator-tests i `backend/tests/ByensGaader.Api.Tests/PublishedPackBuilderTests.cs`
- [X] T006 Implementér validering, kanonisering og pakkegenerator i `backend/src/ByensGaader.Api/Features/Content/PublishedPackBuilder.cs`
- [X] T007 Tilføj bootstrap/split-tests for eksisterende pakke i `backend/tests/ByensGaader.Api.Tests/AuthoringRepositoryTests.cs`
- [X] T008 Implementér authoring-repository og idempotent bootstrap i `backend/src/ByensGaader.Api/Features/Content/AuthoringRepository.cs`

## Fase 3 — User Story 1: opgavevis redigering

**Mål:** En quizmaster kan liste, hente, oprette, rette og slette én opgave med dens egen ETag.

**Uafhængig test:** To forskellige opgaver kan gemmes fra samme udgangspunkt; en forældet ETag på samme opgave giver 412.

- [X] T009 [P] [US1] Tilføj HTTP-kontrakttests for mission-list/get/put/delete i `backend/tests/ByensGaader.Api.Tests/MissionAuthoringEndpointTests.cs`
- [X] T010 [P] [US1] Tilføj HTTP-kontrakttests for medie- og kildemetadata i `backend/tests/ByensGaader.Api.Tests/CatalogAuthoringEndpointTests.cs`
- [X] T011 [US1] Implementér mission-endpoints i `backend/src/ByensGaader.Api/Features/Content/MissionAuthoringEndpoints.cs`
- [X] T012 [US1] Implementér media/source-metadataendpoints og referencetjek i `backend/src/ByensGaader.Api/Features/Content/CatalogAuthoringEndpoints.cs`
- [X] T013 [US1] Flyt audit til authoring-lageret og bevar læseendpointet i `backend/src/ByensGaader.Api/Features/Content/AuditTrail.cs`

## Fase 4 — User Story 2: sikker og genoptagelig publicering

**Mål:** En gemning publicerer deterministisk, og en afbrudt publicering kan genoptages uden en halv offentlig pakke.

**Uafhængig test:** Fejl efter kildeskrivning efterlader dirty state; et nyt forsøg publicerer samme contentVersion og renser state.

- [X] T014 [P] [US2] Tilføj lease-, dirty-state- og recoverytests i `backend/tests/ByensGaader.Api.Tests/ContentPublisherTests.cs`
- [X] T015 [US2] Implementér publication coordinator med lease, versionspakke og stable latest i `backend/src/ByensGaader.Api/Features/Content/ContentPublisher.cs`
- [X] T016 [US2] Implementér minutvis reconciliation i `backend/src/ByensGaader.Api/Features/Content/PublicationReconciler.cs`
- [X] T017 [US2] Registrér authoring/publisher/reconciler og eksponér publication-header i `backend/src/ByensGaader.Api/Program.cs`
- [X] T018 [US2] Bevar legacy pack-PUT som sikker overgang til ældre TestFlight-admin i `backend/src/ByensGaader.Api/Features/Content/PutPackEndpoint.cs`

## Fase 5 — User Story 3: webadmin redigerer én opgave

**Mål:** Webadmin indlæser authoring-data og gemmer kun ændrede objekter med deres ETags.

**Uafhængig test:** En ændret mission udløser ét mission-PUT og viser published/pending; kladder gendannes stadig lokalt.

- [X] T019 [P] [US3] Udvid webmodellernes revisionsmetadata i `webApps/webadmin/src/app/core/models.ts`
- [X] T020 [P] [US3] Tilføj klienttests for opgavevise endpoints i `webApps/webadmin/src/app/core/content-api.service.spec.ts`
- [X] T021 [US3] Implementér authoring-list/get/put/delete i `webApps/webadmin/src/app/core/content-api.service.ts`
- [X] T022 [US3] Refaktorér web-store til objektvise diffs, ETags og publication-status i `webApps/webadmin/src/app/core/content-store.service.ts`
- [X] T023 [US3] Tilpas editorens gem/slet-flow og statusvisning i `webApps/webadmin/src/app/app.ts` og `webApps/webadmin/src/app/app.html`

## Fase 6 — User Story 4: iOS-admin redigerer én opgave

**Mål:** iOS-admin indlæser authoring-data og gemmer kun den berørte opgave med dens ETag.

**Uafhængig test:** En opgave kan rettes uden at sende hele pakken, og 412 kræver kun genhentning/fletning af samme opgave.

- [X] T024 [P] [US4] Tilføj revisionsmetadata og aggregate-tests i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdminTests/PackDocumentTests.swift`
- [X] T025 [US4] Implementér authoring-list/get/put/delete i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/PackClient.swift`
- [X] T026 [US4] Refaktorér dokumentets revisionssporing og opgavevise serialisering i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/PackDocument.swift`
- [X] T027 [US4] Tilpas forside, editor-save, sletning og kladder i `iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/ContentView.swift` og `DraftStore.swift`

## Fase 7 — Migration, drift og færdiggørelse

- [X] T028 [P] Tilføj sikkert split/pull-værktøj og dry-run i `backend/pull-content.sh` og `backend/seed-content.sh`
- [X] T029 [P] Opdatér backendens driftsdokumentation og konfiguration i `backend/README.md` og `docs/drift/udrulning.md`
- [X] T030 Kør backend-, webadmin- og iOS-admin-tests fra `specs/003-indholdslager/quickstart.md`
- [X] T031 Kontrollér Spec Kit-artefakter mod implementationen og markér alle opgaver færdige i `specs/003-indholdslager/tasks.md`

## Afhængigheder

```text
Setup → Fundament → US1 → US2 → US3 og US4 → Migration/drift → samlet validering
```

US3 og US4 kan implementeres uafhængigt efter US2. Tests mærket `[P]` berører
andre filer, men udføres fortsat før den kode, de specificerer.

## Implementeringsstrategi

Backendens opgavevise kilde og publicering er MVP. Legacy `PUT /content/{locale}/pack`
bevares under overgangen, så den allerede installerede TestFlight-admin ikke
stopper med at kunne gemme, før en ny build er distribueret. Ingen Azure-migration
eller produktionsudrulning udføres automatisk af implementationen.
