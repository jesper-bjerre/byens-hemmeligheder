# Feature Specification: Opgaveafvikling — pilotindhold og spillerens løsningsflow

**Feature Branch**: `001-opgaveafvikling-pilot`

**Created**: 2026-07-25

**Status**: Draft

**Input**: User description: "Input til de 3 opgaver er nu beskrevet i folderen `docs/design af opgaver`. Fortsæt spec kit arbejde."

## Kontekst og afgrænsning

Denne feature er projektets første lodrette snit. Den gør det muligt at:

1. **repræsentere** en opgave som struktureret indhold med alt det, forfatningen kræver
   for publicering, og
2. **afvikle** opgaven for en spiller i felten fra aktivering til belønning.

De tre opgavedokumenter i `docs/design af opgaver/` er specifikationens **kildesandhed
og acceptgrundlag**. Enhver oplysning i disse dokumenter, som ikke kan repræsenteres i
modellen, er en mangel ved denne feature:

| Opgave | Fil | Status i dokumentet | Rolle som testcase |
|---|---|---|---|
| Bølgen – Den femte besked | `7100/Boelgen_Opgave.md` | Felttestklar | Primær testcase: observation → kode `592` |
| Fjordenhus – Vandets tromler | `7100/Fjordenhus_Opgave.md` | Felttestklar | Anden kodeopgave: `428`, samme mekanik, andet indhold |
| Den gamle bro i Tirsbæk Bakker | `7120/Tirsbaek_Broen_Opgave.md` | Researchklar, **facit ikke fastlagt** | Negativ testcase: indhold uden entydigt facit MÅ IKKE kunne spilles |

Den tredje opgave er bevidst medtaget som negativ testcase. Den beviser, at
publiceringsporten virker: et fagligt stærkt, men uverificeret indhold skal kunne ligge
i systemet uden nogensinde at nå en spiller.

**Uden for denne feature** (kræver egne specifikationer):

- Quizmasterportalens redigeringsflader (indhold oprettes i denne feature via import/seed
  og statusskift, ikke via en fuld redaktionel UI)
- Login, e-mail med engangskode og profiloprettelse (feature forudsætter en eksisterende
  spillerprofil)
- Meta-opgaver på tværs af lokationer (inventory-genstande **registreres**, men forbruges
  ikke af en meta-gåde endnu)
- Interaktiv kortrotation som svarmekanik (Tirsbæk-opgavens anbefalede mekanik)
- Kortvisning, ruteplanlægning og navigation mellem lokationer
- Highscorelister og offentlig visning af profiler

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Familien løser en opgave på stedet (Priority: P1)

En familie står ved fjorden med Bølgen foran sig. Telefonen registrerer, at de er ved
opgavens standpunkt, og åbner missionen. De læser den fiktive besked, der tydeligt er
mærket som fiktion, og som angiver læserækkefølgen **Øjet → Etagerne → Pausen**. Ét
familiemedlem tæller de fem bølgetoppe; de øvrige finder de to dokumenterede oplysninger
i opgavens historiske materiale. De indtaster `592`, får bekræftelse, 100 point, den
historiske forklaring og genstanden **Det femte signal** i deres inventory.

**Why this priority**: Dette er produktets kerneværdi. Uden dette flow findes der intet
spil. Alle øvrige historier er beskyttelse af eller forbedring på denne ene rejse.

**Independent Test**: Kan testes fuldstændigt ved at seede Bølgen-opgaven som Publiceret,
placere en testenhed inden for aktiveringsradius og gennemføre opgaven. Leverer en komplet
spilbar opgave med point og belønning.

**Acceptance Scenarios**:

1. **Given** Bølgen-opgaven har status Publiceret og spilleren er inden for
   aktiveringsradius af det registrerede standpunkt, **When** spilleren åbner missionen,
   **Then** vises narrativ intro, den tydelige fiktionsmærkning, opgavens trin og
   svarfeltet.
2. **Given** opgaven er aktiv, **When** spilleren indtaster `592`, **Then** godkendes
   svaret, spilleren tildeles 100 point, den historiske forklaringstekst vises, og
   **Det femte signal** tilføjes til inventory.
3. **Given** opgaven er aktiv, **When** spilleren indtaster `5 9 2` eller `5-9-2`,
   **Then** behandles svaret som identisk med `592` og godkendes.
