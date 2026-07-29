# Feature Specification: Fundament og lodret snit

**Feature Branch**: `001-fundament-og-lodret-snit`

**Created**: 2026-07-25

**Status**: Draft

**Input**: User description: "Feature 1: Fundament og lodret snit — iOS-app der kan afvikle to komplette, stedsbaserede opgaver ende til ende. Bølgen (facit 592) og Fjordenhus (facit 428) fra `docs/design af opgaver/opgaver/7100/`. Indhold er data, ikke kode: en valideret indholdspakke driver begge opgaver gennem den samme motor. Ingen backend, ingen konti, ingen inventory, ingen rute eller sammenhængende historie — opgaverne er fritstående. Spillerrejse: kort → missionsdetalje → GPS-aktivering ved lokationen → narrativ intro → opgavetrin (observation, faktaspørgsmål, talkode) → op til 3 progressive hints med pointfradrag → korrekt svar → belønningsskærm med point og historisk forklaring. Lokal progression i append-only hændelseslog. Dansk."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Løs en opgave på stedet (Priority: P1)

En familie står ved Vejle Havn. De åbner appen, ser Bølgen på kortet, læser hvor lang tid opgaven tager og hvad de skal være opmærksomme på, går hen til standpunktet, får opgaven låst op af deres position, læser en kort fortælling, tæller de fem bølgetoppe, svarer på to spørgsmål ud fra appens historiske materiale, samler de tre tal til koden og får point plus en forklaring på, hvad Bølgen egentlig fortæller om Vejle.

**Why this priority**: Dette er hele produktløftet i én tur. Kan familien ikke gennemføre denne rejse, er der intet at måle og ingenting at felteste. Alle andre historier er understøttende.

**Independent Test**: En person med telefonen kan stilles ved Bølgen uden forklaring og gennemføre fra kort til belønningsskærm. Leverer i sig selv svaret på "er gåden sjov, og forstår folk flowet".

**Acceptance Scenarios**:

1. **Given** spilleren er uden for lokationens aktiveringsradius, **When** spilleren åbner missionen, **Then** vises afstand, forventet varighed, sværhedsgrad, sikkerhedsnoter og tilgængelighedsnoter, og den primære handling er at gå til stedet — ikke at starte opgaven.
2. **Given** spilleren har opholdt sig inden for aktiveringsradius længe nok til, at positionen er bekræftet, **When** opgaven åbnes, **Then** vises den narrative intro med synlig fiktionsmarkering.
3. **Given** spilleren er på observationstrinnet, **When** spilleren vælger det korrekte antal bølgetoppe, **Then** bekræftes svaret, og næste trin låses op.
4. **Given** spilleren har fundet alle tre deltal, **When** spilleren indtaster `592`, **Then** gennemføres opgaven, point tildeles én gang, og belønningsskærmen viser point, pointopdeling og den historiske forklaring.
5. **Given** spilleren indtaster et forkert svar, **When** svaret bekræftes, **Then** trækkes ingen point, og spilleren kan forsøge igen uden begrænsning.
6. **Given** spilleren indtaster `529`, **When** svaret bekræftes, **Then** forklarer feedbacken, at tallene er rigtige, men rækkefølgen forkert.

---

### User Story 2 - Anden opgave uden ny kode (Priority: P2)

Fjordenhus tilføjes til appen udelukkende ved at skrive indhold. Der skrives ingen ny skærm, ingen ny trinstype og ingen opgavespecifik logik. Spilleren oplever en opgave med sin egen fortælling, sine egne spor, sine egne hints og sit eget facit — men afviklet af den samme motor.

**Why this priority**: Dette er den eneste måde at bevise, at motoren er indholdsdrevet frem for en pænt struktureret enkeltopgave. Beviset skal falde inde i denne feature, ikke tre increments senere, hvor det er dyrt at rette.

