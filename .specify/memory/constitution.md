<!--
SYNC IMPACT REPORT
==================
Version: 1.0.0 → 2.0.0
Bump-type: MAJOR (princip V omdefineret bagudinkompatibelt)

Ændring 2026-07-27 — princip V:
  Var:  "Offline-tolerant og versionsfastholdt afvikling" — sessionen SKULLE
        kunne gennemføres uden netværk, og indholdet var bundlet med appen.
  Nu:   "Serverbåret og versionsfastholdt afvikling" — alt indhold hentes fra en
        central tjeneste, og appen kræver forbindelse.
  Hvorfor: to kilder til indhold (bundle + server) kan drive fra hinanden, og
        princip IV's krav om øjeblikkelig pause uden deploy er umuligt, når
        facit ligger i en binær på tusind telefoner. Se docs/ADR/0004.
  Pris: en tur uden dækning kan ikke gennemføres. Bevidst byttehandel.
  Uændret: progression skrives lokalt først og synkroniseres idempotent;
        GameSession fastholder sin indholdsversion.

Historik:
Version: TEMPLATE (ikke-udfyldt) → 1.0.0
Bump-type: MAJOR (første ratificering — alle principper defineret fra bunden)

Principper (nye):
  I.   Stedet er spillet (lokationsspecificitet) — NON-NEGOTIABLE
  II.  Entydigt og bevisbart facit — NON-NEGOTIABLE
  III. AI assisterer, mennesker udgiver — NON-NEGOTIABLE
  IV.  Sikkerhed, adgang og rettigheder går forud for spilværdi — NON-NEGOTIABLE
  V.   Serverbåret og versionsfastholdt afvikling
  VI.  Privatliv ved design og dataminimering — NON-NEGOTIABLE
  VII. Tilgængelig familieoplevelse uden tidspres

Tilføjede sektioner:
  - Tekniske rammer (erstatter [SECTION_2_NAME])
  - Udviklings- og redaktionelt workflow (erstatter [SECTION_3_NAME])
  - Governance (udfyldt)

Fjernede sektioner: ingen

Templates og afhængige artefakter:
  ✅ .specify/templates/plan-template.md — "Constitution Check" udleder gates
     dynamisk fra denne fil; ingen ændring nødvendig
  ✅ .specify/templates/spec-template.md — generisk; ingen ændring nødvendig
  ✅ .specify/templates/tasks-template.md — generisk; ingen ændring nødvendig
  ✅ .specify/templates/checklist-template.md — generisk; ingen ændring nødvendig
  ⚠ README.md — indeholder endnu ingen henvisning til forfatningen (afventer,
     opdateres når første feature-spec oprettes)

Udskudte punkter (TODO): ingen
-->

# Byens Hemmeligheder — Forfatning

Denne forfatning er projektets øverste normative dokument. Den udleder sine
principper af `docs/foranalyse/Byens_Hemmeligheder_Projektgrundlag.md` og
`docs/design af opgaver/`, og den går forud for enhver anden praksis, vane eller
bekvemmelighed i udviklingen af platformen.

**Sprogkonvention:** `SKAL` = ufravigeligt krav. `SKAL IKKE` / `MÅ IKKE` =
ufravigeligt forbud. `BØR` = stærk anbefaling, hvor en dokumenteret afvigelse er
mulig og skal begrundes i pull requestet.

## Core Principles

### I. Stedet er spillet (NON-NEGOTIABLE)

Det fysiske sted SKAL være en aktiv del af opgaven — ikke blot et GPS-checkpoint.
En opgave, der kan løses hjemmefra uden at have været på lokationen, SKAL IKKE
publiceres som bærende opgave; den må kun anvendes som overgang eller variation
og SKAL mærkes som sådan.

Konkrete krav:

- Hver opgave SKAL bygge på mindst én **observerbar invariant**: en permanent
  form, et dokumenteret årstal, en fast relation mellem objekter, en entydig
  retning eller et tilsvarende stabilt træk ved stedet.
- Facit MÅ IKKE afhænge af variable forhold: refleksioner, forbipasserende,
  events, vegetation, midlertidige skilte, belysning eller vejr.
