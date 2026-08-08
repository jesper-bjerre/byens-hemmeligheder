# Køreplan

**Sidst opdateret:** 8. august 2026

## Aktuel status: authentication er i drift

Begge iOS-apps er uploadet, lagerresearchen er afsluttet, og authentication,
authorization og produktionssikring er aktiveret og smoke-testet i PROD. Den
interne test kan derfor fokusere på spilleroplevelsen og opgavernes kvalitet.

Partnerdialog, rekruttering og særskilt kommunikation med quizmastere er ikke
en del af denne leverance og må ikke blokere den. Authentication implementeres
som beskrevet i [feature 004](../../specs/004-authentication-og-roller/spec.md).

Det tidligere åbne skrive-API er lukket. Begge admin-klienter kræver login, og
offentlig spillerlæsning forbliver anonym.

| | Mål | Status |
|---|---|---|
| 1 | Intern test af opgavernes kvalitet | 🟡 I gang |
| 2 | Research og design af et bedre lager til opgavedata | ✅ Afsluttet |
| 3 | Login, adgangskontrol og produktionssikring | ✅ Aktiv og smoke-testet i PROD; iOS-builds uploadet |
| 4 | Implementering af opgavevist Blob-lager | ✅ Afsluttet |

---

## Mål 1 — Intern test af opgavernes kvalitet

Begge iOS-apps er i TestFlight. Testdata betragtes som midlertidige. Formålet
er nu at validere spilleroplevelsen og opgavernes kvalitet.

Fejl og observationer fra testen noteres, men udløser ikke automatisk en større
arkitekturombygning, mens testen kører.

### Favoritter og aktuelle opgaver

Spillere med konto kan gemme en opgave som favorit. De aggregerede, anonyme
summer driver **Favoritter lige nu**, mens nye favoritter inden for 30 dage
driver **Trender lige nu**. Gæster kan læse listerne og spille alle frigivne
opgaver, men kan ikke like: vi opretter ikke et skjult device-id for et barn.

Lagringsbeslutningen og dens pris står i
[ADR 0011](../ADR/0011-favoritter-og-trending-i-table-storage.md).

### Offentlige profilnavne og moderation

Den næste releaseudvidelse er implementeret lokalt: en indlogget spiller kan
vælge et offentligt profilnavn, og andre indloggede spillere kan rapportere et
vist navn fra highscorelisten. Navnet valideres og ratebegrænses server-side.
Admin kan i web-admin skjule navnet eller blokere en ikke-Admin-konto; highscore
viser straks **Anonym spiller**, hvis navnet ikke længere må vises.

Rapporter opbevares i højst 90 dage. Highscore udleverer fortsat hverken
konto-id eller e-mail. Funktionen ligger lokalt i commit `a2fc88c`; backend,
Swift, Angular og begge iOS Release-builds er grønne. Spillerbuild 8 er
forberedt. Committen er endnu ikke pushet, så funktionen afventer fortsat
`main` → DEV → manuel PROD-gate og et nyt spillerarkiv.

**Nye oplevelser** sorteres efter det serverstyrede `releasedAt`, altså hvornår
opgaven skiftede til Frigivet — ikke hvornår kladden blev oprettet. Eksisterende
PROD-opgaver er migreret med 7. august 2026 som frigivelsesdato.

Indloggede spilleres lokale, forklarlige pointledger synkroniseres idempotent
til den første rigtige highscore. Den provisoriske lagring og den accepterede
pris ved, at serveren endnu ikke genberegner point, står i
[ADR 0012](../ADR/0012-provisorisk-pointledger-i-table-storage.md).

DEV har samme typer kørende ressourcer som PROD: API, adminweb og spillerweb.
Relevante ændringer på `main` udrulles automatisk til DEV. Backend-pipelinen
smoke-tester sundhed, HTTPS og anonym adgangskontrol dér. PROD-udrulning er
derefter en separat manuel GitHub Action med menneskelig bekræftelse af, at
samme commit er verificeret i DEV; det følger forfatningens princip III.

## Mål 2 — Research af et bedre lager til opgavedata

Researchen ligger i
[`specs/003-indholdslager/research.md`](../../specs/003-indholdslager/research.md).
Den tager højde for, at spillerlæsninger udgør omtrent 99 % af trafikken, mens
få quizmastere opretter og retter indhold. Partnerorganisationer er ikke en
datagrænse; deres quizmastere arbejder i samme samling.