**Independent Test**: Sammenlign ændringssættet for Fjordenhus. Hvis det består af indholds- og mediefiler alene, er historien bestået. Den kan spilles selvstændigt uden Bølgen.

**Acceptance Scenarios**:

1. **Given** indholdspakken indeholder både Bølgen og Fjordenhus, **When** spilleren åbner kortet, **Then** vises begge som selvstændige opgaver uden indbyrdes afhængighed eller krævet rækkefølge.
2. **Given** spilleren har gennemført Bølgen, **When** spilleren åbner Fjordenhus, **Then** er den umiddelbart tilgængelig og kræver ikke, at Bølgen er løst.
3. **Given** spilleren er ved Fjordenhus, **When** spilleren indtaster `428`, **Then** gennemføres opgaven med sin egen completion-tekst og sin egen historiske forklaring.
4. **Given** Fjordenhus blev tilføjet til produktet, **When** ændringssættet gennemgås, **Then** indeholder det ingen opgavespecifik programlogik.

---

### User Story 3 - GPS-problemer ender aldrig i en blindgyde (Priority: P3)

Spilleren står det rigtige sted, men positionen vil ikke falde på plads — høje bygninger, dårligt signal, eller telefonen har kun fået lov at dele omtrentlig position. Appen forklarer på almindeligt dansk, hvad der sker, og hvad spilleren kan gøre, og efter et rimeligt stykke tid tilbyder den at fortsætte alligevel.

**Why this priority**: Bølgen og Fjordenhus er begge høje konstruktioner ved vand — de vanskeligste forhold, der findes. En familie, der er gået derned og bliver mødt af en spinner uden udvej, er en tabt felttest og en tabt familie. Forfatningen tillader ikke, at en ægte spiller afvises hårdt.

**Independent Test**: Gennemgå hver eneste tilstand, positionsbekræftelsen kan befinde sig i, og bekræft at hver enkelt viser en forklaring og mindst én handling.

**Acceptance Scenarios**:

1. **Given** positionen endnu ikke er bekræftet, **When** spilleren venter, **Then** vises hvilken tilstand appen er i, og hvad spilleren kan gøre.
2. **Given** positionen er for upræcis til at bekræfte nærhed, **When** tilstanden vises, **Then** forklares det uden teknisk sprog, og spilleren får en konkret handling.
3. **Given** spilleren kun har givet adgang til omtrentlig position, **When** opgaven forsøges åbnet, **Then** forklares hvorfor det ikke rækker, og spilleren tilbydes at give præcis adgang.
4. **Given** positionen ikke er blevet bekræftet inden for et fastsat tidsrum, **When** spilleren stadig venter, **Then** tilbydes det at fortsætte uden positionsbekræftelse, og gennemførelsen mærkes med, hvordan den blev åbnet.
5. **Given** spilleren passerer forbi lokationen uden at standse, **When** spilleren bevæger sig videre, **Then** bekræftes positionen ikke.
6. **Given** spilleren har afvist eller er forhindret i at give positionsadgang, **When** appen åbnes, **Then** er der stadig en vej videre, og appen forklarer konsekvensen.

---

### User Story 4 - Turen overlever afbrydelse (Priority: P4)

Midt i opgaven ringer telefonen, batteriet er lavt, eller der er ingen dækning. Spilleren vender tilbage og fortsætter præcis, hvor hun slap — med samme trin, samme brugte hints og samme forsøgshistorik.

**Why this priority**: Tabt progression efter en halv times gåtur er den mest tillidsødelæggende fejl, produktet kan lave. Indholdet hentes fra tjenesten, men progressionen skrives lokalt først — netop for at et kortvarigt udfald koster ventetid og ikke en tur.

**Independent Test**: Start en opgave, afbryd på hver af trinnene, genstart appen, og bekræft at tilstanden er intakt. Gennemfør derefter hele opgaven med enheden i flytilstand.

**Acceptance Scenarios**:

1. **Given** spilleren har gennemført første trin og brugt ét hint, **When** appen lukkes helt og åbnes igen, **Then** fortsættes fra samme trin med hintet stadig registreret som brugt.
2. **Given** enheden er i flytilstand fra start til slut, **When** spilleren gennemfører hele opgaven, **Then** lykkes gennemførelsen, og point beregnes korrekt.
3. **Given** spilleren allerede har gennemført en opgave, **When** opgaven åbnes igen, **Then** tildeles grundpointene ikke igen.
4. **Given** spilleren pauser i vilkårligt lang tid, **When** opgaven senere gennemføres uden hints, **Then** tildeles fulde grundpoint.

---

### User Story 5 - Defekt indhold når aldrig frem til spilleren (Priority: P5)

Den, der skriver eller retter en opgave, får besked med det samme, hvis indholdet ikke kan publiceres — manglende facit, forkert antal hints, hints der ikke summer korrekt, en distraktor der ved en fejl også accepteres som rigtigt svar, manglende sikkerheds- eller rettighedsoplysninger, eller et facit der modsiger opgavedokumentet.

**Why this priority**: Uden quizmasterportal er den automatiske validering den eneste publiceringsport, der findes. Den håndhæver forfatningens krav om entydigt facit, sikkerhed og rettigheder, og den er samtidig fundamentet for portalen senere.

**Independent Test**: Indfør bevidst hver enkelt defekt i en kopi af indholdet og bekræft, at hver enkelt afvises med en forståelig fejl.

**Acceptance Scenarios**:

1. **Given** en opgave mangler kanonisk facit, sikkerhedsnoter, tilgængelighedsnoter, kilder eller rettighedsoplysninger på et medie, **When** indholdet valideres, **Then** afvises det med angivelse af hvilket felt der mangler.
2. **Given** en opgave har andet end tre hints, eller hintfradragene summer til andet end det fastsatte, **When** indholdet valideres, **Then** afvises det.
3. **Given** et kanonisk facit ikke selv bedømmes som korrekt af sin egen svarregel, **When** indholdet valideres, **Then** afvises det.
4. **Given** et registreret typisk forkert svar også bedømmes som korrekt, **When** indholdet valideres, **Then** afvises det.
5. **Given** indholdet indeholder den ugyldige kode `541`, **When** indholdet valideres, **Then** afvises det.
6. **Given** en henvisning peger på et ikke-eksisterende trin, hint eller medie, **When** indholdet valideres, **Then** afvises det.

---

### Edge Cases

- Spilleren indtaster færre cifre end koden kræver. Dette er et ufærdigt svar, ikke et forkert — det må ikke tælle som fejlforsøg eller udløse afvisende feedback.
- Spilleren indtaster koden med mellemrum eller bindestreger (`5 9 2`, `5-9-2`). Skal accepteres som samme svar.
- Et facit med foranstillet nul skal bevares som skrevet og ikke behandles som et tal.
- Spilleren bruger et hint, lukker det og åbner det igen. Der må kun trækkes point én gang.
- Spilleren står ved lokationen, men enhedens position er åbenlyst kunstig. Gennemførelsen skal stadig lykkes; hvordan den blev åbnet registreres.
- Alle fem bølgetoppe kan ikke ses på grund af afspærring, arrangement eller byggeri. Opgaven skal kunne markeres som midlertidigt utilgængelig uden at fjerne den.
- Spilleren gennemfører opgaven, mens indholdet ændres. Den igangværende session skal afsluttes på den version, den startede på.
- Telefonen har blokeret positionsadgang gennem forældrestyring. Appen skal forklare det og tilbyde en vej videre.
- Spilleren åbner appen uden netværk. Appen skal sige det tydeligt og vise, hvad hen kan gøre — ikke fremstå som om opgaven er i stykker.

## Requirements *(mandatory)*

### Functional Requirements

**Indhold som data**

