# Research: næste lager til opgavedata

**Feature**: 003 — Indholdslageret
**Opdateret**: 2026-08-03
**Input**: [spec.md](./spec.md)

## Konklusion

**Anbefalingen er fortsat Azure Blob Storage, men med én privat JSON-blob pr.
opgave og en genereret offentlig spillerpakke. Azure SQL skal ikke indføres
nu.**

Den tidligere SQL-anbefaling byggede især på en antagelse om, at partnere
skulle have adskilte dataområder. Den antagelse gælder ikke: alle quizmastere
arbejder i samme indholdssamling. Dermed er der hverken et aktuelt
multi-tenancy-behov, relationelle ejergrænser eller forespørgsler, der kræver en
database.

Blob Storage løser de konkrete problemer direkte:

- én opgave kan hentes og gemmes uden resten af samlingen;
- hver opgave har sin egen ETag, så forskellige opgaver ikke konflikter;
- kladder ligger i en privat container og kommer ikke i spillerpakken;
- en blob-lease kan serialisere den korte publicering;
- versioning og soft delete kan gøre fejlagtige overskrivninger og sletninger
  gendannelige;
- spillerne henter fortsat én statisk, cachebar pakke.

Løsningen bruger den eksisterende Storage-konto. Den har derfor ingen ny fast
månedspris. Ved prisopslaget 3. august 2026 kostede Hot LRS i West Europe
omtrent 0,0043 USD pr. 10.000 læsninger, 0,054 USD pr. 10.000 skrivninger og
0,018–0,020 USD pr. GB/måned. For den nuværende indholdsmængde er den ekstra
omkostning praktisk talt nul; medier og netværkstrafik er ikke medregnet.

## Arbejdsprofilen

Den aktuelle fixtur er 63.462 bytes og indeholder 11 opgaver, 11 steder, 31
mediebeskrivelser og 6 kilder. Cirka 99 % af trafikken er spillerlæsninger, mens
få quizmastere skriver sjældent.

De aktuelle behov er:

1. Gem én opgave uden at uploade hele pakken.
2. Lad to quizmastere rette hver sin opgave uden brugeroplevet konflikt.
3. Hold kladder og facit ude af den offentlige pakke.
4. Publicér eller pausér en opgave inden for minutter.
5. Bevar den eksisterende spillerkontrakt og billige læsevej.
6. Kunne gendanne en fejl eller en afbrudt publicering.

Der er ikke aktuelt behov for joins, vilkårlige serverforespørgsler,
transaktioner over mange domæneobjekter, rapportering eller adskilte
partnerdata. Det er netop de egenskaber, der ellers kunne retfærdiggøre SQL.

## Beslutning 1 — adskil privat skrivekilde og offentlig læsemodel

### Beslutning

```text
Quizmaster-apps
      │
      ▼
API → privat authoring-container → publiceringsjob → offentlig content-pack
              │                         │                    │
              ├─ én JSON pr. opgave     ├─ blob-lease        └─ spillerapps
              ├─ media/kilder           └─ retry/reconcile
              └─ audit
```

Den private container er den redaktionelle kilde. Den offentlige pakke er en
afledt læsemodel. Spillerne må aldrig læse authoring-containeren.

Foreslåede stier:

```text
authoring/da-DK/missions/{missionId}.json
authoring/da-DK/media/{mediaId}.json
authoring/da-DK/sources/{sourceId}.json
authoring/da-DK/index.json
authoring/da-DK/publication-state.json
authoring/locks/da-DK

content/da-DK/content-pack.json
content/da-DK/versions/{contentVersion}.json
```

`index.json` er en regenererbar admin-læsemodel med titel, status og postnummer.
Den er ikke kilde. Mediefiler og konverterede fortællinger bliver liggende som
uforanderlige blobs på deres nuværende stier.

### Begrundelse

Adskillelsen løser kladdeproblemet uden database. Det offentlige endpoint
bevarer samme URL, JSON-form og ETag-adfærd. De 99 % læsninger påvirkes derfor
ikke af antallet af redaktionelle filer.

### Alternativer

- **Nuværende ene blob**: fravalgt, fordi alle opgaver deler ETag og upload.
- **SQL på læsevejen**: fravalgt; statisk JSON er billigere og mere cachebar.
- **Table Storage**: giver også ETag pr. entitet, men dokumentet ender stadig
  som JSON i et felt og køber ingen nødvendig forespørgselsfunktion.

## Beslutning 2 — én blob og én ETag pr. redaktionelt objekt

### Beslutning

Mission og lokation gemmes samlet som ét JSON-aggregate. Medie- og
kildemetadata gemmes hver for sig, fordi de kan deles mellem opgaver.

Et `GET` returnerer blobbens ETag. `PUT` af en eksisterende opgave kræver
`If-Match`; oprettelse kræver `If-None-Match: *`. Azure afviser skrivningen,
hvis blobben er ændret siden læsningen. To forskellige opgaveblobs har
uafhængige ETags.

### Begrundelse

Kontrakten er naturligt dokumentformet med indlejrede kort, hints og svar.
Blobben bevarer wire-formatet direkte og kræver ingen skemamigration ved et nyt
valgfrit kontraktfelt.

Admin-indekset gør listevisning billig uden at downloade alle dokumenter til
klienten. Serveren kan altid regenerere indekset fra blobberne, hvis det er
mistet eller gammelt.

## Beslutning 3 — publicering med lease og genopretning

### Beslutning

Alle gemninger for `da-DK` bruger den samme korte lease på
`authoring/locks/da-DK`. Leasen serialiserer kun serverens skrive- og
publiceringssekvens; quizmasteren låser ikke dokumentet, mens det redigeres.

