# Research: næste lager til opgavedata

**Feature**: 003 — Indholdslageret

**Opdateret**: 2026-08-02

**Input**: [spec.md](./spec.md)

## Konklusion

**Anbefalingen er Azure SQL Database som redaktionel kilde og Azure Blob
Storage som offentlig læsemodel.**

Opgaver gemmes som selvstændige JSON-dokumenter i SQL med få udtrukne kolonner
til listevisning, ejerskab og status. Når en quizmaster gemmer, genererer
backenden en uforanderlig `content-pack.json` med kun publicerbart indhold og
lægger den i Blob Storage. Spillerne læser fortsat pakken og medierne; de rammer
aldrig databasen.

Det er ikke en anbefaling om en stor database. Startniveauet er **Azure SQL
Basic, 5 DTU og 2 GB**, som i West Europe aktuelt koster 0,161 USD pr. dag —
omtrent 4,90 USD pr. måned. Niveauet kan skaleres uden at ændre datamodellen.

Anbefalingen erstatter den tidligere konklusion om én blob pr. opgave. Den
tidligere analyse antog fem quizmastere og ingen partnerstruktur. Den nye
forudsætning er, at løsningen skal kunne præsenteres for partnere og få flere
quizmastere, mens omtrent 99 % af alle kald fortsat er spillerlæsninger.

## Arbejdsprofilen

Den aktuelle fixtur er 63.462 bytes og indeholder 11 opgaver, 11 steder, 31
mediebeskrivelser og 6 kilder. Det er cirka 5,8 KB pr. opgave inklusive dens
andel af fælles data.

Selv ved 10.000 opgaver er selve opgaveindholdet sandsynligvis under 100 MB.
Medierne bliver i Blob Storage og tæller ikke med i databasen. Kapacitet er
derfor ikke beslutningens svære del; de vigtige egenskaber er:

- 99 % læsninger skal være statiske, cachebare og billige.
- En quizmaster skal gemme én opgave uden at sende eller låse alle andre.
- To quizmastere skal kun kollidere, når de retter samme opgave.
- Kladder og deres facit må ikke indgå i den offentlige læsemodel.
- En kommende partnergrænse må ikke kræve, at alle id'er og tabeller bygges om.
- Indholdskontrakten ændres ofte og skal kunne udvides uden en tabelmigration
  for hvert nyt tekstfelt.

## Beslutning 1 — adskil skrivekilde og læsemodel

### Beslutning

Den redaktionelle kilde og spillerens læsemodel er to forskellige ting:

```text
Quizmaster-apps → API → Azure SQL → publiceringsjob → Blob-pakke → spillerapps
                            ↘ audit/outbox       ↘ billeder og lyd
```

SQL tager kun quizmastertrafik. Blobben tager spillertrafikken. Den nuværende
`GET /content/{locale}/pack` bevares som kompatibilitetsvej, mens en direkte
offentlig blobadresse kan tilføjes til nye klientversioner senere.

### Begrundelse

En database på læsevejen ville være den dyreste og mindst cachebare løsning på
et problem, som en statisk fil allerede løser. En blob som eneste skrivekilde
ville omvendt mangle relationer til partner/ejerskab og gøre fremtidige roller
til metadata, som applikationen selv skulle håndhæve.

CQRS her betyder ikke microservices. API, publicering og baggrundsjob bliver i
den samme modulære monolit og deler én database.

### Alternativer

- **SQL ved hvert spillerkald**: fravalgt; databasen ville blive dimensioneret
  efter den trafik, som en statisk pakke allerede håndterer bedre.
- **Kun blob**: teknisk tilstrækkeligt til opgaver, men en ny afvigelse fra
  forfatningens relationelle ramme netop før partner-/ejerskabsbehovet opstår.

## Beslutning 2 — Azure SQL Basic som første størrelse

### Beslutning

Start med én Azure SQL Database i DTU-niveauet Basic. App Service forbinder med
sin managed identity; der indføres ingen databaseadgangskode eller connection
string med en hemmelighed.

### Begrundelse

Basic giver 5 DTU og 2 GB på et fast, lavt prisniveau. Databasen er altid klar,
hvilket er mere værd i felten end automatisk pause. Azure SQL har automatisk
backup og point-in-time restore på alle niveauer, og den eksisterende App
Service-identitet kan få mindst mulige SQL-rettigheder.

