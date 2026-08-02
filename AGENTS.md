# Byens Hemmeligheder — instruktioner til AI-klienter

Denne fil gælder **uanset hvilken klient der læser den** — Claude Code, Codex
eller noget tredje. `CLAUDE.md` peger hertil.

## ⚠️ Dette repository er PUBLIC på GitHub

Alt, der committes, kan læses af alle. En hemmelighed, der først committes og
derefter slettes, er **stadig kompromitteret** — den ligger i git-historikken,
i GitHubs caches og i alle forks og kloner. Sletning er ikke en rettelse.

## Politik for hemmeligheder

### 1. Gitignore før filen oprettes — ikke bagefter

Før du opretter, skriver til eller flytter en fil, der kan indeholde en
hemmelighed, **SKAL** du først sikre, at den er dækket af `.gitignore`.
Rækkefølgen er ufravigelig: udvid `.gitignore`, bekræft dækningen, opret
derefter filen.

Bekræft dækningen med:

```bash
git check-ignore -v <sti>
```

Kommandoen skal returnere den regel, der dækker filen. Returnerer den intet,
er filen **ikke** ignoreret, og den må ikke oprettes, før reglen er tilføjet.

### 2. Hvad der regnes som en hemmelighed

Uanset filnavn: alt der kan bruges til at logge ind, signere, betale eller
kalde en betalt tjeneste.

| Kategori | Eksempler |
|---|---|
| Miljøfiler | `.env`, `.env.local`, `fastlane/.env` |
| Private nøgler | `*.p8`, `*.p12`, `*.pfx`, `*.pem`, `*.key`, `*.jks`, `*.keystore` |
| Apple-signering | `AuthKey_*.p8` (App Store Connect API), `*.mobileprovision`, `*.provisionprofile` |
| SSH og netværk | `id_rsa`, `id_ed25519`, `.netrc`, `.npmrc`, `.pypirc` |
| Sky og tjenester | `.aws/credentials`, service account-JSON, connection strings |
| Generiske | `secrets.json`, `credentials.json`, `appsettings.*.local.json` |
| Nøgler i tekst | API-nøgler, tokens, adgangskoder og connection strings i kildekode, JSON, tests, dokumentation, kommentarer eller commit-beskeder |

Abonnements- og tenant-id'er hører i GitHub-secrets, ikke i filer i repoet.

### 3. Skriv aldrig en rigtig værdi i en sporet fil

Brug altid en pladsholder i alt, der committes:

```
APPSTORE_KEY_ID=<indsæt lokalt, commit aldrig>
```

Har en konfiguration brug for at være dokumenteret, så commit en
`*.example`-, `*.sample`- eller `*.template`-fil med pladsholdere — aldrig
filen med de rigtige værdier.

### 4. Kontrollér før hvert commit

Før `git add` og `git commit` **SKAL** du kontrollere, hvad der faktisk
lander i commit'et:

```bash
git status --porcelain
git diff --cached
```

Ser du en fil fra tabellen ovenfor blandt de sporede eller iscenesatte filer,
så **stop**. Tilføj mønsteret til `.gitignore`, fjern filen fra staging med
`git rm --cached <sti>`, og fortsæt først derefter.

`git add -A` er farlig i dette repo: der ligger ofte ændringer fra en tidligere
session i staging. Tilføj de filer, du selv har rørt, ved navn.

### 5. Hvis en hemmelighed alligevel er blevet committet

Rækkefølgen er vigtig, og den er ikke til forhandling:

1. **Rotér hemmeligheden med det samme.** Tilbagekald nøglen hos udstederen og
   udsted en ny. Dette er det eneste skridt, der faktisk lukker hullet.
2. Fjern filen fra arbejdstræet og tilføj den til `.gitignore`.
3. Sig det til brugeren — også hvis det var din egen fejl. En kompromitteret
   nøgle i et public repo skal et menneske forholde sig til.

Forsøg **ikke** at omskrive historikken (`filter-repo`, `force push`) uden at
brugeren udtrykkeligt beder om det. Det ødelægger klonede kopier og fjerner
alligevel ikke nøglen fra GitHubs caches eller fra eksisterende forks.

### 6. Rapporterings- og logdata

Feltdata, GPS-spor, testerfeedback og diagnostiske eksporter kan indeholde
personoplysninger. De følger forfatningens princip VI om dataminimering og
committes ikke uden at være gennemgået først.

`audit.jsonl` i blob bærer quizmasternes navne og forlader ikke serveren.

## Forhold til forfatningen

`.specify/memory/constitution.md` er projektets øverste normative dokument.
Denne fil er en arbejdsinstruks og må ikke modsige den. Ved konflikt gælder
forfatningen.

Forfatningens **Tekniske rammer** må kun fraviges gennem en forfatningsændring
eller en ADR, der **eksplicit henviser til afsnittet**. Det blev overtrådt i
ADR 0004 og 0005 og er rettet op i
[ADR 0007](./docs/ADR/0007-blob-nu-relationelt-naar-der-er-konti.md). Sker det
igen, skriv det ned frem for at lade det stå.

---

## Hvad projektet er

En stedsbaseret gåde-app til familier. Man går hen til et sted, og først dér
låser gåden op. To apps og en tjeneste:

| Mappe | Hvad |
|---|---|
| `iOS/` | Spillerappen *Byens Gåder* og `BHKit` (6 SPM-targets) |
| `iOS-admin/` | Quizmaster-appen — opretter og retter opgaver i felten |
| `backend/` | ASP.NET Core-API'et |
| `contracts/` | Skema, golden-filer, testvektorer, og en **fixtur** af indholdet |
| `docs/` | Beslutninger (`ADR/`), drift, arkiv, køreplan |
| `specs/` | Feature-specifikationer og planer (spec-kit) |

**Indholdet ejes af Azure Blob Storage, ikke af repoet.**
`contracts/content/da-DK/content-pack.json` er en fixtur, testene læser — den er
ikke kilden. Se [ADR 0005](./docs/ADR/0005-blob-er-kilden-til-indholdet.md).

## Hvad du skal læse først

1. **[docs/plans/koereplan.md](./docs/plans/koereplan.md)** — hvad der arbejdes
   på nu, i hvilken rækkefølge og hvorfor.
2. `.specify/memory/constitution.md` — de syv principper. Fire er
   NON-NEGOTIABLE.
3. `docs/ADR/` — hvorfor tingene er, som de er. 0007 er **Foreslået** og
   afventer et ja.

## Sprog

**Dansk** i alt, en quizmaster eller en spiller kan se, og i al dokumentation,
kommentarer og commit-beskeder. **Engelske attributnavne** i JSON og på wire.
Kontrakten hedder `description`, `basePoints`, `fictionLabel`; UI'et siger
"Beskrivelse", "Point", "Fiktionsmarkering".

## Byg og test

**Backend** — kræver .NET 10 i `~/.dotnet` og PATH sat i `~/.zshenv` (ikke
`~/.zshrc`, som kun læses i interaktive shells):

```bash
cd backend && dotnet build && dotnet test
./backend/run.sh            # starter på port 5199
```

**BHKit** — `swift test` kræver, at Xcode er valgt, ellers findes modulet
`Testing` ikke:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift test --package-path iOS/Packages/BHKit
```

Enhedstests er standarden. UI-tests køres kun på opfordring, og under fejlsøgning
med `-only-testing:`.

**Apperne** bygges med `xcodebuild` mod simulatoren **iPhone 17** — ikke 17 Pro.
Enhedsforskellen har skjult en rigtig fejl før.

### Fælder, der har kostet tid før

- **SIGBUS i `swift test`** betyder som regel en forældet `.build`. Slet
  `iOS/Packages/BHKit/.build` og kør igen.
- **Kontrakttests mod blob** springes over uden `BH_TEST_BLOB_URI`. De skriver
  og sletter under et tilfældigt præfiks — kør dem aldrig mod produktion.
- **De to udrulningsfælder** (GitHubs uforanderlige OIDC-emne, og at SCM-basis-
  godkendelse er slået fra) står i
  [docs/drift/udrulning.md](./docs/drift/udrulning.md).

## Sådan arbejdes der her

- **Planfiler hører hjemme i `docs/plans/`.** Det gælder planer, der skal
  bevares i repoet; Codex' midlertidige planvisning behøver ikke blive skrevet
  til en fil.
- **Spec Kit-skills findes i klienternes native mapper.** Codex-versionerne er
  i `.agents/skills/`, og Claude Code-versionerne er i `.claude/skills/`.
  Ændres eller geninstalleres Spec Kit, SKAL begge sæt holdes funktionelt
  ens; invocation-syntaksen er `$speckit-*` i Codex og `/speckit-*` i Claude.
- **Beslutninger skrives ned.** En begrundelse, der kun findes i en chat, er
  tabt. Nye arkitekturvalg bliver en ADR i `docs/ADR/` med formen
  Kontekst → Beslutning → Begrundelse → Konsekvenser → Alternativer.
- **Skriv også prisen.** Hver ADR her siger, hvad beslutningen kostede, ikke kun
  hvad den gav. En ADR uden konsekvenser er en reklame.
- **Kommentarer forklarer hvorfor**, ikke hvad. Koden i dette repo er tæt
  kommenteret på dansk, og den vane skal holdes.
- **Simplere UI vinder.** Quizmaster-appen er skåret ned flere gange efter rigtig
  felttest. Et felt, der skal gemmes bag en kontakt, skulle have været slettet af
  kontrakten. Se [specs/002-quizmaster-app/plan.md](./specs/002-quizmaster-app/plan.md).
- **Commits går direkte på `main`.** Det er aftalt med brugeren.
- Backenden udruller automatisk ved push til `main`, der rører `backend/**`.
  B1-planen har ingen deployment slots, så en udrulning går direkte i luften.

## Det, der ikke er i orden lige nu

- **API'et har ingen adgangskontrol.** `PUT` og `DELETE` står med
  `AllowAnonymous()`. Det er accepteret, mens der testes, og er første punkt i
  køreplanen.
- **`httpsOnly` er `false`** på App Service.
- **Kladder udleveres til alle**, der kender adressen — inklusive svarene på
  gåder, der ikke er udgivet.
- **`BH_DEV_TOOLS` er tændt i spillerappens Release.**