Det accepterede og implementerede design er én privat JSON-blob pr. opgave og
en genereret offentlig pakke. SQL bruges kun, hvis senere målinger eller nye
relationelle krav gør det nødvendigt. Se [ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md).

## Mål 3 — Login, adgangskontrol og produktionssikring

Målet er at gøre den validerede løsning klar til data, der ikke længere må
smides væk, uden at nogen udefra kan ødelægge quizmasternes arbejde.

Den tidligere midlertidige idé om én delt skrive-nøgle er erstattet af fuld
authentication og serverstyrede roller. Version 1 bruger Log ind med Apple
direkte og udsteder egne sessions uden Azure AD B2C/Entra External ID. Det
validerede design og implementeringsrækkefølgen står i
[authentication-og-roller.md](./authentication-og-roller.md).

Forfatningsgaten blev godkendt den 6. august 2026. Princip VI og de tekniske
rammer er opdateret i forfatning 4.0.0, så den dataminimerede Apple-identitet,
det interne konto-id og sessionsmetadata nu kan implementeres. Den konkrete
privatlivstekst og interesseafvejning skal fortsat reviewes før offentlig
release, men det blokerer ikke implementering eller test i DEV.

### 3.1 Skrivning er beskyttet

Authentication er aktiv og smoke-testet i PROD. Anonyme authoring-kald og
`/auth/me` afvises med `401`, og HTTP omdirigeres til HTTPS. Rollepolicies
beskytter skrive-, preview- og brugeradministrationsendpoints server-side.

Den besluttede løsning:

- iOS-spillerappen har gæstespil og valgfrit Log ind med Apple. Kun
  autentificerede konti kan optræde på highscore.
- Spillerwebben er fortsat gæstebaseret. Dens login og kontosletning er
  bevidst udskudt fra iPhone-releasen, men står fortsat som åbne featuretasks.
- iOS-admin og web-admin kræver login.
- `User` kan kun bruge frigivet indhold (`published`).
- `Designer` kan desuden se `fieldTestReady` og vedligeholde opgaver.
- `Admin` kan alt det samme og kan vedligeholde Designer-listen.
- API'et validerer Apple-identitet og håndhæver roller server-side. Klientens
  egne rolle- eller navnefelter har ingen autoritet.
- `X-Quizmaster` erstattes i audit af den verificerede konto.
- Første Admin bootstrap'es én gang fra en verificeret Apple-e-mail, der kun
  findes som Azure-konfiguration og ikke i dette offentlige repo.

Andre identitetsudstedere kan senere tilføjes til Android og web som separate
konti. E-mail gemmes som kontaktdata, men er ikke den tekniske kontonøgle, og
konti fra flere IDP'er sammenlægges ikke.

### 3.2 Offentlig og redaktionel læsevej

Den offentlige pakke skal fremover kun indeholde `published`, som UI'et viser
som **Frigivet**. `fieldTestReady` vises som **Klar til udgivelse** og leveres
kun gennem et beskyttet Designer-preview. Den gamle wire-værdi `publishReady`
accepteres midlertidigt som alias for `published`, indtil produktionsindhold og
allerede udsendte klienter er migreret. Nye admin-klienter må ikke oprette den.
Pakkegeneratoren oversætter i overgangsperioden `published` tilbage til
`publishReady` på den offentlige wire, så gamle TestFlight-builds fortsat kan
se opgaverne. Broen fjernes først, når understøttelse af `published` er ude i
alle spillerklienter; derefter migreres PROD-data, og legacy-værdien fjernes.

### 3.3 Resterende Azure-driftspunkt

HTTPS-only er aktiveret og verificeret i PROD. Blob-versionering samt blob- og
container-soft-delete er slået til med 7 dage på `byensgaaderp`. En
lifecycle-regel for gamle versioner mangler fortsat:

```bash
# Tilføj en godkendt lifecycle-regel på byensgaaderp.
```

> Storage-versionering og soft delete er udført 3. august 2026.

### 3.4 PROD- og D-lager er adskilt