- **FR-001**: Alle opgaver MUST afvikles ud fra en indholdspakke, der ligger uden for programlogikken. Ingen opgavespecifik logik må findes i koden.
- **FR-002**: Systemet MUST understøtte trintyperne fortælling, enkeltvalg og talkode, sammensat i vilkårlig rækkefølge pr. opgave.
- **FR-003**: Systemet MUST behandle ukendte trintyper og ukendte feltværdier uden at afvise hele indholdspakken, så senere indholdstyper ikke gør en installeret app ubrugelig.
- **FR-004**: Indholdspakken MUST kunne rumme områder, lokationer og opgaver uden at kræve historier, kapitler eller ruter.

**Spilleroplevelse**

- **FR-005**: Spilleren MUST kunne se tilgængelige opgaver på et kort med angivelse af, om en opgave er åben eller allerede gennemført.
- **FR-006**: Missionsdetaljen MUST vise titel, teaser, sværhedsgrad, forventet varighed, afstand, sikkerhedsnoter, tilgængelighedsnoter og fiktionsmarkering før opgaven startes.
- **FR-007**: Systemet MUST vise fiktionsmarkeringen på den narrative intro og gøre den tilgængelig igen fra opgavens informationsvisning.
- **FR-008**: Systemet MUST vise en sikkerhedspåmindelse om trafik og omgivelser, før spillerens første opgave i en session startes.
- **FR-009**: Hvert trin MUST stille ét hovedspørgsmål og angive eksplicit, hvad spilleren skal se bort fra, når afgrænsning er en del af opgaven.
- **FR-010**: Systemet MUST vise tidligere fundne deltal igen på det trin, hvor de skal bruges, så spilleren ikke skal huske dem.
- **FR-011**: Systemet MUST kunne udpege koden fra fortællingens egne ord, når koden består af flere navngivne led.

**Svar og feedback**

- **FR-012**: Systemet MUST acceptere det kanoniske svar samt indholdets registrerede alternative skriveformer for samme svar.
- **FR-013**: Systemet MUST normalisere mellemrum, bindestreger, typografiske varianter og store/små bogstaver før sammenligning, og MUST sammenligne cifferkoder tegn for tegn, så foranstillede nuller bevares.
- **FR-014**: Systemet MUST skelne mellem forkert svar og ufærdigt svar. Et ufærdigt svar må ikke registreres som fejlforsøg.
- **FR-015**: Systemet MUST vise indholdets specifikke feedback, når et forkert svar matcher et registreret typisk forkert svar, og ellers en generisk, ikke-nedgørende besked.
- **FR-016**: Forkerte svar MUST hverken reducere point eller begrænse antallet af forsøg.

**Hints og point**

- **FR-017**: Hver opgave MUST tilbyde nøjagtigt tre hints, der låses op i rækkefølge.
- **FR-018**: Systemet MUST vise det konkrete pointfradrag på hint-handlingen og kræve en bekræftelse, før hintet åbnes.
- **FR-019**: Et allerede åbnet hint MUST kunne genåbnes uden yderligere fradrag.
- **FR-020**: Point MUST registreres som selvstændige, forklarlige transaktioner, og belønningsskærmen MUST vise opdelingen, når et eller flere hints er brugt.
- **FR-021**: Fradragene MUST komme fra indholdet og ikke fra koden.
- **FR-022**: Forløbet tid MUST ikke påvirke point.
- **FR-023**: Grundpoint MUST kun tildeles én gang pr. opgave.
- **FR-052**: En gennemført opgave MUST ikke kunne startes igen i en udgivelsesbygning. Anden gang kender spilleren facit, og et gennemløb uden hints siger da intet om, hvad hen fandt ud af. Spærringen MUST være udledt af hændelsesloggen, så den overlever en genstart, og MUST håndhæves i motoren og ikke kun i den knap, der skjules. Afgrænsning: dette er ikke i strid med FR-027, som handler om at bekræfte tilstedeværelse — den blokering er midlertidig og har en udvej; denne er endelig og tilsigtet.
- **FR-053**: I en udviklingsbygning MUST den samme opgave kunne gennemføres igen og igen, så et gennemløb kan afprøves uden at nulstille progressionen. Genspilning MUST ikke ændre regnskabet: hverken grundpoint (FR-023) eller hintfradrag MUST tælles på ny, og et hint, der er åbnet, MUST stadig stå som åbnet (FR-019). Undtagelsen MUST ikke kunne slås til udefra i en udgivelsesbygning (FR-051), og release-adfærden MUST kunne efterprøves maskinelt fra en udviklingsbygning.