Prisopslaget er foretaget 2026-08-02 i Microsofts Azure Retail Prices API for
`SQL Database Single Basic`, West Europe: 0,161 USD/dag. Pris er et øjebliksbillede
og skal kontrolleres i Azure-portalen før oprettelse.

### Alternativer

| Mulighed | Vurdering |
|---|---|
| Azure SQL General Purpose Serverless | Compute betales pr. sekund og kan pause, men auto-resume er typisk omkring ét minut. Det er en dårlig første gemmeoplevelse for en quizmaster og er ikke billigere end Basic ved jævnlig redigering. |
| Cosmos DB Serverless | Meget billig ved få operationer og passer naturligt til dokumenter. Den køber global dokumentdistribution, som spillerne ikke bruger, og gør partner-, rolle- og revisionsrelationer til applikationslogik. |
| Azure Database for PostgreSQL B1ms | Fagligt fint, men dyrere og en ny databasefamilie i en stak, der allerede har valgt Azure SQL. Retail-prisen for compute alene er aktuelt ca. 14,50 USD/måned før storage. |
| Table Storage | Billigt og har ETag, men en opgave ender som JSON i en streng. Det giver færre relationer og dårligere transaktioner end SQL uden at forbedre læsevejen. |
| Én blob pr. opgave | Billigst og enklest. Beholdes som migrations-/eksportformat, men ikke som langsigtet primær domænedatabase. |

## Beslutning 3 — hybrid relationel/JSON-model

### Beslutning

Stabile felter bliver relationelle kolonner; den skiftende kontrakt bliver et
JSON-dokument:

- Relationelt: workspace, locale, id, slug, titel, status, postnummer,
  revisionsnummer og ændringstidspunkt.
- JSON: selve missionen og dens lokation i kontraktens engelske wire-format.
- Egne tabeller: mediebeskrivelser, kilder, revisionsspor og publiceringsjob.
- Blob: de tunge mediefiler og genererede spillerpakker.

De eksisterende binære uploadruter for billeder og fortællinger er fortsat
selvstændige ruter. Ved implementering skal de få workspace-kontekst og
kontrollere ejerskab på samme måde som metadata-API'et; denne research ændrer
ikke deres konvertering eller filformater.

JSON gemmes først som `nvarchar(max)` med `CHECK (ISJSON(...)=1)`. Azure SQL har
nu en native `json`-type, men teksttypen giver enklere EF Core-mapping og kan
migreres senere uden at gøre den første leverance afhængig af serverens update
policy. Felter, der bruges i filtre og sortering, duplikeres bevidst som
validerede kolonner og indekseres.

### Begrundelse

En fuldt normaliseret model ville gøre hvert nyt hint- eller tekstfelt til en
databasemigration. Ét stort JSON-dokument pr. opgave ville omvendt skjule
status, ejerskab og listefelter. Hybridmodellen bevarer kontraktens
dokumentform, men lader databasen håndhæve de grænser, der skal være stabile.

### Alternativer

- **Normalisér hvert kort, hint og svar**: fravalgt; høj migrationspris uden
  forespørgselsbehov.
- **Kun én JSON-kolonne**: fravalgt; partnergrænse, status og samtidighed skal
  kunne håndhæves og indekseres uden at parse alle dokumenter.
- **Native `json` fra dag ét**: genovervejes efter et spike med EF Core 10 og
  Azure SQL Basic. Det ændrer ikke API'et eller den logiske model.

## Beslutning 4 — workspace er datagrænsen, ikke loginløsningen

### Beslutning

Alle redaktionelle rækker får `WorkspaceId`. Der oprettes ét standard-workspace
ved migrationen. Et workspace kan senere repræsentere Byens Gåder eller en
partnerorganisation.

Der oprettes **ikke** brugere, roller eller login som del af lagerfeaturen.
Auditsporet beholder quizmasterens viste navn, indtil authentication kommer.
Når identitet implementeres, kan medlemskab og roller referere til det allerede
eksisterende workspace.

### Begrundelse

At undlade workspace nu vil gøre partneradskillelse til en migration af alle
primærnøgler og unikke constraints. At designe hele identitetsmodellen nu ville
omvendt foregribe den særskilte authentication-/authorizationbeslutning.

### Alternativer

