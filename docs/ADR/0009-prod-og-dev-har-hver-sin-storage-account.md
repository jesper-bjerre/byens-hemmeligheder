# ADR 0009 — PROD og DEV har hver sin Storage Account

**Status**: Accepteret
**Dato**: 2026-08-03
**Berører**: [ADR 0005](./0005-blob-er-kilden-til-indholdet.md),
[ADR 0007](./0007-blob-nu-relationelt-naar-der-er-konti.md)

## Kontekst

Storage-kontoen `byensgaaderd` blev oprettet som DEV, men kom under den interne
test til at bære PROD-indhold for `byensgaader-api-p`. Navnet sagde DEV, mens
driftsrollen var PROD. Samtidig brugte lokal backend som standard et filsystem,
så ETags, leases, append blobs, Azure-identitet og netværksfejl først blev prøvet
efter udrulning.

En Storage Account kan ikke omdøbes. En navnerettelse kræver derfor en ny konto,
datakopi og kontrolleret cutover.

## Beslutning

Miljøerne adskilles sådan:

| Miljø | Storage Account | Containere |
|---|---|---|
| PROD | `byensgaaderp` | `content`, `authoring` |
| Kommende DEV App Service | `byensgaaderd` | `content`, `authoring` |
| Lokal backend | `byensgaaderd` | `content-local`, `authoring-local` |

PROD App Services managed identity har kun den nødvendige Blob Contributor-rolle
på `byensgaaderp`. Lokal udvikling bruger `DefaultAzureCredential` og udviklerens
`az login` mod D-kontoen. `FileSystemContentStore` beholdes til isolerede tests
og eksplicit offline-fejlsøgning, men er ikke længere lokal standard.

Den eksisterende D-konto slettes eller nulstilles ikke ved cutover. Dens
oprindelige `content` og `authoring` beholdes først som rollback-snapshot. Den må
først blive aktiv DEV-kilde, når rollback-perioden er afsluttet, og eventuelle
senere PROD-writes er afstemt. Derefter fjernes PROD App Services rolle på
D-kontoen, så miljøgrænsen også håndhæves af RBAC.

## Begrundelse

**Navne og ansvar stemmer.** En ressource med `p` bærer PROD, og en ressource med
`d` kan ændres eller nulstilles uden at ændre spillerdata.

**Lokal drift prøver den rigtige lagertype.** Opgavevise ETags, leases og append
blobs opfører sig som i Azure, fordi de faktisk kører i Azure. Det reducerer
afstanden mellem en lokal godkendelse og drift.

**Separate lokalcontainere begrænser skaden.** En debug-session kan ikke ændre
en kommende D App Services indhold, selv om begge bruger samme billige konto.

**Cutover kan rulles tilbage.** API-hostnavnet og klienterne ændres ikke. Kun
App Service-indstillingen `ContentStore__StorageAccountUri` vælger kontoen.

## Konsekvenser

**Gevinst:** PROD-data har en tydelig ressourcegrænse, Blob-versionering kan
konfigureres efter PROD-behov, og D kan bruges frit til lokal og senere fælles
test.

**Pris:** Lokal backend kræver netværk, `az login` og RBAC. Den er langsommere
end filsystemet, og en fælles D-konto kan stadig være utilgængelig. Testene skal
derfor vælge FileSystem eksplicit og fortsat kunne køre offline.

**Pris:** Der er nu to Storage Accounts at overvåge og konfigurere. Blobforbruget
er lille, men roller, soft delete, versionering, lifecycle og backup skal
kontrolleres pr. konto.

**Pris:** En rollback efter nye PROD-writes er ikke blot et URI-skift. Writes
skal afstemmes, ellers tabes ændringer foretaget efter cutover.

## Migration

Den 3. august 2026 blev `content` og `authoring` kopieret server-side fra
`byensgaaderd` til `byensgaaderp`. Navn, størrelse, Blob-type, content-type og
metadata blev sammenlignet objekt for objekt:

- `content`: 68 blobs, 68.835.970 bytes;
- `authoring`: 87 blobs, 98.977 bytes;
- ingen fejlede kopier.

En lokalt startet backend mod den nye konto og den genstartede PROD App Service
returnerede samme content-version og samme antal publicerede og redaktionelle
objekter før og efter cutover.

## Alternativer

**Behold `byensgaaderd` som PROD.** Ingen migrationsrisiko, men navnet og
miljøgrænsen forbliver misvisende, og D kan ikke nulstilles sikkert.

**Brug samme containere til lokal og kommende DEV.** Billigst i opsætning, men
lokal debugging kan ændre andre testeres data. To ekstra containere koster ikke
en ny fast ressourcepris.

**Behold filsystemet som lokal standard.** Hurtigt og offline, men prøver ikke
de Blob-egenskaber, som netop bærer samtidighed og publicering i drift.

**Opret en tredje Storage Account kun til lokal udvikling.** Giver stærkere
isolation, men tilføjer endnu en ressource uden et aktuelt flerudviklerbehov.
