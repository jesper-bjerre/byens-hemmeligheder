# Quickstart: validering af det nye indholdslager

Denne guide beskriver de scenarier, implementationen skal kunne bevise. Den er
ikke en udrulningsvej og indeholder ingen credentials.

## Forudsætninger

- .NET 10 fra repoets normale opsætning
- Docker til den SQL Server-container, integrationstestene starter
- Xcode valgt gennem `DEVELOPER_DIR`
- Node-versionen fra `webApps/webadmin/package.json`

Testcontainers opretter en isoleret SQL-database med tilfældige lokale
credentials. Der skal ikke oprettes en `.env`-fil eller skrives en adgangskode
i repoet.

## 1. Datalag og HTTP-kontrakter

```bash
cd backend
dotnet test --configuration Release
```

Forventet:

- migrationer kan anvendes på en tom SQL Server;
- opret og ret kræver henholdsvis `If-None-Match` og `If-Match`;
- to rettelser til forskellige opgaver lykkes uafhængigt;
- anden rettelse til samme revision får `412`;
- listekaldet læser oversigtsfelter uden at hente alle JSON-dokumenter;
- delte medie- og kildemetadata har selvstændige ETags og kan ikke slettes,
  mens en mission refererer til dem;
- ingen spillerendpoint åbner en SQL-forbindelse.

## 2. Publicering og fejlgenoptagelse

Integrationstesten gemmer en opgave i SQL og bruger en midlertidig blob-fixture.
Den skal bevise:

1. Kun publicerbare statusser ender i pakken.
2. Et skift til pause fjerner opgaven ved næste publicering.
3. Samme snapshot giver byte-identisk JSON, hash og `contentVersion`.
4. En simuleret blobfejl efter SQL-commit efterlader et pending job.
5. Et nyt forsøg publicerer ændringen præcis én gang.
6. To samtidige jobs kan ikke lade en ældre pakke vinde.

## 3. Migrationsprøve

Kør migrationsværktøjet mod en tom testdatabase med fixturen:

```bash
cd backend
dotnet run --project tools/ByensGaader.ContentMigration -- \
  import ../contracts/content/da-DK/content-pack.json --workspace byens-gaader --dry-run
```

Forventet rapport:

- 11 missioner og 11 lokationer;
- 31 mediebeskrivelser og 6 kilder;
- ingen uafklarede referencer;
- genereret pakke er semantisk identisk med fixturen;
- `--dry-run` skriver hverken SQL eller blob.

## 4. Admin-klienter

```bash
cd webApps/webadmin
npm run check

cd ../..
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild test \
  -project iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin.xcodeproj \
  -scheme ByensGaaderAdmin \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:ByensGaaderAdminTests
```

Begge klienter skal kunne liste opgaver, hente én editor, gemme med ETag og
forklare forskellen mellem “gemt” og “publicering afventer”.

## 5. Kompatibilitet med spillerne

Kør BHKit-kontrakttestene og webspillerens test mod den genererede pakke. Ingen
spillerkode må kræve et nyt felt eller en ny URL for at bestå.

## 6. Azure-spike før ressourceoprettelse

Før den rigtige database oprettes, skal et kort spike bekræfte:

- Azure SQL Basic findes i West Europe med 2 GB og den forventede pris;
- App Servicens managed identity kan forbinde uden password;
- firewall tillader kun de nødvendige udvikler- og App Service-veje;
- EF-migration kører som deployment-step;
- budgetalarm er oprettet;
- en testdatabase kan slettes uden at røre den nuværende DEV-storage.