- Hver publiceret opgave SKAL have et registreret, præcist standpunkt (GPS +
  kigretning + sikker ståflade) verificeret ved fysisk besøg.
- Kvalitetsrubrikkens kriterium **Lokationsrelevans** SKAL være mindst 4 af 5.

*Begrundelse:* Produktets eneste reelle differentiering er stedsspecifik
escape room-kvalitet. Uden dette princip degenererer platformen til en
almindelig quiz-app med kortvisning.

### II. Entydigt og bevisbart facit (NON-NEGOTIABLE)

En opgave SKAL have præcis ét kanonisk korrekt svar med en skriftlig
trin-for-trin-løsning, som kan efterprøves uden forfatterens mundtlige
forklaring.

Konkrete krav:

- Svarreglen SKAL indeholde kanonisk svar plus eksplicit liste over accepterede
  alternative svar (stavevarianter, store/små bogstaver, mellemrum, tal-/ordform).
- Løsningsbeviset SKAL angive alle mellemtrin og kildehenvisning for enhver
  faktaoplysning, der indgår i facit.
- Kodegenerering SKAL vise mapping og læserækkefølge eksplicit i opgavetekst
  eller fortælling. Skjulte mellemregler er forbudt.
- Kvalitetsrubrikkens kriterium **Entydighed** SKAL være mindst 4 af 5.
- Grundreglen: **Kan facit ikke bevises på papir, kan opgaven ikke publiceres.**

*Begrundelse:* Tvetydige svar er den hyppigste kilde til frustration udendørs,
hvor spilleren ikke kan spørge nogen. En lidt enklere, vandtæt opgave slår altid
en spektakulær opgave, der kun virker, når forfatteren forklarer den.

### III. AI assisterer, mennesker udgiver (NON-NEGOTIABLE)

AI er et produktionsværktøj til research, udkast, hintforslag, konsistenskontrol
og eksport. AI er aldrig udgiver — hverken af indhold eller af kode.

Konkrete krav for indhold:

- AI-output SKAL altid behandles som udkast og SKAL redigeres af et menneske før
  review.
- AI MÅ IKKE publicere uden godkendelse, opfinde historiske fakta præsenteret som
  sande, erstatte fysisk besigtigelse, afgøre sikkerhed alene eller anvende
  materiale uden afklarede rettigheder.
- AI-genererede illustrationer SKAL mærkes som illustration eller rekonstruktion
  og MÅ IKKE præsenteres som autentiske historiske fotografier.
- Fakta og fiktion SKAL være tydeligt adskilt i den tekst, spilleren læser.

Konkrete krav for kode:

- AI-assisteret implementering SKAL styres gennem små issues med eksplicitte
  acceptance criteria, korte pull requests og menneskelig review og godkendelse.
- Der SKAL IKKE ske direkte AI-deploy til produktion.

*Begrundelse:* Projektets troværdighed over for museer, arkiver og partnere hviler
på, at et navngivent menneske står bag hver publiceret påstand.

### IV. Sikkerhed, adgang og rettigheder går forud for spilværdi (NON-NEGOTIABLE)

En digital placering dokumenterer ikke, at et sted er sikkert eller lovligt at
bruge. Sikkerhed, lovlig adgang og afklarede rettigheder er publiceringsblokerende
gates — ikke ønskelige egenskaber.

Konkrete krav:

- Hver publiceret opgave SKAL have gennemført sikkerhedsreview ved fysisk besøg
  med vurdering af: trafik og vejkrydsning, vand, skrænter og glat underlag,
  mørke og sæsonforhold, privat område og åbningstider, midlertidige
  afspærringer, mobildækning og GPS-præcision samt hensyn til kirkegårde,
  religiøse steder og fredede genstande.
- Opgaver MÅ IKKE kræve klatring, farlig færdsel, berøring eller flytning af
  fredede genstande, adgang til private områder, at spilleren ser på telefonen
  under krydsning af vej, eller handlinger, der forstyrrer andre eller naturen.
- Hvert mediaasset SKAL have registreret ejer/kilde, licens eller tilladelse,
  kreditering, eventuelle begrænsninger, og om det er historisk, nutidigt eller
  AI-genereret.
