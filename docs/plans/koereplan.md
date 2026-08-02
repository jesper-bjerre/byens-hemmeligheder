# Køreplan

**Sidst opdateret:** 2. august 2026

## Beslutning: research før produktionssikring

Begge iOS-apps er i TestFlight. Den næste periode bruges på to parallelle spor:

1. Apps og idé afprøves internt, mens der findes partnere og flere
   quizmastere.
2. Det kommende lager til opgavedata undersøges og designes **før** login,
   adgangskontrol og den øvrige produktionssikring
   implementeres.

Det er en bevidst ændring af den tidligere rækkefølge. Begrundelsen er, at
partner- og quizmastermodellen kan påvirke datagrænser, ejerskab og
samtidighed. Den beslutning skal ikke træffes efter adgangskontrollen allerede
har låst API'et til den nuværende samlede JSON-fil.

Kun **research og design** er flyttet frem. Det åbne skrive-API og DEV-data er
fortsat accepteret alene til den interne test; data må smides væk. Det nye
skrivelager sættes ikke i produktion uden en særskilt beslutning om rækkefølgen
for migration og adgangskontrol.

| | Mål | Status |
|---|---|---|
| 1 | Intern test, partnerdialog og flere quizmastere | 🟡 I gang |
| 2 | Research og design af et bedre lager til opgavedata | 🟡 I gang |
| 3 | Login, adgangskontrol og produktionssikring | ⏸ Bevidst udskudt |
| 4 | Implementering af nyt lager og den øvrige plan | ⬜ Afventer beslutning |

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
Den skal tage højde for, at spillerlæsninger udgør omtrent 99 % af trafikken,
mens få quizmastere opretter og retter indhold, og at partnerorganisationer kan
blive en kommende ejerskabsgrænse.

Researchen afsluttes med en anbefaling og et reviewpunkt. Først derefter
fastlægges implementeringsrækkefølgen mellem lagerændringen og mål 3.

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
er derfor stadig fraveget, indtil der er rigtige konti. Se
[ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md).

`X-Quizmaster` bliver ved med at være et navn, klienten selv skriver. Det er et
spor, ikke en identitet, og det ændrer sig ikke af, at der kommer en nøgle.

### 3.2 To indstillinger i Azure, der mangler

**HTTPS er ikke påkrævet.** `httpsOnly` står på `false`. En forespørgsel over
almindelig HTTP bliver besvaret — og med 3.1 på plads ville nøglen dermed kunne
sendes i klartekst. Skal rettes **før** nøglen tages i brug:

```bash
az webapp update -n byensgaader-api-p -g Gulvet --https-only true
```

**Blob-versionering er slået fra.** Soft delete er slået til med 7 dage, så en
overskrevet pakke kan hentes tilbage i en uge. Versionering giver
punkt-i-tid-gendannelse uden udløb og koster ingenting ved denne datamængde:

```bash
az storage account blob-service-properties update \
  --account-name byensgaaderd -g byensgaader-d_rg --enable-versioning true
```

> Begge kommandoer blev forsøgt kørt herfra 2. august og blev afvist af
> værktøjsspærringen. De er ikke udført.

### 3.3 Lagerkontoen hedder stadig noget med DEV

`byensgaaderd` holder det indhold, quizmasterne laver. Det er bevidst — hele
kæden kunne køres igennem uden noget at ødelægge — men navnet lyver nu.

**Beslutning: kontoen skiftes ikke før TestFlight.** Det er én app-indstilling
at flytte, og en flytning midt i en felttest koster mere, end navnet forvirrer.
Den skal ske, før der er rigtige spillere.

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

**Foreslået efter den nye research:** Azure SQL som lille redaktionel kilde og
en **genereret** pakke i Blob Storage til spillerne. Databasen ser kun de få
quizmasterkald; omtrent 99 % spillerlæsninger går fortsat mod den statiske
læsemodel. Anbefalingen kræver accept og en ny ADR, før implementeringen starter.

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
| ⬜ | Rigtige konti og roller håndhævet server-side (princip IV) | [ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md) |
