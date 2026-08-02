# Feature 003 — Indholdslageret

**Status:** Research opdateret — afventer accept af [research.md](./research.md)
**Aftalt:** 2. august 2026
**Kode:** `backend/`, `iOS-admin/`

Opgavedata ligger i dag som **én** JSON-fil i blob. Den læses ved hver
appstart og skrives, hver gang en quizmaster gemmer — og en gemning sender hele
samlingen, uanset hvor lille rettelsen er.

Featuren flytter den redaktionelle kilde til små opgaveaggregater i Azure SQL
og lader serveren **generere** den blobpakke, spillerne henter. Begrundelsen og
de fravalgte muligheder står i [research.md](./research.md).

## Hvorfor nu

Tre ting, der alle bliver værre med hver ny opgave:

1. En rettelse koster hele samlingen at lægge op — fra en telefon i felten.
2. `If-Match` sidder på pakken, så to quizmastere kolliderer, selv når de
   retter hver sin opgave.
3. Kladder udleveres til alle, der kender adressen — **inklusive svarene på
   gåder, der ikke er udgivet.**

Det tredje er det, der ikke kan vente, hvis quizmasterne begynder at lave rigtigt
indhold.

## Krav

- **FR-201**: Hver opgave MUST ligge som et selvstændigt aggregate i Azure SQL
  med mission og sted som kontraktnært JSON samt udtrukne kolonner til
  workspace, locale, id, slug, titel, status og postnummer.
- **FR-202**: `PUT` og `GET` på en enkelt opgave MUST findes, og `If-Match`
  MUST gælde **den opgave** og ikke samlingen.
- **FR-203**: Serveren MUST generere `{locale}/content-pack.json` af de opgaver,
  der er spilbare (`fieldTestReady`, `publishReady`).
- **FR-204**: Den genererede pakke MUST NOT indeholde kladder eller deres svar.
- **FR-205**: `GET /content/{locale}/pack` MUST svare uændret — samme adresse,
  samme form, samme `ETag`-opførsel. Spillerappen ændres ikke.
- **FR-206**: Genereringen MUST være serialiseret, så to gemninger tæt på
  hinanden ikke kan efterlade en halv pakke.
- **FR-207**: `contentVersion` MUST afledes og ændre sig, når og kun når pakkens
  indhold ændrer sig.
- **FR-208**: Admin-appene MUST kunne vise hierarkiet uden at hente hvert
  JSON-dokument enkeltvis; listekaldet læser kun de udtrukne oversigtskolonner.
- **FR-209**: Admin-appen MUST hente og gemme én opgave ad gangen.
- **FR-210**: En engangsmigrering MUST importere den nuværende pakke til ét
  standard-workspace og generere en semantisk identisk spillerpakke.
- **FR-211**: `pull-content.sh` MUST eksportere **kilden** som gennemgåelige
  opgavefiler, så fixturen i repoet dækker det, der faktisk redigeres.
- **FR-212**: Den accepterede lagerbeslutning MUST skrives i en ADR. Accepteres
  SQL-anbefalingen, MUST ADR 0007 markeres som afvist eller erstattet.
- **FR-213**: Alle redaktionelle data MUST have `WorkspaceId`; migrationen
  opretter ét standard-workspace uden at implementere brugere eller roller.
- **FR-214**: Gemning og oprettelse af et publiceringsjob MUST ske i samme
  SQL-transaktion. Et fejlet job MUST kunne genoptages idempotent.
- **FR-215**: Mediefiler MUST fortsat ligge i Blob Storage. Kun metadata og
  referencer må ligge i den relationelle kilde.
- **FR-216**: Medie- og kildemetadata MUST have egne opgaveuafhængige
  endpoints og ETags, så delte rettigheds- og kildeoplysninger ikke duplikeres
  i missionernes JSON.
- **FR-217**: Den nuværende `/content/{locale}/pack` MUST være alias for
  standard-workspacets pakke. Nye workspaces MUST have hver sin entydige
  publiceringssti.

## Uden for denne feature

- **Login og adgangskontrol (authentication/authorization).** Datamodellen
  forbereder workspace som grænse, men opretter ikke brugere, medlemskaber
  eller roller.
- **Medier.** De ligger allerede som enkeltfiler og røres ikke.
- **Flere sprog.** Der findes én pakke.

## Rækkefølge

**Research og design gennemføres før adgangskontrollen**, fordi partner- og
workspacegrænsen skal være kendt, før API'ets fremtidige rettigheder designes.
Det er en planbeslutning, ikke tilladelse til at sætte et nyt anonymt
skrivelager i produktion.

Efter accept af researchen:

1. ADR og database-spike: Azure SQL Basic, JSON-mapping og managed identity
2. Datalag: opgaveaggregate, oversigtskolonner, ETag og migrationsværktøj
3. Publicering: transaktionel outbox, deterministisk pakke og blob-lease
4. Endepunkter: liste samt `GET`/`PUT`/`DELETE` pr. opgave
5. Engangsmigrering og eksport af kildefixturer
6. Admin-appene henter og gemmer pr. opgave
7. `PackMerge` skrumper til én opgave — eller udgår efter afprøvning

## Hvad der bliver lettere bagefter

`PackMerge` findes, fordi to quizmastere kunne kollidere på pakken. Retter de
hver sin opgave, kolliderer de ikke længere, og fletningen bliver kun nødvendig,
når to retter **den samme** opgave. Den skal ikke fjernes uden at nogen har
prøvet det af — men den holder op med at være hovedvejen.