**Position**

- **FR-024**: Systemet MUST bekræfte spillerens tilstedeværelse ved lokationen, før opgavens indhold låses op, ud fra en aktiveringsradius og et standpunkt, der er angivet i indholdet.
- **FR-025**: Systemet MUST kræve, at spilleren opholder sig ved stedet et øjeblik, så en forbipasserende ikke får opgaven låst op.
- **FR-026**: Systemet MUST tage højde for positionens usikkerhed, så dårlig præcision fører til et bredere accept-vindue frem for en afvisning.
- **FR-027**: Systemet MUST aldrig blokere en spiller permanent. Efter et fastsat tidsrum uden bekræftelse MUST spilleren kunne fortsætte alligevel.
- **FR-028**: Hver gennemførelse MUST bære en registrering af, hvordan tilstedeværelsen blev fastslået.
- **FR-029**: Hver tilstand i positionsbekræftelsen MUST have en forklaring på almindeligt dansk og mindst én handling.
- **FR-030**: Systemet MUST anmode om positionsadgang i opgavens egen kontekst og ikke ved appens opstart, og MUST håndtere alle udfald, herunder at adgangen er blokeret udefra.
- **FR-031**: Systemet MUST kun bruge positionen, mens appen er i brug, og MUST ikke gemme en løbende præcis rute.

**Progression og afvikling**

- **FR-032**: Systemet MUST hente indhold fra den centrale tjeneste og MUST vise en forståelig tilstand, når forbindelsen mangler. En igangværende tur MUST IKKE gå tabt ved et kortvarigt udfald.
- **FR-033**: Progression MUST gemmes som en tilføj-kun hændelseslog med klient-genererede, entydige nøgler, så en senere synkronisering kan gentages uden at skabe dubletter.
- **FR-034**: Afledt tilstand — point, gennemførte opgaver, brugte hints — MUST kunne genskabes udelukkende ud fra hændelsesloggen.
- **FR-035**: En påbegyndt opgave MUST fastholde den indholdsversion, den blev startet på.
- **FR-036**: Systemet MUST genoptage en afbrudt opgave på samme trin med bevaret hint- og forsøgsstatus efter en fuld genstart af appen.

**Tilgængelighed**

- **FR-037**: Alt indhold, der er nødvendigt for at løse opgaven, MUST være tilgængeligt som tekst. Opgaven må ikke kræve lyd eller evnen til at skelne bestemte farver.
- **FR-038**: Hvert medie MUST have en forfattet alternativ tekst fra indholdet.
- **FR-039**: Grænsefladen MUST understøtte forstørret tekst uden at afskære indhold, og MUST opfylde anerkendte kontrastkrav.
- **FR-040**: Status på kortet MUST kunne aflæses uden at kunne skelne farver.
- **FR-041**: En hel opgave MUST kunne gennemføres udelukkende med skærmlæser.

**Indholdsvalidering**

