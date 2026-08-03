# Køreplan

**Sidst opdateret:** 3. august 2026

## Beslutning: research før produktionssikring

Begge iOS-apps er i TestFlight. Den næste periode bruges på to parallelle spor:

1. Apps og idé afprøves internt, mens der findes partnere og flere
   quizmastere.
2. Det kommende lager til opgavedata undersøges og designes **før** login,
   adgangskontrol og den øvrige produktionssikring
   implementeres.

Det er en bevidst ændring af den tidligere rækkefølge. Researchen har nu
afklaret, at partnernes quizmastere arbejder i samme indholdssamling: der skal
ikke designes multi-tenancy eller adskilte partnerdata. Lageret kan derfor
ændres uden at foregribe den senere adgangskontrol.

Kun **research og design** er flyttet frem. Det åbne skrive-API og DEV-data er
fortsat accepteret alene til den interne test; data må smides væk. Det nye
skrivelager sættes ikke i produktion uden en særskilt beslutning om rækkefølgen
for migration og adgangskontrol.

| | Mål | Status |
|---|---|---|
| 1 | Intern test, partnerdialog og flere quizmastere | 🟡 I gang |
| 2 | Research og design af et bedre lager til opgavedata | ✅ Afsluttet |
| 3 | Login, adgangskontrol og produktionssikring | ⏸ Bevidst udskudt |
| 4 | Implementering af opgavevist Blob-lager | ✅ Afsluttet |

---

## Mål 1 — Intern test og partnerdialog

Begge iOS-apps er i TestFlight. Testdata betragtes som midlertidige. Formålet
er nu at validere spilleroplevelsen, quizmasterens arbejdsgang og om konceptet
kan forklares og sælges til partnere, der kan bidrage med flere quizmastere.

Fejl og observationer fra testen noteres, men udløser ikke automatisk en større
arkitekturombygning, mens testen kører.

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

### 3.1 Skrivning skal beskyttes

**Det er det eneste, der reelt spærrer.** `PUT` og `DELETE` står i dag med
`AllowAnonymous()`. Enhver, der kender adressen, kan omskrive indholdspakken
eller slette billederne.

Den mindste løsning, der virker for fem personer:

- En tilfældig nøgle som app-indstilling `Api__WriteKey` i App Service. Den
  sættes i portalen og **må aldrig stå i repoet** — repoet er public.
- En `PreProcessor` i FastEndpoints, der kræver `X-BH-Key` på alt andet end
  `GET`. Sammenlign i konstant tid; svar `401` uden at afsløre hvorfor.
- `GET` forbliver anonymt. Spillerappen skal ikke kende nøglen.
- Admin-appen læser nøglen fra `Info.plist` gennem en build-indstilling
  `BH_WRITE_KEY`, der sættes i en **ikke-sporet** `Local.xcconfig`.

**Vær ærlig om, hvad det er.** Nøglen ligger i app-binæren og kan hentes ud af
en IPA. Den spærrer for tilfældige, der finder adressen — ikke for en, der vil
ind. Den er en spærring, ikke en rettighedsmodel, og forfatningens princip IV
er derfor stadig fraveget, indtil der er rigtige konti.

`X-Quizmaster` bliver ved med at være et navn, klienten selv skriver. Det er et
spor, ikke en identitet, og det ændrer sig ikke af, at der kommer en nøgle.

### 3.2 To indstillinger i Azure, der mangler

**HTTPS er ikke påkrævet.** `httpsOnly` står på `false`. En forespørgsel over
almindelig HTTP bliver besvaret — og med 3.1 på plads ville nøglen dermed kunne
sendes i klartekst. Skal rettes **før** nøglen tages i brug:

```bash
az webapp update -n byensgaader-api-p -g Gulvet --https-only true
```

**Blob-versionering er slået til på `byensgaaderp`.** Blob- og
container-soft-delete er slået til med 7 dage. En lifecycle-regel for gamle
versioner mangler fortsat:

```bash
# Tilføj en godkendt lifecycle-regel på byensgaaderp.
```

> HTTPS-kravet på App Service er ikke udført. Storage-versionering og soft
> delete er udført 3. august 2026.

### 3.3 PROD- og D-lager er adskilt

PROD bruger `byensgaaderp` i `byensgaader-p_rg`. Den tidligere konto
`byensgaaderd` blev kopieret objekt for objekt og beholdt urørt som kortvarig
rollback. Lokal backend bruger D-kontoens separate `content-local` og
`authoring-local`, så debugging ikke skriver i PROD eller i en kommende D App
Services containere.

Beslutningen og migrationsprisen står i
[ADR 0009](../ADR/0009-prod-og-dev-har-hver-sin-storage-account.md).

### 3.4 Apperne

- **`BH_DEV_TOOLS` er stadig tændt i spillerappens Release**
  (`project.pbxproj`, Release-konfigurationen). Feature 002 flyttede
  GPS-simulering og nulstilling til admin-appen, så den kan slukkes nu. FR-051
  siger, at udviklerværktøjer ikke må findes i en udgivelsesbygning.
- **Spillerappen** peger på drift gennem `BH_CONTENT_BASE_URL` i
  `Shared.xcconfig`. Klar.
- **Admin-appen** peger på drift i begge konfigurationer. Klar, når 3.1 er
  gjort.
- Fremgangsmåden står i [testflight.md](../testflight.md). Den er skrevet til
  spillerappen; admin-appen følger den samme vej med sit eget bundle-id.

### 3.5 Sådan ved vi, at det virker

- `curl -s -o /dev/null -w '%{http_code}' https://byensgaader-api-p.azurewebsites.net/health` → `200`
- Et `PUT` uden `X-BH-Key` → `401`
- Et `PUT` med nøglen → `200`, og `audit.jsonl` har en ny linje
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