4. **Given** opgaven er aktiv, **When** spilleren indtaster `529`, **Then** afvises
   svaret, og den opgavespecifikke feedback for netop `529` vises ("rigtige tal, forkert
   rækkefølge").
5. **Given** Fjordenhus-opgaven er Publiceret, **When** spilleren gennemfører den,
   **Then** gælder samme flow med facit `428` og genstanden **Fjordseglet** — uden
   ændringer i afviklingslogikken.
6. **Given** spilleren er uden for aktiveringsradius, **When** spilleren åbner opgaven,
   **Then** vises standpunktets beskrivelse og afstand, mens opgavens trin og svarfelt
   forbliver låst.
7. **Given** en opgave er løst korrekt, **When** spilleren indsender et nyt svar på samme
   opgave i samme session, **Then** tildeles der ikke point igen.

---

### User Story 2 - Kun godkendt indhold når spilleren, og kan trækkes tilbage straks (Priority: P2)

En redaktør opdager, at der er sat byggehegn op ved Bølgens standpunkt, så de fem
bølgetoppe ikke kan ses. Redaktøren sætter opgaven på pause. Ingen ny spiller kan starte
opgaven, og der udrulles ikke ny app eller backend for at opnå det. Samtidig ligger
Tirsbæk-opgaven i systemet uden fastlagt facit — den er aldrig synlig for nogen spiller.

**Why this priority**: Forfatningens principper II, III og IV er ufravigelige og gør både
publiceringsporten og pausefunktionen til blokerende krav, ikke senere finpudsning. Uden
denne historie kan intet indhold offentliggøres lovligt eller ansvarligt.

**Independent Test**: Kan testes ved at seede indhold i hver status og verificere, at
spillervendte opslag kun returnerer Publiceret indhold, samt at et statusskift til Pauset
slår igennem inden for det aftalte tidsvindue uden ny udrulning.

**Acceptance Scenarios**:

1. **Given** Tirsbæk-opgaven findes med status Kladde og uden kanonisk svar, **When** en
   spiller henter tilgængeligt indhold — også ved direkte opslag på opgavens identitet —
   **Then** returneres opgaven ikke, og den kan ikke besvares.
2. **Given** en opgave er Publiceret, **When** en redaktør sætter den til Pauset,
   **Then** kan ingen ny session starte opgaven inden for 60 sekunder, uden at der er
   udrullet ny software.
3. **Given** en opgave forsøges sat til Publiceret uden kanonisk svar, uden komplet
   hintsæt, uden registreret standpunkt, uden løsningsbevis eller uden rettighedslog for
   sine mediaassets, **Then** afvises statusskiftet med angivelse af den manglende
   leverance.
4. **Given** et statusskift til Publiceret gennemføres, **When** det lykkes, **Then**
   logges bruger, tidspunkt og indholdsversion, og skiftet kræver rollen Administrator
   eller Redaktør.
5. **Given** en spiller er midt i en opgave, **When** opgaven sættes til Pauset, **Then**
   må spillerens igangværende opgave færdiggøres og pointsættes, mens ingen ny spiller kan
   starte den.

---

### User Story 3 - Progressive hints og feedback der hjælper uden at afsløre (Priority: P3)

En 11-årig sidder fast ved Fjordenhus og tæller vinduerne i stedet for cylindrene. Familien
tager hint 1, som afgrænser observationen. Det er ikke nok, og de tager hint 2, som
forklarer læserækkefølgen. De løser opgaven og beholder 93 % af grundpointene. Fradraget
er synligt og forklaret, før de trykker.

**Why this priority**: Hints er en normal del af spillet, ikke en straf (forfatningens
princip VII). Uden hints stiger frafaldet i felten, hvor spilleren ikke kan spørge nogen.
Opgaven kan dog spilles og pointsættes uden hintsystemet, hvorfor det er et selvstændigt
snit.

**Independent Test**: Kan testes ved at gennemføre en opgave med 0, 1, 2 og 3 hints og
verificere point 100, 97, 93 og 88 samt at hvert hint er mere afgrænsende end det forrige.

**Acceptance Scenarios**:

1. **Given** en aktiv opgave med grundpoint 100, **When** spilleren tager hint 1, 2 og 3
   og derefter svarer korrekt, **Then** tildeles 88 point fordelt på forklarlige
   transaktioner (`+100 løst opgave`, `-3 hint 1`, `-4 hint 2`, `-5 hint 3`).
2. **Given** en aktiv opgave, **When** spilleren har taget hint 1, **Then** vises hint 2
   som næste tilgængelige hint sammen med sit fradrag, før spilleren beslutter sig.
3. **Given** hintfradragene er 3 %, 4 % og 5 %, **When** driften ændrer satserne,
   **Then** kan det ske som konfiguration uden ændring i programkode.
4. **Given** spilleren afgiver et svar, der matcher en registreret typisk fejl, **When**
   svaret afvises, **Then** vises den specifikke feedbacktekst for netop den fejl frem for
   en generisk fejlmeddelelse.
5. **Given** spilleren afgiver flere forkerte svar i træk uden match på en registreret
   fejl, **Then** vises opgavens generelle "gentagne forkerte svar"-feedback.
6. **Given** et hint er taget, **When** spilleren lukker og genåbner appen, **Then** er
   hintet stadig taget, og fradraget er ikke registreret to gange.

---

### User Story 4 - Turen holder uden dækning og uden tab (Priority: P4)

En familie starter en mission på havnen, hvor dækningen er ustabil. De gennemfører to
opgaver helt uden netværk. Undervejs udgiver redaktionen en rettelse af opgaveteksten.
Familiens tur ændrer sig ikke undervejs. Da telefonen igen får forbindelse, synkroniseres
alt — og en gentaget synkronisering skaber hverken dubletter eller dobbeltpoint.

**Why this priority**: Forfatningens princip V. Tabt progression efter en times gåtur er
den mest tillidsødelæggende fejl produktet kan lave. Historien er sidst i rækken, fordi en
online-only afvikling kan demonstreres først — men den **skal** være på plads før enhver
offentlig felttest.

**Independent Test**: Kan testes ved at downloade en mission, sætte enheden i flytilstand,
gennemføre opgaverne, genetablere forbindelse og verificere point, inventory og
transaktionslog — samt ved at afspille den samme synkroniseringspakke to gange.

**Acceptance Scenarios**:

1. **Given** en mission er downloadet, **When** enheden er uden netværk, **Then** kan
   samtlige opgaver i missionen læses og besvares, inklusive narrativ, historisk materiale,
   hints, svarregler og de nødvendige billeder.
2. **Given** svar og hints er afgivet offline, **When** forbindelsen vender tilbage,
   **Then** synkroniseres alle hændelser, og spillerens point og inventory er identiske med
   den lokale visning.
3. **Given** den samme synkroniseringspakke sendes igen, **When** serveren behandler den,
   **Then** oprettes ingen dublerede hændelser og ingen ekstra point.
4. **Given** en session er startet på indholdsversion N, **When** version N+1 publiceres
   under turen, **Then** fortsætter sessionen uændret på version N, og de nye tekster
   påvirker ikke facit eller pointgivning i den igangværende tur.
5. **Given** lokal og serverside tilstand er i konflikt, **When** synkronisering
   gennemføres, **Then** er serveren autoritativ, men en allerede gennemført og lokalt
   registreret opgave går ikke tabt.

---

### Edge Cases

- **GPS er utilgængelig eller upræcis ved standpunktet.** Spilleren skal kunne bekræfte sin
  tilstedeværelse manuelt, så turen ikke blokeres af dækning. Den manuelle aktivering
  registreres på sessionen. Selve gåden forbliver stedsafhængig: de fem bølgetoppe kan ikke
  tælles hjemmefra.
- **Spilleren indtaster et svar med uventet formatering** (`592 `, `5.9.2`, `femhalvni`).
  Normaliseringsreglerne skal være eksplicit angivet pr. opgave, og alt uden for den
  angivne liste afvises som forkert — aldrig som teknisk fejl.
- **Spilleren indtaster flere eller færre cifre end forventet** (`5918`, `4280`). Skal give
  den registrerede feedback, ikke en valideringsfejl på inputfeltet.
- **Standpunktets udsyn er spærret** (byggehegn, arrangement, vegetation). Spilleren skal
  kunne rapportere fejl direkte fra opgaven, og rapporten skal kunne udløse pause.
- **Opgaven sættes på pause, mens en spiller står ved den.** Den igangværende opgave
  færdiggøres; nye sessioner blokeres.
- **Indhold uden fastlagt facit** (Tirsbæk). Må hverken kunne publiceres, hentes af en
  spiller eller besvares.
- **Spilleren løser samme opgave to gange** eller genafspiller en mission. Point tildeles
  én gang pr. opgave pr. spiller.
- **Enheden løber tør for lagerplads under download** af en mission. Missionen må ikke
  fremstå som spilbar offline, hvis den ikke er komplet downloadet.
- **Spilleren skifter enhed midt i en tur.** Progression følger profilen, ikke enheden, når
  der er synkroniseret.
- **En opgave har flere svarfelter** (Øjet/Etagerne/Pausen). Delresultater skal kunne
  indtastes hver for sig og evalueres mod samme kanoniske svar.

## Requirements *(mandatory)*

### Indholdsmodel

- **FR-001**: Systemet SKAL kunne repræsentere en opgave med mindst: titel, lokation,
  sværhedsgrad (1–5), opgavetype, målgruppe, forventet varighed, grundpoint, narrativ
  intro, spillervendte trin, kanonisk svar, accepterede alternative svar, hintsæt,
  registrerede typiske fejlsvar med feedback, historisk belønningstekst og
  inventory-belønning.
- **FR-002**: Systemet SKAL kunne repræsentere hvert af de tre opgavedokumenter i
  `docs/design af opgaver/` uden tab af spillervendt indhold og uden tab af de oplysninger,
  publiceringsporten kontrollerer.
- **FR-003**: Systemet SKAL holde **fakta** og **fiktion** adskilt som særskilte felter, så
  fiktive rammefortællinger altid kan vises med den påkrævede fiktionsmærkning i den tekst,
  spilleren læser.
- **FR-004**: Systemet SKAL kunne knytte kildehenvisninger til enhver faktaoplysning, der
  indgår i facit.
- **FR-005**: Systemet SKAL kunne opbevare et skriftligt løsningsbevis med alle mellemtrin
  for hver opgave, adskilt fra det spilleren ser.
- **FR-006**: Systemet SKAL kunne repræsentere et standpunkt med GPS-position, kigretning,
  beskrivelse af sikker ståflade og aktiveringsradius.
- **FR-007**: Systemet SKAL kunne opbevare tilgængelighedsnoter (underlag, stigninger,
  afstand, sigtbarhed, barnevogns- og kørestolsadgang) og en risikovurdering (trafik, vand,
  mørke, privat område) pr. opgave.
- **FR-008**: Systemet SKAL føre en rettighedslog pr. mediaasset med kilde/ejer, licens
  eller tilladelse, kreditering, eventuelle begrænsninger, eventuel udløbsdato og om
  assetet er historisk, nutidigt eller AI-genereret.
- **FR-009**: Systemet SKAL registrere ejerskab pr. opgave: navngiven ansvarlig, seneste
  kontroldato og næste kontroldato.
- **FR-010**: Systemet SKAL kunne repræsentere en opgave, hvis endelige facit endnu ikke er
  fastlagt, uden at et tomt eller foreløbigt facit kan forveksles med et gyldigt svar.

### Svarhåndtering

- **FR-011**: Hver opgave SKAL have præcis ét kanonisk korrekt svar.
- **FR-012**: Systemet SKAL evaluere et spillersvar mod det kanoniske svar plus en
  eksplicit, opgavespecifik liste over accepterede alternativer (mellemrum, bindestreger,
  store/små bogstaver, tal- eller ordform).
- **FR-013**: Normaliseringsreglerne SKAL være data på opgaven, ikke skjult logik i
  klienten, så to klienter aldrig kan nå forskellige resultater for samme svar.
- **FR-014**: Systemet SKAL understøtte svar afgivet enten som ét samlet felt eller som
  flere navngivne delfelter, der sammensættes i den rækkefølge, opgaven angiver.
- **FR-015**: Systemet SKAL understøtte svartypen **valg blandt foruddefinerede
  alternativer** ud over fritekst/kode.
- **FR-016**: Systemet SKAL kunne vise en registreret feedbacktekst knyttet til et
  bestemt forkert svar, og en generel feedbacktekst ved gentagne forkerte svar uden match.
- **FR-017**: Systemet SKAL IKKE afsløre det kanoniske svar i data, der udleveres til
  klienten før opgaven er løst, ud over hvad hints eksplicit giver.

### Hints og point

- **FR-018**: Hver publiceret opgave SKAL have et hintsæt på tre trin, hvor hvert trin er
  mere afgrænsende end det forrige.
- **FR-019**: Systemet SKAL vise hintets pointfradrag, før spilleren bekræfter at tage det.
- **FR-020**: Hintfradrag SKAL være konfigurerbare og SKAL IKKE være hårdkodet.
  Standardsatserne er 3 %, 4 % og 5 % af grundpoint, så alle tre hints efterlader 88 %.
- **FR-021**: Point SKAL gemmes som forklarlige transaktioner med årsag og tidspunkt, så
  ethvert resultat kan rekonstrueres.
- **FR-022**: Systemet SKAL tildele point for en given opgave højst én gang pr. spiller.
- **FR-023**: Tid SKAL kunne registreres som personlig statistik, men SKAL IKKE påvirke
  point.
- **FR-024**: Systemet SKAL tildele den registrerede inventory-genstand ved korrekt
  løsning og gøre den synlig i spillerens inventory.

### Publiceringsport, status og drift

- **FR-025**: Hver opgave SKAL have en status i kæden Kladde → Review → Test → Publiceret →
  Pauset.
- **FR-026**: Systemet SKAL udelukkende udlevere indhold med status Publiceret til
  spillere. Indhold i enhver anden status SKAL IKKE kunne hentes eller besvares, heller
  ikke ved direkte opslag.
- **FR-027**: Systemet SKAL blokere statusskift til Publiceret, hvis en af følgende
  mangler: registreret standpunkt, kanonisk svar, løsningsbevis, komplet hintsæt,
  tilgængelighedsnoter, risikovurdering, rettighedslog for tilknyttede mediaassets eller
  navngiven ansvarlig.
- **FR-028**: Systemet SKAL kunne sætte en enkelt opgave, en lokation eller en hel historie
  på pause øjeblikkeligt uden ny udrulning af software.
- **FR-029**: Statusskift SKAL logges med bruger, tidspunkt, tidligere status, ny status og
  indholdsversion.
- **FR-030**: Adgangen til at publicere og pause SKAL håndhæves på serversiden og SKAL
  kræve rollen Administrator eller Redaktør.
- **FR-031**: Spillere SKAL kunne rapportere en fejl direkte fra en opgave, og rapporten
  SKAL knyttes til opgaven og dens indholdsversion.

### Session, offline og synkronisering

- **FR-032**: En spilsession SKAL fastholde den indholdsversion, den blev startet på, indtil
  sessionen afsluttes.
- **FR-033**: En aktiv mission SKAL kunne downloades komplet — narrativ, trin, historisk
  materiale, svarregler, hints, feedbacktekster og nødvendige billeder — til afvikling uden
  netværk.
- **FR-034**: Svarforsøg, hintforbrug, point og progression SKAL skrives lokalt først og
  synkroniseres, når forbindelsen vender tilbage.
- **FR-035**: Synkronisering SKAL være idempotent: samme hændelse SKAL IKKE kunne skabe
  dubletter eller dobbeltpoint, uanset hvor mange gange den sendes.
- **FR-036**: Ved konflikt SKAL serveren være autoritativ, men en gennemført opgave SKAL
  IKKE gå tabt på grund af kortvarig manglende dækning.
- **FR-037**: Systemet SKAL kunne skelne mellem en delvist og en komplet downloadet mission
  og SKAL IKKE fremstille en delvis mission som spilbar offline.

### Aktivering, tilgængelighed og privatliv

- **FR-038**: En opgaves trin og svarfelt SKAL først låses op, når spilleren er inden for
  opgavens aktiveringsradius, eller når spilleren manuelt har bekræftet sin tilstedeværelse
  ved standpunktet.
- **FR-039**: Manuel bekræftelse af tilstedeværelse SKAL registreres på sessionen, så
  aktiveringsmåden kan skelnes i drift og QA.
- **FR-040**: Systemet SKAL IKKE gemme løbende historik over spillerens præcise positioner.
  Der gemmes alene, at en lokation blev aktiveret og gennemført, samt tidspunkt i nødvendig
  detaljeringsgrad.
- **FR-041**: Alle spillervendte oplysninger, der er nødvendige for at løse en opgave, SKAL
  kunne læses som tekst. En opgave SKAL IKKE kræve lyd eller evnen til at skelne bestemte
  farver.
- **FR-042**: Hver mission SKAL kunne beskrive distance, forventet varighed, underlag og
  stigninger, trapper og alternativer, egnethed til barnevogn og kørestol samt egnethed i
  mørke og på bestemte årstider.
- **FR-043**: Sværhedsgrad SKAL beskrive den mentale udfordring alene. Fysisk risiko og
  tilgængelighed SKAL være separate felter.
- **FR-044**: Kun spillerens valgte profilnavn MÅ vises offentligt. E-mail MÅ ALDRIG
  udleveres til visning.

### Key Entities

- **Historie (mission)**: En sammenhængende oplevelse med titel, område, beskrivelse af
  distance, varighed, underlag, tilgængelighed og årstidsegnethed. Indeholder kapitler
  og/eller opgaver i en defineret rækkefølge.
- **Opgave**: Den enkelte gåde. Bærer metadata, narrativ, trin, svarregel, hintsæt,
  fejlsvarfeedback, belønninger, standpunkt, sikkerheds- og tilgængelighedsnoter,
  løsningsbevis, kilder, ejerskab, status og version.
- **Trin**: Et delelement af opgaven med instruktion, eventuelt delresultat og angivelse af,
  om oplysningen stammer fra fysisk observation eller fra opgavens historiske materiale.
- **Standpunkt**: GPS-position, kigretning, beskrivelse af sikker ståflade og
  aktiveringsradius.
- **Svarregel**: Kanonisk svar, accepterede alternativer, normaliseringsregler, svartype og
  eventuelle navngivne delfelter.
- **Hint**: Rækkefølge, tekst og pointfradrag.
- **Fejlsvarfeedback**: Et registreret forkert svar (eller mønster) og den tilhørende
  vejledende tekst.
- **Inventory-genstand**: Titel, beskrivelse og eventuelt symbol, som tildeles ved løsning
  og senere kan indgå i en meta-opgave.
- **Mediaasset**: Billede eller andet materiale med tilknyttet rettighedspost.
- **Rettighedspost**: Kilde/ejer, licens eller tilladelse, kreditering, begrænsninger,
  udløbsdato og oprindelsestype (historisk, nutidig, AI-genereret).
- **Indholdsversion**: En fastfrosset udgave af en opgave eller historie, som en session kan
  bindes til.
- **Publiceringsstatus og statuslog**: Aktuel status samt historik med bruger, tidspunkt,
  statusskift og version.
- **Spillerprofil**: Profilnavn, identitet og samlet progression. E-mail vises aldrig
  offentligt.
- **GameSession**: En spillers gennemførsel af en historie, bundet til én indholdsversion,
  med aktiveringsmåde, fremdrift og hændelser.
- **Pointtransaktion**: Beløb, årsag (løst opgave, hint 1, hint 2, hint 3), tidspunkt,
  opgavereference og en entydig hændelsesidentitet, der gør gentagen indsendelse ufarlig.
- **Fejlrapport**: Spillerens melding knyttet til opgave, indholdsversion, tidspunkt og
  kategori.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: En familie kan gennemføre Bølgen-opgaven fra aktivering til belønning inden
  for de dokumenterede 8–12 minutter uden vejledning fra en tilstedeværende quizmaster.
- **SC-002**: Alle tre dokumenterede svarformater (`592`, `5 9 2`, `5-9-2`) godkendes i
  100 % af forsøgene, og de fem dokumenterede fejlsvar udløser hver sin registrerede
  feedbacktekst i 100 % af forsøgene.
- **SC-003**: Begge felttestklare opgaver (`592` og `428`) kan afvikles alene ud fra
  indholdsdata, uden opgavespecifikke tilpasninger af systemet. En tredje tilsvarende
  opgave kan tilføjes udelukkende ved at tilføje indhold.
- **SC-004**: Indhold, der ikke har status Publiceret, er utilgængeligt for spillere i
  100 % af forsøgene, inklusive direkte opslag på opgavens identitet.
- **SC-005**: En redaktør kan pause en publiceret opgave, så ingen ny session kan starte den
  inden for 60 sekunder, uden at der udrulles ny software.
- **SC-006**: Et forsøg på at publicere en opgave uden en af de påkrævede leverancer
  afvises i 100 % af tilfældene med angivelse af, hvad der mangler.
- **SC-007**: En spiller, der tager alle tre hints og løser opgaven, ender på 88 % af
  grundpointene, og resultatet kan rekonstrueres fuldstændigt af transaktionsloggen.
- **SC-008**: 0 % af gennemførte opgaver går tabt ved netværksafbrydelse, og gentagen
  synkronisering af den samme hændelsespakke giver 0 dublerede pointtransaktioner.
- **SC-009**: En session, der er startet på indholdsversion N, viser og pointsætter
  udelukkende version N, selv efter at version N+1 er publiceret midt i sessionen.
- **SC-010**: En komplet mission kan gennemføres end-to-end i flytilstand, og hele
  progressionen er korrekt afspejlet efter genetableret forbindelse.
- **SC-011**: Ingen opgave i pilotindholdet kræver lyd eller farveskelnen for at kunne
  løses; alle løsningsnødvendige oplysninger er tilgængelige som tekst.
- **SC-012**: Ingen lagret data indeholder løbende positionshistorik; alene aktiverings- og
  gennemførselshændelser med tidspunkt kan genfindes.
- **SC-013**: Mindst 80 % af testfamilier i målgruppen løser en felttestklar opgave med
  højst to hints.

## Assumptions

- **Featureafgrænsning**: Brugerens instruks ("fortsæt spec kit arbejde") angav ikke en
  feature. Der er valgt det første lodrette snit — indholdsmodel plus spillerens
  løsningsflow — fordi de tre nye opgavedokumenter netop udgør det acceptgrundlag, en sådan
  feature skal måles på. Ændres denne afgrænsning, skal specifikationen skrives om, ikke
  udvides.
- **Spillerprofil forudsættes**: Identitet, e-mail med engangskode og profiloprettelse
  ligger uden for denne feature. Der antages en eksisterende, autentificeret profil.
- **Indhold oprettes ved import/seed**: De tre opgaver bringes ind i systemet som
  strukturerede data. Den redaktionelle brugerflade til at skrive og redigere indhold er en
  senere feature; kun statusskift og pause skal kunne udføres i denne.
- **Aktivering med manuel nødudvej**: Opgaven låses op af nærhed til standpunktet, men
  spilleren kan bekræfte tilstedeværelse manuelt, hvis GPS svigter. Dette bryder ikke
  princippet om, at stedet er spillet, fordi selve observationen ikke kan udføres andetsteds.
  Aktiveringsmåden registreres, så manuel aktivering kan følges i drift.
- **Standard aktiveringsradius**: 50 meter, konfigurerbar pr. opgave, fastlægges endeligt
  ved feltbesøg.
- **Tirsbæk-opgaven forbliver uspilbar** i denne feature. Den anbefalede kortrotationsmekanik
  og dens endelige facit kræver feltdata, som endnu ikke findes, og specificeres separat.
- **Inventory-genstande registreres, men forbruges ikke**: Meta-opgaven, der samler *Vand*,
  *Form* og *Retning*, er en senere feature.
- **Point og hintsatser** følger forfatningens standard (grundpoint 100 for niveau 3;
  fradrag 3/4/5 %) og er konfiguration, ikke kode.
- **Faktakontrol før publicering**: Alle tre dokumenter kræver eksplicit genkontrol af
  kilder før publicering. Denne feature leverer den tekniske port, ikke selve kontrollen.
- **Bølgens forventede varighed** sættes til 8–12 minutter jf. opgavedokumentet. Retnings-
  linjedokumentet angiver 5–8 minutter for samme opgave; opgavedokumentet er nyere og
  regnes som gældende.

## Åbne spørgsmål til `/speckit-clarify`

Følgende er besvaret med dokumenterede antagelser ovenfor, men bør bekræftes, før planlægning
går videre, fordi de påvirker omfang:

1. **Er den valgte featureafgrænsning den ønskede?** Alternativer: (a) kun indholdsmodel og
   import, (b) kun spillerflow mod hårdkodet indhold, (c) det valgte lodrette snit.
2. **Skal manuel bekræftelse af tilstedeværelse tillades i piloten?** Alternativet er en hård
   GPS-port, som er strengere over for princip I, men som gør turen sårbar over for dækning.
3. **Skal denne feature levere web, iOS eller begge klienter?** Specifikationen er
   klientneutral, men valget ændrer estimat og planlægning markant.