- **FR-042**: Indholdet MUST afvises automatisk, hvis obligatoriske felter mangler: kanonisk facit, tre hints, sikkerhedsnoter, tilgængelighedsnoter, kilder, samt ejer, licens og kreditering på hvert medie.
- **FR-043**: Indholdet MUST afvises, hvis et kanonisk facit ikke bedømmes som korrekt af sin egen svarregel.
- **FR-044**: Indholdet MUST afvises, hvis et registreret typisk forkert svar bedømmes som korrekt.
- **FR-045**: Indholdet MUST afvises, hvis hintfradragene ikke summer til den fastsatte samlede værdi.
- **FR-046**: Indholdet MUST afvises, hvis en henvisning til et trin, hint eller medie ikke kan opløses.
- **FR-047**: Indholdet MUST afvises, hvis en kode, der er registreret som ugyldig i opgavedokumentet, forekommer nogen steder i pakken.
- **FR-048**: Indholdet MUST afvises, hvis et medie ikke er mærket med, om det er historisk, nutidigt eller AI-genereret.

**Afgrænsning i denne feature**

- **FR-049**: Systemet MUST ikke oprette brugerkonti, indsamle personoplysninger eller sende data fra enheden.
- **FR-050**: Systemet MUST ikke indeholde inventory, ruter eller kapitelprogression.
- **FR-054**: Spilleren MUST kunne se sine samlede point og hvilke gåder hen har løst. Tallene MUST udledes af hændelsesloggen (FR-034) og MUST ikke være opdigtede.
- **FR-055**: Appen MÅ vise en rangliste som attrap, så testerne kan se, hvad version 1 skal kunne. En sådan attrap MUST være mærket som eksempel **både** med et synligt mærkat og med en sætning i klartekst, og navnene MUST være tydeligt fiktive. Begrundelse: forfatningens princip III forbyder at præsentere noget opdigtet som ægte, og en tester, der tror hen er nummer fire i Vejle, har fået en forkert idé om både spillet og sin egen indsats.
- **FR-051**: Værktøjer, der omgår positionsbekræftelse til udviklingsbrug, MUST ikke være til stede i en udgivelsesbygning.

### Key Entities

- **Indholdspakke**: Den samlede, versionerede mængde indhold appen kan afvikle. Bærer en version, som en påbegyndt opgave bindes til.
- **Område**: Geografisk gruppering, fx Vejle Havn. Har navn og postnummer.
- **Lokation**: Et konkret sted med koordinat, aktiveringsradius, spillerstandpunkt med kigretning, sikkerhedsflag og -noter, tilgængelighedsnoter samt dato for seneste fysiske kontrol.
- **Opgave**: En fritstående mission knyttet til én lokation. Har titel, teaser, sværhedsgrad, forventet varighed, grundpoint, fiktionsmarkering, en ordnet række trin, tre hints, en completion-tekst og en historisk forklaring.
- **Trin**: Ét skridt i en opgave, af en bestemt type — fortælling, enkeltvalg eller talkode. Bærer sin egen tekst, afgrænsning og eventuelle svarregel.
- **Svarregel**: Kanonisk facit, accepterede alternative skriveformer, registrerede typiske forkerte svar med hver sin feedback, samt en generisk feedback.
- **Hint**: Et trin på hinttrappen med rækkefølge, pointfradrag, titel og tekst.
- **Kilde**: Henvisning bag en faktuel påstand — titel, udgiver og adresse.
- **Medie**: Et billede med alternativ tekst, ejer, licens, kreditering og mærkning af, om det er historisk, nutidigt eller AI-genereret.
- **Spilsession**: Spillerens igangværende gennemførelse af én opgave, bundet til den indholdsversion, den startede på.
- **Hændelse**: En uforanderlig post i den tilføj-kun log — opgave åbnet, trin vist, svar afgivet, hint brugt, opgave gennemført. Bærer en entydig, klientgenereret nøgle.
- **Pointtransaktion**: En enkelt, forklarlig ændring af point med begrundelse.
- **Tilstedeværelsesbevis**: Registrering af, hvordan en gennemførelse blev låst op.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: En testperson, der ikke har set appen før, kan stilles ved lokationen uden mundtlig instruktion og gennemføre opgaven fra kort til belønningsskærm.
- **SC-002**: Begge opgaver kan spilles selvstændigt og i vilkårlig rækkefølge, og den anden opgave blev tilføjet uden opgavespecifik programlogik.
- **SC-003**: Et kortvarigt netværksudfald under en igangværende opgave koster ventetid, ikke progression — turen kan genoptages på samme trin, når forbindelsen vender tilbage.
- **SC-004**: Ingen tilstand i positionsbekræftelsen efterlader spilleren uden en forklaring og en handling — nul blindgyder på tværs af samtlige tilstande.
- **SC-005**: En spiller, der bruger alle tre hints, får præcis 88 point, og belønningsskærmen forklarer fradraget.
- **SC-006**: En afbrudt opgave genoptages på samme trin med bevaret hint- og forsøgsstatus i alle testede afbrydelsespunkter.
- **SC-007**: Hver enkelt af de definerede indholdsdefekter afvises automatisk, før indholdet kan indgå i en bygning.
- **SC-008**: Den ugyldige kode `541` forekommer intet sted i produktet, hverken i indhold, tekster, tests eller dokumentation.
- **SC-009**: En hel opgave kan gennemføres udelukkende med skærmlæser og med største tekststørrelse uden afskåret indhold.
- **SC-010**: En spiller, der passerer lokationen uden at standse, får ikke opgaven låst op.

