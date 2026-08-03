# Quickstart: validering af det blobbaserede indholdslager

Guiden beskriver de scenarier, implementeringen skal bevise. Den er ikke en
udrulningsvej og indeholder ingen credentials.

## Forudsætninger

- .NET 10 fra repoets normale opsætning
- Azurite til isolerede storage-integrationstests
- Xcode valgt gennem `DEVELOPER_DIR`
- Node-versionen fra `webApps/webadmin/package.json`

Azurite-data ligger i testens midlertidige mappe og må ikke pege på den
eksisterende Azure-konto.

## 1. Datalag og HTTP-kontrakter

```bash
cd backend
dotnet test --configuration Release
```

Forventet:

- oprettelse kræver `If-None-Match: *`;
- rettelse og sletning kræver den aktuelle blob-ETag i `If-Match`;
- to rettelser til forskellige opgaver lykkes uafhængigt;
- anden rettelse til samme revision får `412`;
- kladder findes i authoring, men aldrig i publiceret pakke;
- medie og kilde kan ikke slettes, mens en mission refererer til dem;
- admin-listen bruger det private indeks, men GET returnerer blobens aktuelle
  ETag.

## 2. Lease, publicering og genoptagelse

Testene skal bevise:

1. Alle authoring-skrivninger respekterer locale-leasen.
2. Samme kildesnapshot giver byte-identisk JSON, hash og `contentVersion`.
3. Versionspakken skrives før den stabile pakke.
4. En simuleret fejl efter opgaveskrivning efterlader dirty state og den gamle
   offentlige pakke intakt.
5. Reconciler publicerer dirty state ved næste forsøg og gør det idempotent.
6. To næsten samtidige gemninger kan ikke lade en ældre pakke vinde.
7. Pause af en opgave bliver synlig i den offentlige pakke inden for ét minut,
   også efter én simuleret transient fejl.

## 3. Migrationsprøve

```bash
./backend/seed-content.sh --dry-run
```

Forventet rapport:

- 11 missioner og 11 lokationer;
- 31 mediebeskrivelser og 6 kilder;
- ingen manglende eller modstridende referencer;
- alle mission/location-aggregater og katalogobjekter kan gendannes fra splittet;
- `--dry-run` skriver ingen blobs.

## 4. Belastningsmåling

Kør generatoren med 11, 100 og 500 syntetiske opgaver. Rapportér mindst P50,
P95, læste/skrevne blobs, genereret størrelse og peak memory. Ved repræsentativ
intern test skal telemetrien desuden vise:

- P95 gem-og-publicér under 2 sekunder;
- leasekonflikter under 1 % af gemningerne;
- ingen dirty state ældre end ét minut, mens API'et er sundt.

Overskrides en tærskel stabilt, genåbnes lagerbeslutningen; det betyder ikke
automatisk, at SQL er løsningen.

## 5. Admin-klienter

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

Begge klienter skal liste opgaver, hente én editor, gemme med ETag og forklare
forskellen mellem “gemt” og “publicering afventer”.

## 6. Azure-spike før migration

Før de nye stier oprettes i den eksisterende konto, skal et isoleret spike
bekræfte:

- privat authoring-container og eksisterende offentlig læsevej;
- ETag-betingelser og leases gennem App Servicens managed identity;
- versioning, blob/container soft delete og lifecycle-indstillinger;
- resource lock og alarm for gentagne publiceringsfejl;
- at en testcontainer kan slettes uden at røre nuværende DEV-indhold.
