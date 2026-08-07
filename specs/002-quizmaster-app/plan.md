# Implementation Plan: Quizmaster-appen

**Branch**: `main` | **Date**: 2026-08-01 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-quizmaster-app/spec.md`

## Summary

Feature 002 giver quizmasterne en iPhone-app, så en opgave kan oprettes og
rettes stående på stedet — med kameraet, med telefonens position, uden git og
uden at nogen redigerer JSON i hånden.

Den bærende tekniske beslutning står allerede i spec'en: **appen modellerer ikke
kontrakten**. `PackDocument` henter pakken som JSON, retter enkeltfelter og
sender den tilbage. Felter, appen ikke kender, overlever en gemning uændret.

Den bærende *redaktionelle* beslutning kom undervejs og var ikke planlagt:
**hvert felt i kontrakten blev til et felt på en skærm**, der skal udfyldes
udendørs med én hånd. Det afslørede, at kontrakten bar felter, hvis svar
allerede var givet et andet sted. Feature 002 forenklede derfor kontrakten selv
— se [ADR 0006](../../docs/ADR/0006-kontrakten-forenklet.md) — og flyttede
ejerskabet af indholdet fra repoet til blob — se
[ADR 0005](../../docs/ADR/0005-blob-er-kilden-til-indholdet.md).

## Technical Context

**Language/Version**: Swift 6, SwiftUI. Deployment target iOS 18.0. Backend
.NET 10 / ASP.NET Core med FastEndpoints

**Primary Dependencies**: Kun Apples egne frameworks — SwiftUI, MapKit,
PhotosUI, CoreLocation. Backenden bruger `Azure.Storage.Blobs` og
`Azure.Identity`

**Storage**: Azure Blob Storage er kilden (ADR 0005). Appen holder en kladde på
disk i `Application Support`, så et afbrudt arbejde overlever, at appen lukkes

**Testing**: swift-testing i et eget `ByensGaaderAdminTests`-target — 60 tests i
syv suiter (Dokumentet, Fletning, Kladden, Ordbogen, Postnumre, Grafikken, Serveren).
xunit v3 i backenden, hvor `ContentStoreContractTests` kører de samme 18
kontroller mod både filsystem og blob

**Target Platform**: iPhone, portrait. TestFlight **intern test** — se spec'ens
afsnit om App Store

**Project Type**: Native mobilapp mod en HTTP-tjeneste

**Constraints**: Skal kunne oprette en opgave i felten uden stabil dækning.
Kontraktændringer må ikke kunne tabes af appen. Ingen godkendelsesgang mellem
quizmastere — sporet er den eneste kontrol

**Scale/Scope**: 5 quizmastere, én indholdspakke, 5 faneblade, 11 opgaver i dag

## Constitution Check

*GATE: Skal bestås før Phase 0 research. Genvurderet efter implementering.*

| Princip | Gate | Status | Hvordan planen opfylder den |
|---|---|---|---|
| **I. Stedet er spillet** (NON-NEG.) | Præcist startsted registreret | ✅ | Knappen "Brug min position" skriver telefonens koordinat, mens quizmasteren står der. Kortet viser markering og aktiveringsradius, så et fejlplaceret punkt ses med det samme. Princippet blev **ændret** til at kræve ét startsted frem for GPS + kigretning + ståflade (ADR 0006) |
| **II. Entydigt og bevisbart facit** (NON-NEG.) | Ét kanonisk facit, eksplicitte alternativer | ⚠️ | Facit skrives nu af det første accepterede svar frem for at være et felt. Kravet er opfyldt ved konstruktion, men selvkonsistenstesten V-02 beviser det ikke længere for indhold skrevet i appen — se Complexity Tracking |
| **III. AI assisterer, mennesker udgiver** (NON-NEG.) | Ingen automatisk publicering | ✅ | Et menneske flytter status til "Frigivet". Serveren udgiver intet af sig selv |
| **IV. Sikkerhed, adgang, rettigheder** (NON-NEG.) | Adgangskontrol, pausefunktion, rettighedslog | ❌ | Feature 001's afvigelse er lukket: en opgave kan tages ud af spil fra telefonen ved at sættes tilbage til "Kladde", og spillerappen holder op med at vise den — uden en app-opdatering. **Men API'et har ingen adgangskontrol** — se Complexity Tracking og [udrulning.md](../../docs/drift/udrulning.md) |
| **V. Serverbåret og versionsfastholdt** | Indhold fra tjenesten; idempotent | ✅ | Blob er kilden (ADR 0005). `If-Match` på hver gemning; ETag er et indholdshash, så en gemning uden ændringer ikke tæller som en |
| **VI. Privatliv og dataminimering** (NON-NEG.) | Ingen unødige personoplysninger | ⚠️ | `X-Quizmaster` er et navn, quizmasteren selv skriver, og det er nødvendigt for FR-111. Revisionssporet forlader aldrig blob og hentes ikke af `pull-content.sh` |
| **VII. Tilgængelig familieoplevelse** | Ingen tidspres; små fradrag | ✅ | Princippet blev **udvidet**: et forkert svar koster nu point, med loft, og en gennemført opgave giver aldrig under 76 af 100 (ADR 0006) |

**Resultat**: Bestået med tre registrerede afvigelser. Princip IV's manglende
adgangskontrol er den eneste, der spærrer for rigtig brug.

## Designvalg truffet under implementeringen

Spec'ens afsnit *Designvalg, der allerede er truffet* dækker de tre, der lå fast
på forhånd. Disse kom af felttest og skal ikke rulles tilbage uden grund.

### Skærmen skal kunne bruges med én hånd i regnvejr

**Ingen Gem-knap.** Der gemmes, når fanebladet forlades. En knap, der viser
"Gem" uden at kvittere for, at der blev gemt, får folk til at trykke igen — og
den, der ikke trykkede, mister sit arbejde. Det er også derfor, kladden skrives
til disk med to sekunders forsinkelse, uafhængigt af serveren.

**Intet Avanceret view.** Der var et, og det blev fjernet. Et felt, der er værd
at have, hører hjemme på skærmen; et felt, der skal gemmes bag en kontakt,
skulle have været slettet af kontrakten. Rettigheder, medietype, filnavn,
kodelængde, sammenligningsform og fiktionsmarkering udfyldes derfor automatisk
med den værdi, de alligevel altid fik.

**Ét tekstfelt pr. ting.** Et hint havde titel og tekst; titlen er nu
"Hint 1" og står i sektionsoverskriften. Et spørgsmål havde overskrift og
spørgsmål; overskriften udledes. To felter, der spørger om det samme med to ord,
bliver udfyldt to gange med det samme.

**Pile frem for træk-og-slip.** Træk krævede, at listen stod i
redigeringstilstand konstant, hvilket fyldte hver række med et håndtag og en rød
cirkel. Med tre detaljer er et træk desuden besværligere end et tryk.

**Billedet er selv knappen.** En knap ved siden af siger ikke, hvilket billede
den hører til, når der er tre.

**Tastaturet skal kunne lukkes.** Der er en Færdig-knap over tastaturet, og
listen lukker det, når man ruller. Uden det kan man ikke skifte faneblad, mens
man skriver — fanebladene ligger under tastaturet.

### Tre statusser i arbejdsgangen

Appen tilbyder **Kladde** (`draft`), **Klar til udgivelse** (`fieldTestReady`)
og **Frigivet** (`published`). Navnene beskriver både redaktionens næste skridt
og spillerens adgang. Kontrakten accepterer fortsat `researchReady`, `paused`
og den ældre `publishReady`, men nye admin-klienter opretter dem ikke.

Bærer en opgave alligevel en ældre status — fordi den blev skrevet i hånden, eller
fordi kontrakten er nyere end appen — vises den med sit rigtige navn og lægges
til som et ekstra valg. En status, quizmasteren ikke kan se, er værre end en,
hen ikke forstår; en opgave, hen ikke kan flytte, er værst.

### Hierarkiet og postnumrene

`Area` blev ikke udvidet med `region` og `postalCode`, som spec'ens
*Rækkefølge* punkt 1 lagde op til. Den blev fjernet. Postnummeret bestemmer både
by og landsdel, og en tabel over Danmarks 1089 postnumre er genereret ind i
koden fra Dataforsyningen — den skal virke uden dækning, og det er præcis i
felten, den bruges.

### Flettning frem for at tabe arbejde

`If-Match` fanger, at to quizmastere rettede samtidig. Det siger ikke, hvad man
så gør. `PackMerge` laver en trevejsfletning på base/vores/deres: arrays flettes
på `id`, og kun felter, begge parter rettede til noget forskelligt, meldes som
konflikt. Derfor holder `PackDocument` en `base`-kopi ved siden af sin egen.

### Serveren vælges ved navn, ikke ved at taste en adresse

FR-102 siger, at adressen er en konfiguration og ikke et felt. En vælger mellem
**Drift** og **Lokal maskine** bryder ikke det: der er intet at stave forkert,
og adresserne står stadig ét sted. Vælgeren findes kun i Debug — en udsendt
bygning peger på drift og bliver der.

### Serveren validerer ikke kontrakten

`PUT /content/{locale}/pack` gemmer, hvad den får. Det var bevidst: en server,
der afviser en kladde, fordi et felt mangler, gør det umuligt at gemme halvt
arbejde og gå videre. Prisen blev betalt med det samme — en tom opgave stod
frigivet i produktion, indtil fixturen blev synkroniseret og testene fangede den
(ADR 0005). **Testene mod fixturen er publiceringsporten**, ikke API'et.

## Project Structure

### Documentation (this feature)

```text
specs/002-quizmaster-app/
├── spec.md              # Feature-specifikation
└── plan.md              # Denne fil
```

Ingen `research.md`, `data-model.md` eller `tasks.md`. Featuren blev bygget
inkrementelt mod en quizmaster, der testede i felten mellem hver runde, og
beslutningerne er skrevet ned bagefter — her og i ADR 0005 og 0006.

### Source Code (repository root)

```text
iOS-admin/ByensGaaderAdmin/
  ByensGaaderAdmin.xcodeproj
  ByensGaaderAdmin/
    ByensGaaderAdminApp.swift
    ContentView.swift            # Forsiden
    Hierarchy.swift              # Landsdel → postnummer → opgaver (FR-105)
    AdminConfiguration.swift     # Serveren, quizmasterens navn (FR-102, FR-111)
    PackClient.swift             # HTTP, ETag, If-Match
    PackDocument.swift           # JSON-stien som redigeringsmodel
    PackBindings.swift           # SwiftUI-bindinger ned i JSON'en
    PackMerge.swift              # Trevejsfletning ved 412
    DraftStore.swift             # Kladde på disk
    MissionFactory.swift         # Nye opgaver og standardtekster
    Vocabulary.swift             # Danske navne til kontraktens værdier (FR-104)
    Postnumre.swift              # Genereret — 1089 postnumre
    MissionEditorView.swift      # De fem faneblade
    PlaceTab.swift               # Kort, markering, "Brug min position" (FR-107)
    CardsTab.swift               # Detaljer: billede + tekst, pile (FR-108)
    QuestionTab.swift            # Svartype og accepterede svar
    HintsTab.swift               # Ét felt pr. hint (FR-109)
    MediaUpload.swift            # Kamera og fotobibliotek
    LocationProvider.swift
    AuditView.swift              # Sporet (FR-111)
    KeyboardDismiss.swift
  ByensGaaderAdminTests/         # 60 tests
    PackDocumentTests.swift      # Dokumentet, Ordbogen, Postnumre
    PackMergeTests.swift         # Fletning, Kladden
    AssetTests.swift             # Grafikken, Serveren
    ContractFixtures.swift       # Læser den samme fixtur som BHKit
  Tools/generate-postnumre.py