## Assumptions

- **Ingen backend.** Der er ingen server, ingen konti, ingen highscore og ingen dataudveksling. Hændelsesloggen er forberedt til senere synkronisering, men synkroniserer intet i denne feature.
- **Ingen inventory — og det ændrer opgavernes sluttekst.** Begge opgavedokumenter afslutter med at overrække en genstand ("Du har fundet **Det femte signal**", henholdsvis Fjordseglet). Uden en samling at lægge dem i antages det, at disse linjer omskrives til ren fortælling, så belønningen bliver beskeden, pointene og den historiske forklaring. Genstandene bevares i opgavedokumenterne til senere brug. **Dette er en indholdsredaktionel beslutning — bekræft den.**
- **Bølgens trin 2 og 3 er spørgsmål, ikke oplysninger.** Opgavedokumentets afsnit 6 stiller dem som spørgsmål med korrekte delresultater, hvor svaret findes i appens historiske materiale. Det følges. Spilleren skal hverken tælle etager visuelt eller søge på internettet.
- **Koordinater, aktiveringsradius og standpunkt er endnu ikke fastlagt.** Begge opgavedokumenter har dem som åbne punkter, der kræver feltbesøg. Denne feature arbejder med foreløbige værdier, og indholdet er derfor ikke publiceringsklart. Den fysiske opmåling hører til et senere increment.
- **Tirsbæk-broen er ikke med.** Opgaven har status researchklar, har intet fastlagt facit, og kræver en kortrotationsmekanik samt et historisk kort med uafklarede rettigheder. Forfatningens princip II udelukker den, indtil feltdata foreligger.
- **Fejlmelding fra opgaven og pausefunktion for publiceret indhold er ikke med.** Begge er forfatningskrav for indhold i drift. Denne feature producerer ikke offentligt distribueret indhold, og kravene falder i det increment, der forbereder ekstern distribution.
- **Målgruppen bærer ofte ældre telefoner**, hvilket sætter en nedre grænse for understøttede enheder.
- **Kortbaggrund er en bekvemmelighed, ikke en afhængighed.** Opgaven skal kunne gennemføres, selv hvis kortfliser ikke kan hentes.
- **Opgavedokumenterne i `docs/design af opgaver/opgaver/` er kilden til sandhed** for tekst, facit, hints og fakta. Indholdspakken er et afledt artefakt, og uoverensstemmelser mellem de to er en fejl i indholdspakken.