- Kvalitetsrubrikkens kriterium **Sikkerhed** SKAL være mindst 4 af 5.
- Platformen SKAL kunne pause en enkelt opgave, lokation eller historie øjeblikkeligt
  uden deploy. Denne pausefunktion er en P0-kapabilitet, ikke en senere finpudsning.

*Begrundelse:* Én ulykke eller ét rettighedsbrud kan lukke projektet. Evnen til at
trække indhold tilbage inden for minutter er derfor lige så vigtig som evnen til
at publicere det.

### V. Serverbåret og versionsfastholdt afvikling

Alt indhold bor på en central tjeneste. Appen kræver forbindelse, og en påbegyndt
tur SKAL IKKE kunne gå tabt eller ændre sig under spilleren.

Konkrete krav:

- Indhold SKAL hentes fra tjenesten. Appen SKAL IKKE bære en indholdspakke, der
  kan drive fra serverens.
- Appen SKAL fortælle spilleren tydeligt, hvornår forbindelsen mangler, og hvad
  hen kan gøre. Manglende dækning SKAL IKKE fremstå som en fejl i opgaven eller
  i spillerens svar.
- Svarforsøg, point og progression SKAL skrives lokalt først og synkroniseres
  **idempotent**. Gentagen synkronisering af samme hændelse SKAL IKKE skabe
  dubletter eller dobbeltpoint.
- En `GameSession` SKAL fastholde den indholdsversion, spilleren startede på.
  En publiceret rettelse SKAL IKKE ændre facit eller point under en igangværende
  tur.
- Point SKAL gemmes som forklarlige transaktioner (fx `+100 løst opgave`,
  `-3 hint 1`), så ethvert resultat kan rekonstrueres efter senere rettelser.
- Serveren er autoritativ ved konflikt, men en spiller SKAL IKKE miste en
  gennemført tur på grund af et kortvarigt udfald.

*Begrundelse:* Én kilde til indhold gør det muligt at rette en fejl eller pause
en opgave uden en app-udgivelse — hvilket princip IV kræver som P0. Prisen er, at
dækning bliver en forudsætning, og derfor er det ikke nok at fejle stille: den
lokale hændelseslog og versionsfastholdelsen findes netop for, at et udfald
koster ventetid og ikke en tur.

### VI. Privatliv ved design og dataminimering (NON-NEGOTIABLE)

Der indsamles kun de data, der er nødvendige for at levere oplevelsen. Målgruppen
er børn og unge, hvilket hæver kravet, ikke sænker det.

Konkrete krav:

- Piloten indsamler kun: e-mail til identifikation og engangskode, valgt
  profilnavn, progression/score/achievements/inventory samt nødvendig teknisk
  telemetry og fejlrapportering.
- Kun det valgte profilnavn MÅ vises offentligt. E-mail MÅ ALDRIG vises på
  highscorelister eller i anden offentlig visning.
- GPS anvendes primært **på enheden** til at afgøre nærhed. Løbende historisk
  sporing af præcise positioner SKAL IKKE gemmes, medmindre et konkret og
  dokumenteret formål kræver det. Som standard gemmes kun, at en lokation blev
  aktiveret eller gennemført, samt tidspunkt i nødvendig detaljeringsgrad.
- Der oprettes ikke separate børnekonti i piloten. Indførsel af børnekonti SKAL
  udløse en særskilt juridisk vurdering af samtykke, alderskontrol, kommunikation
  og profiloffentlighed før implementering.
- Referencefotos og mockups BØR undgå identificerbare personer.
- Enhver ny datakategori SKAL begrundes i pull requestet med formål,
  behandlingsgrundlag og slettefrist, før feltet implementeres.

*Begrundelse:* Dataminimering er billigere at designe ind end at rette bagud, og en
platform for børn har ingen margin for fejl på dette område.

### VII. Tilgængelig familieoplevelse uden tidspres

Produktet skal fungere for hele familien, i sollys, under bevægelse og for
deltagere med forskellige forudsætninger. Spillet MÅ ALDRIG belønne farlig fart.

