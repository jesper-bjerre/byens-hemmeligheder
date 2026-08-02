# Feature 003 — Indholdslageret

**Status:** Foreslået — afventer accept af [research.md](./research.md)
**Aftalt:** 2. august 2026
**Kode:** `backend/`, `iOS-admin/`

Opgavedata ligger i dag som **én** JSON-fil i blob. Den læses ved hver
appstart og skrives, hver gang en quizmaster gemmer — og en gemning sender hele
samlingen, uanset hvor lille rettelsen er.

Featuren deler kilden op i én fil pr. opgave og lader serveren **generere** den
pakke, spillerne henter. Begrundelsen og de fravalgte muligheder — Table
Storage, Azure SQL, Cosmos — står i [research.md](./research.md).

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

- **FR-201**: Hver opgave MUST ligge som sin egen blob,
  `{locale}/missions/{id}.json`, med sit sted og sine mediebeskrivelser.
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
- **FR-208**: Admin-appen MUST kunne vise hierarkiet uden at hente hver opgave
  enkeltvis — et genereret kladdeindeks eller ét listekald.
- **FR-209**: Admin-appen MUST hente og gemme én opgave ad gangen.
- **FR-210**: En engangsmigrering MUST dele den nuværende pakke op, uden at
  nogen opgave ændrer indhold.
- **FR-211**: `pull-content.sh` MUST hente **kilden**, så fixturen i repoet
  dækker det, der faktisk redigeres.
- **FR-212**: Afvigelsen fra forfatningens **Tekniske rammer** MUST skrives ned
  i en ADR, der eksplicit henviser til afsnittet — se
  [ADR 0007](../../docs/ADR/0007-blob-nu-relationelt-naar-der-er-konti.md).

## Uden for denne feature

- **Azure SQL.** Kommer, når konti, roller og progression gør det nødvendigt.
  Research afsnit D beskriver, hvordan blobben da bliver læsemodel frem for
  kilde — spillerappen mærker det ikke.
- **Medier.** De ligger allerede som enkeltfiler og røres ikke.
- **Flere sprog.** Der findes én pakke.

## Rækkefølge

**Adgangskontrollen (mål 1) skal være på plads først.** At bygge et nyt
skrivelag oven på en `PUT`, enhver kan kalde, er at bygge på noget, der skal
rives op igen.

1. Delt lagerlag: skriv en opgave, generér pakken, én blob-lease om genereringen
2. Endepunkter: `GET`/`PUT /content/{locale}/missions/{id}`, kladdeindekset
3. Engangsmigrering + `pull-content.sh`
4. Admin-appen henter og gemmer pr. opgave
5. `PackMerge` skrumper til én opgave — eller udgår

## Hvad der bliver lettere bagefter

`PackMerge` findes, fordi to quizmastere kunne kollidere på pakken. Retter de
hver sin opgave, kolliderer de ikke længere, og fletningen bliver kun nødvendig,
når to retter **den samme** opgave. Den skal ikke fjernes uden at nogen har
prøvet det af — men den holder op med at være hovedvejen.
