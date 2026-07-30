# Backend

Quizmasternes API. ASP.NET med FastEndpoints, kører på macOS og Windows.

## Hvad dette API **ikke** gør

Spillernes app henter **ikke** herfra. Indholdspakker og billeder ligger som
statiske filer i Azure Blob Storage og hentes direkte med ETag — appens
`ContentPackSource` taler allerede det sprog.

Det er ikke en forenkling for nu; det er arkitekturen:

| | Læsning (spillere) | Skrivning (quizmastere) |
|---|---|---|
| Hvem | Alle, anonymt | Få, godkendte |
| Hvad | Statisk JSON og billeder | Dette API |
| Skalering | Ingen server involveret | Skalerer til nul |
| Pris | Nærmest ingenting | Kun når nogen redigerer |

API'et bruges altså kun, når en quizmaster opretter eller retter en opgave.
Derfor kan det sove resten af tiden.

## Kom i gang

Kræver **.NET 10 SDK**. Det er installeret i `~/.dotnet` uden
administratorrettigheder, fordi Homebrews cask kræver `sudo`:

```bash
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0
```

Læg det i din PATH — fx i `~/.zshrc`:

```bash
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
```

Derefter:

```bash
cd backend
dotnet restore
dotnet build
dotnet test
```

## Start serveren, så appen virker i simulatoren

```bash
./backend/run.sh
```

Scriptet sætter PATH til .NET i hjemmemappen, starter på port 5199 og slår
forespørgselslogning til — så det kan **ses**, at appen faktisk ringer. Uden det
ligner en tavs server en app, der ikke prøver, og det kostede flere runder at
opdage.

Det advarer også, hvis porten ikke stemmer med `BH_CONTENT_BASE_URL` i
`iOS/Config/Local.xcconfig`. Gør den ikke det, henter appen ingenting, og fejlen
ser ud som manglende indhold frem for en forkert port.

En anden port: `PORT=5200 ./backend/run.sh` — husk at rette xcconfig tilsvarende.

API'et lytter på `http://localhost:5xxx`. Swagger findes på `/swagger` — kun i
udvikling. En API-beskrivelse er en køreplan for den, der vil finde huller.

Kontrollér sundhedstjekket:

```bash
curl http://localhost:5xxx/health
```

## Struktur

```
backend/
  Directory.Build.props      Fælles indstillinger for alle projekter
  Directory.Packages.props   Alle pakkeversioner ét sted (Central Package Management)
  ByensGaader.slnx           Løsningsfil i det nye XML-format
  src/ByensGaader.Api/
    Program.cs               Opstart og rutning
    Features/                Én mappe pr. funktion, ikke pr. lagtype
  tests/ByensGaader.Api.Tests/
```

Mapperne følger **funktion**, ikke lag. `Features/Health/` indeholder alt om
sundhedstjekket. Der kommer ingen `Controllers/`, `Services/`, `Models/` —
den opdeling spreder én ændring ud over fire mapper.

## Hemmeligheder

Ingen nøgler i `appsettings.json`. Den fil er sporet og ligger i et **public**
repo.

- **Lokalt:** `dotnet user-secrets set "Azure:StorageAccountUri" "..."` —
  gemmer uden for repoet.
- **I Azure:** managed identity. Ingen nøgle at lække.

`appsettings.Development.json`, `appsettings.local.json` og
`appsettings.Production.json` er dækket af `.gitignore`. Kontrollér med
`git check-ignore -v <sti>`, hvis du er i tvivl.

## Testkøreren

xunit **v3** kører på Microsoft.Testing.Platform, ikke på den gamle VSTest.
Derfor står `TestingPlatformDotnetTestSupport` i `Directory.Build.props`, og
`Microsoft.NET.Test.Sdk` er bevidst fravalgt.

Uden den indstilling siger `dotnet test` "No test is available" **uden at
fejle** — den grønneste måde at have nul dækning på.

## Ruter er eksplicitte

Der er hverken globalt rutepræfiks eller versionering. Begge dele blev prøvet og
fjernet igen: de omskrev ruterne bag ryggen på endepunkterne, så `/health` blev
til noget andet, end der stod i koden. Hvert endepunkt angiver sin fulde rute.

Versionering tilføjes, når der findes et endepunkt, der skal versioneres.

## Endnu ikke besluttet

Skelettet indeholder med vilje kun et sundhedstjek. Tre spørgsmål skal besvares,
før der bygges endepunkter:

1. Er quizmaster-værktøjet en del af Byens Gåder eller en selvstændig app?
2. Skal spillere have konti? Hi-scores kræver det; ellers forbliver læsevejen
   anonym og gratis.
3. Hvem godkender en opgave, før den bliver synlig? En godkendelsesgang ændrer
   datamodellen — kladde, indsendt, godkendt, publiceret.