Under leasen gør API'et følgende:

1. Genkontrollerer opgavens ETag.
2. Markerer `publication-state.json` som dirty med et nyt request-id.
3. Skriver den ene opgave betinget med dens ETag.
4. Regenererer admin-indeks og offentlig pakke deterministisk.
5. Skriver først den versionsbestemte pakke og derefter den stabile latest-pakke.
6. Markerer request-id'et som publiceret og frigiver leasen.

Fejler trin 4–6, er den gamle offentlige pakke stadig hel og gyldig. API'et
viser “gemt — publicering afventer”. En `BackgroundService` ved opstart og
mindst én gang i minuttet sammenligner dirty-state med senest publicerede
request-id og forsøger igen under samme lease. Der kræves derfor ikke SQL,
Service Bus eller endnu en Azure-ressource.

`contentVersion` er SHA-256 af den kanonisk serialiserede pakke. Den
versionsbestemte blob skrives med `If-None-Match: *`, så samme version er
idempotent. Den stabile `content-pack.json` opdateres først, når hele pakken er
klar.

### Pris og begrænsning

Gemninger bliver kortvarigt serialiseret. Det er acceptabelt ved få
quizmastere, men mindre velegnet ved høj samtidig skrivetrafik. Det er en
bevidst lavpris-byttehandel, som skal måles i stedet for at blive løst på
forhånd med en database.

## Beslutning 4 — versionshistorik og gendannelse

### Beslutning

Aktivér blob versioning samt blob- og container-soft-delete, før indholdet ikke
længere må smides væk. En lifecycle-regel sletter gamle versioner efter den
aftalte periode, så historikken ikke vokser uden grænse.

Auditsporet fortsætter som append blob. Blobversioner er teknisk gendannelse;
auditsporet forklarer, hvem der forsøgte at ændre hvad. Det viste
quizmasternavn er fortsat ikke en identitet, før authentication implementeres.

### Begrundelse

Azure anbefaler versioning og soft delete som lagdelt beskyttelse mod
overskrivning og sletning. Hver blobversion faktureres som lager, men
JSON-dokumenterne er små, og lifecycle begrænser væksten.

## Hvorfor SQL ikke er nødvendigt nu

SQL Basic ville koste omtrent 4,90 USD pr. måned og kræve databaseserver,
firewall, managed identity-bruger, migrationer, backup-/restore-procedure og
overvågning. Det er ikke voldsomt i absolutte tal, men det er en fast pris og
en ny driftsflade for funktioner, Blob Storage allerede leverer til denne
arbejdsprofil.

SQL ville konkret give:

- transaktioner på tværs af opgaver, media, kilder og outbox;
- constraints og relationel referentiel integritet;
- effektive filtre, sorteringer og rapporter på tværs af store datasæt;
- mindre arbejde pr. publicering, hvis pakken senere kan bygges inkrementelt.

Ingen af disse er et aktuelt krav. Authentication og authorization kræver
heller ikke SQL; API'et kan beskytte de samme blob-endpoints og føre audit uden
at flytte indholdet. Partnernes quizmastere arbejder i samme datasæt, så der er
ingen tenantgrænse at modellere.

## Målbare kriterier for at genoverveje SQL

SQL undersøges igen, hvis mindst ét konkret behov indtræffer:

1. En redaktionel handling skal være atomisk på tværs af flere opgaver eller
   katalogobjekter, og kompensation ikke er forsvarlig.
2. Admin kræver vilkårlige, kombinerede serverforespørgsler eller rapportering,
   som et genereret indeks ikke kan betjene.
3. P95 for gem-og-publicér overstiger 2 sekunder eller lease-konflikter rammer
   mere end 1 % af gemningerne over en repræsentativ måned.
4. Den fulde regenerering overskrider App Servicens sikre tids- eller
   hukommelsesbudget ved den faktiske opgavemængde.
5. Data udvides med serverbåret progression, point eller andre stærkt
   relationelle domæner. De data kan få SQL uden automatisk at flytte
   opgaveindholdet med.

Konti og roller alene er **ikke** længere et migrationskriterium. Flere byer er
heller ikke i sig selv et kriterium; de kan organiseres med blobpræfikser og
genererede indeksfiler, så længe målingerne ovenfor holder.

## Drift og sikkerhed

Denne research implementerer ikke authentication eller authorization og ændrer
ikke risikoen ved det nuværende anonyme skrive-API.

Før data ikke længere må smides væk, kræves stadig:

- privat authoring-container og mindst mulige Blob Data Contributor-rettighed
  til App Servicens managed identity;
- versioning, blob/container soft delete, lifecycle og resource lock;
- overvågning af dirty publiceringsstate og gentagne lease-/publiceringsfejl;
- authentication/authorization før eksterne quizmastere får skriveadgang;
- migrationsprøve og dokumenteret rollback til den nuværende samlede blob.

## Kilder

- [Optimistisk samtidighed og ETags i Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/concurrency-manage)
- [Betingede Blob-operationer](https://learn.microsoft.com/en-us/rest/api/storageservices/specifying-conditional-headers-for-blob-service-operations)
- [Blob leases](https://learn.microsoft.com/en-us/rest/api/storageservices/lease-blob)
- [List Blobs, præfikser og paginering](https://learn.microsoft.com/en-us/rest/api/storageservices/list-blobs)
- [Versioning og soft delete](https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-vs-versioning-options)
- [Lifecycle management](https://learn.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-overview)
- [Azure Retail Prices API](https://prices.azure.com/api/retail/prices)
