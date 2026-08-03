# Feature 003 — Indholdslageret

**Status:** Accepteret og implementeret
**Aftalt:** 3. august 2026
**Kode:** `backend/`, `iOS-admin/`, `webApps/webadmin/`

Opgavedata ligger i dag som én JSON-fil i Blob Storage. Featuren opdeler den
redaktionelle kilde i én privat JSON-blob pr. opgave og lader serveren generere
den samlede offentlige pakke, spillerne allerede henter.

Azure SQL indføres ikke. Partneres data skal ikke adskilles, og der er ikke
aktuelt relationelle forespørgsler eller transaktioner, som retfærdiggør en ny
fast driftsomkostning.

## Hvorfor nu

1. En lille rettelse uploader i dag hele samlingen fra quizmasterens enhed.
2. Alle quizmastere deler pakkens ETag og konflikter derfor på tværs af opgaver.
3. Kladder og deres facit kan udleveres sammen med den offentlige pakke.

## Krav

- **FR-201**: Hver opgave MUST ligge som et selvstændigt JSON-aggregate i en
  privat authoring-container med mission og lokation.
- **FR-202**: `GET`, `PUT` og `DELETE` MUST arbejde på én opgave, og `If-Match`
  MUST bruge den opgaveblobs ETag. Oprettelse MUST bruge `If-None-Match: *`.
- **FR-203**: Serveren MUST generere `{locale}/content-pack.json` af de opgaver,
  der er spilbare (`fieldTestReady`, `publishReady`).
- **FR-204**: Den genererede pakke MUST NOT indeholde kladder eller deres svar.
- **FR-205**: `GET /content/{locale}/pack` MUST bevare adresse, form og
  ETag-adfærd, så spillerapps ikke skal ændres.
- **FR-206**: Gemning og publicering MUST serialiseres med en kort blob-lease,
  så en ældre generering ikke kan overskrive en nyere.
- **FR-207**: `contentVersion` MUST være SHA-256 af den deterministisk
  serialiserede pakke og kun ændre sig, når pakkeindholdet ændrer sig.
- **FR-208**: En privat, regenererbar `index.json` MUST give admin-appene
  hierarkiet uden at hente alle opgavedokumenter.
- **FR-209**: Admin-appene MUST hente og gemme én opgave ad gangen.
- **FR-210**: En engangsmigrering MUST splitte den nuværende pakke uden at
  ændre kilden under dry-run. Den offentlige pakke er den forventede projektion
  af spilbare opgaver; kladder må bevidst ikke længere kopieres til den.
- **FR-211**: `pull-content.sh` MUST eksportere authoring-kilden som
  gennemgåelige opgavefiler til repoets fixture.
- **FR-212**: Lagerafvigelsen fra forfatningens relationelle mål MUST beskrives
  og accepteres i ADR 0007 før implementering.
- **FR-213**: Alle quizmastere MUST arbejde i samme indholdssamling. Featuren
  MUST NOT indføre workspace, tenant eller partneropdeling.
- **FR-214**: `publication-state.json` MUST markeres dirty før opgaveskrivning.
  En background reconciler MUST genoptage publicering idempotent ved opstart og
  mindst én gang i minuttet.
- **FR-215**: Billeder og fortællinger MUST forblive uforanderlige blobs. Deres
  eksisterende konvertering og komprimering ændres ikke.
- **FR-216**: Medie- og kildemetadata MUST have egne blobs, endpoints og ETags,
  så delte oplysninger ikke duplikeres i opgaverne.
- **FR-217**: Den eksisterende offentlige pakke MUST opdateres sidst. En
  versionsbestemt pakke MUST skrives først med `If-None-Match: *`.
- **FR-218**: Blob versioning, blob/container soft delete og lifecycle MUST
  være dokumenterede produktionskrav, men behøver ikke aktiveres, mens
  testdata bevidst må smides væk.
- **FR-219**: Implementeringen MUST måle gem-og-publicér-tid samt leasekonflikt,
  så SQL kun genovervejes ud fra de accepterede tærskler i researchen.

## Uden for denne feature

- Login, authentication og authorization.
- Multi-tenancy, workspaces og særskilte partnerdatasæt.
- Database til opgaveindhold.
- Ændring af billed- eller lydformater.
- Flere sprog; strukturen beholder locale i stien, men kun `da-DK` findes nu.

## Rækkefølge efter accept

1. Accepter den reviderede ADR 0007.
2. Implementér privat authoring-container, opgaveblobs og ETag-endpoints.
3. Implementér indeks, lease, dirty-state og deterministisk publicering.
4. Migrér den nuværende pakke gennem et verificeret dry-run.
5. Skift iOS-admin og webadmin til opgavevise kald.
6. Mål publiceringstid og leasekonflikter under intern test.

Authentication og produktionssikring forbliver bevidst efter denne research.
Det er ikke tilladelse til at give eksterne quizmastere adgang til det åbne API.