- **Globalt indhold uden ejergrænse**: fravalgt på grund af partnerretningen.
- **Fuld multitenancy og roller nu**: fravalgt; brugeren har udtrykkeligt
  placeret authorization efter denne research.

## Beslutning 5 — publicering er transaktion + outbox

### Beslutning

En opgavegemning og et publiceringsjob skrives i samme SQL-transaktion. Efter
commit forsøger API'et straks at generere pakken. Fejler blobskrivningen, ligger
jobbet i outbox-tabellen og prøves igen af en `BackgroundService`.

En kort blob-lease pr. workspace/locale serialiserer genereringen på tværs af
eventuelle API-instanser. Efter leasen er taget, læses alle publicerbare opgaver
fra en konsistent databasesnapshot, sorteres deterministisk og serialiseres.
`contentVersion` og HTTP-ETag afledes af SHA-256 over den færdige pakke.

### Begrundelse

SQL og Blob Storage kan ikke deltage i samme atomiske transaktion. Outboxen gør
en fejlet publicering synlig og genoptagelig uden at rulle quizmasterens gemte
arbejde tilbage. Blob-leasen forhindrer, at en ældre generering skriver over en
nyere.

### Alternativer

- **Skriv SQL og blob uden outbox**: fravalgt; et netværksudfald kan efterlade
  den offentlige pakke permanent gammel.
- **Service Bus/Azure Functions**: robust, men endnu en tjeneste for få
  daglige skrivninger. Outboxen kan senere sende til en kø uden API-ændring.
- **Generér kun periodisk**: fravalgt; en pauset usikker opgave skal forsvinde
  fra læsemodellen med det samme.

## Kontrakt og kompatibilitet

- `GET /content/{locale}/pack` og den eksisterende spillerkontrakt ændres ikke.
- Ruten er et bagudkompatibelt alias for standard-workspacets pakke. Hvert nyt
  workspace får en entydig publiceringssti og blobsti.
- Admin får liste-, hent-, gem- og slet-endpoints pr. opgave.
- Delte medie- og kildemetadata får egne endpoints og ETags. De må ikke
  duplikeres i opgaveaggregaterne, fordi en rettighedsrettelse skal have ét
  autoritativt sted.
- SQL `rowversion` eksponeres som HTTP-ETag. `If-Match` gælder én opgave.
- Oprettelse bruger `If-None-Match: *`; filnavne og id'er genbruges ikke.
- En response fortæller, om læsemodellen er publiceret eller stadig afventer
  retry. Gemte redaktionelle ændringer må ikke fremstilles som tabt.
- Den nuværende pakke kan migreres deterministisk til ét standard-workspace og
  eksporteres tilbage byte-semantisk identisk efter kanonisk sortering.

## Drift og sikkerhed

Denne research implementerer ikke authentication eller authorization. Den
ændrer heller ikke den aktuelle risiko ved det anonyme skrive-API.

Produktionsaktivering af SQL-skrivevejen kræver senere:

- managed identity fra App Service til Azure SQL med mindst mulige rettigheder;
- firewall eller netværksgrænse for databaseserveren;
- automatiske EF-migrationer som et særskilt deployment-step, ikke ved hvert
  app-start;
- budgetalarm og månedlig kontrol;
- authentication/authorization før partnerdata behandles som beskyttede data;
- en dokumenteret rollback, hvor den gamle blobpakke kan genaktiveres.

## Kilder

- [Azure SQL: Basic og øvrige DTU-niveauer](https://learn.microsoft.com/en-us/azure/azure-sql/database/service-tiers-dtu)
- [Azure SQL serverless: pause, prisprincip og resume-latens](https://learn.microsoft.com/en-us/azure/azure-sql/database/serverless-tier-overview)
- [JSON-dokumenter i Azure SQL](https://learn.microsoft.com/en-us/sql/relational-databases/json/store-json-documents-in-sql-tables)
- [Managed identity fra App Service til Azure SQL](https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-sql-database)
- [Automatiske backups og point-in-time restore](https://learn.microsoft.com/en-us/azure/azure-sql/database/recovery-using-backups)
- [Cosmos DB serverless](https://learn.microsoft.com/en-us/azure/cosmos-db/serverless)
- [Azure Retail Prices API](https://prices.azure.com/api/retail/prices)