backend/src/ByensGaader.Api/
  Features/Content/
    PutPackEndpoint.cs           # If-Match, X-Quizmaster
    MediaWriteEndpoints.cs       # 409 på kendt filnavn
    AuditTrail.cs                # JSON Lines, diff på id og status
    GetAuditEndpoint.cs
  Storage/
    IContentStore.cs
    ContentPath.cs               # Delt sti- og ETag-logik
    FileSystemContentStore.cs
    BlobContentStore.cs
backend/seed-content.sh          # repo → blob, kun til en tom container
backend/pull-content.sh          # blob → fixtur

.github/workflows/
  backend-ci.yml
  backend-deploy.yml             # Med kontrol af at /health svarer 200
```

**Structure Decision**: `iOS-admin/` er en fritstående rodmappe ved siden af
`iOS/` og deler **ikke** BHKit. Spec'ens begrundelse er stabilitet — spillerne
skal ikke arve admin-appens hastværksudgivelser — men der er en pris:
`Mission.isPlayable`, statusnavnene og normaliseringsreglerne findes nu to
steder. Admin-appens `ContractFixtures` læser den samme fixtur som BHKit, så en
kontraktændring, der kun bliver lavet ét af stederne, får tests til at fejle.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| **Princip IV: API'et har ingen adgangskontrol.** Hvert endepunkt står med `AllowAnonymous()` — også `PUT` og `DELETE`. Enhver, der finder adressen, kan omskrive pakken | Accepteret bevidst, mens quizmasterne testede på TestFlight. Alternativet var at udskyde al felttest, indtil brugerkonti fandtes, og dermed teste appen uden nogen, der havde brugt den | Den midlertidige idé om en delt nøgle er forkastet. Næste feature implementerer direkte Log ind med Apple, egne sessions og de serverstyrede roller User, Designer og Admin. Se [`docs/plans/authentication-og-roller.md`](../../docs/plans/authentication-og-roller.md) |
| **Princip II: V-02 beviser mindre end før.** `canonicalAnswer` skrives af det første accepterede svar, så selvkonsistenstesten er sand pr. konstruktion for indhold fra appen | To felter, hvor det ene skal være en kopi af en linje i det andet, er to steder at tage fejl. Fejlen forhindres nu ved kilden i stedet for at blive fanget bagefter | At beholde facit som et redigerbart felt ville bevare testens beviskraft, men først indføre den fejl, den skulle fange. Svækkelsen står skrevet i `answer-normalization.md`, i svarmotorens kommentar og i ADR 0006, så ingen senere læser V-02 som en garanti |
| **Formkravene i BHKits tests gælder kun `isPlayable`-opgaver** | Da pakken blev håndredigeret, var enhver ufærdig opgave en fejl. Nu er en kladde under arbejde normal, og spillerappen viser den ikke | At kræve detaljer og miniature af alle opgaver ville gøre testsuiten rød, hver gang en quizmaster begyndte på noget. Referencer, id-entydighed, hints, svarregler og rettigheder holdes stadig for **alle** opgaver |

## Hvad der mangler

- **Fase 5**: Authentication, serverstyrede roller og lukning af authoring-API.
  Se [authentication-og-roller.md](../../docs/plans/authentication-og-roller.md).
- **`BH_DEV_TOOLS` er stadig tændt i spillerappens Release.** Spec'en siger, den
  kan slukkes, når GPS-simulering og nulstilling er flyttet herover. Det er de.
- **De syv `mission.ny-opgave-N`-id'er** skal have rigtige slugs, når titlerne
  er på plads. Id'et er ikke synligt for spilleren, men det står i medienavne.
- **Admin-appen har ingen UI-tests.** En fejlrapport om, at kun to faneblade var
  synlige, kunne aldrig genskabes, og der er ikke noget, der ville have fanget
  den.
- **Én JSON pr. opgave i blob plus et indeks.** Udskudt bevidst, til appen har
  været i brug.
