# Implementeringsplan: opgaveblobs og statisk læsemodel

**Branch**: `main` | **Dato**: 2026-08-03 | **Spec**: [spec.md](./spec.md)

## Summary

Den redaktionelle kilde opdeles fra én samlet JSON-blob til én privat blob pr.
opgave. Medie- og kildemetadata får tilsvarende egne blobs. En kort lease
serialiserer gemning og generering af admin-indeks og offentlig
`content-pack.json`. ETag pr. blob giver optimistisk samtidighed pr. objekt.

Azure SQL indføres ikke. Planen er et designgrundlag og kræver accept af den
reviderede research og ADR 0007 før implementering.

## Technical Context

**Language/Version**: C# / .NET 10, Swift/SwiftUI og TypeScript/Angular 22
**Primary Dependencies**: ASP.NET Core, FastEndpoints og Azure.Storage.Blobs
**Storage**: Eksisterende Azure Storage-konto; Azurite/filsystem i tests
**Testing**: xUnit v3, FastEndpoints.Testing, Swift Testing og Vitest
**Target Platform**: Linux App Service B1, iOS 18+ og moderne browsere
**Project Type**: Modulær monolit med to admin-klienter og statiske læsepakker
**Performance Goals**: P95 gem-og-publicér under 2 sekunder; leasekonflikt
under 1 %; spillerpakken kræver højst ét blobread
**Constraints**: Cirka 99 % reads, få skribenter, fælles indholdssamling,
bagudkompatibel spiller-URL og kontrakt
**Scale/Scope**: 11 opgaver nu; design og målinger valideres op til 500 opgaver
før SQL eller anden database genovervejes

De nuværende binære uploadruter for billeder og fortællinger bevares. Deres
komprimering, konvertering og offentlige mediestier ændres ikke.

## Constitution Check

| Princip/ramme | Resultat | Begrundelse |
|---|---|---|
| I. Stedet er spillet | Bestået | Mission og lokation gemmes atomisk som ét aggregate. |
| II. Entydigt facit | Bestået | Hele svarreglen versionsskiftes med opgaven. |
| III. Mennesker udgiver | Bestået | Kun accepterede statusser genereres til den offentlige pakke. |
| IV. Sikkerhed og rettigheder | Bestået for design | Pause udløser straks publicering; metadata om rettigheder har én kilde. Authentication er fortsat særskilt. |
| V. Serverbåret/versioneret | Bestået | Versionerede pakker og indholdshash fastholder sessionens indhold. |
| VI. Dataminimering | Bestået | Ingen bruger-, tenant- eller positionsdata tilføjes. |
| VII. Familieoplevelsen | Bestået | Spillerflow og pointregler ændres ikke. |
| Modulær monolit | Bestået | Ingen ny deploybar tjeneste. |
| API-first/OpenAPI | Bestået | Kontrakten ligger i `contracts/content-authoring-api.yaml`. |
| Lavt pilotbudget | Bestået | Eksisterende Storage-konto genbruges; ingen ny fast pris. |
| Relationel primær database | **Begrundet afvigelse** | Opgaveindholdet er et lille dokumentdomæne uden aktuelle relationelle krav. ADR 0007 skal eksplicit acceptere afvigelsen og SQL-tærsklerne. |

Implementering må ikke begynde, før ADR-afvigelsen er accepteret. Der er ingen
øvrige forfatningsafvigelser eller uafklarede tekniske spørgsmål.

## Project Structure

```text
backend/src/ByensGaader.Api/
├── Features/Content/       # endpoints og publiceringsorkestrering
└── Storage/
    ├── Authoring/          # opgave-, media-, source- og indeksblobs
    └── Publishing/         # lease, dirty-state og pakkegenerator

backend/tests/ByensGaader.Api.Tests/
├── Storage/                # ETags, blobstier og migration
└── Publishing/             # determinisme, lease og recovery

iOS-admin/                  # skiftes til opgavevise endpoints
webApps/webadmin/           # skiftes til opgavevise endpoints

specs/003-indholdslager/
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/content-authoring-api.yaml
```

## Leverancefaser

### Fase A — beslutning og storage-spike

1. Accepter eller afvis Blob-anbefalingen og tærsklerne for SQL.
2. Accepter en revideret ADR 0007 som eksplicit afvigelse fra de tekniske rammer.
3. Bevis ETag, lease, versioning og soft delete i en isoleret container.
4. Mål fuld pakkegenerering med 11, 100 og 500 syntetiske opgaver.

### Fase B — privat skrivekilde

1. Tilføj stikonventioner og repositories for mission, media og source.
2. Implementér liste/hent/gem/slet pr. objekt med betingede bloboperationer.
3. Generér privat admin-indeks fra kilden.
4. Bevar eksisterende append-only audit.

### Fase C — sikker publicering

1. Implementér locale-lease og dirty publication-state.
2. Generér kanonisk pakke og SHA-256-contentVersion.
3. Skriv versionspakke før stable latest-pakke.
4. Tilføj BackgroundService til opstarts- og minutvis reconciliation.
5. Log og mål varighed, konflikter og gentagne fejl uden indholdsdata.

### Fase D — migration og klienter

1. Split eksisterende pakke i en tom testcontainer og sammenlign output.
2. Bevar rollback, indtil en fuld intern test er gennemført.
3. Skift webadmin og iOS-admin til opgavevise kald.
4. Eksportér authoring-kilden som repo-fixture via `pull-content.sh`.

## SQL som senere eskalation

Planen indeholder ingen SQL-spike. En database undersøges først, hvis den
accepterede måling eller et nyt atomisk/query-behov udløser et kriterium i
[research.md](./research.md). Konti, roller, flere quizmastere eller flere byer
er ikke alene migrationskriterier.

## Complexity Tracking

Lease og reconciliation er ekstra logik, men de genbruger én eksisterende
tjeneste og matcher den lave skrivetrafik. Prisen er kort serialisering af
gemninger og fuld regenerering. Den pris måles eksplicit, så en senere
databasebeslutning kan bygge på driftstal frem for forventninger.
