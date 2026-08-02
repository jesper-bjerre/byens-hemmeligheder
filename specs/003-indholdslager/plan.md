# Implementeringsplan: relationel skrivekilde og statisk læsemodel

**Branch**: `main` | **Dato**: 2026-08-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature 003 og den reviderede [research](./research.md).

## Summary

Den redaktionelle kilde flyttes fra én samlet JSON-blob til Azure SQL. Hver
opgave er et selvstændigt aggregate med stabile oversigtsfelter som kolonner og
den skiftende kontrakt som JSON. En transaktionel outbox genererer fortsat en
statisk `content-pack.json` i Blob Storage, så spillerlæsninger ikke belaster
databasen, og den eksisterende spillerkontrakt bevares.

Planen er et designgrundlag. Implementering og produktionsmigration kræver
accept af researchen og en særskilt beslutning om rækkefølgen i forhold til
login og adgangskontrol.

## Technical Context

**Language/Version**: C# / .NET 10, Swift/SwiftUI til iOS-admin og TypeScript /
Angular 22 til webadmin

**Primary Dependencies**: ASP.NET Core, FastEndpoints, EF Core 10 SQL Server,
Microsoft.Data.SqlClient, Azure.Storage.Blobs og Azure.Identity

**Storage**: Azure SQL Database Basic til redaktionelle data; Azure Blob
Storage til genererede pakker og media; filsystem og SQL-container i tests

**Testing**: xUnit v3, FastEndpoints.Testing, Testcontainers for SQL Server,
Swift Testing og Vitest

**Target Platform**: Linux App Service B1 i West Europe, iOS 18+ og moderne
browsere

**Project Type**: Modulær monolit med API, to admin-klienter og statisk
læsemodel til tre spillerklienter

**Performance Goals**: Quizmasterliste under 500 ms ved varm database;
opgavegemning under 2 sekunder uden medieupload; spillerpakken må aldrig kræve
et SQL-kald

De nuværende binære uploadruter for billeder og fortællinger bevares. I
implementeringen får de workspace-kontekst og samme ejerskabsgrænse som
mediemetadataene; deres eksisterende komprimerings- og konverteringsansvar
ændres ikke af lagerdesignet.

**Constraints**: Cirka 99 % spillerlæsninger; få samtidige skribenter; ingen
hemmeligheder i repoet; offentlig spillerkontrakt og URL skal forblive
bagudkompatibel; en opgave skal kunne pauses inden for minutter

**Scale/Scope**: 11 opgaver nu; designmål 10.000 opgaver, 100 workspaces og 100
samtidige quizmaster-sessioner uden arkitekturændring; media holdes udenfor SQL

## Constitution Check

*Gate før research og genkontrolleret efter design.*

| Princip/ramme | Resultat | Hvordan designet overholder det |
|---|---|---|
| I. Stedet er spillet | Bestået | Mission og lokation migreres som ét redaktionelt aggregate; koordinat og sikkerhedsdata mistes ikke. |
| II. Entydigt facit | Bestået | Hele svarreglen versionsstyres sammen med missionen og publiceres deterministisk. |
| III. Mennesker udgiver | Bestået | Kun godkendte statustyper kommer i læsemodellen; publicering er en synlig serverhandling. |
| IV. Sikkerhed og rettigheder | Bestået for designfasen | Pause fjerner opgaven gennem samme publiceringsvej, og mediemetadata bevares. Login er eksplicit uden for denne research; det nuværende anonyme API udvides ikke af dokumentændringen. |
| V. Serverbåret og versionsfastholdt | Bestået | Pakkehash bliver `contentVersion`; gamle pakker kan bevares efter version, så sessioner kan fastholde indhold. |
| VI. Dataminimering | Bestået | Workspace er organisationsdata. Der tilføjes ingen bruger-, e-mail- eller GPS-historik. Audit bruger fortsat vist quizmasternavn indtil identitetsfeaturen. |
| VII. Familieoplevelsen | Bestået | Ingen ændring af spillerens flow eller pointregler. |
| Modulær monolit | Bestået | SQL-modul, publisher og API bliver i samme backend; ingen ny microservice. |
| Relationel primær database | Bestået | Azure SQL bliver kilden; JSON bruges som dokumentkolonne, eksport og læsemodel, ikke som løs primærfil. |
| API-first/OpenAPI | Bestået | Admin-kontrakten beskrives i [contracts/content-authoring-api.yaml](./contracts/content-authoring-api.yaml). |
| Lavt pilotbudget | Bestået | Basic-niveauet er omtrent 4,90 USD/måned ved prisopslaget; budgetalarm er et driftskrav. |

