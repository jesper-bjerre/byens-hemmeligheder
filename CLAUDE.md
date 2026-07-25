# Byens Hemmeligheder — instruktioner til Claude Code

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

## Forhold til forfatningen

`.specify/memory/constitution.md` er projektets øverste normative dokument.
Denne fil er en arbejdsinstruks til Claude Code og må ikke modsige den. Ved
konflikt gælder forfatningen.
