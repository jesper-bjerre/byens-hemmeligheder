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

Læg det i PATH via `~/.zshenv` — **ikke** `~/.zshrc`:

```bash
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
```

Zsh læser kun `.zshrc` i *interaktive* shells. Står linjerne der, virker
`dotnet` i terminalen, men ikke i scripts, byggeværktøjer eller noget, der
kalder `zsh -c` — og fejlen ser ud som "dotnet er ikke installeret". Det samme
gælder Homebrew og dermed `az`.

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

## Lageret

Der er to implementeringer af `IContentStore`, og de er dækket af **den samme**
testsuite (`ContentStoreContractTests`). Grænsefladen findes for at kunne skifte
lager uden at røre endepunkterne, og det løfte holder kun, hvis de to opfører
sig ens.

| | `FileSystem` | `Blob` |
|---|---|---|
| Bruges | lokalt | i Azure |
| Samtidighed | læs, sammenlign, skriv — ikke atomisk | `If-Match` på blobbens ETag |
| Sporet | `FileMode.Append` | append blob |
| Adgang | mappen | managed identity |

Skiftes med `ContentStore:Provider`.

### ETag'en er to ting

Klienterne får en **indholdshash**, så en pakke, der migreres eller genskabes
uændret, beholder sin ETag og alle apps får `304` frem for at hente alt igen.
Blobbens egen ETag ændrer sig ved hver skrivning, også når indholdet er det
samme — den kan ikke bruges til det.

Til gengæld er blobbens ETag det eneste, der gør en skrivning atomisk. Derfor
bæres begge: hashen ligger som metadata på blobben, så en skrivning kun behøver
at hente egenskaberne for at se, om klienten skrev oven på den udgave, hen troede.

### Kør mod en DEV-konto

Opret i portalen eller med `az`:

- en storage-konto, fx `byensgaaderd`
- en container ved navn `content`
- rollen **Storage Blob Data Contributor** til dig selv på kontoen

Derefter:

```bash
az login
dotnet user-secrets set "ContentStore:Provider" "Blob"
dotnet user-secrets set "ContentStore:StorageAccountUri" "https://byensgaaderd.blob.core.windows.net"
```

`DefaultAzureCredential` bruger dit `az login` lokalt og managed identity i
Azure. Der er ingen nøgle at lække og intet at rotere, hvis repoet er public.

Kontrakttestene mod Azure køres sådan — de er ellers markeret som oversprunget:

```bash
BH_TEST_BLOB_URI="https://byensgaaderd.blob.core.windows.net" dotnet test
```

> De skriver og sletter. Kør dem aldrig mod produktion.

### Udrulning

Hvad der kører i Azure, hvordan det kommer derop, og de to fælder, der kostede
en halv dag: [`docs/drift/udrulning.md`](../docs/drift/udrulning.md).

Indholdet i blob ejes ikke af dette repo — se
[ADR 0005](../docs/ADR/0005-blob-er-kilden-til-indholdet.md).

## Hemmeligheder

Ingen nøgler i `appsettings.json`. Den fil er sporet og ligger i et **public**
repo.

- **Lokalt:** `dotnet user-secrets set "ContentStore:StorageAccountUri" "..."` —
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

## Endepunkter

| | | |
|---|---|---|
| `GET` | `/health` | Sundhedstjek |
| `GET` | `/content/{locale}/pack` | Indholdspakken. ETag og `304` |
| `GET` | `/content/{locale}/media` | Hvilke medier der ligger |
| `GET` | `/content/{locale}/media/{fil}` | Ét billede eller én lydfil |
| `GET` | `/content/{locale}/audit` | Sporet over ændringer. Nyeste først |
| `PUT` | `/content/{locale}/pack` | Gemmer pakken. Kræver `If-Match` og `X-Quizmaster` |
| `POST` | `/content/{locale}/media/{fil}` | Lægger et medie op. `409` på et kendt navn |
| `DELETE` | `/content/{locale}/media/{fil}` | Fjerner et medie |

`PUT` bruger **optimistisk samtidighed**: klienten sender den ETag, pakken blev
hentet med. Har en anden gemt i mellemtiden, svares `412`, og klienten skal
hente igen. Alle quizmastere kan rette i alt, så uden det taber den, der gemmer
sidst, den andens arbejde uden at nogen opdager det.

Serveren kontrollerer, at kroppen er gyldig JSON med `contentVersion` og
`missions` — ikke kontrakten i dybden. Den grænse er bevidst: serveren beskytter
mod ulæselige filer, ikke mod dårligt indhold. En server, der kender kontrakten,
skal udrulles hver gang den udvides.

## Sporet over ændringer

Hver gemning skriver en linje i `{locale}/audit.jsonl`: hvem, hvornår, hvilken
opgave og fra og til hvilken status (FR-111). Filen kan kun tilføjes til, og der
findes intet endepunkt, der kan rette i den — et revisionsspor, der kan
redigeres af dem, det holder øje med, beviser ingenting.

Navnet står i `X-Quizmaster`, og mangler det, afvises gemningen med `400`. Det
er ikke godtgørelse; der er ingen adgangskontrol endnu. Men et spor, klienten
kan springe over, mangler netop de gemninger, hvor nogen havde travlt — og det
er dem, man spørger til bagefter.

Sporet er det eneste sted, serveren kigger ned i pakken, og den læser kun tre
feltnavne: `contentVersion`, `missions[].id` og `missions[].status`. Skifter de
navn, står der ingenting i sporet; pakken gemmes stadig.

## Endnu ikke besluttet

To af de tre oprindelige spørgsmål er besvaret i `specs/002-quizmaster-app`:
quizmaster-værktøjet er sin **egen app**, så spillerne ikke arver hver
hastværksudgivelse, og der er **ingen godkendelsesgang** — alle quizmastere kan
flytte enhver opgave mellem statusser, og sporet står i stedet for godkendelsen.

Tilbage står:

1. Skal spillere have konti? Hi-scores kræver det; ellers forbliver læsevejen
   anonym og gratis.
2. Hvordan godtgøres en quizmaster? `X-Quizmaster` er i dag et navn, klienten
   selv skriver. Det er nok til at spore, men ikke til at nægte adgang, og
   admin-rollen i specs/002 styrer brugere, der endnu ikke findes.