Efter Phase 1 er der ingen ny forfatningsafvigelse. Den eksisterende udskydelse
af login/adgangskontrol består, men lagerdesignet gør den ikke større og må ikke
produktionsaktiveres for partnerdata uden et særskilt sikkerhedsreview.

## Project Structure

```text
backend/
├── src/ByensGaader.Api/
│   ├── Features/Content/        # endpoints og publiceringsorkestrering
│   ├── Persistence/             # DbContext, entiteter og migrations
│   └── Storage/                 # blob-læsemodel og media
└── tests/ByensGaader.Api.Tests/
    ├── Persistence/             # SQL-container og repositorytests
    ├── Publishing/              # determinisme, outbox og fejlgenoptagelse
    └── Features/Content/        # HTTP-kontrakttests

iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/
├── PackClient.swift             # skiftes til opgave-endpoints
└── PackDocument.swift           # reduceres til opgaveaggregate

webApps/webadmin/src/app/
├── core/content-api.service.ts  # liste/hent/gem pr. opgave
└── mission-editor/              # editoren beholder kontraktfelterne

contracts/
└── content/                     # eksport af den redaktionelle kilde som fixtures

specs/003-indholdslager/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/content-authoring-api.yaml
```

**Structure Decision**: Der tilføjes et persistence-modul i den eksisterende
backend. Klienterne og den offentlige kontrakt forbliver i deres nuværende
projekter. Ingen ny deploybar tjeneste oprettes.

## Leverancefaser

### Fase A — beslutning og spike

1. Accepter eller afvis researchens Azure SQL-anbefaling.
2. Erstat eller afvis ADR 0007 og skriv den accepterede hybridarkitektur i en
   ny ADR.
3. Bevis EF Core 10-mapping af rå JSON, `rowversion`, managed identity og Basic-
   niveauets funktioner i en isoleret testdatabase.

### Fase B — skrivekilde

1. Tilføj DbContext, migrations og repositories bag domænegrænseflader.
2. Implementér workspace, mission, media, source, audit og outbox.
3. Implementér opgave-endpoints samt særskilte endpoints med ETag til delte
   medie- og kildemetadata.

### Fase C — publicering

1. Generér pakken deterministisk fra en konsistent SQL-læsning.
2. Serialisér med blob-lease og afled version/ETag af indholdshash.
3. Kør straks efter gemning og genoptag fejl fra outboxen.
4. Bevar den eksisterende `GET /content/{locale}/pack` uændret.

### Fase D — migration og klienter

1. Importér den eksisterende blob til standard-workspace og sammenlign den
   genererede pakke semantisk med kilden.
2. Skift webadmin og iOS-admin til opgavevise kald.
3. Eksportér SQL-kilden som repo-fixtures gennem `pull-content.sh`.
4. Bevar rollback til den gamle blobskrivning, indtil en fuld intern test er
   gennemført.

## Complexity Tracking

Ingen afvigelser. Hybridlagringen er mere kompleks end én blob, men den følger
forfatningens relationelle ramme og er nødvendig for partnergrænse,
opgavesamtidighed og sikker publicering. Blobben forbliver en afledt læsemodel,
ikke en ekstra kilde.