PROD bruger `byensgaaderp` i `byensgaader-p_rg`. Den tidligere konto
`byensgaaderd` blev kopieret objekt for objekt og beholdt urørt som kortvarig
rollback. Lokal backend bruger D-kontoens separate `content-local` og
`authoring-local`, så debugging ikke skriver i PROD eller i en kommende D App
Services containere.

Beslutningen og migrationsprisen står i
[ADR 0009](../ADR/0009-prod-og-dev-har-hver-sin-storage-account.md).

### 3.5 Apperne

- **GPS-simulering er en rollebeskyttet spillerfunktion.** Den 6. august 2026
  blev det besluttet, at en verificeret Designer/Admin skal kunne simulere GPS
  fra Profil — også i TestFlight/Release. Users og gæster ser intet værktøj.
  Release reagerer ikke på launch-argumenter; det ville være en skjult bagdør.
  Det gamle compile-flag `BH_DEV_TOOLS` er derfor fjernet som produktgrænse.
- **Spillerappen** peger på drift gennem `BH_CONTENT_BASE_URL` i
  `Shared.xcconfig`. Klar.
- **Admin-apps** peger på drift, bruger Apple-login og sender bearer-session på
  de beskyttede kald.
- Fremgangsmåden står i [testflight.md](../testflight.md). Den er skrevet til
  spillerappen; admin-appen følger den samme vej med sit eget bundle-id.

### 3.6 Sådan ved vi, at det virker

- `curl -s -o /dev/null -w '%{http_code}' https://byensgaader-api-p.azurewebsites.net/health` → `200`
- Et `PUT` uden session → `401`
- Et `PUT` som User → `403`
- Et `PUT` som Designer/Admin → succes og en auditlinje med verificeret konto
- User/gæst kan ikke hente `fieldTestReady`; Designer/Admin kan se den i preview
- Kun en Admin kan ændre en konto mellem User og Designer
- `http://` (ikke `https://`) → omdirigering, ikke et svar

---

## Mål 4 — Implementering af et bedre lager til opgavedata

Analysen er lavet: [`specs/003-indholdslager/research.md`](../../specs/003-indholdslager/research.md).
Kravene står i [`spec.md`](../../specs/003-indholdslager/spec.md).

**Revideret forslag:** én privat JSON-blob pr. opgave som redaktionel kilde og
en **genereret** pakke i Blob Storage til spillerne. Den eksisterende
Storage-konto genbruges, og der kommer ingen ny fast databasepris. ETag pr.
opgave løser samtidighed, mens en kort lease og dirty-state gør publicering
genoptagelig. Anbefalingen kræver accept af den reviderede ADR 0007.

Det løser tre ting, der bliver værre for hver ny opgave:

1. En rettelse koster i dag hele samlingen at lægge op fra en telefon i felten.
2. `If-Match` sidder på pakken, så to quizmastere kolliderer, selv når de retter
   hver sin opgave.
3. **Kladder udleveres til alle, der kender adressen — inklusive svarene på
   gåder, der ikke er udgivet.**

**Researchen venter ikke længere på mål 3.** Kun produktionsaktivering og den
endelige migration af skrivevejen kræver en ny rækkefølgebeslutning efter
researchen.

---

## Derefter — den øvrige plan

Det, der lå og ventede, da lager- og sikkerhedsarbejdet kom til. Ingen af dem
spærrer for den aktuelle interne test.

| | Hvad | Hvor det står |
|---|---|---|
| ⬜ | De syv `mission.ny-opgave-N`-id'er skal have rigtige slugs, når titlerne er på plads | [002/plan.md](../../specs/002-quizmaster-app/plan.md) |
| ⬜ | Admin-appen har ingen UI-tests. En fejlrapport om, at kun to faneblade var synlige, kunne aldrig genskabes | [002/plan.md](../../specs/002-quizmaster-app/plan.md) |
| ⬜ | Ståvejledningen ("stå på promenaden med fjorden til venstre") forsvandt med `vantagePoint`. Skal den tilbage, hører den til som indhold | [ADR 0006](../ADR/0006-kontrakten-forenklet.md) |
| ⬜ | `backend-deploy.yml` udløses af `backend/**` — også af en rettet README. Workflowets egen kommentar siger, det ikke må ske | [udrulning.md](../drift/udrulning.md) |
| ⬜ | Rigtige konti og roller håndhævet server-side (princip IV) | [Mål 3](#mål-3--login-adgangskontrol-og-produktionssikring) |