Konkrete krav:

- Tid registreres som personlig statistik og MÅ IKKE have væsentlig pointmæssig
  betydning. Der indføres ikke tidsbaseret konkurrence.
- Hints er en normal del af spillet. Den samlede hintstraf SKAL forblive lille
  (standard: 3 % + 4 % + 5 %, så alle tre hints efterlader 88 % af grundpointene)
  og SKAL være konfigurerbar frem for hårdkodet.
- UI SKAL levere høj kontrast, store trykflader, korte tekstblokke, understøttelse
  af tekstskalering og skærmlæsning samt én hovedregel ad gangen.
- Hver mission SKAL beskrive distance, forventet varighed, underlag og stigninger,
  trapper og alternativer, egnethed til barnevogn/kørestol samt om oplevelsen
  fungerer i mørke eller bestemte årstider.
- Sværhedsgrad 1–5 beskriver den **mentale** udfordring. Fysisk risiko og
  tilgængelighed SKAL beskrives i separate felter og SKAL IKKE blandes ind i
  sværhedsgraden.

*Begrundelse:* Den reelle brugsenhed er en familie med aldersspredning. Et design,
der belønner den hurtigste enkeltspiller, ødelægger produktets kerneværdi.

## Tekniske rammer

Følgende rammer er gældende for al implementering, indtil de ændres gennem en
forfatningsændring eller en ADR, der eksplicit henviser til dette afsnit.

**Arkitektur:**

- Fælles API og domænemodel for web og iOS. **Modulær monolit** frem for tidlige
  microservices.
- **API-first**: klienter (iOS, webspiller, quizmasterportal) taler udelukkende
  gennem det dokumenterede API. Nye endpoints SKAL være beskrevet i OpenAPI.
- Relationel database er den primære domænedatabase for indhold, versioner,
  progression og point. Table Storage anvendes kun til simple sidebehov.
  JSON-filer anvendes kun til engangsprototyper eller seed-data.
- Rolle- og rettighedsmodel SKAL håndhæves server-side. Klientside-skjul af
  funktioner er ikke adgangskontrol.

**Stak (udgangspunkt):**

| Lag | Valg |
|---|---|
| Backend | ASP.NET Core Web API, Entity Framework Core, OpenAPI |
| Data | Azure SQL Database; Azure Blob Storage til media |
| iOS | Swift/SwiftUI, MapKit, Core Location, lokal krypteret caching |
| Web | Responsiv webspiller + quizmasterportal (rammeværk fastlægges ved teknisk spike) |
| Drift | Azure, GitHub Actions, infrastructure as code (Bicep eller tilsvarende) |

**Identitet:**

- E-mail med engangskode er den primære loginmetode. Face ID/Touch ID MÅ kun
  genåbne en eksisterende session og erstatter ALDRIG backend-identiteten.

**Bevidst uden for MVP:** socialt netværk og chat, formelle hold/holdkoder/
hold-highscore, omfattende antisnydesystem, tidsbaseret konkurrence, avanceret AR,
afhængighed af fysiske rekvisitter, fuldautomatisk AI-publicering og
betalingsflow. Arbejde på disse områder SKAL afvises i review med henvisning
hertil, medmindre forfatningen først ændres.

**Omkostninger:** Drift SKAL holdes inden for et aftalt lavt pilotbudget.
Budgetalarmer SKAL være aktive, og omkostninger til Azure, e-mail, kort og AI
SKAL gennemgås månedligt.

## Udviklings- og redaktionelt workflow

**Kodeleverance:**

- Arbejde nedbrydes i små issues med eksplicitte acceptance criteria.
- Pull requests er korte og fokuserede og SKAL indeholde automatiserede tests for
  ny forretningslogik: unit-tests for domæneregler, integrationstests for
  API-kontrakter og datalag.
- Arkitekturbeslutninger SKAL dokumenteres som ADR under `docs/ADR/`.
- Statisk analyse og dependency scanning SKAL køre i CI. Rød CI blokerer merge.
- Migrationer SKAL være forlæns-kompatible: en deploy MÅ IKKE ugyldiggøre en
  igangværende `GameSession`.

