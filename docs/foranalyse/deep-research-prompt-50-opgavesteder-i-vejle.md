# Deep Research-prompt: 50 opgavesteder i Vejle-området

Kopiér hele prompten nedenfor ind i en ny ChatGPT Deep Research-samtale.
Slutproduktet skal være en downloadbar Markdown-fil; det er ikke nok, at
rapporten kun vises i samtalen.

```text
Du er senior-researcher, lokalhistoriker og outdoor-puzzle-designer for den
danske familieapp Byens Hemmeligheder. Udfør en grundig, kildekritisk Deep
Research og find de 50 stærkeste NYE lokationer i Vejle-området, hvor stedets
dokumenterede historie og et stabilt fysisk træk kan bære en god opgave i
appen.

VIGTIG LEVERANCE

1. Afslut ikke med kun et svar i chatten.
2. Opret den fulde rapport som en UTF-8-kodet Markdown-fil med filnavnet:
   `Opgaver i Vejle området - deep-research-report.md`
3. Hvis du har adgang til Python eller et filværktøj, skal du skrive den
   endelige rapport til
   `/mnt/data/Opgaver i Vejle området - deep-research-report.md` og vedhæfte
   et downloadlink til filen.
4. Kontrollér før aflevering, at filen ikke er tom, at alle 50 kandidater er
   med, at nummereringen 01–50 er ubrudt, og at alle hyperlinks er bevaret som
   almindelige Markdown-links.
5. Chatbeskeden ved aflevering skal være kort og primært indeholde linket til
   filen.
6. Hvis pladsen bliver knap, skal du forkorte prosa og gentagelser — aldrig
   udelade kandidater, obligatoriske felter, løsningsbeviser eller kilder. En
   delrapport er ikke en gyldig aflevering.

FORMÅL OG EFTERFØLGENDE BRUG

Rapporten bliver givet til en anden AI-agent, som senere opretter opgaverne som
kladder i produktionssystemet. Din rapport skal derfor både være en
prioriteret analyse og en præcis dataoverdragelse. Du må ikke selv publicere,
kalde API'er eller påstå, at noget er fysisk verificeret.

Et menneske skal efterfølgende redigere, besøge, teste og godkende opgaverne.
Du skal derfor ikke foregive, at dine udkast er færdige. Lever i stedet den
bedst mulige draft med mest muligt konkret, dokumenteret indhold. Udfyld alle
felter, der med rimelighed kan research'es eller foreslås, og markér resten
præcist som et åbent punkt. Et velbeskrevet usikkert punkt er bedre end en
opdigtet værdi, men `ikke fundet` må først bruges, når relevante kilder faktisk
er undersøgt.

En teknisk kladde i systemet kan godt gemmes med generiske standardværdier,
men det er ikke målet. Rapporten skal levere alle de redaktionelle oplysninger,
der er nødvendige for at oprette en meningsfuld produktionskladde uden
pladsholdertekst. Tekniske id'er, slugs og referencer kan den efterfølgende
agent udlede; brug ikke researchtid på at opfinde dem.

GEOGRAFISK AFGRÆNSNING

- Brug Vejle Kommune som den ydre grænse.
- Prioritér Vejle by, Bredballe, Tirsbæk, Mølholm, Grejsdalen, Vejle Ådal,
  Jelling, Egtved, Børkop, Brejning, Gadbjerg, Randbøldal og andre steder, der
  kan indgå i attraktive klynger eller dagsture fra Vejle.
- Skab geografisk variation, men rangér kvalitet højere end en kunstig ligelig
  fordeling.
- En "lokation" skal være et konkret sted, som en familie kan opsøge. Et helt
  kvarter, en bred historisk periode eller en person uden et konkret fysisk
  sted tæller ikke.
- Flere kandidater i samme område er tilladt, hvis de har forskellige fysiske
  observationer og selvstændige historier. Undgå dubletter forklædt som nye
  kandidater.

DISSE EKSISTERENDE ELLER PÅBEGYNDTE OPGAVER MÅ IKKE TÆLLE MED I DE 50

- Bølgen ved Vejle Havn
- Fjordenhus
- Den gamle bro / Den forsvundne landevej i Tirsbæk Bakker
- Vera's hul ved Frydenlund 98
- Søen ved Frydenlund og de eksisterende placeholder-søopgaver samme sted
- Højen i Tirsbæk Bakker

Du må gerne omtale dem i en kort dubletkontrol, men de må ikke optage en plads
i ranglisten.

PRODUKTPRINCIPPER, SOM ALLE KANDIDATER SKAL BEDØMMES MOD

Målgruppen er familier og cirka 10–15-årige. Dansk skal være kort, klart og
egnet til en mobilskærm i sollys.

1. Stedet er spillet. En bærende opgave skal kræve mindst én observation på
   stedet og må ikke bare være en almindelig quiz, der kunne løses hjemmefra.
2. Observationen skal bygge på en stabil, observerbar invariant: fx en
   permanent form, inskription, dokumenteret årstal, antal faste elementer,
   fast relation mellem objekter eller entydig retning.
3. Facit må ikke afhænge af vejr, lys, refleksioner, vegetation, parkerede
   biler, forbipasserende, events, midlertidige skilte, åbne døre, skiftende
   udstillinger eller andre variable forhold.
4. Der skal være præcis ét kanonisk facit. Det skal kunne bevises trin for trin
   med kilder for alle historiske fakta og en tydelig regel for, hvordan
   observationen omsættes til svaret.
5. En lidt enklere, vandtæt opgave er bedre end en spektakulær, tvetydig
   opgave. Skjulte mellemregler og vilkårlige koder er forbudt.
6. Fakta og fiktion skal adskilles tydeligt. En fiktiv ramme må aldrig
   præsenteres som et ægte historisk brev, fund eller citat.
7. Opgaven må ikke kræve klatring, berøring eller flytning af genstande,
   adgang til privat område, farlig færdsel, forstyrrelse af natur eller andre,
   eller brug af telefon under krydsning af vej.
8. Vær særligt kritisk ved vand, trafik, cykelstier, skrænter, mørke,
   kirkegårde, religiøse steder, fortidsminder, fredede genstande og steder med
   åbningstider.
9. AI-research erstatter ikke fysisk besøg. Online oplysninger om adgang,
   sikkerhed, sigtbarhed, GPS og tilgængelighed er kun foreløbige.
10. AI-output er et udkast. Skriv aldrig "publiceringsklar" eller
    "felttestklar". Alle kandidater skal ende som `draft` og have en eksplicit
    liste over det, et menneske skal færdiggøre.

KILDEKRAV OG KILDEKRITIK

- Brug aktuelle, direkte og stabile links. Kontrollér, at siden faktisk
  understøtter påstanden.
- Hver kandidat skal normalt have mindst to uafhængige, relevante kilder, og
  mindst én skal så vidt muligt være en primær eller autoritativ kilde:
  Vejle Stadsarkiv, VejleMuseerne, Vejle Kommune, Slots- og Kulturstyrelsen,
  Museum Vejle, Nationalmuseet, Historisk Atlas, Trap Danmark, et relevant
  arkiv, en officiel institutionsside, en arkitekts primærside eller en
  veldokumenteret faglig udgivelse.
- Turistsider kan bruges til praktiske fakta, men må ikke alene bære et
  historisk facit. Wikipedia, blogs, sociale medier, korttjenester og
  brugergenererede sider må bruges til at opdage spor, men ikke som eneste
  dokumentation for centrale påstande.
- Skeln mellem dokumenteret fakta, sandsynlig fortolkning og ubekræftet lokal
  overlevering. Sagn må bruges som tydeligt markeret sagn, aldrig som fakta.
- Opfind aldrig et citat. Brug korte citater sparsomt og kun med præcis kilde.
- Hvis to kilder er uenige, beskriv konflikten. Vælg ikke lydløst den version,
  der giver den bedste gåde.
- Angiv adgangsdato for alle webkilder.
- Sæt et almindeligt klikbart Markdown-link direkte efter hver væsentlig
  faktapåstand. Brug ikke interne ChatGPT-citationsmarkører som `cite...` i
  den afleverede fil; de kan ikke bruges af den efterfølgende agent.
- Angiv desuden kilderne i et fast "Kildedata"-afsnit pr. kandidat med de
  felter, systemets kontrakt bruger: `title`, `publisher`, `url` og `kind`.
  `kind` skal være en af: `officialTourism`, `architectPrimary`, `archive`,
  `press`, `municipal`, `other`.

UDVÆLGELSE OG RANGERING

Lav først en bred bruttoliste på mindst 80 konkrete steder. Vis ikke hele den
lange arbejdsproces, men beskriv kort metode og fravalg. Fjern derefter steder,
som mangler en stabil lokal observation, har et uklart facit, kun kan bruges
inden for snævre åbningstider, sandsynligvis kræver privat adgang, er for
følsomme, eller har for svagt kildegrundlag.

Rangér de 50 resterende med en begrundet score på 0–100 ud fra:

- lokationsspecificitet og kvaliteten af den fysiske invariant: 25 point
- historisk fortællekraft og relevans for familier: 20 point
- facitets entydighed og bevisbarhed: 20 point
- kildekvalitet: 15 point
- foreløbig adgang, sikkerhed og tilgængelighed: 10 point
- mulighed for klynger/ruter og geografisk variation: 10 point

En kandidat må kun komme i top 50, hvis både lokationsrelevans og entydighed
foreløbigt vurderes til mindst 4 af 5. Kandidater med alvorlig, sandsynlig
sikkerheds- eller adgangsblokering skal fravælges, ikke blot rangeres lavt.

DATA, SOM SKAL LEVERES FOR HVER AF DE 50 KANDIDATER

Brug den samme struktur og de samme feltnavne for hver kandidat. Udelad ingen
felter. Skriv `ukendt — skal feltverificeres` eller `ikke fundet` i stedet for at
gætte. Felterne er et mål for den mest informationsrige draft, ikke en påstand
om, at opgaven er færdig. Hvor et opgavegreb stadig er usikkert, skal du levere
dit bedste begrundede forslag og samtidig beskrive præcis, hvad et menneske
skal kontrollere eller omskrive.

A. Identitet og prioritering

- rangnummer 01–50
- samlet score 0–100 med kort begrundelse
- stedets officielle eller mest præcise navn
- postnummer på fire cifre
- fuld adresse eller præcis stedbeskrivelse, hvis stedet ingen vejadresse har
- område/by
- foreslået opgavetitel og kort titel
- kort spillerrettet beskrivelse på 1–2 sætninger
- tags
- foreslået klynge/rute og nærliggende kandidater

B. Dokumenteret historie

- 3–6 centrale historiske fakta med direkte kilde ved hver fakta
- hvorfor historien er interessant for en familie med børn/unge
- hvad der er sikkert dokumenteret
- hvad der er usikkert, omstridt, sagn eller fortolkning
- kort kildekritisk vurdering

C. Stedet som spil

- den konkrete observerbare invariant
- hvorfor den forventes at være permanent og robust hele året
- hvad spilleren konkret skal kigge på, tælle, sammenligne eller aflæse
- hvad spilleren eksplicit skal ignorere
- hvorfor opgaven ikke kan løses hjemmefra alene
- foreløbig lokationsrelevans 1–5 og begrundelse
- mindst én sandsynlig tvetydighed eller fejlkilde, som skal testes i felten

D. Udkast til den konkrete opgave

- `status`: altid `draft`
- foreslået `difficulty` fra 1–5; sværhedsgrad må aldrig skabes gennem fysisk
  risiko
- foreslået `estimatedMinutes`, mindst 1
- foreslået `basePoints`, normalt 100
- `fictionLabel`: præcis dansk tekst, der skelner fiktion fra fakta
- kort fiktiv ramme eller skriv tydeligt, at ingen fiktiv ramme anbefales
- `questionKind`: vælg præcis én af `freeText`, `numericCode` eller
  `singleChoice`
- det præcise spillerrettede spørgsmål
- ved `singleChoice`: mindst to svarmuligheder med præcis én korrekt
- ved `numericCode`: kodelængde 1–12 og en fuldstændig, eksplicit mapping og
  læserækkefølge
- kanonisk facit som tekst; foranstillede nuller skal bevares
- alle rimelige accepterede svarformer, herunder stavning, mellemrum,
  bindestreger og tal-/ordform, når relevant; det første svar skal være facit
- 1–3 sandsynlige nærved-svar med konkret, hjælpsom feedback, når meningsfuldt
- fuldt trin-for-trin-løsningsbevis, inklusive kilde ved alle faktuelle
  mellemtrin
- præcis tre progressive hints:
  - hint 1, "Hvor", 3 %: et lille skub mod det relevante sted eller objekt
  - hint 2, "Hvordan", 4 %: forklar metoden eller afgrænsningen
  - hint 3, "Næsten løsningen", 5 %: giv næsten hele vejen uden at skjule en
    ekstra regel
- belønningsteksterne `headline`, `subheadline`, `messageLabel`, `message` og
  `historyFact`; den historiske forklaring skal være kildeunderstøttet
- foreløbig entydighed 1–5 og begrundelse

E. Stedsdata til produktionskladde og feltbesøg

Systemet kræver følgende felter på en lokation. Deep Research må kun levere
foreløbige online-indikationer; den efterfølgende agent lader de endelige
feltværdier stå uverificerede, indtil et menneske har været på stedet.

- `name`
- `postalCode`
- `address`
- `researchCoordinate`: latitude/longitude for selve seværdigheden eller et
  sandsynligt observationsområde, med kilde og tydelig mærkning
  `IKKE FELTVERIFICERET STARTSTED`. Angiv `ikke fundet`, hvis koordinatet ikke
  kan dokumenteres. Opfind aldrig decimaler.
- `latitude` og `longitude` til produktionskladden: anbefal `null`, indtil
  startstedet er fysisk registreret
- `activationRadiusMetres`: anbefal standarden 45, men markér den som
  feltverificering
- `maxAcceptableAccuracyMetres`: anbefal standarden 40 og kontrollér, at den
  ikke overstiger aktiveringsradius; markér den som feltverificering
- `dwellSeconds`: anbefal standarden 20
- `accuracyProfile`: foreløbigt `standard` eller `urbanCanyon` med begrundelse
- foreløbig vurdering af offentlig adgang: ja, nej eller usikker, med kilde og
  eventuelle åbningstider. Det er en researchvurdering, ikke et feltbevis.
- anbefalet boolesk kladdeværdi for `publicAccess`: `true` kun når en
  autoritativ kilde dokumenterer offentlig adgang; ellers `false`, indtil et
  menneske har afklaret forholdet
- foreløbige sikkerhedsflag blandt: `traffic`, `water`, `steepSlope`,
  `darkness`, `privateProperty`, `cyclePath`, `construction`, `crowding`
- foreløbige sikkerhedsnoter
- foreløbig tilgængelighed: underlag, hældning, trin, kørestol
  (`yes`/`partial`/`no`/`unknown`), barnevogn
  (`yes`/`partial`/`no`/`unknown`), afstand fra adgang hvis dokumenteret, og
  noter
- `fieldVerified`: altid `false`
- `lastPhysicallyVerified`: altid `null`
- konkret forslag til sikkert observationsområde, hvis kilderne understøtter
  det, men aldrig en påstand om et godkendt startsted
- en kort, specifik feltcheckliste for netop denne kandidat
- en separat `Mennesket skal færdiggøre`-liste med alle mangler i fakta,
  opgavetekst, facit, feltforhold, medier, rettigheder og test

F. Medier og rettigheder

Medier er ikke et teknisk minimum: opgaven kan oprettes med `heroMediaId` og
andre mediareferencer som `null` og med en tom kortliste. Foreslå alligevel
højst 1–2 realistiske mediekilder, hvis de er relevante.

For hvert medieforslag skal du angive URL, motiv, ejer, licens/tilladelse,
kreditering, eventuelle begrænsninger og om materialet er historisk eller
nutidigt. Skriv `rettigheder ikke afklaret — må ikke bruges`, hvis licensen ikke
er eksplicit. Et pressefoto eller et billede på en webside er ikke automatisk
frit at genbruge. AI-genererede billeder må ikke bære information, som opgaven
skal løses med, og må ikke ligne autentiske historiske fotografier.

G. Kildedata

Afslut hver kandidat med en komplet, deduplikeret liste over de kilder, der
blev brugt til netop kandidaten. For hver kilde:

- `title`
- `publisher`
- `url`
- `kind`: en af kontraktens seks tilladte værdier
- `accessed`: dato i formatet YYYY-MM-DD
- `supports`: en kort liste over de konkrete påstande, kilden understøtter

FELTER, SOM DU IKKE SKAL OPFINDE

Den efterfølgende agent udleder selv mission-id, slug, location-id, step-id,
hint-id'er og source-id'er. Følgende tekniske standarder behøver du kun omtale
i metodeafsnittet og ikke gentage 50 gange:

- `heroMediaId`, `thumbnailMediaId`, `placeMediaId`, `moodMediaId` og
  `narrationMediaId`: `null`, indtil rigtige medier er valgt og registreret
- `cards`: tom liste, indtil kort og eventuelle billeder er redaktionelt valgt
- `storyId`, `chapterId`, `nextChapterId`: `null`
- `sourceIds`: udledes af Kildedata

RAPPORTENS PRÆCISE STRUKTUR

# 50 nye opgavesteder i Vejle-området

## 1. Executive summary

Kort konklusion, geografisk dækning, vigtigste risici og de 10 bedste steder.

## 2. Metode, afgrænsning og kildekritik

Beskriv bruttoliste, udvælgelse, scoring, dubletkontrol og begrænsninger ved
online research.

## 3. Hvad systemet kræver

Forklar kort forskellen mellem:

- teknisk kladde: appen kan indsætte standarder og pladsholdere
- meningsfuld produktionskladde: kræver de redaktionelle data i denne rapport
- publicering: kræver menneskelig redigering, fysisk GPS/startsted,
  sikkerheds- og tilgængelighedsreview, rettigheder, solve-test og godkendelse

## 4. Prioriteret oversigt over alle 50

Lav en kompakt tabel med rang, sted, postnummer, område, historiens kerne,
fysisk invariant, opgavetype, samlet score, største risiko og foreslået klynge.

## 5. Kandidatdossierer

Lav præcis 50 underafsnit med denne nummerering og de faste underoverskrifter:

### 01 — [sted]
#### Identitet og prioritering
#### Dokumenteret historie
#### Stedet som spil
#### Opgaveudkast
#### Stedsdata og feltbesøg
#### Medier og rettigheder
#### Kildedata

Fortsæt uden spring til:

### 50 — [sted]

## 6. Foreslåede klynger og ruter

Gruppér kandidaterne i realistiske gåruter eller udflugter. Angiv ikke
gangafstande eller rejsetider som fakta, medmindre de er kontrolleret mod en
kilde; mærk ellers estimater tydeligt.

## 7. Fravalgte næsten-kandidater

Nævn 10–20 stærke steder fra bruttolisten, der blev fravalgt, og den konkrete
grund: dublet, privat adgang, variabel observation, svag kilde, tvetydigt facit,
sikkerhed eller andet.

## 8. Samlet feltplan

Prioritér feltbesøg for top 10, derefter 11–25 og til sidst 26–50. Saml
gentagne kontroller i en praktisk checkliste, men behold også de
kandidatspecifikke checks i hvert dossier.

## 9. Kvalitetskontrol af leverancen

Afslut med en tabel med 50 rækker og disse checks:

- mindst to brugbare kilder eller tydelig begrundelse for en sjælden undtagelse
- autoritativ kilde til centrale historiske fakta
- direkte links virker
- stabil fysisk invariant identificeret
- lokationsrelevans mindst 4/5
- entydighed mindst 4/5
- kanonisk facit og accepterede svar angivet
- løsningsbevis komplet
- præcis tre hints med 3/4/5 %
- alle fem completion-tekster angivet
- status `draft`
- `fieldVerified: false`
- `lastPhysicallyVerified: null`
- feltrisici og åbne punkter angivet

SLUTKONTROL FØR DU SKRIVER FILEN

- Der er præcis 50 nye, konkrete lokationer og ingen af de udelukkede steder.
- Hver kandidat har en dokumenteret historie OG en stedsspecifik fysisk
  observation; trivia alene er ikke nok.
- Hver kandidat har det mest konkrete og entydige opgaveudkast, kilderne
  tillader, ikke kun en løs idé. Uafklarede dele er tydeligt overdraget til et
  menneske.
- Ingen online oplysning er fejlagtigt gjort til fysisk verifikation.
- Ingen kandidat kaldes publiceringsklar eller felttestklar.
- Ingen sikkerheds-, adgangs-, GPS- eller rettighedsoplysning er opdigtet.
- Alle centrale fakta og alle faktuelle led i facit har direkte kilder.
- Alle interne ChatGPT-citationsmarkører er erstattet af holdbare
  Markdown-links.
- Rapporten kan forstås uden adgang til denne prompt eller et eksternt repo.
- Den downloadbare Markdown-fil er faktisk oprettet og ikke tom.
```

## Repoafledning bag prompten

Promptens felter er afledt af den aktuelle kontrakt i
`contracts/bh-content-v1.schema.json`, admin-appens oprettelsesstandarder i
`iOS-admin/ByensGaaderAdmin/ByensGaaderAdmin/MissionFactory.swift` og
projektets publiceringsporte i `.specify/memory/constitution.md`.

Den vigtigste skelnen er, at admin-appen teknisk kan oprette en kladde og fylde
resten med standarder, men en researchleverance skal erstatte alle redaktionelle
pladsholdere. Koordinat, adgang, sikkerhed, tilgængelighed og feltverifikation
kan Deep Research kun forberede; de kan ikke godkendes uden et fysisk besøg.
