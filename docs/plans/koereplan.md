# Køreplan

**Sidst opdateret:** 2. august 2026

Tre mål, i rækkefølge. Nummer 2 må ikke begyndes før nummer 1 — begrundelsen
står under mål 2.

| | Mål | Status |
|---|---|---|
| 1 | Backenden klar, så begge apps kan testes fra TestFlight | 🟡 I gang |
| 2 | Et bedre lager til opgavedata | ⬜ Analyseret, ikke påbegyndt |
| 3 | Fortsætte den nuværende plan | ⬜ |

---

## Mål 1 — Backenden klar til TestFlight

Målet er, at et par quizmastere kan installere begge apps og bruge dem på
rigtige steder, uden at nogen udefra kan ødelægge deres arbejde.

### 1.1 Skrivning skal beskyttes

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

### 1.2 To indstillinger i Azure, der mangler

**HTTPS er ikke påkrævet.** `httpsOnly` står på `false`. En forespørgsel over
almindelig HTTP bliver besvaret — og med 1.1 på plads ville nøglen dermed kunne
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

### 1.3 Lagerkontoen hedder stadig noget med DEV

`byensgaaderd` holder det indhold, quizmasterne laver. Det er bevidst — hele
kæden kunne køres igennem uden noget at ødelægge — men navnet lyver nu.

**Beslutning: kontoen skiftes ikke før TestFlight.** Det er én app-indstilling
at flytte, og en flytning midt i en felttest koster mere, end navnet forvirrer.
Den skal ske, før der er rigtige spillere.

### 1.4 Apperne

- **`BH_DEV_TOOLS` er stadig tændt i spillerappens Release**
  (`project.pbxproj`, Release-konfigurationen). Feature 002 flyttede
  GPS-simulering og nulstilling til admin-appen, så den kan slukkes nu. FR-051
  siger, at udviklerværktøjer ikke må findes i en udgivelsesbygning.
- **Spillerappen** peger på drift gennem `BH_CONTENT_BASE_URL` i
  `Shared.xcconfig`. Klar.
- **Admin-appen** peger på drift i begge konfigurationer. Klar, når 1.1 er
  gjort.
- Fremgangsmåden står i [testflight.md](../testflight.md). Den er skrevet til
  spillerappen; admin-appen følger den samme vej med sit eget bundle-id.

### 1.5 Sådan ved vi, at det virker

- `curl -s -o /dev/null -w '%{http_code}' https://byensgaader-api-p.azurewebsites.net/health` → `200`
- Et `PUT` uden `X-BH-Key` → `401`
- Et `PUT` med nøglen → `200`, og `audit.jsonl` har en ny linje
- `http://` (ikke `https://`) → omdirigering, ikke et svar

---

## Mål 2 — Et bedre lager til opgavedata

Analysen er lavet: [`specs/003-indholdslager/research.md`](../../specs/003-indholdslager/research.md).
Kravene står i [`spec.md`](../../specs/003-indholdslager/spec.md).

**Kort:** én blob pr. opgave som kilde, og en **genereret** pakke til
spillerne. Table Storage og Azure SQL er begge undersøgt og fravalgt nu — med
en betingelse skrevet ned for, hvornår SQL alligevel skal ind
([ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md)).

Det løser tre ting, der bliver værre for hver ny opgave:

1. En rettelse koster i dag hele samlingen at lægge op fra en telefon i felten.
2. `If-Match` sidder på pakken, så to quizmastere kolliderer, selv når de retter
   hver sin opgave.
3. **Kladder udleveres til alle, der kender adressen — inklusive svarene på
   gåder, der ikke er udgivet.**

**Hvorfor den venter på mål 1:** at bygge et nyt skrivelag oven på en `PUT`,
enhver kan kalde, er at bygge på noget, der skal rives op igen. Punkt 3 ovenfor
er også kun det halve problem, så længe skrivevejen står åben.

---

## Mål 3 — Den nuværende plan

Det, der lå og ventede, da mål 1 og 2 kom til. Ingen af dem spærrer for noget.

| | Hvad | Hvor det står |
|---|---|---|
| ⬜ | De syv `mission.ny-opgave-N`-id'er skal have rigtige slugs, når titlerne er på plads | [002/plan.md](../../specs/002-quizmaster-app/plan.md) |
| ⬜ | Admin-appen har ingen UI-tests. En fejlrapport om, at kun to faneblade var synlige, kunne aldrig genskabes | [002/plan.md](../../specs/002-quizmaster-app/plan.md) |
| ⬜ | Ståvejledningen ("stå på promenaden med fjorden til venstre") forsvandt med `vantagePoint`. Skal den tilbage, hører den til som indhold | [ADR 0006](../ADR/0006-kontrakten-forenklet.md) |
| ⬜ | `backend-deploy.yml` udløses af `backend/**` — også af en rettet README. Workflowets egen kommentar siger, det ikke må ske | [udrulning.md](../drift/udrulning.md) |
| ⬜ | Rigtige konti og roller håndhævet server-side (princip IV) | [ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md) |
