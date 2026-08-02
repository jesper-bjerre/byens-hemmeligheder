# Research: hvordan opgavedata skal lagres

**Feature**: 003 — Indholdslageret | **Dato**: 2026-08-02
**Input**: [spec.md](./spec.md)

Analysen svarer på ét spørgsmål: **hvad skal holde opgavedata, nu hvor de
skrives fra en telefon og læses af alle?**

## Hvordan det ser ud i dag

Alt indhold ligger i **én** blob: `da-DK/content-pack.json`.

| Måling | Værdi |
|---|---|
| Pakkens størrelse | 48.319 bytes |
| Opgaver | 11 |
| Pr. opgave inkl. sted, medier og kilder | ~4,4 KB |
| Steder / medier / kilder | 11 / 31 / 6 |

Fremskrevet: 100 opgaver ≈ 440 KB, 500 opgaver ≈ 2,1 MB.

**Læsning** sker ved hver appstart, betinget med `If-None-Match`. Serveren
sammenligner et indholdshash og svarer som regel `304` uden krop. Den vej er
billig og bliver ved med at være det.

**Skrivning** sker sjældent — men **hver eneste gemning sender hele pakken**.
En quizmaster, der retter en stavefejl, lægger i dag 48 KB op. Ved 500 opgaver
er det 2,1 MB over 4G, mens hen står ude i marken.

## De tre problemer, der skal løses

### 1. Skrivningen koster hele pakken

Prisen for en rettelse er uafhængig af rettelsens størrelse. Det er ikke et
problem i dag; det er et problem, der vokser lineært med succesen.

### 2. `If-Match` dækker for meget

Optimistisk samtidighed er sat på **pakken**. To quizmastere, der retter hver
sin opgave i hver sin ende af landet, kolliderer. `PackMerge` findes præcis for
at rydde op efter det. Det er en god trevejsfletning — men den findes for at
behandle et symptom, som forsvinder, hvis samtidigheden sættes på den enkelte
opgave.

### 3. Kladder udleveres til alle

`GET /content/{locale}/pack` sender pakken, som den ligger. Den indeholder
kladder: ufærdige gåder, foreløbige koordinater og **de accepterede svar**.
Spillerappen filtrerer dem fra med `isPlayable`, men filtreringen sker på
klienten. Enhver, der kender adressen, kan hente en gåde, der ikke er udgivet
endnu.

Svarene ligger klientside med vilje — spillet skal kunne afvikles uden dækning.
Men et **uudgivet** svar burde ikke gøre det, og et menneskes beslutning om at
udgive burde have en virkning på serveren og ikke kun i en `filter`-linje
(forfatningens princip III).

## Hvad forfatningen allerede siger

Afsnittet **Tekniske rammer** er utvetydigt:

> Relationel database er den primære domænedatabase for indhold, versioner,
> progression og point. Table Storage anvendes kun til simple sidebehov.
> JSON-filer anvendes kun til engangsprototyper eller seed-data.

Stakken nævner **Azure SQL Database**, og Blob Storage kun til medier.

**Dagens løsning er altså allerede en afvigelse**, og hverken ADR 0004 eller
ADR 0005 nævner det. Rammerne må ændres "gennem en forfatningsændring eller en
ADR, der eksplicit henviser til dette afsnit" — det er ikke sket. Uanset hvad
denne analyse ender med, skal den mangel lukkes.

## Mulighederne

### A. Som i dag — én pakke

**For**: Ingen ændring. Én fil at læse, at sikkerhedskopiere og at forstå.
Betinget læsning virker perfekt.

**Imod**: Alle tre problemer ovenfor. Skrivningen vokser med samlingen, ikke med
rettelsen.

**Holder til**: 50-100 opgaver. Langt ud over det, quizmasterne når i år.

### B. Én blob pr. opgave + en genereret pakke

Kilden bliver `da-DK/missions/<id>.json` — én lille fil med opgaven, dens sted
og dens mediebeskrivelser. Serveren **genererer** `content-pack.json` af de
opgaver, der er frigivet, hver gang en opgave gemmes.

**For**:

- Skrivningen koster ~4 KB uanset samlingens størrelse.
- `If-Match` sættes på den enkelte opgave. To quizmastere i hver sin ende af
  landet kolliderer ikke længere.
- Læsemodellen indeholder **kun** frigivet indhold. Kladder og deres svar
  forlader ikke serveren. At sætte status til Frigivet bliver en handling med en
  virkning.
- Spillerappen ændres ikke. Den henter den samme adresse og får den samme form.
- Ingen ny tjeneste, ingen skema-migrering, ingen ekstra regning.
- Blobbens egenskaber beholdes: betinget læsning, anonym adgang, versionering,
  soft delete, og filer et menneske kan læse i portalen.

**Imod**:

- To skrivninger pr. gemning (opgaven, derefter pakken). Pakken er afledt, så en
  fejlet anden skrivning kan gentages — men den skal kunne gentages, og to
  samtidige genereringer skal ikke kunne flette sig ind i hinanden.
- "Vis alle opgaver" i admin-appen bliver N kald eller ét listekald plus N. Løses
  med en tilsvarende genereret **kladdeindeks** til admin-appen.

### C. Azure Table Storage

**For**: Findes allerede på kontoen. Ekstremt billig. ETag pr. entitet gratis.
Punktopslag på `PartitionKey`/`RowKey` — fx postnummer og opgave-id.

**Imod**:

- **Læsevejen mister sin bedste egenskab.** En tabel har ingen HTTP-cache og
  ingen `304`. Hver læsning skal gennem API'et, som skal samle entiteter til en
  pakke — eller lægge den samlede pakke i blob bagefter. Gør man det, har man
  mulighed B *plus* en database.
- **En opgave er et dokument.** Kort, hints og accepterede svar er indlejrede
  lister. Table har ingen indlejrede typer, så opgaven ville ligge som JSON i en
  strengegenskab. Det er en nøgle-værdi-butik med dårligere ergonomi end blob.
- Forfatningen siger "kun til simple sidebehov". Domænets kerneindhold er ikke et
  sidebehov.

**Verdikt**: Køber ETag pr. entitet, som B også giver, og punktopslag, ingen har
brug for. Betaler med læsevejens cacheegenskab. **Nej.**

### D. Azure SQL Database — forfatningens eget valg

**For**:

- Rammerne peger på den. At følge dem koster ingen begrundelse.
- Rigtige forespørgsler, relationer og transaktioner. Temporale tabeller giver
  versionshistorik uden at bygge den.
- Den bærer også det, der **er** på vej: konti, roller håndhævet server-side
  (princip IV), progression og point.

**Imod**:

- **Ingen af de ting findes endnu.** Der er ingen konti (princip VI), og
  progression skrives lokalt (ADR 0002). Det eneste serverdata er indhold.
- Kontrakten er dokumentformet. At mappe den til tabeller med EF Core er reelt
  arbejde og trækker mod ADR 0001, hvor kontrakttyperne *er* API'ets DTO'er.
  Hver ny felttilføjelse ville kræve en migrering, hvor den i dag koster
  ingenting.
- En database løser **ikke** læsevejen. En anonym spillerapp skal ikke ramme SQL
  ved hver appstart; man ville alligevel generere en pakke og lægge den i blob.
- Omkostning og drift: en serverless-database med auto-pause koster en kold start
  netop dér, hvor en quizmaster venter.

**Verdikt**: Rigtig — men til et problem, der endnu ikke er stillet.

### E. Cosmos DB

Rigtig dokumentdatabase, global replikering, ingen skema-migrering.

**Imod**: Prisen og driften for fem quizmastere og hundrede dokumenter. Løser
lige så lidt læsevejen som D.

**Verdikt**: Nej. Genovervejes, hvis indholdet bliver flersproget og
fler-by med reelle forespørgselsbehov.

## Anbefaling

**Mulighed B nu. Mulighed D når konti, roller og progression kommer — og
uden at det bliver et brud.**

De to udelukker ikke hinanden, fordi **læsevejen og skrivevejen vil noget
forskelligt**:

| | Vil have |
|---|---|
| Læsning (mange, anonyme, hyppige) | Statisk, cachebart, versioneret, uden database i loopet |
| Skrivning (få, autentificerede, sjældne) | Små enheder, samtidighed pr. opgave, historik, rettigheder |

En genereret pakke i blob er den rigtige **læsemodel**, uanset hvad der senere
holder sandheden. Går indholdet en dag i Azure SQL, bliver blobben læsemodellen
i stedet for kilden, og spillerappen mærker det ikke. Det er den samme grænse,
der allerede er trukket i dag — den bliver bare eksplicit.

Skridt 1 er derfor lille, vendbart og fjerner de tre problemer nu, uden at
foregribe skridt 2.

## Konsekvenser, der skal håndteres

**Genereringen skal være serialiseret.** To gemninger tæt på hinanden må ikke
kunne skrive hver sin halvdel af pakken. En blob-lease på pakken under
genereringen, eller en generering, der læser alle opgaver forfra og skriver med
`If-Match`, med ét genforsøg.

**`contentVersion` bliver afledt.** Den skrives ikke længere i hånden. Den skal
ændre sig, når og kun når pakken ændrer sig — ellers holder `304`-vejen op med
at være sand.

**Fixturen i repoet ændrer form.** `pull-content.sh` henter i dag én fil. Den
skal hente kilden — opgavefilerne — for at testene fortsat dækker det, der
faktisk redigeres.

**Rækkefølgen er ikke ligegyldig.** Adgangskontrollen (mål 1) kommer først. At
lave lageret om, mens `PUT` stadig står åben for enhver, er at bygge ovenpå et
fundament, der skal rives op.