**Indholdsleverance (publiceringsport):**

Indhold følger den cykliske kæde: idé og stedvalg → kildepakke → AI-udkast →
menneskelig redigering → solve-test → feltverifikation med GPS og referencefoto →
sikkerheds- og adgangstjek → målgruppetest → revision → publicering.

En opgave må først publiceres, når alt følgende foreligger:

| Leverance | Minimumskrav |
|---|---|
| Præcist standpunkt | GPS, foto, kigretning, sikker ståflade |
| Referencefotos | 3–8 fotos i dagslys |
| Entydigt facit | Kanonisk svar + accepterede alternativer |
| Løsningsbevis | Alle mellemtrin dokumenteret |
| Hintsæt | 3 trinvise hints, hvert mere afgrænsende end det forrige |
| Tilgængelighedsnoter | Underlag, trapper, afstand, sigtbarhed |
| Risikovurdering | Trafik, vand, mørke, privat område |
| Rettighedslog | Kilde, licens, kredit, eventuel udløbsdato |
| QA-data | Solve-test, felttest, familietest |
| Ejerskab | Navngiven ansvarlig, seneste kontroldato, næste kontroldato |

Ingen opgave publiceres med kritiske rubrikscorer under 3. Lokationsrelevans,
entydighed og sikkerhed SKAL være mindst 4.

**Statusmodel:** Kladde → Review → Test → Publiceret → Pauset. Statusskift til
Publiceret SKAL kræve rollen Administrator eller Redaktør og SKAL logges med
bruger, tidspunkt og version.

**Drift:** Spillere SKAL kunne rapportere en fejl direkte fra opgaven. Kritiske
sikkerhedsfejl behandles straks og udløser pause. Indhold med gentagne fejlmeldinger
sendes tilbage til review.

## Governance

Denne forfatning har forrang for alle andre arbejdsdokumenter, konventioner og
vaner i projektet. Ved konflikt mellem forfatningen og et andet dokument gælder
forfatningen, indtil den ændres.

**Overholdelse:**

- Hver `plan.md` SKAL gennemføre et Constitution Check mod principperne I–VII før
  Phase 0 research og igen efter Phase 1 design.
- Enhver afvigelse fra et princip SKAL registreres i planens **Complexity
  Tracking**-tabel med: hvilken regel der brydes, hvorfor det er nødvendigt, og
  hvorfor det enklere alternativ blev afvist. En afvigelse uden registrering er
  en fejl, der SKAL rettes før merge.
- Principper mærket NON-NEGOTIABLE kan ikke fraviges gennem Complexity Tracking.
  De kræver en forfatningsændring.
- Pull requests SKAL gennemgås for overholdelse af de principper, ændringen berører.

**Ændringsprocedure:**

1. Et ændringsforslag beskriver den foreslåede tekst, begrundelsen og de artefakter,
   der påvirkes.
2. Forslaget godkendes af product owner samt den fagligt ansvarlige for det berørte
   område (redaktionel kvalitet, fysisk sikkerhed, GDPR og rettigheder, eller teknik
   og drift).
3. Ved godkendelse opdateres denne fil, versionen bumpes, og Sync Impact Report
   øverst i filen opdateres.
4. Påvirkede templates under `.specify/templates/` og påvirket dokumentation
   opdateres i samme pull request.

**Versionering (semantisk):**

- **MAJOR** — et princip fjernes eller omdefineres bagudinkompatibelt, eller
  governance-modellen ændres grundlæggende.
- **MINOR** — et nyt princip eller en ny sektion tilføjes, eller eksisterende
  vejledning udvides materielt.
- **PATCH** — præciseringer, sproglige rettelser og ikke-semantiske justeringer.

**Ansvarlige:** Før offentlig pilot SKAL der være navngivne ejere for produkt og
prioritering, historisk/redaktionel kvalitet, fysisk sikkerhed, GDPR og
rettigheder, teknik og drift samt support og indholdsfejl. Uden en navngiven ejer
for et område må der ikke publiceres indhold, som falder inden for det område.

**Version**: 2.0.0 | **Ratified**: 2026-07-25 | **Last Amended**: 2026-07-27
