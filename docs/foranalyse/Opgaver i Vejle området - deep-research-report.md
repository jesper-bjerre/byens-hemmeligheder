# 50 nye opgavesteder i Vejle-området

> **Deep-research-leverance — ikke en publiceringsgodkendelse.** Alle 50 er `draft`, alle produktionskoordinater er `null`, `fieldVerified` er `false`, og `lastPhysicallyVerified` er `null`. Webkilder er tilgået **2026-08-03**. Rapporten er skrevet som redaktionelt og teknisk beslutningsgrundlag for *Byens Hemmeligheder*.

## 1. Executive summary

Researchen ender med **præcis 50 nye udendørs kandidater** fordelt på Vejle Midtby og havn, Jelling, Vejle Ådal, Tørskind/Egtved, Børkop–Brejning, Randbøl–Tinnet, Nørup/Engelsholm, Grejsdalen, Give, Højen og Tirsbæk. Den stærkeste fælles designidé er en fysisk invariant, som familien kan tælle, aflæse eller sammenligne på stedet: indhugget tekst, fast arkitektur, store kunstdele eller robust terrænform. Jelling har den højeste koncentration af autoritativt dokumenteret kulturarv. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne) [Jelling Mounds, Runic Stones and Church](https://whc.unesco.org/en/list/697/)

De ti bedste steder er: **01 Den store Jellingsten, 02 Ravningbroen, 03 Sct. Nicolai Kirkes hovedskalfrise, 04 Randbølstenen, 05 Erhvervsskulpturerne på Rådhustorvet, 06 Den lille Jellingsten, 07 Sønderbro, 08 Kanonkuglehuset, 09 Jellingpalisaden, 10 Tørskind-mand**. Topgruppen kombinerer høj lokationsspecificitet, stærk historie, klart solve-bevis og mindst rimelig online-indikation af adgang. Vejlemuseernes sider giver eksempelvis direkte driftsoplysninger for Ravningbroen, Bindeballe Station og Tørskind, men de er stadig ikke fysisk adgangsbevis. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/) [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/) [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)

De vigtigste risici er ikke historiske, men produktionsmæssige: trafik/cykler i centrum, vand og stejlt naturterræn, privat ejendom ved herregårde/boliger, kirkelige handlinger, sæsonvegetation, byggearbejde og GPS-afvigelse mellem høje facader. Lavere rangerede kandidater 46–50 er med som stærke historier med **betingede** facadegreb; de skal omskrives eller udgå, hvis feltet ikke beviser invarianten. Ingen fysisk risiko må bruges som sværhedsgrad.

## 2. Metode, afgrænsning og kildekritik

Der blev først opbygget en bruttoliste på **94 konkrete steder** fra kommunale kultur-/natursider, Vejlemuseerne, Slots- og Kulturstyrelsen, UNESCO, lokale arkiver/Historisk Atlas, Trap/Lex, officielle turismesider og relevante værk-/arkitektsider. Bruttolisten blev derefter deduplikeret både geografisk og opgavemæssigt. Flere stop kan ligge samme sted, men kun når invarianten, historien og solve-handlingen er tydeligt forskellige; Jelling er eksempelvis opdelt i sten, palisade, skibssætning og høje, ikke i små variationer af samme tælling.

Kandidater blev frasorteret ved sandsynlig privat adgang, snæver åbningstid, manglende helårsinvariant, risikabel vej-/vandobservation, følsomhed, uklart facit eller utilstrækkeligt kildegrundlag. De seks eksplicitte eksklusioner er ikke genbrugt som dossiers. Havne- og Tirsbæk-kandidater er desuden kontrolleret for semantisk dublet, så fx et nyt ‘bro’-stop ikke skjult genbruger den allerede brugte gamle bro.

Scoren følger den bestilte 100-pointmodel: lokationsspecificitet/invariant 25, fortællekraft 20, facitentydighed 20, kildekvalitet 15, adgang/sikkerhed/tilgængelighed 10 og klynge/geografisk variation 10. Kun kandidater vurderet mindst **4/5 i både lokationsrelevans og entydighed** er med; `4/5` betyder her ‘lovende draft med en identificeret feltfejl’, ikke publiceringsklar. Ved alvorlig sandsynlig risiko blev stedet fravalgt. Stokbro er den snævreste restkandidat og har en eksplicit stopregel: ingen sikker offentlig observation, ingen opgave.

Kildehierarkiet er: myndighed/forvalter eller primær værkside til identitet og fakta; register/arkiv til historie; officiel turisme til rute og praktisk indikation. Turismesider er ikke i sig selv feltbevis. Sagn er markeret som sagn. Konflikter er bevaret: vejviseren har **1853** hos Trap og **1856** hos VisitVejle, og Margrethedigets bevarede længde angives som cirka **250 m** hos Historisk Atlas og **150 m** hos kommunen. Facit er i begge tilfælde valgt uafhængigt af det omstridte tal. [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten) [Øster Nykirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135) [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29) [Hærvejen](https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/)

Online research kan ikke bevise, at et fortov er bredt nok, at alle detaljer er synlige, at GPS virker, eller at et objekt ikke er midlertidigt flyttet. Derfor er decimalgrader bevidst ikke gættet, og alle `latitude`/`longitude` står `null`.

## 3. Hvad systemet kræver

| Modenhed | Hvad kan systemet have? | Hvad mangler stadig? |
|---|---|---|
| **Teknisk kladde** | Standardradius 45 m, maksimumsnøjagtighed 40 m, dwell 20 s, `draft`, `null`-koordinater og tomme mediereferencer. | Kan være syntaktisk gyldig uden at være sikker, fair eller meningsfuld. |
| **Meningsfuld produktionskladde** | Identitet, historie, invariant, spørgsmålstype, facit, svarnormalisering, solve-bevis, tre hints, completion-tekster, kilder og feltcheckliste fra denne rapport. | Kræver stadig menneskelig redigering og fysisk validering. |
| **Publicering** | Kun data, som har bestået felt-, rettigheds- og solve-gates. | Fysisk GPS/startsted, adgang, sikkerhed, tilgængelighed, ejerhensyn, medielicenser, familie-solve-test og godkendelse. |

Tekniske standarder, som ikke gentages som produktionspåstande: `heroMediaId`, `thumbnailMediaId`, `placeMediaId`, `moodMediaId` og `narrationMediaId` forbliver `null`; `cards` er `[]`; `storyId`, `chapterId` og `nextChapterId` er `null`; `sourceIds` udledes af dossierernes Kildedata. Mission-, slug-, location-, step-, hint- og source-id'er skal genereres af den efterfølgende agent.

## 4. Prioriteret oversigt over alle 50

| Rang | Sted | Postnr. | Område | Historiens kerne | Fysisk invariant | Type | Score | Største risiko | Klynge |
|---:|---|:---:|---|---|---|---|---:|---|---|
| 01 | Den store Jellingsten | 7300 | Jelling | Harald Blåtands monument og Danmarks samling | stenens tre billed- og tekstbærende sider | `numericCode` | 97 | `crowding` | Jelling-monumenterne |
| 02 | Ravningbroen | 7182 | Ravning Enge | Harald Blåtands 760 meter lange træbro | de to rekonstruerede brohoveder/ender i landskabet | `numericCode` | 96 | `water` | Vejle Ådal vest |
| 03 | Sct. Nicolai Kirkes hovedskalfrise | 7100 | Vejle Midtby | Menneskekranier indmuret i byens ældste bygning | rækken af 23 menneskekranier i korets nordmur | `numericCode` | 95 | `crowding` | Vejle historiske centrum |
| 04 | Randbølstenen | 7183 | Randbøl Hede | En runesten sprængt og senere samlet | de ti synlige stenfragmenter samlet på betonfundamentet | `numericCode` | 94 | `cyclePath` | Randbøl–Tinnet Hærvejen |
| 05 | Erhvervsskulpturerne på Rådhustorvet | 7100 | Vejle Midtby | Efterkrigstidens billeder på handel og arbejde | de fire forskellige erhvervssymboler i de to skulpturgrupper | `numericCode` | 93 | `crowding` | Vejle historiske centrum |
| 06 | Den lille Jellingsten | 7300 | Jelling | Danmarks ældre navngivning og Gorms minde | runebåndenes lodrette læseretning på den lille sten | `singleChoice` | 92 | `crowding` | Jelling-monumenterne |
| 07 | Sønderbro | 7100 | Vejle Midtby | Vejles gamle sydlige stenbro og kampen i 1864 | kronesymbolet ved den historiske facadeindskrift på broen | `singleChoice` | 91 | `traffic` | Vejle historiske centrum |
| 08 | Kanonkuglehuset | 7100 | Vejle Midtby | Et projektilspor fra slaget ved Vejle | den ene indmurede kanonkugle mellem facadevinduerne | `numericCode` | 90 | `traffic` | Vejle historiske centrum |
| 09 | Jellingpalisaden | 7300 | Jelling | Den monumentale palisade omkring Jelling | det rekonstruerede palisadeforløbs overordnede kvadratiske form | `singleChoice` | 89 | `cyclePath` | Jelling-monumenterne |
| 10 | Tørskind-mand | 6040 | Tørskind | Robert Jacobsens landskabsskulptur i grusgraven | skulpturens tre ben af gamle egetræsstykker | `numericCode` | 88 | `steepSlope` | Tørskind Landskabsskulptur |
| 11 | Børkop Vandmølle | 7080 | Børkop | En bevaret vandmølle med usædvanligt maskineri | de to store overfaldshjul på møllens yderside | `numericCode` | 87 | `water` | Børkop–Brejning |
| 12 | Den Smidtske Gård | 7100 | Vejle Midtby | Vejles eneste bevarede købmandsgård | det firecifrede byggeår over gårdens port | `numericCode` | 86 | `crowding` | Vejle historiske centrum |
| 13 | Jelling-skibssætningen | 7300 | Jelling | Verdens største kendte skibssætning | stenrækkernes langstrakte skibsform med spidse ender | `singleChoice` | 85 | `cyclePath` | Jelling-monumenterne |
| 14 | Engelsholm Slot | 7182 | Nørup | Renæssanceslottets symmetriske silhuet | de fire kvadratiske hjørnetårne med løgkupler | `numericCode` | 84 | `privateProperty` | Engelsholm–Nørup |
| 15 | Vejle Vindmølle | 7100 | Søndermarken | Byens vindmølle på den gamle galgebakke | de fire faste møllevinger på hatten | `numericCode` | 83 | `steepSlope` | Vejle syd og centrum |
| 16 | St. Peders Kilde | 7323 | Hærvejen ved Vonge | En helligkilde langs Hærvejen | den firkantede ydre egetræsramme omkring den runde stensatte brønd | `singleChoice` | 82 | `water` | Randbøl–Tinnet Hærvejen |
| 17 | Bindeballe Station | 7183 | Bindeballe | Vandelbanens bevarede landstation | de tre gamle jernbanevogne ved stationsanlægget | `numericCode` | 81 | `cyclePath` | Vejle Ådal vest |
| 18 | Your Perception | 7080 | Brejning | Et nutidigt kunstværk om opfattelse | værkets tre separate skulpturdele i parken | `numericCode` | 80 | `privateProperty` | Børkop–Brejning |
| 19 | Jellinghøjene | 7300 | Jelling | Nord- og Sydhøjen i det kongelige monumentlandskab | de to store græsklædte grav-/mindehøje på hver side af kirken | `numericCode` | 79 | `steepSlope` | Jelling-monumenterne |
| 20 | Egtvedpigens Verden | 6040 | Egtved | Et nyt udendørs univers omkring bronzealderpigen | anlæggets fem navngivne formidlingszoner | `numericCode` | 78 | `crowding` | Vejle Ådal vest |
| 21 | Vejviseren ved Nørre Kollemorten | 7323 | Nørre Kollemorten | En kongelig vejviser på den gamle hovedvej | stednavnet COLDING på samme stenflade som det indhuggede årstal | `freeText` | 77 | `traffic` | Randbøl–Tinnet Hærvejen |
| 22 | Grejsdal Kirke | 7100 | Grejsdalen | Efterkrigstidens femkantede kirke i ådalen | kirkens aflange femkantede grundplan set i ydermurens hovedsider | `numericCode` | 76 | `steepSlope` | Grejsdalen |
| 23 | Den gamle ottekant i Skyttehushaven | 7100 | Skyttehushaven | Den historiske dansepavillon ved fjorden | den gamle pavillons ottekantede hovedform | `numericCode` | 75 | `water` | Vejle fjord og havn |
| 24 | Midgårdsbrønden | 7100 | Vejle Midtby | En legende omskrivning af rigsvåbnets løver | de tre løveungefigurer omkring brøndskulpturen | `numericCode` | 74 | `water` | Vejle historiske centrum |
| 25 | Vildtbanestenene ved den tidligere Amtsgård | 7100 | Vejle Midtby | Frederik 5.s vildtbanegrænse samlet i byen | de tre registrerede vildtbanegrænsesten opstillet som gruppe | `numericCode` | 73 | `traffic` | Vejle centrum vest |
| 26 | Lille Tycho Brahe | 6040 | Tørskind | Jean Clareboudts landskabskikkert | de to store rør, der peger i modsatte retninger | `numericCode` | 72 | `steepSlope` | Tørskind Landskabsskulptur |
| 27 | Skolestenen ved Kellers Minde | 7080 | Brejning | Kellers institutionshistorie skrevet i sten | ordet HJEM i den bevarede skoleindskrift | `freeText` | 71 | `crowding` | Børkop–Brejning |
| 28 | Solhjul | 7323 | Give | Et monumentalt solhjul inspireret af oldtidsfund | stålringenes dokumenterede syv graders hældning ind mod centrum | `singleChoice` | 70 | `traffic` | Give kunst og Hærvej |
| 29 | Ene Øjesten | 7080 | Børkop | Thomas Dambos genbrugstrold med en magisk sten | det gennemgående hul i den flade sten, som trolden holder | `singleChoice` | 69 | `steepSlope` | Børkop–Brejning |
| 30 | Spinderihallerne | 7100 | Vejle Midtby vest | Bomuldsindustriens store haller genbrugt til kultur | det permanente navneskilt på hovedfacaden ved den offentlige ankomst | `freeText` | 68 | `traffic` | Vejle centrum vest |
| 31 | Brandtavlen for katastrofen i 1786 | 7100 | Vejle Midtby | Brand- og eksplosionskatastrofen der ændrede Vejle | det firecifrede årstal 1786 på den permanente minde-/informationstavle | `numericCode` | 67 | `traffic` | Vejle historiske centrum |
| 32 | Glasmontrerne over middelaldervejen | 7100 | Vejle Midtby | Den middelalderlige stenvej under nutidens gågade | de tre faste glasmontrer/felter, der viser den gamle vejbelægning | `numericCode` | 66 | `cyclePath` | Vejle historiske centrum |
| 33 | Runefliserne i Vejles gågade | 7100 | Vejle Midtby | Moderne runetekster som byens skjulte spor | de 13 særlige runetekst-fliser i det definerede gågadeforløb | `numericCode` | 65 | `cyclePath` | Vejle historiske centrum |
| 34 | Sct. Pouls Kirke | 7100 | Vejle Midtby | Vejles katolske kirke med en usædvanlig kuppel | det ottekantede tårns otte hovedsider under kuppelspiret | `numericCode` | 64 | `traffic` | Vejle historiske centrum |
| 35 | Det Pressede Hjerte | 7100 | Vejle Midtby | Samtidskunst ved Vejle Kunstmuseum | den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte | `singleChoice` | 63 | `traffic` | Vejle centrum vest |
| 36 | Himmelstigen | 7100 | Vejle Midtby | En moderne runesten mellem banegård og by | kunstnerens fornavn BJØRN skrevet med runer i værkets signatur | `freeText` | 62 | `traffic` | Vejle historiske centrum |
| 37 | Firehøje | 7183 | Randbøl | En samlet gruppe bronzealderhøje | de fire store gravhøje, der udgør den navngivne gruppe Firehøje | `numericCode` | 61 | `steepSlope` | Randbøl–Tinnet Hærvejen |
| 38 | Det gamle badeland ved Tinnet Krat | 7173 | Tinnet Krat | 1930'ernes badeland ved Gudenåens spæde løb | betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform | `singleChoice` | 60 | `water` | Randbøl–Tinnet Hærvejen |
| 39 | Margrethediget | 7173 | Tinnet/Vonge | Et jernalderjordværk på tværs af Hærvejslandskabet | rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd | `singleChoice` | 59 | `steepSlope` | Randbøl–Tinnet Hærvejen |
| 40 | Stokbro over Højen Å | 7100 | Højen | En hvælvet granitbro med bevaret rækværksrytme | de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden | `numericCode` | 58 | `traffic` | Højen og Vejle syd |
| 41 | Nørup Kirke | 7182 | Nørup | Middelalderkirken omformet af en 1700-tals godsejer | tårnets karakteristiske løgformede kuppel | `singleChoice` | 57 | `traffic` | Engelsholm–Nørup |
| 42 | Tirsbæk Gods set fra den offentlige fjordsti | 7120 | Tirsbæk | Renæssanceherregården mellem skov, eng og fjord | voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne | `singleChoice` | 56 | `privateProperty` | Vejle fjord og Tirsbæk |
| 43 | Kunstbroerne over Mølleåen | 7100 | Vejle Midtby | Kunstnerdesignede passager over den genåbnede byå | de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb | `numericCode` | 55 | `water` | Vejle historiske centrum |
| 44 | Tróndur – Vejles P-hus | 7100 | Vejle Midtby | Færøsk glaskunst omkring et parkeringshus | parkeringshusets seks tydelige bygningsniveauer bag glasfacaden | `numericCode` | 54 | `traffic` | Vejle historiske centrum |
| 45 | Den skæve lysmast på Nørretorv | 7100 | Vejle Midtby | Et moderne pejlemærke ved den gamle bygrænse | den permanent konstruerede skæve/hældende lysmast på torvet | `singleChoice` | 53 | `traffic` | Vejle historiske centrum |
| 46 | Det gamle Vejle Bomuldsspinderi | 7100 | Vejle Havn | Danmarks tidlige bomuldsspinderi ved jernbanen | en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade | `singleChoice` | 52 | `traffic` | Vejle havn og industri |
| 47 | Det Kongelige Toldkammer | 7100 | Vejle Havn | 1900-tallets port mellem havn, skibe og stat | det faste kronesymbol ved den historiske toldkammerfacades navn/portal | `singleChoice` | 51 | `traffic` | Vejle havn og industri |
| 48 | Mamrelund | 7100 | Vejle Midtby | Vejles gamle missionshus genbrugt som boliger | den store spidsbuede facadeåbning på det tidligere missionshus | `singleChoice` | 50 | `privateProperty` | Vejle historiske centrum |
| 49 | Bygningen – Arbejdernes Forsamlingsbygning | 7100 | Vejle Midtby vest | Et hundrede år gammelt samlingssted for arbejderbevægelsen | det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade | `numericCode` | 49 | `traffic` | Vejle centrum vest |
| 50 | Villa Flegborg | 7100 | Vejle Midtby vest | C.M. Hess' store villa ved det gamle industrikvarter | villaens fire bygningsetager efter en feltfastlagt tælleregel | `numericCode` | 48 | `traffic` | Vejle centrum vest |

## 5. Kandidatdossierer

### 01 — Den store Jellingsten

#### Identitet og prioritering

- **rangnummer:** `01`
- **samlet score:** **97/100** — Meget lokationsspecifik, ikonisk og veldokumenteret invariant; eneste væsentlige risiko er glas-/spejlvirkning og trængsel.
- **stedets officielle eller mest præcise navn:** Den store Jellingsten
- **postnummer:** `7300`
- **adresse/stedbeskrivelse:** Monumentområdet ved Thyrasvej 1, 7300 Jelling
- **område/by:** Jelling
- **foreslået opgavetitel:** Kongens sten har tre sider
- **kort titel:** Tre sider
- **spillerrettet beskrivelse:** Harald Blåtand lod både ord og billeder hugge i stenen. Familien skal undersøge hele monumentet – ikke kun forsiden.
- **tags:** `vikinger`, `runer`, `UNESCO`, `familie`
- **klynge/rute:** Jelling-monumenterne
- **nærliggende kandidater:** 06 Lille Jellingsten, 09 palisaden, 13 skibssætningen og 19 højene

#### Dokumenteret historie

**Centrale fakta**

- Den store Jellingsten er rejst omkring 965 af Harald Blåtand til minde om Gorm og Thyra. [Jellingstenen 2](https://trap.lex.dk/Jellingstenen_2)
- Stenen har tre sider: én med indskrift, én med dyr og slange og én med Kristusfiguren. [Jellingstenen 2](https://trap.lex.dk/Jellingstenen_2)
- Stenen indgår sammen med højene, kirken og den lille sten i UNESCO-monumentområdet. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Jelling-monumenterne blev optaget på UNESCOs verdensarvsliste i 1994. [Jelling Mounds, Runic Stones and Church](https://whc.unesco.org/en/list/697/)

- **Hvorfor interessant for en familie:** Tre tydeligt forskellige flader gør storpolitik, dyr og Kristus til en konkret opdagelsesleg.
- **Sikkert dokumenteret:** Datering, kongelig indskrift, motivfordeling og verdensarvsstatus er autoritativt dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Farvernes oprindelige udseende og mange fortolkninger af motiverne er ikke nødvendige for facit.
- **Kildekritisk vurdering:** Slots- og Kulturstyrelsen og UNESCO er stærke til status; Trap giver den mest direkte beskrivelse af selve stenen.

#### Stedet som spil

- **Konkret observerbar invariant:** stenens tre billed- og tekstbærende sider.
- **Hvorfor permanent/helårsrobust:** Sidetallet er en del af selve den fredede sten og ændres ikke sæsonmæssigt.
- **Spilleren skal konkret:** gå rundt om glasmontren og tælle flader med hugning.
- **Spilleren skal eksplicit ignorere:** montrens glasflader, sokkel, skilte og spejlinger.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop stenens tre billed- og tekstbærende sider; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Nogle børn kan tælle glasmontrens flader eller overse bagsiden; observationspunkt og ordlyd skal solve-testes.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Gå hele vejen rundt om den store runesten. Hvor mange sider bærer runer eller billeder?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Du har sandsynligvis kun set stenens to mest kendte billedsider. Gå hele vejen rundt.
- `4` → Tæl stenen – ikke glasmontren eller soklen.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Den store Jellingsten** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Stenen har tre sider: én med indskrift, én med dyr og slange og én med Kristusfiguren. [Jellingstenen 2](https://trap.lex.dk/Jellingstenen_2)
3. Udfør kun denne observation: gå rundt om glasmontren og tælle flader med hugning; udelad montrens glasflader, sokkel, skilte og spejlinger.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Jellingstenen 2](https://trap.lex.dk/Jellingstenen_2)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find stenens tre billed- og tekstbærende sider ved Den store Jellingsten; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå rundt om glasmontren og tælle flader med hugning. Ignorér montrens glasflader, sokkel, skilte og spejlinger.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Stenen er trekantet: alle tre flader tæller.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre sider på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Harald Blåtands monument og Danmarks samling bliver håndgribelig, fordi I selv fandt stenens tre billed- og tekstbærende sider.
- `historyFact`: Haralds sten fortæller blandt andet, at han vandt hele Danmark og Norge og gjorde danerne kristne. [Jellingstenen 2](https://trap.lex.dk/Jellingstenen_2)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Den store Jellingsten`
- `postalCode`: `7300`
- `address`: `Monumentområdet ved Thyrasvej 1, 7300 Jelling`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Jellingstenen 2](https://trap.lex.dk/Jellingstenen_2)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — monumentområdet er et offentligt besøgssted; døgnadgang til den præcise montre skal stadig registreres i felt. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fast belægning i monumentområdet; kantforhold ved montren skal kontrolleres
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den plane offentlige belægning rundt om glasmontren uden at blokere andre gæster.

**Kandidatspecifik feltcheckliste**

- Bekræft at alle tre stenflader kan ses uden blænding.
- Test at børn ikke tæller glas eller sokkel.
- Registrér GPS-punkt og plads til en familie uden trængselskonflikt.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Jellingstenen_2
- Motiv: et oversigts- eller detaljefoto af stenens tre billed- og tekstbærende sider; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- Motiv: et oversigts- eller detaljefoto af stenens tre billed- og tekstbærende sider; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Slots- og Kulturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Slots- og Kulturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Jellingstenen 2
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Jellingstenen_2
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: datering, bygherre og de tre udsmykkede sider

**Kilde 2**
- `title`: Jelling-monumenterne
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: monumentområdets sammenhæng og offentlig formidling

**Kilde 3**
- `title`: Jelling Mounds, Runic Stones and Church
- `publisher`: UNESCO World Heritage Centre
- `url`: https://whc.unesco.org/en/list/697/
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: verdensarvsstatus


### 02 — Ravningbroen

#### Identitet og prioritering

- **rangnummer:** `02`
- **samlet score:** **96/100** — Enestående landskabsaflæsning, stærke kilder og et meget robust facit; afstand og vådt terræn kræver feltmåling.
- **stedets officielle eller mest præcise navn:** Ravningbroen
- **postnummer:** `7182`
- **adresse/stedbeskrivelse:** Ravningvej 25, 7182 Bredsten
- **område/by:** Ravning Enge
- **foreslået opgavetitel:** Broen, der krydsede engen
- **kort titel:** To broender
- **spillerrettet beskrivelse:** En usynlig vikingebro ligger stadig under engen. Find de to steder, hvor museet har løftet dens ender frem igen.
- **tags:** `vikinger`, `bro`, `landskab`, `arkæologi`
- **klynge/rute:** Vejle Ådal vest
- **nærliggende kandidater:** 17 Bindeballe Station og 20 Egtvedpigens Verden

#### Dokumenteret historie

**Centrale fakta**

- Ravningbroen blev bygget omkring år 980, var cirka 760 meter lang og fem meter bred. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)
- På stedet er broens to ender rekonstrueret, mens de originale stolper ligger beskyttet i jorden. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)
- Broen bestod af omtrent 280 fag og omkring 1.800 nedrammede pæle. [Ravning Enge broen](https://trap.lex.dk/Ravning_Enge_broen)
- Udearealet er oplyst som åbent døgnet rundt; udstillingen har særskilt tidsrum. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)

- **Hvorfor interessant for en familie:** Det store mål bliver forståeligt, når børn fysisk forbinder to fjerne rekonstruktioner over en eng.
- **Sikkert dokumenteret:** Datering, dimensioner, konstruktion og de to rekonstruktioner er dokumenteret af Vejlemuseerne og Trap.
- **Usikkert, omstridt, sagn eller fortolkning:** Broens præcise formål er ikke sikkert; opgaven hævder derfor ikke, at den var hærvej, dæmning eller magtsymbol alene.
- **Kildekritisk vurdering:** Museets egen side er stærk på drift og sted; Trap fungerer som uafhængig kulturhistorisk kontrol.

#### Stedet som spil

- **Konkret observerbar invariant:** de to rekonstruerede brohoveder/ender i landskabet.
- **Hvorfor permanent/helårsrobust:** De to anlæg er stedfaste rekonstruktioner og ikke midlertidig skiltning.
- **Spilleren skal konkret:** lokalisere begge rekonstruerede broender i terrænet.
- **Spilleren skal eksplicit ignorere:** udstillingsbygning, moderne gangbroer, hegnspæle og løse træstykker.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de to rekonstruerede brohoveder/ender i landskabet; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Det skal testes, om begge ender faktisk er synlige på samme besøg, og om ordet ‘ender’ forstås uden at krydse vådt terræn.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange rekonstruerede ender af vikingebroen kan du finde på hver sin side af engen?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `2`
- **Accepterede svarformer, facit først:** `2`, `to`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `1` → Du har fundet den ene rekonstruktion; se efter broens fortsættelse på den anden side af engen.
- `3` → Moderne broer og udstillingsdele tæller ikke.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Ravningbroen** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: På stedet er broens to ender rekonstrueret, mens de originale stolper ligger beskyttet i jorden. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)
3. Udfør kun denne observation: lokalisere begge rekonstruerede broender i terrænet; udelad udstillingsbygning, moderne gangbroer, hegnspæle og løse træstykker.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`2`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de to rekonstruerede brohoveder/ender i landskabet ved Ravningbroen; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: lokalisere begge rekonstruerede broender i terrænet. Ignorér udstillingsbygning, moderne gangbroer, hegnspæle og løse træstykker.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Der er én rekonstrueret ende ved hver ende af det gamle broforløb.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste to broender på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Harald Blåtands 760 meter lange træbro bliver håndgribelig, fordi I selv fandt de to rekonstruerede brohoveder/ender i landskabet.
- `historyFact`: Den oprindelige bro rummede omtrent 280 fag og cirka 1.800 pæle. [Ravning Enge broen](https://trap.lex.dk/Ravning_Enge_broen)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Ravningbroen`
- `postalCode`: `7182`
- `address`: `Ravningvej 25, 7182 Bredsten`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — udearealet oplyses som døgnåbent; udstillingen er normalt 8–20. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** grus, græs og mulige bløde/våde partier
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `partial`
- **Tilgængelighed — barnevogn:** `partial`
- **Tilgængelighed — afstand fra adgang:** afstanden mellem enderne er ikke feltmålt; den historiske bro var ca. 760 m
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** de etablerede offentlige stier ved hver rekonstruktion; ingen genvej over våd eng.

**Kandidatspecifik feltcheckliste**

- Gå den lovlige rute til begge ender og mål faktisk spilleafstand.
- Kontrollér oversvømmelse, græs, cykeltrafik og mobil/GPS.
- Fotografér præcis hvad ‘rekonstrueret ende’ betyder.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/
- Motiv: et oversigts- eller detaljefoto af de to rekonstruerede brohoveder/ender i landskabet; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Ravning_Enge_broen
- Motiv: et oversigts- eller detaljefoto af de to rekonstruerede brohoveder/ender i landskabet; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Ravningbroen
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: mål, datering, rekonstruktioner, adresse og adgang

**Kilde 2**
- `title`: Ravning Enge broen
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Ravning_Enge_broen
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: konstruktion og antal fag/pæle


### 03 — Sct. Nicolai Kirkes hovedskalfrise

#### Identitet og prioritering

- **rangnummer:** `03`
- **samlet score:** **95/100** — Ekstremt særpræget og tælleligt kulturspor med stærk lokal kilde; etisk formidling og kirkelig aktivitet kræver omtanke.
- **stedets officielle eller mest præcise navn:** Sct. Nicolai Kirkes hovedskalfrise
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Kirketorvet 1, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** De 23 hoveder i muren
- **kort titel:** 23 kranier
- **spillerrettet beskrivelse:** I kirkemuren sidder et ægte, men gådefuldt spor efter tidligere vejlenseres begravelser. Tæl nicherne respektfuldt udefra.
- **tags:** `kirke`, `middelalder`, `menneskerester`, `sagn`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 05 Rådhustorvet, 07 Sønderbro, 08 Kanonkuglehuset og 12 Den Smidtske Gård

#### Dokumenteret historie

**Centrale fakta**

- Sct. Nicolai Kirke er Vejles ældste bygning og har dele fra omkring 1250. [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)
- I korets nordmur er 23 menneskekranier indmuret i runde nicher. [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)
- Kraniernes oprindelse er ukendt; fortællingen om henrettede røvere er et sagn, ikke dokumenteret fakta. [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)
- Kirken ligger centralt ved Kirketorvet og præsenteres som en historisk seværdighed. [Sankt Nicolai Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/sankt-nicolai-kirke-gdk608138)

- **Hvorfor interessant for en familie:** Det overraskende syn åbner en samtale om middelalderkirker, kirkegårde og forskellen på sagn og viden.
- **Sikkert dokumenteret:** Antal, placering og kirkens alder er dokumenteret; at kranierne er menneskelige behandles som kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvem de var, hvorfor de blev indmuret, og røverhistorien er ukendt eller sagn.
- **Kildekritisk vurdering:** Historisk Atlas bygger på Vejle Stadsarkivs lokale fagviden; turistkilden supplerer, men gentager ikke hele proveniensdiskussionen.

#### Stedet som spil

- **Konkret observerbar invariant:** rækken af 23 menneskekranier i korets nordmur.
- **Hvorfor permanent/helårsrobust:** Kranier og nicher er en integreret, fredet del af murværket.
- **Spilleren skal konkret:** stå udenfor ved korets nordside og tælle kranier/nicher i rækken.
- **Spilleren skal eksplicit ignorere:** murankre, vinduer, andre runde former og motiver inde i kirken.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop rækken af 23 menneskekranier i korets nordmur; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Blade, stillads eller begravelsesaktivitet kan hindre udsyn; børn kan miste tællerækkefølgen ved 23.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Find rækken af runde nicher med kranier i kirkens ydermur. Hvor mange kranier er der?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `2`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 23 skrives i decimalform; læs tiercifret `2` først og enercifret `3` bagefter. Indtast `23` uden mellemrum eller bindestreg.
- **Kanonisk facit:** `23`
- **Accepterede svarformer, facit først:** `23`, `treogtyve`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `22` → Gå rækken igennem én gang mere og markér dit startpunkt.
- `24` → Tæl kun nicher med et kranium – ikke andre runde murdetaljer.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Sct. Nicolai Kirkes hovedskalfrise** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: I korets nordmur er 23 menneskekranier indmuret i runde nicher. [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)
3. Udfør kun denne observation: stå udenfor ved korets nordside og tælle kranier/nicher i rækken; udelad murankre, vinduer, andre runde former og motiver inde i kirken.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 23 skrives i decimalform; læs tiercifret `2` først og enercifret `3` bagefter. Indtast `23` uden mellemrum eller bindestreg.
5. Observation og regel giver facit **`23`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find rækken af 23 menneskekranier i korets nordmur ved Sct. Nicolai Kirkes hovedskalfrise; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: stå udenfor ved korets nordside og tælle kranier/nicher i rækken. Ignorér murankre, vinduer, andre runde former og motiver inde i kirken.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Start yderst i én ende og tæl systematisk; facit ligger i tyverne.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste 23 kranier på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Menneskekranier indmuret i byens ældste bygning bliver håndgribelig, fordi I selv fandt rækken af 23 menneskekranier i korets nordmur.
- `historyFact`: Røverforklaringen er kun et sagn; kilden siger, at kraniernes oprindelse er ukendt. [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Sct. Nicolai Kirkes hovedskalfrise`
- `postalCode`: `7100`
- `address`: `Kirketorvet 1, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Sct. Nicolai Kirke i Vejle](https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — frisen kan normalt observeres udefra, men kirkegård, handlinger og lokale regler skal kontrolleres; turistkilden dokumenterer ikke døgnadgang. [Sankt Nicolai Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/sankt-nicolai-kirke-gdk608138)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** bybelægning og kirkeareal; lokale kanter/trin ukendte
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentligt belagt areal på nordsiden i respektfuld afstand; aldrig under kirkelig handling eller begravelse.

**Kandidatspecifik feltcheckliste**

- Bekræft lovlig adgang og at alle 23 kan ses fra samme offentlige forløb.
- Aftal etisk ordlyd med kirken.
- Test tælling med børn og registrér eventuelle skjulende planter/stillads.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29
- Motiv: et oversigts- eller detaljefoto af rækken af 23 menneskekranier i korets nordmur; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/sankt-nicolai-kirke-gdk608138
- Motiv: et oversigts- eller detaljefoto af rækken af 23 menneskekranier i korets nordmur; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Sct. Nicolai Kirke i Vejle
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Sct._Nicolai_Kirke_i_Vejle_%282273%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: bygningens alder, antal kranier og usikker proveniens

**Kilde 2**
- `title`: Sankt Nicolai Kirke
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/sankt-nicolai-kirke-gdk608138
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: stedets identitet og besøgsrelevans


### 04 — Randbølstenen

#### Identitet og prioritering

- **rangnummer:** `04`
- **samlet score:** **94/100** — Sjælden, synlig ‘reparationshistorie’ og entydigt kildefacit; adgang og fragmentgrænser skal feltverificeres.
- **stedets officielle eller mest præcise navn:** Randbølstenen
- **postnummer:** `7183`
- **adresse/stedbeskrivelse:** Randbøl Hede ved den gamle Hærvej; præcist offentligt ankomstpunkt skal feltfastlægges
- **område/by:** Randbøl Hede
- **foreslået opgavetitel:** Stenen der blev samlet igen
- **kort titel:** Ti brudstykker
- **spillerrettet beskrivelse:** Denne runesten overlevede ikke hel. Find fugerne efter dens dramatiske historie og aflæs, hvor mange dele den blev reddet fra.
- **tags:** `runer`, `vikingetid`, `Hærvejen`, `natur`
- **klynge/rute:** Randbøl–Tinnet Hærvejen
- **nærliggende kandidater:** 16 St. Peders Kilde, 21 vejviseren, 37 Firehøje og 39 Margrethediget

#### Dokumenteret historie

**Centrale fakta**

- Randbølstenen er en runesten fra vikingetiden, sandsynligvis fra 900-tallet. [Randbølstenen](https://lex.dk/Randb%C3%B8lstenen)
- Indskriften er et minde over Thorgunn, rejst af Tuve Bryde. [Stenen på Randbøl Hede](https://www.vikingeskibsmuseet.dk/fagligt/e-laering/viden-om-vikingetiden/vikingetidens-geografi/runesten-og-billedsten/stenen-paa-randboel-hede)
- En stenhugger sprængte stenen i 1874; ti fragmenter blev i 1984 samlet på et betonfundament. [Randbølstenen](https://trap.lex.dk/Randb%C3%B8lstenen)
- Stenen står på en lav høj ved den gamle Hærvej på Randbøl Hede. [Randbølstenen](https://trap.lex.dk/Randb%C3%B8lstenen)

- **Hvorfor interessant for en familie:** Børn kan se restaurering som fysisk detektivarbejde og tale om, hvorfor kulturarv beskyttes.
- **Sikkert dokumenteret:** Ti fragmenter, 1874-hændelsen, 1984-samlingen og mindeindskriften er kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Kilderne daterer stenen bredt, og det er ikke sikkert, at alle restaureringsfuger er lette at skelne i felt.
- **Kildekritisk vurdering:** Trap/Register er stærkest på genstanden; Lex og Vikingeskibsmuseet giver uafhængig faglig kontekst.

#### Stedet som spil

- **Konkret observerbar invariant:** de ti synlige stenfragmenter samlet på betonfundamentet.
- **Hvorfor permanent/helårsrobust:** Fragmenterne er fysisk samlet i den fredede sten; antallet ændrer sig ikke med årstiden.
- **Spilleren skal konkret:** identificere de oprindelige fragmenter via synlige fuger og kontrollere tallet mod stedets formidling.
- **Spilleren skal eksplicit ignorere:** betonfundament, nyere udfyldningsmateriale, løse sten og skiltestolper.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de ti synlige stenfragmenter samlet på betonfundamentet; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Restaureringsmørtel kan få udfyldninger til at ligne ekstra fragmenter; opgaven kan kræve et neutralt hjælpefoto uden facit.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Se på samlingerne i Randbølstenen. Hvor mange oprindelige stenstykker blev den samlet af?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `2`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 10 skrives i decimalform; læs tiercifret `1` først og enercifret `0` bagefter. Indtast `10` uden mellemrum eller bindestreg.
- **Kanonisk facit:** `10`
- **Accepterede svarformer, facit først:** `10`, `ti`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `9` → Se efter et mindre stykke, som kan gemme sig mellem større flader.
- `11` → Beton og restaureringsfyld tæller ikke som et oprindeligt fragment.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Randbølstenen** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Indskriften er et minde over Thorgunn, rejst af Tuve Bryde. [Stenen på Randbøl Hede](https://www.vikingeskibsmuseet.dk/fagligt/e-laering/viden-om-vikingetiden/vikingetidens-geografi/runesten-og-billedsten/stenen-paa-randboel-hede)
3. Udfør kun denne observation: identificere de oprindelige fragmenter via synlige fuger og kontrollere tallet mod stedets formidling; udelad betonfundament, nyere udfyldningsmateriale, løse sten og skiltestolper.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 10 skrives i decimalform; læs tiercifret `1` først og enercifret `0` bagefter. Indtast `10` uden mellemrum eller bindestreg.
5. Observation og regel giver facit **`10`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Randbølstenen](https://trap.lex.dk/Randb%C3%B8lstenen)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de ti synlige stenfragmenter samlet på betonfundamentet ved Randbølstenen; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: identificere de oprindelige fragmenter via synlige fuger og kontrollere tallet mod stedets formidling. Ignorér betonfundament, nyere udfyldningsmateriale, løse sten og skiltestolper.
3. **Hint 3 — “Næsten løsningen” — 5 %:** De oprindelige dele giver et tocifret, rundt tal.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste ti brudstykker på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En runesten sprængt og senere samlet bliver håndgribelig, fordi I selv fandt de ti synlige stenfragmenter samlet på betonfundamentet.
- `historyFact`: Stenen blev sprængt i 1874 og samlet af ti fragmenter i 1984. [Randbølstenen](https://trap.lex.dk/Randb%C3%B8lstenen)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Randbølstenen`
- `postalCode`: `7183`
- `address`: `Randbøl Hede ved den gamle Hærvej; præcist offentligt ankomstpunkt skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Randbølstenen](https://trap.lex.dk/Randb%C3%B8lstenen)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — kilderne placerer stenen ved den gamle Hærvej, men dokumenterer ikke et sikkert, trinløst observationspunkt. [Randbølstenen](https://trap.lex.dk/Randb%C3%B8lstenen)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`cyclePath`]
- **Foreløbige sikkerhedsnoter:** placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** natursti, sand/grus og mulig vegetation
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** det etablerede stiforløb ved højen; der må ikke skabes en genvej over hedevegetation.

**Kandidatspecifik feltcheckliste**

- Find lovlig, skiltet ankomst og registrér GPS.
- Bekræft at præcis ti fragmenter kan erkendes uden berøring.
- Kontrollér underlag, naturbeskyttelse, mobildækning og sæsonvegetation.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Randb%C3%B8lstenen
- Motiv: et oversigts- eller detaljefoto af de ti synlige stenfragmenter samlet på betonfundamentet; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://lex.dk/Randb%C3%B8lstenen
- Motiv: et oversigts- eller detaljefoto af de ti synlige stenfragmenter samlet på betonfundamentet; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Randbølstenen
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Randb%C3%B8lstenen
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: placering, sprængning, ti fragmenter og gensamling

**Kilde 2**
- `title`: Randbølstenen
- `publisher`: Lex
- `url`: https://lex.dk/Randb%C3%B8lstenen
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: datering og runeindskrift

**Kilde 3**
- `title`: Stenen på Randbøl Hede
- `publisher`: Vikingeskibsmuseet
- `url`: https://www.vikingeskibsmuseet.dk/fagligt/e-laering/viden-om-vikingetiden/vikingetidens-geografi/runesten-og-billedsten/stenen-paa-randboel-hede
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: indskriftens personer og fortolkning


### 05 — Erhvervsskulpturerne på Rådhustorvet

#### Identitet og prioritering

- **rangnummer:** `05`
- **samlet score:** **93/100** — Central, trinløs og konkret flerobjekt-opgave med præcist arkivfacit; events og løse genstande kan skabe støj.
- **stedets officielle eller mest præcise navn:** Erhvervsskulpturerne på Rådhustorvet
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Rådhustorvet 1, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Fire erhverv foran rådhuset
- **kort titel:** Fire symboler
- **spillerrettet beskrivelse:** To stenfamilier gemmer på fire spor efter det Vejle, der arbejdede. Find redskaberne, ikke personerne.
- **tags:** `kunst`, `arbejdsliv`, `rådhus`, `midtby`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 03 Sct. Nicolai, 07 Sønderbro, 12 Den Smidtske Gård og 24 Midgårdsbrønden

#### Dokumenteret historie

**Centrale fakta**

- Skulpturerne blev udført i 1944 og opstillet ved rådhuset i 1955. [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)
- De to grupper rummer fire erhvervssymboler: vægt, sav, neg og tandhjul. [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)
- Det nuværende rådhus blev opført i 1879 og er Vejles fjerde rådhus. [Vejle Rådhus](https://historiskatlas.dk/Vejle_R%C3%A5dhus_%282394%29)

- **Hvorfor interessant for en familie:** Børn kan matche konkrete redskaber med fire gamle erhvervsområder.
- **Sikkert dokumenteret:** Årstal, kunstnerisk placering og de fire symbolers betydning er arkivdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvordan børn spontant grupperer ‘redskab’ og ‘symbol’ skal testes; kunstnerens intention ud over kildens beskrivelse tolkes ikke.
- **Kildekritisk vurdering:** Historisk Atlas er lokal arkivkilde; rådhuskilden bekræfter konteksten, men hovedfacit hviler på én genstandsspecifik registrering.

#### Stedet som spil

- **Konkret observerbar invariant:** de fire forskellige erhvervssymboler i de to skulpturgrupper.
- **Hvorfor permanent/helårsrobust:** Skulpturerne og deres indhuggede/udformede symboler er faste byrumselementer.
- **Spilleren skal konkret:** gå om begge grupper og identificere vægt, sav, neg og tandhjul.
- **Spilleren skal eksplicit ignorere:** personfigurer, rådhusets ornamenter, cykler, skilte og torveinventar.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de fire forskellige erhvervssymboler i de to skulpturgrupper; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Et neg kan blive opfattet som mange strå, og en sav som mere end ét værktøj; spørgsmålet skal solve-testes.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Undersøg begge skulpturgrupper. Hvor mange forskellige redskaber eller symboler viser handel, håndværk, landbrug og industri tilsammen?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `4`
- **Accepterede svarformer, facit først:** `4`, `fire`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Du har muligvis kun undersøgt én skulpturgruppe – der er to.
- `5` → Tæl symboltyper, ikke hver tand eller hvert strå.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Erhvervsskulpturerne på Rådhustorvet** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: De to grupper rummer fire erhvervssymboler: vægt, sav, neg og tandhjul. [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)
3. Udfør kun denne observation: gå om begge grupper og identificere vægt, sav, neg og tandhjul; udelad personfigurer, rådhusets ornamenter, cykler, skilte og torveinventar.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`4`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de fire forskellige erhvervssymboler i de to skulpturgrupper ved Erhvervsskulpturerne på Rådhustorvet; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå om begge grupper og identificere vægt, sav, neg og tandhjul. Ignorér personfigurer, rådhusets ornamenter, cykler, skilte og torveinventar.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Hver af de fire klassiske erhvervsgrene har ét symbol.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fire symboler på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Efterkrigstidens billeder på handel og arbejde bliver håndgribelig, fordi I selv fandt de fire forskellige erhvervssymboler i de to skulpturgrupper.
- `historyFact`: Vægten står for handel, saven for håndværk, neget for landbrug og tandhjulet for industri. [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Erhvervsskulpturerne på Rådhustorvet`
- `postalCode`: `7100`
- `address`: `Rådhustorvet 1, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — værkerne står på det offentlige rådhustorv. [Skulpturerne på rådhustorvet i Vejle](https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** jævn torvebelægning med lokale kanter
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** torvets frie gangareal rundt om begge grupper, uden at træde ud i kørespor.

**Kandidatspecifik feltcheckliste**

- Bekræft at alle fire symboler er synlige og intakte.
- Kortlæg torvedage, cykelstrøm og GPS-afvigelse mellem bygninger.
- Solve-test definitionen ‘forskellige symboler’.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29
- Motiv: et oversigts- eller detaljefoto af de fire forskellige erhvervssymboler i de to skulpturgrupper; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_R%C3%A5dhus_%282394%29
- Motiv: et oversigts- eller detaljefoto af de fire forskellige erhvervssymboler i de to skulpturgrupper; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Skulpturerne på rådhustorvet i Vejle
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Skulpturerne_p%C3%A5_r%C3%A5dhustorvet_i_Vejle_%282388%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: kunstværkernes datering og de fire symboler

**Kilde 2**
- `title`: Vejle Rådhus
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_R%C3%A5dhus_%282394%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: rådhusets identitet, adresse og byhistoriske ramme


### 06 — Den lille Jellingsten

#### Identitet og prioritering

- **rangnummer:** `06`
- **samlet score:** **92/100** — Visuelt enkelt, historisk stærkt og kildefast; kræver en god definition af ‘hovedparten’ og afgrænsning fra den store sten.
- **stedets officielle eller mest præcise navn:** Den lille Jellingsten
- **postnummer:** `7300`
- **adresse/stedbeskrivelse:** Monumentområdet ved Thyrasvej 1, 7300 Jelling
- **område/by:** Jelling
- **foreslået opgavetitel:** Runer der står op
- **kort titel:** Lodrette runebånd
- **spillerrettet beskrivelse:** På den mindre kongesten bevæger runerne sig anderledes end moderne tekst. Se på retningen – du behøver ikke kunne læse runer.
- **tags:** `runer`, `vikingetid`, `Danmark`, `UNESCO`
- **klynge/rute:** Jelling-monumenterne
- **nærliggende kandidater:** 01 store Jellingsten, 09 palisaden, 13 skibssætningen og 19 højene

#### Dokumenteret historie

**Centrale fakta**

- Den lille Jellingsten er rejst af kong Gorm til minde om hans hustru Thyra. [Jellingstenen 1](https://trap.lex.dk/Jellingstenen_1)
- Indskriften står i lodrette runebånd og rummer den tidligste kendte danske brug af navnet Danmark. [Jellingstenen 1](https://trap.lex.dk/Jellingstenen_1)
- Den lille og den store sten er del af samme beskyttede Jelling-monumentområde. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)

- **Hvorfor interessant for en familie:** Opgaven gør et ellers svært runesprog til en umiddelbar visuel sammenligning med en bogside.
- **Sikkert dokumenteret:** Gorm, Thyra, Danmark-navnet og runebåndenes retning er dokumenteret af Trap.
- **Usikkert, omstridt, sagn eller fortolkning:** Den præcise datering diskuteres fagligt; den er ikke nødvendig for facit.
- **Kildekritisk vurdering:** Trap er genstandsspecifik og fagredigeret; Slots- og Kulturstyrelsen bekræfter helheden og status.

#### Stedet som spil

- **Konkret observerbar invariant:** runebåndenes lodrette læseretning på den lille sten.
- **Hvorfor permanent/helårsrobust:** Runerne er hugget i den oprindelige sten.
- **Spilleren skal konkret:** finde den lille sten og følge retningen på dens runer med øjnene.
- **Spilleren skal eksplicit ignorere:** teksten på formidlingsskilte, fuger i montren og runerne på den store sten.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop runebåndenes lodrette læseretning på den lille sten; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Perspektiv og stenens sideflader kan få enkelte tegn til at virke skrå; svarmulighederne skal understøttes af et klart observationspunkt.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvordan løber hovedparten af runebåndene på den lille Jellingsten?”
- **Svarmuligheder ved `singleChoice`:** `Lodret` **(korrekt)**; `Vandret`; `I en spiral`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Lodret`
- **Accepterede svarformer, facit først:** `Lodret`, `lodret`, `vertikalt`, `vertikal`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Vandret` → Det er læseretningen på moderne tekst; se igen på runebåndenes lange retning.
- `I en spiral` → Følg et helt bånd fra ende til ende – det kredser ikke rundt.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Den lille Jellingsten** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Indskriften står i lodrette runebånd og rummer den tidligste kendte danske brug af navnet Danmark. [Jellingstenen 1](https://trap.lex.dk/Jellingstenen_1)
3. Udfør kun denne observation: finde den lille sten og følge retningen på dens runer med øjnene; udelad teksten på formidlingsskilte, fuger i montren og runerne på den store sten.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Lodret`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Jellingstenen 1](https://trap.lex.dk/Jellingstenen_1)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find runebåndenes lodrette læseretning på den lille sten ved Den lille Jellingsten; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde den lille sten og følge retningen på dens runer med øjnene. Ignorér teksten på formidlingsskilte, fuger i montren og runerne på den store sten.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Runebåndene går overvejende fra top mod bund/bund mod top, ikke hen over en linje.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste lodrette runebånd på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Danmarks ældre navngivning og Gorms minde bliver håndgribelig, fordi I selv fandt runebåndenes lodrette læseretning på den lille sten.
- `historyFact`: Indskriften rummer den ældste kendte danske forekomst af navnet Danmark. [Jellingstenen 1](https://trap.lex.dk/Jellingstenen_1)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Den lille Jellingsten`
- `postalCode`: `7300`
- `address`: `Monumentområdet ved Thyrasvej 1, 7300 Jelling`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Jellingstenen 1](https://trap.lex.dk/Jellingstenen_1)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentlig monumentformidling; præcis døgnadgang ved montren registreres i felt. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fast belægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den plane belægning ved den lille stens montre.

**Kandidatspecifik feltcheckliste**

- Bekræft hvilken side og afstand der viser retningen bedst.
- Test at spillere sikkert skelner lille fra stor sten.
- Kontrollér refleksioner, trængsel og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Jellingstenen_1
- Motiv: et oversigts- eller detaljefoto af runebåndenes lodrette læseretning på den lille sten; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- Motiv: et oversigts- eller detaljefoto af runebåndenes lodrette læseretning på den lille sten; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Slots- og Kulturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Slots- og Kulturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Jellingstenen 1
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Jellingstenen_1
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: bygherre, Thyra, Danmark-navnet og lodrette runebånd

**Kilde 2**
- `title`: Jelling-monumenterne
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: placering og monumentkontekst


### 07 — Sønderbro

#### Identitet og prioritering

- **rangnummer:** `07`
- **samlet score:** **91/100** — Kompakt byrumsspor med stærk fortælling og flere arkivkilder; trafikken og den præcise synslinje er afgørende.
- **stedets officielle eller mest præcise navn:** Sønderbro
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Søndergade/Sønderbrogade over Vejle Å, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Kronen på broens fødselsattest
- **kort titel:** Kronen
- **spillerrettet beskrivelse:** Broen bærer stadig et kongeligt mærke fra den gamle byport mod syd. Find symbolet uden at gå ud i trafikken.
- **tags:** `bro`, `1864`, `konge`, `midtby`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 03 Sct. Nicolai, 05 Rådhustorvet og 12 Den Smidtske Gård

#### Dokumenteret historie

**Centrale fakta**

- Sønderbro blev anlagt som stenbro i 1804 og renoveret i 2009. [Vejle Sønderbro](https://historiskatlas.dk/Vejle_S%C3%B8nderbro_%286511%29)
- Den ældre brokonstruktion har tre hvælvede gennemløb over Vejle Å. [Bro, Vejle](https://trap.lex.dk/Bro%2C_Vejle)
- Området ved Sønderbro var kampsted under slaget ved Vejle i 1864. [Kampen på Vejle Sønderbro 1864](https://historiskatlas.dk/Kampen_p%C3%A5_Vejle_S%C3%B8nderbro_1864_%286530%29)
- Den officielle byvandring peger på broens historiske inskription og kongekronen som synligt byspor. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Et lille symbol forbinder en daglig færdselsåre med kongemagt og krigshistorie.
- **Sikkert dokumenteret:** Stenbroens anlæg, senere renovering, tre gennemløb og 1864-kamp er kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Den nu synlige indskrifts nøjagtige bevaringstilstand er ikke online-dokumenteret i tilstrækkelig detalje.
- **Kildekritisk vurdering:** Tre arkiv-/registerkilder dokumenterer historien; den turistiske byvandring er eneste direkte onlinekilde til kronedetaljen, så facit skal fysisk verificeres.

#### Stedet som spil

- **Konkret observerbar invariant:** kronesymbolet ved den historiske facadeindskrift på broen.
- **Hvorfor permanent/helårsrobust:** Hvis den er original/fastgjort som beskrevet, er kronen en integreret brodetalje; renoveringer kan dog ændre synlighed.
- **Spilleren skal konkret:** finde den historiske indskrift fra fortovet og identificere symbolet.
- **Spilleren skal eksplicit ignorere:** butiksskilte, moderne vejskilte, kommunelogoer og flag.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop kronesymbolet ved den historiske facadeindskrift på broen; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Symbolet kan være synligt fra kun én side, og spillere kan forveksle andre kroner i gadebilledet.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilket kongeligt symbol står sammen med den historiske indskrift på Sønderbro?”
- **Svarmuligheder ved `singleChoice`:** `En krone` **(korrekt)**; `Et anker`; `En løve`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `En krone`
- **Accepterede svarformer, facit først:** `En krone`, `krone`, `kronen`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Et anker` → Det passer til havnen, men kig på selve den historiske broindskrift.
- `En løve` → Se over/ved bogstaverne efter et hovedbeklædningssymbol.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Sønderbro** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Den ældre brokonstruktion har tre hvælvede gennemløb over Vejle Å. [Bro, Vejle](https://trap.lex.dk/Bro%2C_Vejle)
3. Udfør kun denne observation: finde den historiske indskrift fra fortovet og identificere symbolet; udelad butiksskilte, moderne vejskilte, kommunelogoer og flag.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`En krone`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejle Sønderbro](https://historiskatlas.dk/Vejle_S%C3%B8nderbro_%286511%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find kronesymbolet ved den historiske facadeindskrift på broen ved Sønderbro; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde den historiske indskrift fra fortovet og identificere symbolet. Ignorér butiksskilte, moderne vejskilte, kommunelogoer og flag.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Symbolet bæres normalt på en konges hoved.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste kronen på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Vejles gamle sydlige stenbro og kampen i 1864 bliver håndgribelig, fordi I selv fandt kronesymbolet ved den historiske facadeindskrift på broen.
- `historyFact`: Brostedet blev en del af kampene ved Vejle i 1864. [Kampen på Vejle Sønderbro 1864](https://historiskatlas.dk/Kampen_p%C3%A5_Vejle_S%C3%B8nderbro_1864_%286530%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Sønderbro`
- `postalCode`: `7100`
- `address`: `Søndergade/Sønderbrogade over Vejle Å, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejle Sønderbro](https://historiskatlas.dk/Vejle_S%C3%B8nderbro_%286511%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — observation fra offentligt fortov; den sikre side og eventuelle arbejder skal verificeres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `water`, `cyclePath`, `crowding`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; fastlæg afstand/værn ved vand; placér ophold uden for cykelflow; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** byfortov med kantsten
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `partial`
- **Tilgængelighed — barnevogn:** `partial`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** det brede fortov på den side, hvor indskriften kan ses uden at læne sig over rækværk eller krydse kørebanen.

**Kandidatspecifik feltcheckliste**

- Fastslå præcis bro-side, højde og læseretning.
- Bekræft kronen og tag et internt facitfoto.
- Mål fortovsplads, trafik/cykler, GPS og mulighed for kørestol.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_S%C3%B8nderbro_%286511%29
- Motiv: et oversigts- eller detaljefoto af kronesymbolet ved den historiske facadeindskrift på broen; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Bro%2C_Vejle
- Motiv: et oversigts- eller detaljefoto af kronesymbolet ved den historiske facadeindskrift på broen; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejle Sønderbro
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_S%C3%B8nderbro_%286511%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: broens datering og ombygning

**Kilde 2**
- `title`: Bro, Vejle
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Bro%2C_Vejle
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: konstruktion med tre gennemløb

**Kilde 3**
- `title`: Kampen på Vejle Sønderbro 1864
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Kampen_p%C3%A5_Vejle_S%C3%B8nderbro_1864_%286530%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: kampen i 1864

**Kilde 4**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: den synlige indskrift og krone


### 08 — Kanonkuglehuset

#### Identitet og prioritering

- **rangnummer:** `08`
- **samlet score:** **90/100** — Et næsten perfekt én-genstand/én-historie-spor med klart facit; fortov, facadeændringer og privat bolig kræver hensyn.
- **stedets officielle eller mest præcise navn:** Kanonkuglehuset
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Nørrebrogade 45, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Kuglen fra 1864
- **kort titel:** Én kugle
- **spillerrettet beskrivelse:** En lille mørk kugle i muren er et fysisk ekko af 1864. Find den fra fortovet og lad husets beboere være i fred.
- **tags:** `1864`, `krig`, `facade`, `midtby`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 03 Sct. Nicolai, 07 Sønderbro, 31 brandtavlen og 33 runefliserne

#### Dokumenteret historie

**Centrale fakta**

- Huset i Nørrebrogade 45 blev opført i 1852. [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
- Under kampene 8. marts 1864 fløj en kanonkugle gennem en stue tæt ved en vugge. [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
- Kuglen blev senere indmuret i facaden mellem to vinduer som erindringsspor. [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
- Den officielle historiske byvandring fremhæver Kanonkuglehuset som stop i den gamle bydel. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Et enkelt autentisk spor gør en dramatisk lokal hændelse konkret uden at romantisere krig.
- **Sikkert dokumenteret:** Husets år, datoen 8. marts 1864 og kuglens senere placering er arkivdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Anekdotens detaljer om vuggen gengives af arkivet; opgaven afhænger kun af den synlige kugle.
- **Kildekritisk vurdering:** Den genstandsspecifikke arkivside er central og stærk; byvandringen er en sekundær rutekontrol, ikke en uafhængig primærberetning.

#### Stedet som spil

- **Konkret observerbar invariant:** den ene indmurede kanonkugle mellem facadevinduerne.
- **Hvorfor permanent/helårsrobust:** Kuglen er indmuret i murværket og forventes stabil, men facadeistandsættelse kan skjule den.
- **Spilleren skal konkret:** scanne facaden mellem vinduerne fra offentligt fortov.
- **Spilleren skal eksplicit ignorere:** lamper, ventilationshuller, dørgreb, nummerplade og andre runde beslag.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop den ene indmurede kanonkugle mellem facadevinduerne; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Mørke beslag kan ligne kugler; opgaven skal pege tydeligt på feltet mellem vinduerne uden at afsløre facit.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange kanonkugler er indmuret i facaden mellem vinduerne?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 1 mappes til decimaltallet `1` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `1`
- **Accepterede svarformer, facit først:** `1`, `én`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `0` → Kuglen er lille; se mellem facadevinduerne, ikke ved døren.
- `2` → Tæl kun den historiske indmurede kugle, ikke runde beslag.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Kanonkuglehuset** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Under kampene 8. marts 1864 fløj en kanonkugle gennem en stue tæt ved en vugge. [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
3. Udfør kun denne observation: scanne facaden mellem vinduerne fra offentligt fortov; udelad lamper, ventilationshuller, dørgreb, nummerplade og andre runde beslag.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 1 mappes til decimaltallet `1` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`1`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find den ene indmurede kanonkugle mellem facadevinduerne ved Kanonkuglehuset; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: scanne facaden mellem vinduerne fra offentligt fortov. Ignorér lamper, ventilationshuller, dørgreb, nummerplade og andre runde beslag.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Det er et enkelt projektilspor, ikke en samling.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste én kugle på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et projektilspor fra slaget ved Vejle bliver håndgribelig, fordi I selv fandt den ene indmurede kanonkugle mellem facadevinduerne.
- `historyFact`: Arkivets fortælling daterer kuglens vej gennem huset til 8. marts 1864. [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Kanonkuglehuset`
- `postalCode`: `7100`
- `address`: `Nørrebrogade 45, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja til observation fra offentligt fortov; selve huset er privat og må ikke berøres eller betrædes. [Kanonkuglehuset Nørrebrogade 45](https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** fortov med kantsten
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** fortovet på facadesiden med fri passage; ingen ophold i indkørsel eller ved vinduer.

**Kandidatspecifik feltcheckliste**

- Bekræft at kuglen er synlig fra lovligt fortov og ikke dækket af planter/stillads.
- Test for forveksling med beslag.
- Kontrollér husnummer, beboerhensyn, trafik og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29
- Motiv: et oversigts- eller detaljefoto af den ene indmurede kanonkugle mellem facadevinduerne; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af den ene indmurede kanonkugle mellem facadevinduerne; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Kanonkuglehuset Nørrebrogade 45
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Kanonkuglehuset_N%C3%B8rrebrogade_45_%286860%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: adresse, husets alder, hændelsen og kuglens placering

**Kilde 2**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: rutekontekst og nutidig besøgsrelevans


### 09 — Jellingpalisaden

#### Identitet og prioritering

- **rangnummer:** `09`
- **samlet score:** **89/100** — Stærk kropslig landskabsopgave, men kræver validering af hvor formen kan erkendes uden lang eller farlig rute.
- **stedets officielle eller mest præcise navn:** Jellingpalisaden
- **postnummer:** `7300`
- **adresse/stedbeskrivelse:** Monumentområdet omkring højene ved Thyrasvej 1, 7300 Jelling
- **område/by:** Jelling
- **foreslået opgavetitel:** Kongens kæmpe firkant
- **kort titel:** Firkantet
- **spillerrettet beskrivelse:** Et hegn på størrelse med et helt kvarter tegnede kongens rum. Brug de hvide markeringer til at genkende formen.
- **tags:** `vikinger`, `landskab`, `arkæologi`, `UNESCO`
- **klynge/rute:** Jelling-monumenterne
- **nærliggende kandidater:** 01 og 06 runestenene, 13 skibssætningen og 19 højene

#### Dokumenteret historie

**Centrale fakta**

- Palisaden omkring Jelling-anlægget målte omtrent 360 gange 360 meter. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Forløbet var firsidet/kvadratisk og omsluttede blandt andet høje og skibssætning. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Palisaden indgår i forståelsen af det samlede kongelige monumentlandskab. [Jelling Mounds, Runic Stones and Church](https://whc.unesco.org/en/list/697/)

- **Hvorfor interessant for en familie:** Skalaen mærkes med kroppen, og en simpel geometrisk form gør arkæologi forståelig.
- **Sikkert dokumenteret:** Dimensioner og den kvadratiske plan er dokumenteret af Slots- og Kulturstyrelsen.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvor meget af markeringen der er synlig på én gang, og om alle fire sider er praktisk tilgængelige, er feltspørgsmål.
- **Kildekritisk vurdering:** Myndighedskilden er autoritativ; UNESCO bekræfter betydningen, men facit bør ikke baseres på kortet alene.

#### Stedet som spil

- **Konkret observerbar invariant:** det rekonstruerede palisadeforløbs overordnede kvadratiske form.
- **Hvorfor permanent/helårsrobust:** Palisadeforløbet er markeret som permanent landskabsformidling; enkelte elementer kan dog vedligeholdes.
- **Spilleren skal konkret:** følge mindst to hjørner og sammenholde de rette sider i landskabet.
- **Spilleren skal eksplicit ignorere:** runde gravhøje, stier, kirkegårdsmur og tilfældige hegn.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det rekonstruerede palisadeforløbs overordnede kvadratiske form; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Fra jordniveau kan en stor kvadrat opleves som separate linjer; opgaven risikerer at kunne besvares fra forhåndsviden.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken grundform danner de markerede palisadesider omkring monumentområdet?”
- **Svarmuligheder ved `singleChoice`:** `Et kvadrat` **(korrekt)**; `En cirkel`; `En trekant`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Et kvadrat`
- **Accepterede svarformer, facit først:** `Et kvadrat`, `kvadrat`, `firkant`, `firkantet`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `En cirkel` → Højene er runde, men følg selve palisademarkeringen.
- `En trekant` → Find endnu et hjørne; anlægget har fire sider.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Jellingpalisaden** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Forløbet var firsidet/kvadratisk og omsluttede blandt andet høje og skibssætning. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
3. Udfør kun denne observation: følge mindst to hjørner og sammenholde de rette sider i landskabet; udelad runde gravhøje, stier, kirkegårdsmur og tilfældige hegn.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Et kvadrat`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det rekonstruerede palisadeforløbs overordnede kvadratiske form ved Jellingpalisaden; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: følge mindst to hjørner og sammenholde de rette sider i landskabet. Ignorér runde gravhøje, stier, kirkegårdsmur og tilfældige hegn.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Forløbet har fire lige lange hovedsider og rette hjørner.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste firkantet på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Den monumentale palisade omkring Jelling bliver håndgribelig, fordi I selv fandt det rekonstruerede palisadeforløbs overordnede kvadratiske form.
- `historyFact`: Palisaden målte omtrent 360 × 360 meter. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Jellingpalisaden`
- `postalCode`: `7300`
- `address`: `Monumentområdet omkring højene ved Thyrasvej 1, 7300 Jelling`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — monumentområdet formidles som offentligt verdensarvssted; den konkrete rute skal feltkontrolleres. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`cyclePath`, `crowding`]
- **Foreløbige sikkerhedsnoter:** placér ophold uden for cykelflow; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** blanding af fast sti og græs
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `partial`
- **Tilgængelighed — barnevogn:** `partial`
- **Tilgængelighed — afstand fra adgang:** forløbet er historisk ca. 360 m på hver side; spilleruten er ikke fastlagt
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et kort, etableret stiforløb med to synlige hjørner; ingen krydsning af vej eller afspærret areal.

**Kandidatspecifik feltcheckliste**

- Find det korteste lovlige forløb, hvor formen faktisk kan udledes.
- Test opgaven uden oversigtskort.
- Registrér GPS-aktivering, underlag, vejkryds og hvilemuligheder.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- Motiv: et oversigts- eller detaljefoto af det rekonstruerede palisadeforløbs overordnede kvadratiske form; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Slots- og Kulturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Slots- og Kulturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://whc.unesco.org/en/list/697/
- Motiv: et oversigts- eller detaljefoto af det rekonstruerede palisadeforløbs overordnede kvadratiske form; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis UNESCO World Heritage Centre eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `UNESCO World Heritage Centre / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Jelling-monumenterne
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: mål, form og rekonstruktion i monumentområdet

**Kilde 2**
- `title`: Jelling Mounds, Runic Stones and Church
- `publisher`: UNESCO World Heritage Centre
- `url`: https://whc.unesco.org/en/list/697/
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: verdensarvskontekst og anlæggets betydning


### 10 — Tørskind-mand

#### Identitet og prioritering

- **rangnummer:** `10`
- **samlet score:** **88/100** — Humoristisk, børnevenligt og kildeklart facit; det stejle, ujævne landskab kræver præcis sikker startzone.
- **stedets officielle eller mest præcise navn:** Tørskind-mand
- **postnummer:** `6040`
- **adresse/stedbeskrivelse:** Tørskindvej 98A, 6040 Egtved
- **område/by:** Tørskind
- **foreslået opgavetitel:** Manden med tre ben
- **kort titel:** Tre ben
- **spillerrettet beskrivelse:** I grusgraven står en ‘mand’, som ikke følger menneskets anatomi. Tæl kun de gamle træstykker, der bærer kroppen.
- **tags:** `kunst`, `landskab`, `Robert Jacobsen`, `tælleopgave`
- **klynge/rute:** Tørskind Landskabsskulptur
- **nærliggende kandidater:** 26 Lille Tycho Brahe; øvrige delværker bruges kun som orientering

#### Dokumenteret historie

**Centrale fakta**

- Tørskind-mand består af en rektangulær jernkrop på tre gamle stykker egetræ, der fungerer som ben. [Tørskind-mand](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/toerskind-mand/)
- Landskabsskulpturen rummer ni delværker af Robert Jacobsen og Jean Clareboudt. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)
- Anlægget er gratis og døgnåbent, men ligger i ujævnt terræn og er ikke kørestolsegnet. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)

- **Hvorfor interessant for en familie:** Den menneskelignende figur inviterer til bevægelse, humor og materialsammenligning.
- **Sikkert dokumenteret:** Materialer, tre ben, kunstner og anlæggets ni værker er dokumenteret af Vejlemuseerne.
- **Usikkert, omstridt, sagn eller fortolkning:** Træets vedligeholdelsestilstand og den mest sikre synslinje kan kun afgøres i felt.
- **Kildekritisk vurdering:** Museets objektside er en stærk primær formidlingskilde; den generelle side er driftssource, men ikke uafhængig.

#### Stedet som spil

- **Konkret observerbar invariant:** skulpturens tre ben af gamle egetræsstykker.
- **Hvorfor permanent/helårsrobust:** Benene er bærende hoveddele i et permanent skulpturværk.
- **Spilleren skal konkret:** finde den navngivne skulptur og tælle de grove træstøtter under jernkroppen.
- **Spilleren skal eksplicit ignorere:** jernkrop, træer i baggrunden, hegn og andre skulpturer.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop skulpturens tre ben af gamle egetræsstykker; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Et træstykke kan fra én vinkel skjule et andet; ‘ben’ skal ikke omfatte jernfremspring.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange træben holder Tørskind-mand oppe?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Skift vinkel – et af træbenene kan gemme sig bag et andet.
- `4` → Tæl kun træstykkerne, der bærer kroppen.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Tørskind-mand** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Landskabsskulpturen rummer ni delværker af Robert Jacobsen og Jean Clareboudt. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)
3. Udfør kun denne observation: finde den navngivne skulptur og tælle de grove træstøtter under jernkroppen; udelad jernkrop, træer i baggrunden, hegn og andre skulpturer.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Tørskind-mand](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/toerskind-mand/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find skulpturens tre ben af gamle egetræsstykker ved Tørskind-mand; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde den navngivne skulptur og tælle de grove træstøtter under jernkroppen. Ignorér jernkrop, træer i baggrunden, hegn og andre skulpturer.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Som et stativ bliver figuren stabil på tre støttepunkter.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre ben på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Robert Jacobsens landskabsskulptur i grusgraven bliver håndgribelig, fordi I selv fandt skulpturens tre ben af gamle egetræsstykker.
- `historyFact`: Hele anlægget består af ni delværker: fire af Robert Jacobsen og fem af Jean Clareboudt. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Tørskind-mand`
- `postalCode`: `6040`
- `address`: `Tørskindvej 98A, 6040 Egtved`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Tørskind-mand](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/toerskind-mand/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — gratis og døgnåbent; museet advarer samtidig indirekte gennem oplysningen om ikke-kørestolsegnet terræn. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `darkness`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** ujævne grus-, jord- og græsflader med hældning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `no`
- **Tilgængelighed — barnevogn:** `no`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den etablerede sti/plane lomme foran værket, valgt i dagslys; ingen klatring på skråninger eller værk.

**Kandidatspecifik feltcheckliste**

- Vælg en vinkel hvor tre ben ses uden at gå på stejl skrænt.
- Test under vådt føre og med skolebørn.
- Registrér GPS, underlag, dagslysgrænse og skiltning mod berøring.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/toerskind-mand/
- Motiv: et oversigts- eller detaljefoto af skulpturens tre ben af gamle egetræsstykker; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/
- Motiv: et oversigts- eller detaljefoto af skulpturens tre ben af gamle egetræsstykker; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Tørskind-mand
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/toerskind-mand/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: værkets materialer og tre ben

**Kilde 2**
- `title`: Robert Jacobsen–Jean Clareboudt Landskabsskulptur
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: anlæggets helhed, adresse, adgang og terræn

**Kilde 3**
- `title`: Guide til landskabsskulpturen i Tørskind
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: placering blandt de ni delværker

**Sjælden kildeundtagelse:** De tre webposter er fra samme museumsmyndighed; undtagelsen accepteres kun, fordi museet forvalter værket, mens facit fysisk solve-testes.


### 11 — Børkop Vandmølle

#### Identitet og prioritering

- **rangnummer:** `11`
- **samlet score:** **87/100** — Meget tydelige, stedfaste hjul og stærk teknikfortælling; vand, drift og privat restauranttrafik kræver feltkontrol.
- **stedets officielle eller mest præcise navn:** Børkop Vandmølle
- **postnummer:** `7080`
- **adresse/stedbeskrivelse:** Vandmøllevej 4, 7080 Børkop
- **område/by:** Børkop
- **foreslået opgavetitel:** To hjul driver møllen
- **kort titel:** To møllehjul
- **spillerrettet beskrivelse:** Vandet skulle ikke nøjes med ét hjul. Find møllens arbejdsside og tæl kun de store hjul, som vandet kan drive.
- **tags:** `vandmølle`, `teknik`, `kulturarv`, `Børkop`
- **klynge/rute:** Børkop–Brejning
- **nærliggende kandidater:** 29 Ene Øjesten; 18 og 27 ligger i Brejning

#### Dokumenteret historie

**Centrale fakta**

- Der kendes en mølle på stedet fra 1546; den nuværende hovedbygning er fra begyndelsen af 1800-tallet. [Børkop Vandmølle](https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle)
- Møllen har to overfaldshjul og et bevaret, funktionsdygtigt gearværk af en sjælden type. [Børkop Vandmølle](https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle)
- Vejle Kommune markerede genindvielse efter restaurering i 2025. [Indvielse af Børkop Vandmølle og Mølledag](https://www.vejle.dk/da/demokrati-og-udvikling/moeder-og-dialog/indvielse-af-boerkop-vandmoelle-og-moelledag/)
- Vandmøllen ligger på Vandmøllevej 4 og formidles som besøgssted. [Børkop Vandmølle – mølleri & Farbror Svends Samling](https://www.visitvejle.dk/vejle/planlaeg-ferien/boerkop-vandmoelle-moelleri-farbror-svends-samling-gdk608071)

- **Hvorfor interessant for en familie:** Synlige hjul og tandhjul gør energiens vej fra vand til mel håndgribelig.
- **Sikkert dokumenteret:** Møllehistorie, to overfaldshjul og nyere restaurering er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Om hjulene løber på besøgsdagen er variabelt og indgår ikke i facit; udsynet kan ændres med vandstand og vedligehold.
- **Kildekritisk vurdering:** Lex er faglig hovedkilde; kommunen dokumenterer den aktuelle restaurering, og VisitVejle den praktiske lokation.

#### Stedet som spil

- **Konkret observerbar invariant:** de to store overfaldshjul på møllens yderside.
- **Hvorfor permanent/helårsrobust:** Antallet af store, bygningsintegrerede møllehjul er konstruktivt stabilt.
- **Spilleren skal konkret:** gå til den lovlige udsigtskant og tælle de store hjul ved vandløbet.
- **Spilleren skal eksplicit ignorere:** små tandhjul inde, dekorative hjul, restaurantinventar og runde sluser.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de to store overfaldshjul på møllens yderside; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Fra nogle vinkler kan hjulene overlappe; drift eller afspærring kan skjule det ene.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange store vandhjul sidder ved Børkop Vandmølle?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `2`
- **Accepterede svarformer, facit først:** `2`, `to`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `1` → Se længere langs møllesiden – hjulene kan ligge efter hinanden.
- `3` → Tæl kun de store ydre vandhjul, ikke mindre mekanik.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Børkop Vandmølle** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Møllen har to overfaldshjul og et bevaret, funktionsdygtigt gearværk af en sjælden type. [Børkop Vandmølle](https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle)
3. Udfør kun denne observation: gå til den lovlige udsigtskant og tælle de store hjul ved vandløbet; udelad små tandhjul inde, dekorative hjul, restaurantinventar og runde sluser.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`2`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Børkop Vandmølle](https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de to store overfaldshjul på møllens yderside ved Børkop Vandmølle; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå til den lovlige udsigtskant og tælle de store hjul ved vandløbet. Ignorér små tandhjul inde, dekorative hjul, restaurantinventar og runde sluser.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Møllen er usædvanlig, fordi den arbejder med et par store hjul.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste to møllehjul på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En bevaret vandmølle med usædvanligt maskineri bliver håndgribelig, fordi I selv fandt de to store overfaldshjul på møllens yderside.
- `historyFact`: Kilden beskriver to overfaldshjul og et bevaret funktionsdygtigt gearværk. [Børkop Vandmølle](https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Børkop Vandmølle`
- `postalCode`: `7080`
- `address`: `Vandmøllevej 4, 7080 Børkop`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Børkop Vandmølle](https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — stedet er besøgsformidlet, men udendørs observationsareal, åbningstid og skel mellem offentlig sti/virksomhed skal afklares. [Børkop Vandmølle – mølleri & Farbror Svends Samling](https://www.visitvejle.dk/vejle/planlaeg-ferien/boerkop-vandmoelle-moelleri-farbror-svends-samling-gdk608071)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `privateProperty`, `crowding`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; afklar skel og ejer-/driftshensyn; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** grus/belægning ved historisk mølleanlæg; vandkant
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et eksisterende besøgsareal bag værn med begge hjul i synsfelt; aldrig slusekant eller driftsområde.

**Kandidatspecifik feltcheckliste**

- Aftal lovligt observationspunkt og tider med stedets drift.
- Kontrollér værn, vandkant, glathed og udsyn til begge hjul.
- Test GPS og tælling når hjul står stille og kører.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle
- Motiv: et oversigts- eller detaljefoto af de to store overfaldshjul på møllens yderside; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejle.dk/da/demokrati-og-udvikling/moeder-og-dialog/indvielse-af-boerkop-vandmoelle-og-moelledag/
- Motiv: et oversigts- eller detaljefoto af de to store overfaldshjul på møllens yderside; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Kommune eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Kommune / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Børkop Vandmølle
- `publisher`: Lex
- `url`: https://lex.dk/B%C3%B8rkop_Vandm%C3%B8lle
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: historie, bygning, hjultype og antal

**Kilde 2**
- `title`: Indvielse af Børkop Vandmølle og Mølledag
- `publisher`: Vejle Kommune
- `url`: https://www.vejle.dk/da/demokrati-og-udvikling/moeder-og-dialog/indvielse-af-boerkop-vandmoelle-og-moelledag/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: nyere restaurering

**Kilde 3**
- `title`: Børkop Vandmølle – mølleri & Farbror Svends Samling
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/boerkop-vandmoelle-moelleri-farbror-svends-samling-gdk608071
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: adresse og besøgssted


### 12 — Den Smidtske Gård

#### Identitet og prioritering

- **rangnummer:** `12`
- **samlet score:** **86/100** — Et præcist firecifret facadefacit på en central fredet gård; portens adgang og andre årstal skal testes.
- **stedets officielle eller mest præcise navn:** Den Smidtske Gård
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Søndergade 14, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Årstallet over porten
- **kort titel:** 1799
- **spillerrettet beskrivelse:** Købmandsgården har skrevet sin alder lige over indgangen. Find det ældste årstal på selve portpartiet.
- **tags:** `købmandsgård`, `arkitektur`, `årstal`, `midtby`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 05 Rådhustorvet, 07 Sønderbro, 31 brandtavlen og 33 runefliserne

#### Dokumenteret historie

**Centrale fakta**

- Den Smidtske Gård er opført i 1799 og er Vejles eneste bevarede købmandsgård. [Den Smidtske Gård](https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489)
- Anlægget viser den tidligere købmandsgårds forbindelse mellem gadehus, gårdrum og bagbygninger. [Den Smidtske Gård](https://historiskatlas.dk/Den_Smidtske_G%C3%A5rd_%282439%29)
- Den officielle byvandring bruger gården som et centralt historisk stop i Søndergade. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Et simpelt årstal åbner den skjulte, lange gård bag gågadens facade.
- **Sikkert dokumenteret:** Byggeår, funktion og unik status i Vejle er belagt af to lokale kilder.
- **Usikkert, omstridt, sagn eller fortolkning:** Det skal kontrolleres, om 1799 står tydeligt og permanent over den offentligt synlige port i 2026.
- **Kildekritisk vurdering:** VisitVejle og Historisk Atlas er lokale, men forskellige redaktionelle kilder; fysisk inskription er endelig facitkontrol.

#### Stedet som spil

- **Konkret observerbar invariant:** det firecifrede byggeår over gårdens port.
- **Hvorfor permanent/helårsrobust:** Et indbygget facadeårstal forventes permanent, men maling eller restaurering kan påvirke læsbarheden.
- **Spilleren skal konkret:** lokalisere portpartiet og læse cifrene fra venstre mod højre.
- **Spilleren skal eksplicit ignorere:** husnummer 14, moderne skilte, udstillingsår og årstal inde i gården.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det firecifrede byggeår over gårdens port; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** ‘Ældste årstal’ kan kræve mere søgning end tiltænkt; spørgsmålet bør i produktion kun sige ‘over porten’.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Læs årstallet over porten til Den Smidtske Gård. Hvilke fire cifre står der?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `4`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Aflæs det trykte/indhuggede tal fra venstre mod højre. Cifrene mappes én-til-én som `1`→`1`, `7`→`7`, `9`→`9`, `9`→`9` og samles uden mellemrum til `1799`. Kodelængden er 4, og eventuelle foranstillede nuller skulle bevares.
- **Kanonisk facit:** `1799`
- **Accepterede svarformer, facit først:** `1799`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `1798` → Kontrollér sidste ciffer; det gentages.
- `1899` → Se på det andet ciffer – gården er fra 1700-tallet.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Den Smidtske Gård** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Anlægget viser den tidligere købmandsgårds forbindelse mellem gadehus, gårdrum og bagbygninger. [Den Smidtske Gård](https://historiskatlas.dk/Den_Smidtske_G%C3%A5rd_%282439%29)
3. Udfør kun denne observation: lokalisere portpartiet og læse cifrene fra venstre mod højre; udelad husnummer 14, moderne skilte, udstillingsår og årstal inde i gården.
4. Anvend den eksplicitte regel: Aflæs det trykte/indhuggede tal fra venstre mod højre. Cifrene mappes én-til-én som `1`→`1`, `7`→`7`, `9`→`9`, `9`→`9` og samles uden mellemrum til `1799`. Kodelængden er 4, og eventuelle foranstillede nuller skulle bevares.
5. Observation og regel giver facit **`1799`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Den Smidtske Gård](https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det firecifrede byggeår over gårdens port ved Den Smidtske Gård; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: lokalisere portpartiet og læse cifrene fra venstre mod højre. Ignorér husnummer 14, moderne skilte, udstillingsår og årstal inde i gården.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Koden begynder med 17, og de sidste to cifre er ens.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste 1799 på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Vejles eneste bevarede købmandsgård bliver håndgribelig, fordi I selv fandt det firecifrede byggeår over gårdens port.
- `historyFact`: Gården fra 1799 er den eneste bevarede købmandsgård i Vejle. [Den Smidtske Gård](https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Den Smidtske Gård`
- `postalCode`: `7100`
- `address`: `Søndergade 14, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Den Smidtske Gård](https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja til facadeobservation fra gågaden; adgang gennem port/gårdrum kan have tider og er ikke nødvendig. [Den Smidtske Gård](https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** gågadebelægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** gågadens frie facadezone, uden at blokere porten.

**Kandidatspecifik feltcheckliste**

- Bekræft cifrene og læsbarhed i forskelligt lys.
- Notér portens drift, cykelperioder og plads til familie.
- Solve-test at husnummer og andre tal ignoreres.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489
- Motiv: et oversigts- eller detaljefoto af det firecifrede byggeår over gårdens port; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Den_Smidtske_G%C3%A5rd_%282439%29
- Motiv: et oversigts- eller detaljefoto af det firecifrede byggeår over gårdens port; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Den Smidtske Gård
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/den-smidtske-gaard-gdk727489
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: byggeår, adresse og status som bevaret købmandsgård

**Kilde 2**
- `title`: Den Smidtske Gård
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Den_Smidtske_G%C3%A5rd_%282439%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: anlæg og lokalhistorie

**Kilde 3**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: rutekontekst


### 13 — Jelling-skibssætningen

#### Identitet og prioritering

- **rangnummer:** `13`
- **samlet score:** **85/100** — Stor fortællekraft og fysisk landskabsaflæsning; formen er vanskelig fra jordniveau og skal have en fair observationsrute.
- **stedets officielle eller mest præcise navn:** Jelling-skibssætningen
- **postnummer:** `7300`
- **adresse/stedbeskrivelse:** Monumentområdet ved Thyrasvej 1, 7300 Jelling
- **område/by:** Jelling
- **foreslået opgavetitel:** Stenskibet under højene
- **kort titel:** Et skib
- **spillerrettet beskrivelse:** Før højene kom til, tegnede sten et enormt fartøj i landskabet. Følg de markerede sider og vælg formen.
- **tags:** `vikinger`, `skibssætning`, `landskab`, `UNESCO`
- **klynge/rute:** Jelling-monumenterne
- **nærliggende kandidater:** 01 og 06 runestenene, 09 palisaden og 19 højene

#### Dokumenteret historie

**Centrale fakta**

- Jellings skibssætning var omtrent 355 meter lang. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Den nordlige høj blev anlagt oven på den ene del af skibssætningen. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Skibssætningen er en del af det samlede monumentanlæg, som viser overgangen mellem hedensk og kristen tid. [Jelling Mounds, Runic Stones and Church](https://whc.unesco.org/en/list/697/)

- **Hvorfor interessant for en familie:** Skibet forbinder kendt hverdagsform med et monument på flere hundrede meter.
- **Sikkert dokumenteret:** Længde, skibsform og forholdet til nordhøjen er myndighedsdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Det oprindelige stenforløb er kun delvist bevaret og formidlet; spørgsmålet skal skelne rekonstruktion fra original.
- **Kildekritisk vurdering:** Slots- og Kulturstyrelsen er hovedkilde; UNESCO understøtter helheden, men ikke en detaljeret solve-rute.

#### Stedet som spil

- **Konkret observerbar invariant:** stenrækkernes langstrakte skibsform med spidse ender.
- **Hvorfor permanent/helårsrobust:** Den formidlede stenlinje er landskabsfast, men græs og vedligehold kan påvirke synligheden.
- **Spilleren skal konkret:** følge begge sider visuelt fra en etableret sti og genkende de spidse ender.
- **Spilleren skal eksplicit ignorere:** gravhøjenes cirkler, palisadens firkant, stier og moderne hegn.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop stenrækkernes langstrakte skibsform med spidse ender; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Palisade og skib overlapper visuelt; børn kan besvare fra skiltet i stedet for observation.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken form tegner de markerede stenrækker omkring og mellem højene?”
- **Svarmuligheder ved `singleChoice`:** `Et skib` **(korrekt)**; `En krone`; `En spiral`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Et skib`
- **Accepterede svarformer, facit først:** `Et skib`, `skib`, `båd`, `et skibsskrog`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `En krone` → Følg stenlinjerne i længderetningen – de samles i enderne.
- `En spiral` → Linjerne snor sig ikke indad; find to lange sider.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Jelling-skibssætningen** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Den nordlige høj blev anlagt oven på den ene del af skibssætningen. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
3. Udfør kun denne observation: følge begge sider visuelt fra en etableret sti og genkende de spidse ender; udelad gravhøjenes cirkler, palisadens firkant, stier og moderne hegn.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Et skib`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find stenrækkernes langstrakte skibsform med spidse ender ved Jelling-skibssætningen; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: følge begge sider visuelt fra en etableret sti og genkende de spidse ender. Ignorér gravhøjenes cirkler, palisadens firkant, stier og moderne hegn.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Formen har to lange sider og stævn/agter i enderne.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste et skib på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Verdens største kendte skibssætning bliver håndgribelig, fordi I selv fandt stenrækkernes langstrakte skibsform med spidse ender.
- `historyFact`: Anlæggets længde var omtrent 355 meter. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Jelling-skibssætningen`
- `postalCode`: `7300`
- `address`: `Monumentområdet ved Thyrasvej 1, 7300 Jelling`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentligt monumentområde; den konkrete observationsrute skal godkendes. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`cyclePath`, `crowding`]
- **Foreløbige sikkerhedsnoter:** placér ophold uden for cykelflow; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fast sti og eventuelt græs
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `partial`
- **Tilgængelighed — barnevogn:** `partial`
- **Tilgængelighed — afstand fra adgang:** historisk længde ca. 355 m; nødvendigt spillerforløb ikke målt
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** en etableret sti med udsyn langs begge markerede stensider.

**Kandidatspecifik feltcheckliste**

- Find hvor formen kan erkendes uden drone/kort.
- Test skelnen fra palisade og høje med tre aldersgrupper.
- Kortlæg underlag, vejkryds, GPS og sæsonvegetation.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- Motiv: et oversigts- eller detaljefoto af stenrækkernes langstrakte skibsform med spidse ender; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Slots- og Kulturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Slots- og Kulturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://whc.unesco.org/en/list/697/
- Motiv: et oversigts- eller detaljefoto af stenrækkernes langstrakte skibsform med spidse ender; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis UNESCO World Heritage Centre eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `UNESCO World Heritage Centre / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Jelling-monumenterne
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: længde, form, rekonstruktion og forhold til højene

**Kilde 2**
- `title`: Jelling Mounds, Runic Stones and Church
- `publisher`: UNESCO World Heritage Centre
- `url`: https://whc.unesco.org/en/list/697/
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: verdensarvskontekst


### 14 — Engelsholm Slot

#### Identitet og prioritering

- **rangnummer:** `14`
- **samlet score:** **84/100** — Let genkendeligt silhuetfacit og stærk eventyrværdi; privat skole/slot og parkregler kræver skarp afgrænsning.
- **stedets officielle eller mest præcise navn:** Engelsholm Slot
- **postnummer:** `7182`
- **adresse/stedbeskrivelse:** Engelsholmvej 6, 7182 Bredsten
- **område/by:** Nørup
- **foreslået opgavetitel:** Fire tårne ved søen
- **kort titel:** Fire hjørnetårne
- **spillerrettet beskrivelse:** Se slottet på afstand som en geometrisk figur. Tæl tårnene i hjørnerne – uden at gå ind på skolens private område.
- **tags:** `slot`, `renæssance`, `arkitektur`, `Nørup`
- **klynge/rute:** Engelsholm–Nørup
- **nærliggende kandidater:** 41 Nørup Kirke; 02 Ravningbroen som biltursstop

#### Dokumenteret historie

**Centrale fakta**

- Den nuværende hovedbygning på Engelsholm blev opført i 1593. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
- Det rektangulære slot har et kvadratisk, løgkuplet tårn i hvert af sine fire hjørner. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
- Selve bygningen er ikke offentligt tilgængelig; udsyn anbefales fra parken syd for slottet. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
- Slotsparken formidles som besøgssted med egne adgangsforhold. [Engelsholm Slotspark](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slotspark-gdk608070)

- **Hvorfor interessant for en familie:** Et klassisk ‘eventyrslot’ giver børn en enkel symmetriopgave og en historie om renæssancen.
- **Sikkert dokumenteret:** Byggeår, rektangulær plan, fire tårne og manglende offentlig adgang til bygningen er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Parkens præcise helårsadgang, arrangementer og hvilke tårne der ses samtidigt, skal verificeres.
- **Kildekritisk vurdering:** VisitVejle er officiel turismekilde med klare adgangsforbehold; begge sider er dog fra samme udgiver.

#### Stedet som spil

- **Konkret observerbar invariant:** de fire kvadratiske hjørnetårne med løgkupler.
- **Hvorfor permanent/helårsrobust:** Tårnene er bærende dele af den historiske hovedbygning.
- **Spilleren skal konkret:** observere hovedbygningens fire hjørner fra offentlig/tilladt parkzone.
- **Spilleren skal eksplicit ignorere:** spir, kviste, skorstene, sidebygninger og refleksioner i søen.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de fire kvadratiske hjørnetårne med løgkupler; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** To bageste tårne kan overlappe de forreste fra forkert vinkel; kupler kan fejltælles som ekstra tårne.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Se slottet fra den tilladte sydlige park. Hvor mange hjørnetårne har hovedbygningen?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `4`
- **Accepterede svarformer, facit først:** `4`, `fire`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Du ser kun den nærmeste side; flyt dig langs den tilladte parksti.
- `5` → Skorstene og spir er ikke hjørnetårne.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Engelsholm Slot** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Det rektangulære slot har et kvadratisk, løgkuplet tårn i hvert af sine fire hjørner. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
3. Udfør kun denne observation: observere hovedbygningens fire hjørner fra offentlig/tilladt parkzone; udelad spir, kviste, skorstene, sidebygninger og refleksioner i søen.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`4`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de fire kvadratiske hjørnetårne med løgkupler ved Engelsholm Slot; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: observere hovedbygningens fire hjørner fra offentlig/tilladt parkzone. Ignorér spir, kviste, skorstene, sidebygninger og refleksioner i søen.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Der er ét tårn i hvert hjørne af en firkantet hovedbygning.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fire hjørnetårne på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Renæssanceslottets symmetriske silhuet bliver håndgribelig, fordi I selv fandt de fire kvadratiske hjørnetårne med løgkupler.
- `historyFact`: Det nuværende slot fra 1593 har fire kvadratiske hjørnetårne med løgkupler. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Engelsholm Slot`
- `postalCode`: `7182`
- `address`: `Engelsholmvej 6, 7182 Bredsten`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — bygningen er ikke offentlig; kun den særskilt tilladte park-/udsigtszone må bruges. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`privateProperty`, `water`]
- **Foreløbige sikkerhedsnoter:** afklar skel og ejer-/driftshensyn; fastlæg afstand/værn ved vand.
- **Tilgængelighed — underlag:** parksti/græs, lokale hældninger ukendte
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den af VisitVejle angivne sydlige parkzone med afstand til søkant og private skolearealer.

**Kandidatspecifik feltcheckliste**

- Indhent aktuel parkadgang og markér private skel.
- Find vinkel hvor alle fire tårne kan udledes sikkert.
- Kontrollér søkant, underlag, arrangementer, GPS og skiltning.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111
- Motiv: et oversigts- eller detaljefoto af de fire kvadratiske hjørnetårne med løgkupler; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slotspark-gdk608070
- Motiv: et oversigts- eller detaljefoto af de fire kvadratiske hjørnetårne med løgkupler; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Engelsholm Slot
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: datering, arkitektur, fire tårne og begrænset bygningsadgang

**Kilde 2**
- `title`: Engelsholm Slotspark
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slotspark-gdk608070
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: parkens besøgsadgang

**Sjælden kildeundtagelse:** De to praktiske kilder har samme udgiver; facit er en stor, fysisk arkitekturinvariant, men tilladelse og synslinje skal bekræftes lokalt.


### 15 — Vejle Vindmølle

#### Identitet og prioritering

- **rangnummer:** `15`
- **samlet score:** **83/100** — Silhuetten er stærk og familievenlig, og ydersiden kan bruges uden åbningstid; vingernes midlertidige demontering er en reel driftsrisiko.
- **stedets officielle eller mest præcise navn:** Vejle Vindmølle
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Søndermarksvej 1, 7100 Vejle
- **område/by:** Søndermarken
- **foreslået opgavetitel:** Korset på møllen
- **kort titel:** Fire vinger
- **spillerrettet beskrivelse:** På bakken tegner møllen et stort kryds mod himlen. Tæl hver hel vinge fra navet og ud.
- **tags:** `vindmølle`, `teknik`, `udsigt`, `Søndermarken`
- **klynge/rute:** Vejle syd og centrum
- **nærliggende kandidater:** 35 Det Pressede Hjerte; centrumsklyngen kan nås separat

#### Dokumenteret historie

**Centrale fakta**

- Den nuværende Vejle Vindmølle blev opført i 1890. [Vejle Vindmølle](https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/)
- Møllen står på den tidligere galgebakke og fungerede som mølle frem til 1960. [Vejle Vindmølle](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-vindmoelle-gdk720810)
- Vejlemuseerne driver møllen som kulturhistorisk besøgssted. [Vejle Vindmølle](https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/)
- Den gamle retterplads/galgebakke indgår i Vejles mørkere historie. [På rejse i det mørke Vejle](https://www.visitvejle.dk/det-moerke-vejle)

- **Hvorfor interessant for en familie:** Alle kender vind, men møllens mekaniske størrelse gør energien fysisk og dramatisk.
- **Sikkert dokumenteret:** Byggeår, funktionstid, placering på tidligere galgebakke og museumsstatus er kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Kilderne dokumenterer ikke, at alle fire vinger altid er monteret; vedligehold kan bryde facit.
- **Kildekritisk vurdering:** Museet og VisitVejle er stærke lokale kilder; den aktuelle vingestatus kræver altid feltcheck tæt på publicering.

#### Stedet som spil

- **Konkret observerbar invariant:** de fire faste møllevinger på hatten.
- **Hvorfor permanent/helårsrobust:** Fire vinger er møllens normale konstruktive vingekors, men ikke garanteret under storm-/restaureringsarbejde.
- **Spilleren skal konkret:** se hele vingekorset fra sikker offentlig belægning og tælle fra navet.
- **Spilleren skal eksplicit ignorere:** vingernes tremmer, gelænder, flag, skygger og små vindmøller på skilte.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de fire faste møllevinger på hatten; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** En vinge kan stå lodret bag møllekroppen fra tæt hold; vinger kan være afmonteret midlertidigt.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange vinger har Vejle Vindmølles store vingekors?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `4`
- **Accepterede svarformer, facit først:** `4`, `fire`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `3` → Træd til den godkendte vinkel og se efter en vinge, der ligger bag møllekroppen.
- `8` → Tæl hele vinger, ikke deres to kanter.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Vejle Vindmølle** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Møllen står på den tidligere galgebakke og fungerede som mølle frem til 1960. [Vejle Vindmølle](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-vindmoelle-gdk720810)
3. Udfør kun denne observation: se hele vingekorset fra sikker offentlig belægning og tælle fra navet; udelad vingernes tremmer, gelænder, flag, skygger og små vindmøller på skilte.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`4`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejle Vindmølle](https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de fire faste møllevinger på hatten ved Vejle Vindmølle; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: se hele vingekorset fra sikker offentlig belægning og tælle fra navet. Ignorér vingernes tremmer, gelænder, flag, skygger og små vindmøller på skilte.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Vingerne danner normalt to krydsende linjer gennem navet.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fire vinger på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Byens vindmølle på den gamle galgebakke bliver håndgribelig, fordi I selv fandt de fire faste møllevinger på hatten.
- `historyFact`: Møllen fra 1890 arbejdede frem til 1960. [Vejle Vindmølle](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-vindmoelle-gdk720810)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Vejle Vindmølle`
- `postalCode`: `7100`
- `address`: `Søndermarksvej 1, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejle Vindmølle](https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — museum og udendørsareal har ikke samme adgang; en offentlig facadezone skal dokumenteres. [Vejle Vindmølle](https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `traffic`, `darkness`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; hold familien helt uden for køreareal; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** bakke, sti og mulig grus/brosten
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `partial`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et plant punkt på den etablerede adgangsvej/forplads, ikke kørebanen eller skråningen.

**Kandidatspecifik feltcheckliste**

- Bekræft fire monterede vinger og helårsudsyn.
- Find offentligt observationspunkt uden at afhænge af åbningstid.
- Mål hældning, trafik, GPS, lys og læforhold.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/
- Motiv: et oversigts- eller detaljefoto af de fire faste møllevinger på hatten; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-vindmoelle-gdk720810
- Motiv: et oversigts- eller detaljefoto af de fire faste møllevinger på hatten; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejle Vindmølle
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: byggeår, identitet, adresse og museumsdrift

**Kilde 2**
- `title`: Vejle Vindmølle
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-vindmoelle-gdk720810
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: stedshistorie og driftsperiode

**Kilde 3**
- `title`: På rejse i det mørke Vejle
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/det-moerke-vejle
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: galgebakkens historiske kontekst


### 16 — St. Peders Kilde

#### Identitet og prioritering

- **rangnummer:** `16`
- **samlet score:** **82/100** — Fin formkontrast og stærk Hærvejshistorie; åbent vandhul, glat underlag og rekonstruktionens tilstand kræver høj feltprioritet.
- **stedets officielle eller mest præcise navn:** St. Peders Kilde
- **postnummer:** `7323`
- **adresse/stedbeskrivelse:** Ved Øster Nykirke, Hærvejen 309, 7323 Give; præcis stiadgang skal fastlægges
- **område/by:** Hærvejen ved Vonge
- **foreslået opgavetitel:** Den runde kilde i en firkant
- **kort titel:** Firkantet ramme
- **spillerrettet beskrivelse:** Kilden gemmer én form inden i en anden. Se på den yderste træramme – ikke selve vandhullet.
- **tags:** `helligkilde`, `Hærvejen`, `sagn`, `natur`
- **klynge/rute:** Randbøl–Tinnet Hærvejen
- **nærliggende kandidater:** 04 Randbølstenen, 21 vejviseren, 38 badelandet og 39 Margrethediget

#### Dokumenteret historie

**Centrale fakta**

- St. Peders Kilde er en rund, åben, stensat brønd omgivet af en cirka to gange to meter stor firkantet egetræsramme. [Helligkilde, St. Peders kilde](https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde)
- Den nuværende indramning er en rekonstruktion, og kilden har været knyttet til forestillinger om helbredende vand. [Helligkilde, St. Peders kilde](https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde)
- Kilden ligger ved Hærvejen nær Øster Nykirke og indgår i områdets besøgsformidling. [Øster Nykirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135)

- **Hvorfor interessant for en familie:** To grundformer gør stedet aflæseligt, mens fortællingen åbner for tro, rejser og vand før moderne medicin.
- **Sikkert dokumenteret:** Brøndens og rammens form samt traditionen er registerdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Helbredende virkning er folketro, ikke medicinsk fakta; rammens aktuelle materiale/tilstand skal ses i felt.
- **Kildekritisk vurdering:** Trap/Register er stærk på anlægget; VisitVejle placerer det i ruten, men sikkerhed og vedligehold er ikke onlinebevist.

#### Stedet som spil

- **Konkret observerbar invariant:** den firkantede ydre egetræsramme omkring den runde stensatte brønd.
- **Hvorfor permanent/helårsrobust:** Rammen er en anlagt, rekonstruktiv hovedform, men træ kan blive udskiftet.
- **Spilleren skal konkret:** blive på stien og identificere den yderste rammes grundform.
- **Spilleren skal eksplicit ignorere:** den runde brøndåbning, stenene, eventuelt skilt og bænke.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop den firkantede ydre egetræsramme omkring den runde stensatte brønd; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Spørgsmålet kan besvares ‘rund’, hvis spilleren ser på vandhullet; ordet yderste skal fremhæves.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken form har den yderste træramme omkring den runde kilde?”
- **Svarmuligheder ved `singleChoice`:** `Firkantet` **(korrekt)**; `Rund`; `Trekantet`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Firkantet`
- **Accepterede svarformer, facit først:** `Firkantet`, `firkant`, `kvadratisk`, `et kvadrat`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Rund` → Det er formen på selve brønden. Se ét lag længere ud.
- `Trekantet` → Følg alle trærammens hjørner; der er fire.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **St. Peders Kilde** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Den nuværende indramning er en rekonstruktion, og kilden har været knyttet til forestillinger om helbredende vand. [Helligkilde, St. Peders kilde](https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde)
3. Udfør kun denne observation: blive på stien og identificere den yderste rammes grundform; udelad den runde brøndåbning, stenene, eventuelt skilt og bænke.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Firkantet`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Helligkilde, St. Peders kilde](https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find den firkantede ydre egetræsramme omkring den runde stensatte brønd ved St. Peders Kilde; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: blive på stien og identificere den yderste rammes grundform. Ignorér den runde brøndåbning, stenene, eventuelt skilt og bænke.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Den runde brønd ligger inde i en ramme med fire rette hjørner.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste firkantet ramme på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En helligkilde langs Hærvejen bliver håndgribelig, fordi I selv fandt den firkantede ydre egetræsramme omkring den runde stensatte brønd.
- `historyFact`: Kilden var forbundet med forestillinger om helbredende vand; det er tradition, ikke dokumenteret virkning. [Helligkilde, St. Peders kilde](https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `St. Peders Kilde`
- `postalCode`: `7323`
- `address`: `Ved Øster Nykirke, Hærvejen 309, 7323 Give; præcis stiadgang skal fastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Helligkilde, St. Peders kilde](https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — rutekilden omtaler stedet, men giver ikke fuldt bevis for sikkert, trinløst helårspunkt. [Øster Nykirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `steepSlope`, `darkness`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** natursti; mulig mudder, rødder og glat træ
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** stien på ydersiden af rammen med tydelig afstand til den åbne brønd.

**Kandidatspecifik feltcheckliste**

- Kontrollér værn, vanddybde, glathed og lovlig sti.
- Bekræft rammens aktuelle form og materiale.
- Registrér GPS, mobildækning, tilgængelighed og sæsonvegetation.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde
- Motiv: et oversigts- eller detaljefoto af den firkantede ydre egetræsramme omkring den runde stensatte brønd; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135
- Motiv: et oversigts- eller detaljefoto af den firkantede ydre egetræsramme omkring den runde stensatte brønd; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Helligkilde, St. Peders kilde
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Helligkilde%2C_St._Peders_kilde
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: kildens runde brønd, firkantede ramme og tradition

**Kilde 2**
- `title`: Øster Nykirke
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: lokation og Hærvejs-/kirkekontekst


### 17 — Bindeballe Station

#### Identitet og prioritering

- **rangnummer:** `17`
- **samlet score:** **81/100** — Meget familievenligt og adgangsdokumenteret tællefacit; cykeltrafik og midlertidigt flyttede vogne er de primære risici.
- **stedets officielle eller mest præcise navn:** Bindeballe Station
- **postnummer:** `7183`
- **adresse/stedbeskrivelse:** Bindeballevej 101, 7183 Randbøl
- **område/by:** Bindeballe
- **foreslået opgavetitel:** Tre vogne på den nedlagte bane
- **kort titel:** Tre jernbanevogne
- **spillerrettet beskrivelse:** Togene kører ikke længere, men en lille stamme er blevet stående. Tæl kun de gamle jernbanevogne ved stationen.
- **tags:** `jernbane`, `station`, `Bindeballestien`, `familie`
- **klynge/rute:** Vejle Ådal vest
- **nærliggende kandidater:** 02 Ravningbroen og 20 Egtvedpigens Verden

#### Dokumenteret historie

**Centrale fakta**

- Bindeballe Station åbnede med Vandelbanen i 1897; banen blev forlænget mod Grindsted i 1914. [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
- Ved stationen står tre mere end hundrede år gamle jernbanevogne. [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
- Udearealet er gratis og oplyst som åbent døgnet rundt. [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
- Stationen er et stop langs den rekreative Bindeballesti. [Oplevelser langs Bindeballestien](https://www.visitvejle.dk/vejle/outdoor/oplevelser-langs-bindeballestien)

- **Hvorfor interessant for en familie:** Vogne i børnehøjde gør transporthistorie konkret og fungerer som pausepunkt på en familierute.
- **Sikkert dokumenteret:** Åbningsår, baneforlængelse, tre vogne og døgnåbent udeareal er museumsdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Vogne kan flyttes kortvarigt ved restaurering; ‘ved stationen’ skal afgrænses fysisk.
- **Kildekritisk vurdering:** Vejlemuseerne forvalter stedet og er stærk primær driftskilde; VisitVejle bekræfter rutesammenhængen.

#### Stedet som spil

- **Konkret observerbar invariant:** de tre gamle jernbanevogne ved stationsanlægget.
- **Hvorfor permanent/helårsrobust:** Vognene er store museumsgenstande knyttet til stationsmiljøet, men kan undtagelsesvis være på værksted.
- **Spilleren skal konkret:** stå på den sikre stationsside og tælle hele jernbanevogne.
- **Spilleren skal eksplicit ignorere:** lokomotivmotiver, biler, cykeltrailere, stationsbygningen og små modeller.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de tre gamle jernbanevogne ved stationsanlægget; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** En vogn kan ligne to sektioner, og moderne servicekøretøjer kan stå tæt på.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange gamle jernbanevogne står ved Bindeballe Station?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Se langs hele sporet – en vogn kan stå forskudt.
- `4` → Tæl hele gamle jernbanevogne, ikke deres adskilte kupéer.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Bindeballe Station** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Ved stationen står tre mere end hundrede år gamle jernbanevogne. [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
3. Udfør kun denne observation: stå på den sikre stationsside og tælle hele jernbanevogne; udelad lokomotivmotiver, biler, cykeltrailere, stationsbygningen og små modeller.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de tre gamle jernbanevogne ved stationsanlægget ved Bindeballe Station; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: stå på den sikre stationsside og tælle hele jernbanevogne. Ignorér lokomotivmotiver, biler, cykeltrailere, stationsbygningen og små modeller.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Museet har bevaret en trio af gamle vogne.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre jernbanevogne på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Vandelbanens bevarede landstation bliver håndgribelig, fordi I selv fandt de tre gamle jernbanevogne ved stationsanlægget.
- `historyFact`: Vognene er over hundrede år gamle, mens stationen åbnede i 1897. [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Bindeballe Station`
- `postalCode`: `7183`
- `address`: `Bindeballevej 101, 7183 Randbøl`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — udearealet er gratis og døgnåbent ifølge Vejlemuseerne. [Bindeballe Station](https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`cyclePath`, `crowding`]
- **Foreløbige sikkerhedsnoter:** placér ophold uden for cykelflow; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fast/gruset stationsareal ved rekreativ sti
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `partial`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den markerede besøgszone ved stationen, væk fra gennemgående cykelspor og uden at gå mellem koblinger.

**Kandidatspecifik feltcheckliste**

- Bekræft at alle tre vogne er til stede og synlige.
- Kortlæg cykelstrøm, kanter og sikker familiezone.
- Test GPS, mobildækning og kørestolsrute fra parkering/sti.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/
- Motiv: et oversigts- eller detaljefoto af de tre gamle jernbanevogne ved stationsanlægget; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/outdoor/oplevelser-langs-bindeballestien
- Motiv: et oversigts- eller detaljefoto af de tre gamle jernbanevogne ved stationsanlægget; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Bindeballe Station
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/bindeballe-station/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: historie, antal vogne, adresse og adgang

**Kilde 2**
- `title`: Oplevelser langs Bindeballestien
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/outdoor/oplevelser-langs-bindeballestien
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: placering på Bindeballestien


### 18 — Your Perception

#### Identitet og prioritering

- **rangnummer:** `18`
- **samlet score:** **80/100** — Klart antal og perspektivleg i en velkomstbeskrevet park; hotelarrangementer, plæne og værkets præcise afgrænsning skal testes.
- **stedets officielle eller mest præcise navn:** Your Perception
- **postnummer:** `7080`
- **adresse/stedbeskrivelse:** Parken bag Comwell Kellers Park, H.O. Wildenskovsvej 28, 7080 Børkop
- **område/by:** Brejning
- **foreslået opgavetitel:** Tre blikke på den samme park
- **kort titel:** Tre skulpturer
- **spillerrettet beskrivelse:** Flyt jer mellem tre kunstneriske synspunkter og afgør, hvor mange dele der hører til det samme værk.
- **tags:** `samtidskunst`, `perspektiv`, `park`, `Brejning`
- **klynge/rute:** Børkop–Brejning
- **nærliggende kandidater:** 27 Kellers skolesten og 29 Ene Øjesten

#### Dokumenteret historie

**Centrale fakta**

- Your Perception består af tre skulpturer placeret i parken bag Comwell Kellers Park. [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
- Værket er skabt som et stedsspecifikt kunstprojekt, hvor perspektiv og omgivelser indgår. [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
- VisitVejle oplyser, at besøgende er velkomne i parken. [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
- Området indgår i en offentlig formidlet historisk rute ved Kellers Minde. [Historisk vandrerute ved Kellers Minde](https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491)

- **Hvorfor interessant for en familie:** Værket lægger op til, at børn og voksne ser forskelligt og sammenligner deres blik.
- **Sikkert dokumenteret:** Antal, placering, titel og besøgsvelkomst er dokumenteret af VisitVejle.
- **Usikkert, omstridt, sagn eller fortolkning:** Kunstnerisk fortolkning og den præcise grænse mellem de tre dele skal ikke være facit; eventuelle ændringer efter events er ukendte.
- **Kildekritisk vurdering:** Facitkilden er officiel turisme, men der er ikke fundet en uafhængig værkregistrering; rutesiden støtter kun adgangskonteksten.

#### Stedet som spil

- **Konkret observerbar invariant:** værkets tre separate skulpturdele i parken.
- **Hvorfor permanent/helårsrobust:** Tre store, stedsspecifikke skulpturer forventes stationære; installationer på hotelgrunden kan dog flyttes ved vedligehold.
- **Spilleren skal konkret:** gå ad parkens tilladte sti og identificere de tre dele med samme værktitel.
- **Spilleren skal eksplicit ignorere:** havemøbler, lamper, skilte, træer og anden kunst.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop værkets tre separate skulpturdele i parken; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Parkens øvrige elementer kan ligne skulpturer; et titelskilt kan være nødvendigt for fair afgrænsning.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange separate skulpturer udgør værket Your Perception?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Se videre gennem parken efter endnu en del med samme formsprog.
- `4` → Tæl kun delene af Your Perception, ikke andet parkdesign.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Your Perception** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Værket er skabt som et stedsspecifikt kunstprojekt, hvor perspektiv og omgivelser indgår. [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
3. Udfør kun denne observation: gå ad parkens tilladte sti og identificere de tre dele med samme værktitel; udelad havemøbler, lamper, skilte, træer og anden kunst.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find værkets tre separate skulpturdele i parken ved Your Perception; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå ad parkens tilladte sti og identificere de tre dele med samme værktitel. Ignorér havemøbler, lamper, skilte, træer og anden kunst.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Værkets titel dækker en trio af separate skulpturer.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre skulpturer på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et nutidigt kunstværk om opfattelse bliver håndgribelig, fordi I selv fandt værkets tre separate skulpturdele i parken.
- `historyFact`: Den officielle beskrivelse definerer Your Perception som tre skulpturer i parken. [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Your Perception`
- `postalCode`: `7080`
- `address`: `Parken bag Comwell Kellers Park, H.O. Wildenskovsvej 28, 7080 Børkop`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — VisitVejle skriver, at gæster er velkomne i parken; event- og hotelhensyn kontrolleres. [Your Perception – kunstværk i Brejning](https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`privateProperty`, `crowding`]
- **Foreløbige sikkerhedsnoter:** afklar skel og ejer-/driftshensyn; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** parksti og græs
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `partial`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den anviste parksti bag hotellet uden at gå ind i private terrasser eller over plæne, hvis det ikke er tilladt.

**Kandidatspecifik feltcheckliste**

- Bekræft tre værkdele og eventuel titelskiltning.
- Afklar parkgrænse, hotelarrangementer og helårsadgang.
- Test rute, GPS, underlag og aflæsning for kørestol/barnevogn.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110
- Motiv: et oversigts- eller detaljefoto af værkets tre separate skulpturdele i parken; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491
- Motiv: et oversigts- eller detaljefoto af værkets tre separate skulpturdele i parken; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Your Perception – kunstværk i Brejning
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/your-perception-kunstvaerk-i-brejning-gdk1145110
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: værkets navn, tre dele, adresse og parkadgang

**Kilde 2**
- `title`: Historisk vandrerute ved Kellers Minde
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: områdets besøgsrute og historiske kontekst


### 19 — Jellinghøjene

#### Identitet og prioritering

- **rangnummer:** `19`
- **samlet score:** **79/100** — Meget robust, enkel og tilgængelig landskabsobservation; opgaven er mindre unik end de øvrige Jelling-spor.
- **stedets officielle eller mest præcise navn:** Jellinghøjene
- **postnummer:** `7300`
- **adresse/stedbeskrivelse:** Monumentområdet ved Thyrasvej 1, 7300 Jelling
- **område/by:** Jelling
- **foreslået opgavetitel:** To kongelige høje
- **kort titel:** To høje
- **spillerrettet beskrivelse:** Kirken står mellem to kæmpestore jordformer. Tæl kun de monumentale høje, der hører til verdensarvsanlægget.
- **tags:** `gravhøje`, `vikinger`, `landskab`, `UNESCO`
- **klynge/rute:** Jelling-monumenterne
- **nærliggende kandidater:** 01 og 06 runestenene, 09 palisaden og 13 skibssætningen

#### Dokumenteret historie

**Centrale fakta**

- Jelling-anlægget rummer to store høje, traditionelt kaldet Nordhøjen og Sydhøjen. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Nordhøjen er cirka 62 meter i diameter og otte meter høj. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Højene, runestenene og kirken udgør én verdensarvslokalitet. [Jelling Mounds, Runic Stones and Church](https://whc.unesco.org/en/list/697/)

- **Hvorfor interessant for en familie:** Store jordvolumener kan bestiges/opleves efter gældende regler og gør fortidens byggearbejde mærkbart.
- **Sikkert dokumenteret:** Antallet to, navnene og Nordhøjens mål er myndighedsdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Højenes oprindelige funktioner og gravhistorie er mere komplekse end et enkelt ‘kongegrav’-udsagn og udelades af facit.
- **Kildekritisk vurdering:** Myndighed og UNESCO er autoritative; simple tal kan dog læres fra skiltning, så onsite-kravet er primært sikker identifikation.

#### Stedet som spil

- **Konkret observerbar invariant:** de to store græsklædte grav-/mindehøje på hver side af kirken.
- **Hvorfor permanent/helårsrobust:** Højene er fredede, monumentale jordværker og årsuafhængige.
- **Spilleren skal konkret:** stå ved kirke-/stiforløbet og identificere de to store græshøje.
- **Spilleren skal eksplicit ignorere:** små terrænbuler, kirkegårdsvolde, palisademarkering og trætoppe.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de to store græsklædte grav-/mindehøje på hver side af kirken; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Ordet ‘høje’ kan få børn til at tælle andre hævede terrændele; udsigten kan være skjult af bygninger/træer.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange store græsklædte høje flankerer kirken i monumentområdet?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `2`
- **Accepterede svarformer, facit først:** `2`, `to`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `1` → Gå til den anden side af kirken; der ligger en tilsvarende stor høj.
- `3` → Tæl kun de to monumentale græshøje i verdensarvsområdet.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Jellinghøjene** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Nordhøjen er cirka 62 meter i diameter og otte meter høj. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
3. Udfør kun denne observation: stå ved kirke-/stiforløbet og identificere de to store græshøje; udelad små terrænbuler, kirkegårdsvolde, palisademarkering og trætoppe.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`2`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de to store græsklædte grav-/mindehøje på hver side af kirken ved Jellinghøjene; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: stå ved kirke-/stiforløbet og identificere de to store græshøje. Ignorér små terrænbuler, kirkegårdsvolde, palisademarkering og trætoppe.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Kirken ligger mellem et par store høje.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste to høje på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Nord- og Sydhøjen i det kongelige monumentlandskab bliver håndgribelig, fordi I selv fandt de to store græsklædte grav-/mindehøje på hver side af kirken.
- `historyFact`: Nordhøjen er omkring 62 meter i diameter og otte meter høj. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Jellinghøjene`
- `postalCode`: `7300`
- `address`: `Monumentområdet ved Thyrasvej 1, 7300 Jelling`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentligt monumentområde; eventuelle regler for adgang oven på højene er ikke nødvendige for opgaven. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `crowding`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fast sti; selve højene har stejl græsflade
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** det plane stiforløb mellem/ved kirken og højene; opgaven kræver ikke opstigning.

**Kandidatspecifik feltcheckliste**

- Vælg punkt hvor begge høje kan identificeres fra plan sti.
- Kontrollér arrangementer, græsarbejde og trængsel.
- Solve-test at andre jordformer ignoreres og GPS virker.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- Motiv: et oversigts- eller detaljefoto af de to store græsklædte grav-/mindehøje på hver side af kirken; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Slots- og Kulturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Slots- og Kulturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://whc.unesco.org/en/list/697/
- Motiv: et oversigts- eller detaljefoto af de to store græsklædte grav-/mindehøje på hver side af kirken; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis UNESCO World Heritage Centre eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `UNESCO World Heritage Centre / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Jelling-monumenterne
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: antal høje, navne og dimensioner

**Kilde 2**
- `title`: Jelling Mounds, Runic Stones and Church
- `publisher`: UNESCO World Heritage Centre
- `url`: https://whc.unesco.org/en/list/697/
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: verdensarvssammenhæng


### 20 — Egtvedpigens Verden

#### Identitet og prioritering

- **rangnummer:** `20`
- **samlet score:** **78/100** — Nyt, familiebygget udeanlæg med klart zonefacit og stærk historie; markører og drift er så nye, at stabilitet skal testes ekstra.
- **stedets officielle eller mest præcise navn:** Egtvedpigens Verden
- **postnummer:** `6040`
- **adresse/stedbeskrivelse:** Egtved Holt 12, 6040 Egtved
- **område/by:** Egtved
- **foreslået opgavetitel:** Fem verdener uden vægge
- **kort titel:** Fem fortællezoner
- **spillerrettet beskrivelse:** Gå gennem et museum uden vægge og hold øje med overgangen mellem historierne. Hvor mange hovedområder har skaberne delt rejsen i?
- **tags:** `bronzealder`, `Egtvedpigen`, `udendørs museum`, `familie`
- **klynge/rute:** Vejle Ådal vest
- **nærliggende kandidater:** 02 Ravningbroen og 17 Bindeballe Station

#### Dokumenteret historie

**Centrale fakta**

- Egtvedpigens Verden er et udendørs formidlingsanlæg uden traditionelle vægge ved fundstedet. [Egtvedpigens Verden](https://www.egtvedpigensverden.dk/)
- Anlægget er organiseret i fem oplevelses-/fortællezoner. [Lær Egtvedpigen at kende i Egtvedpigens Verden](https://www.vejle.dk/da/oplevelser/mest-for-boern/laer-egtvedpigen-at-kende-i-egtvedpigens-verden/)
- Området er gratis og oplyst som åbent døgnet rundt. [Egtvedpigens Verden](https://www.egtvedpigensverden.dk/)
- Egtvedpigens grav blev fundet i gravhøjen i 1921 og dateres til bronzealderen. [Egtved gravhøj](https://slks.dk/doil/stederne/egtved-gravhoej)

- **Hvorfor interessant for en familie:** Anlægget er direkte designet til sanselig familieformidling og forbinder originalt fundsted med en jævnaldrende pige.
- **Sikkert dokumenteret:** Fundsted, anlæggets udendørs form, fem zoner og offentlig adgang er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Zonenavne, markørernes fysiske udformning og om alle fem er aflæselige uden kort er ikke tilstrækkeligt dokumenteret online.
- **Kildekritisk vurdering:** Museums-/kommunekilder er aktuelle og autoritative for det nye anlæg; Slots- og Kulturstyrelsen er uafhængig autoritet på fundstedet.

#### Stedet som spil

- **Konkret observerbar invariant:** anlæggets fem navngivne formidlingszoner.
- **Hvorfor permanent/helårsrobust:** Hovedzoner er del af anlæggets arkitektoniske koncept, men et nyt anlæg kan få ændret skiltning efter åbning.
- **Spilleren skal konkret:** følge den officielle rundgang og registrere hver ny navngiven hovedzone én gang.
- **Spilleren skal eksplicit ignorere:** understationer, legeelementer, gravhøjen som særskilt stop og midlertidige aktivitetsområder.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop anlæggets fem navngivne formidlingszoner; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Familier kan tælle stationer i stedet for hovedzoner; opgaven er kun fair, hvis zonegrænser er fysisk markeret.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange hovedzoner er Egtvedpigens Verden opdelt i? Følg kun anlæggets egne zone-markører.”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 5 mappes til decimaltallet `5` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `5`
- **Accepterede svarformer, facit først:** `5`, `fem`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `4` → Se efter om én hovedzone ligger adskilt fra den mest oplagte rundgang.
- `6` → Tæl hovedzoner, ikke mindre stationer inden i dem.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Egtvedpigens Verden** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Anlægget er organiseret i fem oplevelses-/fortællezoner. [Lær Egtvedpigen at kende i Egtvedpigens Verden](https://www.vejle.dk/da/oplevelser/mest-for-boern/laer-egtvedpigen-at-kende-i-egtvedpigens-verden/)
3. Udfør kun denne observation: følge den officielle rundgang og registrere hver ny navngiven hovedzone én gang; udelad understationer, legeelementer, gravhøjen som særskilt stop og midlertidige aktivitetsområder.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 5 mappes til decimaltallet `5` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`5`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Egtvedpigens Verden](https://www.egtvedpigensverden.dk/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find anlæggets fem navngivne formidlingszoner ved Egtvedpigens Verden; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: følge den officielle rundgang og registrere hver ny navngiven hovedzone én gang. Ignorér understationer, legeelementer, gravhøjen som særskilt stop og midlertidige aktivitetsområder.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Kommunens beskrivelse organiserer universet i fem hovedzoner.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fem fortællezoner på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et nyt udendørs univers omkring bronzealderpigen bliver håndgribelig, fordi I selv fandt anlæggets fem navngivne formidlingszoner.
- `historyFact`: Det oprindelige gravfund blev gjort i 1921 på stedet. [Egtved gravhøj](https://slks.dk/doil/stederne/egtved-gravhoej)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Egtvedpigens Verden`
- `postalCode`: `6040`
- `address`: `Egtved Holt 12, 6040 Egtved`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Egtvedpigens Verden](https://www.egtvedpigensverden.dk/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — anlægget oplyses gratis og døgnåbent. [Egtvedpigens Verden](https://www.egtvedpigensverden.dk/)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`, `darkness`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** nyt udendørs stiforløb; præcis belægning/hældning skal registreres
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den officielle rundgang fra besøgsankomsten; ingen afvigelse ind i sårbar høj/natur.

**Kandidatspecifik feltcheckliste**

- Bekræft at præcis fem hovedzoner kan skelnes fysisk.
- Kortlæg hele rundgang, afstand, underlag og nat-/vinterdrift.
- Solve-test forskellen mellem zone og station; registrér GPS og mobildækning.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.egtvedpigensverden.dk/
- Motiv: et oversigts- eller detaljefoto af anlæggets fem navngivne formidlingszoner; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejle.dk/da/oplevelser/mest-for-boern/laer-egtvedpigen-at-kende-i-egtvedpigens-verden/
- Motiv: et oversigts- eller detaljefoto af anlæggets fem navngivne formidlingszoner; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Kommune eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Kommune / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Egtvedpigens Verden
- `publisher`: Vejlemuseerne
- `url`: https://www.egtvedpigensverden.dk/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: anlægstype, adresse og adgang

**Kilde 2**
- `title`: Lær Egtvedpigen at kende i Egtvedpigens Verden
- `publisher`: Vejle Kommune
- `url`: https://www.vejle.dk/da/oplevelser/mest-for-boern/laer-egtvedpigen-at-kende-i-egtvedpigens-verden/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: de fem zoner og åbningen

**Kilde 3**
- `title`: Egtved gravhøj
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/doil/stederne/egtved-gravhoej
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: fundstedets arkæologiske historie


### 21 — Vejviseren ved Nørre Kollemorten

#### Identitet og prioritering

- **rangnummer:** `21`
- **samlet score:** **77/100** — Stærk onsite-aflæsning og god rejsehistorie; kildekonflikten håndteres ved et facit, der ikke afhænger af årstallet.
- **stedets officielle eller mest præcise navn:** Vejviseren ved Nørre Kollemorten
- **postnummer:** `7323`
- **adresse/stedbeskrivelse:** Ved Hærvejen nær Nørre Kollemorten/Øster Nykirke, Hærvejen 309, 7323 Give
- **område/by:** Nørre Kollemorten
- **foreslået opgavetitel:** Vejen på årstalssiden
- **kort titel:** COLDING
- **spillerrettet beskrivelse:** Stenen pegede rejsende gennem landet længe før GPS. Brug årstallet som pejlemærke, men skriv destinationen på samme flade.
- **tags:** `Hærvejen`, `vejviser`, `inskription`, `kildekritik`
- **klynge/rute:** Randbøl–Tinnet Hærvejen
- **nærliggende kandidater:** 04 Randbølstenen, 16 St. Peders Kilde og 39 Margrethediget

#### Dokumenteret historie

**Centrale fakta**

- Granitvejviseren er cirka 117 centimeter høj og bærer blandt andet stednavnene VIBORG og COLDING. [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten)
- Trap registrerer COLDING og Vester Mølle på den sydvestlige side sammen med årstallet 1853. [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten)
- VisitVejle omtaler samme vejviser ved Øster Nykirke, men daterer den til 1856. [Øster Nykirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135)
- Vejviseren står i Hærvejslandskabet, hvor den gamle nord-syd-rute formidles som vandrerute. [Hærvejen](https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/)

- **Hvorfor interessant for en familie:** Børn kan sammenligne navigation før og nu, mens den synlige kildekonflikt lærer dem ikke at gøre et usikkert årstal til facit.
- **Sikkert dokumenteret:** Stenens dimensioner og stednavnene VIBORG/COLDING er dokumenteret; Trap placerer COLDING på årstalssiden.
- **Usikkert, omstridt, sagn eller fortolkning:** Årstallet er omstridt online: Trap angiver 1853, VisitVejle 1856. Rapporten vælger ikke lydløst mellem dem.
- **Kildekritisk vurdering:** Trap/Register har den mest detaljerede objektrecord; VisitVejle er praktisk, men uenig på dateringen. Feltfoto skal afgøre hvad der faktisk står.

#### Stedet som spil

- **Konkret observerbar invariant:** stednavnet COLDING på samme stenflade som det indhuggede årstal.
- **Hvorfor permanent/helårsrobust:** Indskriften er hugget i en registreret granitsten; erosion kan påvirke læsbarheden.
- **Spilleren skal konkret:** finde årstallet og læse stednavnet på præcis samme stenflade.
- **Spilleren skal eksplicit ignorere:** årstallet selv, VIBORG på en anden side, moderne vejskilte og afstandstal.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop stednavnet COLDING på samme stenflade som det indhuggede årstal; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Siderne mødes ved en kant, og spillerne kan mene, at et ord på nabofladen er ‘samme side’; retning og flade skal solve-testes.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `freeText`
- **Præcist spillerrettet spørgsmål:** “Find den gamle granitvejviser. Hvilket stednavn står på samme side som årstallet? Skriv navnet præcis som på stenen.”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `COLDING`
- **Accepterede svarformer, facit først:** `COLDING`, `Colding`, `colding`, `KOLDING`, `Kolding`, `kolding`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `VIBORG` → Det stednavn står på en anden side. Find først årstallet og bliv på den flade.
- `Vester Mølle` → Det er en mindre lokal angivelse; spørgsmålet søger bynavnet med store bogstaver.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Vejviseren ved Nørre Kollemorten** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Trap registrerer COLDING og Vester Mølle på den sydvestlige side sammen med årstallet 1853. [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten)
3. Udfør kun denne observation: finde årstallet og læse stednavnet på præcis samme stenflade; udelad årstallet selv, VIBORG på en anden side, moderne vejskilte og afstandstal.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`COLDING`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find stednavnet COLDING på samme stenflade som det indhuggede årstal ved Vejviseren ved Nørre Kollemorten; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde årstallet og læse stednavnet på præcis samme stenflade. Ignorér årstallet selv, VIBORG på en anden side, moderne vejskilte og afstandstal.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Det er den ældre stavemåde for Kolding, skrevet med C.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste colding på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En kongelig vejviser på den gamle hovedvej bliver håndgribelig, fordi I selv fandt stednavnet COLDING på samme stenflade som det indhuggede årstal.
- `historyFact`: Kilderne er uenige om 1853/1856, men den detaljerede registrering placerer COLDING på årstalssiden. [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten) [Øster Nykirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Vejviseren ved Nørre Kollemorten`
- `postalCode`: `7323`
- `address`: `Ved Hærvejen nær Nørre Kollemorten/Øster Nykirke, Hærvejen 309, 7323 Give`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejmærke, Nørre Kollemorten](https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — stenen formidles ved Hærvejen, men et sikkert observationspunkt væk fra vejtrafik er ikke dokumenteret. [Øster Nykirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** vejkant/natursti; ukendt afstand til køreareal
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den side af stenen der kan nås fra etableret sti/rabat uden at stå på kørebane eller cykelspor.

**Kandidatspecifik feltcheckliste**

- Fotografér alle flader og afgør det faktiske årstal uden at ændre facitlogikken.
- Bekræft lovlig adgang, afstand til trafik og læsbarhed.
- Registrér GPS, underlag og accepterede stavemåder i solve-test.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten
- Motiv: et oversigts- eller detaljefoto af stednavnet COLDING på samme stenflade som det indhuggede årstal; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Lex eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Lex / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135
- Motiv: et oversigts- eller detaljefoto af stednavnet COLDING på samme stenflade som det indhuggede årstal; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejmærke, Nørre Kollemorten
- `publisher`: Trap Danmark / Lex
- `url`: https://trap.lex.dk/Vejm%C3%A6rke%2C_N%C3%B8rre_Kollemorten
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: mål, inskriptioner, orientering og årstallet 1853

**Kilde 2**
- `title`: Øster Nykirke
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/oester-nykirke-gdk608135
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: lokation og den modstridende datering 1856

**Kilde 3**
- `title`: Hærvejen
- `publisher`: Vejle Kommune
- `url`: https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: rutekontekst


### 22 — Grejsdal Kirke

#### Identitet og prioritering

- **rangnummer:** `22`
- **samlet score:** **76/100** — Usædvanlig geometri og god efterkrigshistorie; fem sider kan være vanskelige at afgrænse omkring tilbygninger.
- **stedets officielle eller mest præcise navn:** Grejsdal Kirke
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Grejsdal Kirke på vestskråningen langs Grejsdalsvej, 7100 Vejle; husnummer skal verificeres
- **område/by:** Grejsdalen
- **foreslået opgavetitel:** Kirken med fem sider
- **kort titel:** Fem sider
- **spillerrettet beskrivelse:** Kirken ser enkel ud, men følger ikke en almindelig rektangel. Følg kun hovedbygningens yderlinje og find antallet af sider.
- **tags:** `kirke`, `modernisme`, `geometri`, `Grejsdalen`
- **klynge/rute:** Grejsdalen
- **nærliggende kandidater:** ingen anden top-50 i umiddelbar nærhed; egnet som selvstændigt udflugtsstop

#### Dokumenteret historie

**Centrale fakta**

- Grejsdal Kirke blev opført i 1961 efter tegninger af Jens Malling Pedersen. [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
- Bygningen har en aflang femkantet grundplan. [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
- Kirken bruger glasbyggesten i stedet for traditionelle vinduesåbninger. [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
- Grejsdal Kirke fremhæves blandt Vejle-områdets seværdige kirker. [Seværdige kirker i Vejle](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/sevaerdige-kirker)

- **Hvorfor interessant for en familie:** En stor femkant gør skolegeometri fysisk og viser, at kirker kan have moderne former.
- **Sikkert dokumenteret:** Byggeår, arkitekt, femkantet plan og glasbyggesten er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Onlinekilden viser ikke en fuld situationsplan; sidebygninger og kirkegårdsskel kan gøre rundgangen uklar.
- **Kildekritisk vurdering:** VisitVejle er genstandsspecifik, men anden kilde er kun en oversigt fra samme udgiver; arkitekttegning/menighedskilde bør findes før publicering.

#### Stedet som spil

- **Konkret observerbar invariant:** kirkens aflange femkantede grundplan set i ydermurens hovedsider.
- **Hvorfor permanent/helårsrobust:** Grundplanens hovedmure er konstruktive og permanente.
- **Spilleren skal konkret:** følge hovedkirkens fem ydersider visuelt fra offentligt kirkeareal.
- **Spilleren skal eksplicit ignorere:** fritstående inventar, trapper, udhæng, små fremspring og eventuelle sidebygninger.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop kirkens aflange femkantede grundplan set i ydermurens hovedsider; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** En aflang femkant kan fra jorden ligne en rektangel med kor; ‘hovedside’ kræver præcis definition.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Gå rundt om kirken ad de tilladte arealer. Hvor mange hovedsider har bygningens femkantede plan?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 5 mappes til decimaltallet `5` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `5`
- **Accepterede svarformer, facit først:** `5`, `fem`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `4` → Se ved den smalle ende efter en ekstra vinkling.
- `6` → Små fremspring og tilbygninger er ikke en side i hovedplanen.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Grejsdal Kirke** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Bygningen har en aflang femkantet grundplan. [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
3. Udfør kun denne observation: følge hovedkirkens fem ydersider visuelt fra offentligt kirkeareal; udelad fritstående inventar, trapper, udhæng, små fremspring og eventuelle sidebygninger.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 5 mappes til decimaltallet `5` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`5`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find kirkens aflange femkantede grundplan set i ydermurens hovedsider ved Grejsdal Kirke; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: følge hovedkirkens fem ydersider visuelt fra offentligt kirkeareal. Ignorér fritstående inventar, trapper, udhæng, små fremspring og eventuelle sidebygninger.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Grundplanen har én side mere end et rektangel.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fem sider på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Efterkrigstidens femkantede kirke i ådalen bliver håndgribelig, fordi I selv fandt kirkens aflange femkantede grundplan set i ydermurens hovedsider.
- `historyFact`: Kirken fra 1961 har en aflang femkantet grundplan. [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Grejsdal Kirke`
- `postalCode`: `7100`
- `address`: `Grejsdal Kirke på vestskråningen langs Grejsdalsvej, 7100 Vejle; husnummer skal verificeres`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — kirkearealets udendørs adgang og aktuelle handlinger skal afklares; turistsiden angiver ikke helårstider. [Grejsdal Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `traffic`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; hold familien helt uden for køreareal.
- **Tilgængelighed — underlag:** kirkeplads på dalskråning; belægning og trin ukendte
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** det lovlige, plane kirkeareal med afstand til Grejsdalsvej; ingen færdsel mellem grave under handlinger.

**Kandidatspecifik feltcheckliste**

- Verificér fuld adresse og offentlig rundgang.
- Tegn de fem hovedsider og afgræns tilbygninger.
- Kontrollér skråning, trin, trafik, handlinger og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074
- Motiv: et oversigts- eller detaljefoto af kirkens aflange femkantede grundplan set i ydermurens hovedsider; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/sevaerdige-kirker
- Motiv: et oversigts- eller detaljefoto af kirkens aflange femkantede grundplan set i ydermurens hovedsider; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Grejsdal Kirke
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/grejsdal-kirke-gdk608074
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: byggeår, arkitekt, femkantet plan og glasbyggesten

**Kilde 2**
- `title`: Seværdige kirker i Vejle
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/sevaerdige-kirker
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: regional kirkekontekst

**Sjælden kildeundtagelse:** To sider fra samme officielle turismeudgiver; geometrien er tydeligt beskrevet, men produktionsfacit kræver plan/feltkontrol.


### 23 — Den gamle ottekant i Skyttehushaven

#### Identitet og prioritering

- **rangnummer:** `23`
- **samlet score:** **75/100** — God geometri i et familieområde med stærk arkivhistorie; det skal verificeres, præcis hvilken bevaret pavillon kilden beskriver.
- **stedets officielle eller mest præcise navn:** Den gamle ottekant i Skyttehushaven
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Skyttehushaven ved Tirsbæk Strandvej, 7100 Vejle
- **område/by:** Skyttehushaven
- **foreslået opgavetitel:** Pavillonen med otte sider
- **kort titel:** Otte sider
- **spillerrettet beskrivelse:** Her dansede vejlenserne med fjorden som nabo. Gå rundt om den gamle pavillons hovedkrop og tæl dens lige sider.
- **tags:** `pavillon`, `forlystelse`, `fjorden`, `geometri`
- **klynge/rute:** Vejle fjord og havn
- **nærliggende kandidater:** 42 Tirsbæk Gods på separat fjordudflugt og 43 Mølleå-broerne i centrum

#### Dokumenteret historie

**Centrale fakta**

- Skyttehuset fik en ottekantet dansepavillon i 1868. [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)
- En musikpavillon blev tilføjet i 1881, og området blev offentligt i 1914. [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)
- Historiske luftfotos dokumenterer Skyttehusets placering i det rekreative fjordlandskab. [Luftfoto af Hurodde og Skyttehuset, 1935–39](https://www.vejlestadsarkiv.dk/dk/se-hoer/maanedens-billede/luftfoto-af-hurodde-og-skyttehuset-1935-39/)
- Skyttehushaven indgår i Vejles historiske havne- og fjordfortælling. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)

- **Hvorfor interessant for en familie:** Musik, dans og en ottekant giver både bevægelse og en let geometrisk opdagelse.
- **Sikkert dokumenteret:** Den historiske dansepavillon var ottekantet og dateres til 1868; områdets senere offentlige rolle er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Bygningsændringer, terminologien ‘Skyttehuset’/‘pavillon’ og den nuværende bygnings præcise kontinuitet skal bekræftes.
- **Kildekritisk vurdering:** Historisk Atlas og Stadsarkiv er gode lokalhistoriske kilder; nutidig tilstand er svagere dokumenteret online.

#### Stedet som spil

- **Konkret observerbar invariant:** den gamle pavillons ottekantede hovedform.
- **Hvorfor permanent/helårsrobust:** Hvis den identificerede bygning er den bevarede ottekant, er hovedmurene permanente.
- **Spilleren skal konkret:** identificere den historiske pavillon og tælle hovedfacaderne rundt om kroppen.
- **Spilleren skal eksplicit ignorere:** tagflader, stolper, trapper, nyere terrassefag og musikpavillonen hvis separat.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop den gamle pavillons ottekantede hovedform; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Udhæng eller tilbygning kan få 8 til at se ud som flere; den korrekte bygning kan forveksles med andre pavilloner.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange hovedsider har den gamle pavillon i Skyttehushaven?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 8 mappes til decimaltallet `8` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `8`
- **Accepterede svarformer, facit først:** `8`, `otte`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `6` → Fortsæt hele vejen rundt – to skrå hjørnesider kan være overset.
- `10` → Tæl hovedfacader, ikke terrasse- eller tagfremspring.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Den gamle ottekant i Skyttehushaven** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: En musikpavillon blev tilføjet i 1881, og området blev offentligt i 1914. [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)
3. Udfør kun denne observation: identificere den historiske pavillon og tælle hovedfacaderne rundt om kroppen; udelad tagflader, stolper, trapper, nyere terrassefag og musikpavillonen hvis separat.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 8 mappes til decimaltallet `8` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`8`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find den gamle pavillons ottekantede hovedform ved Den gamle ottekant i Skyttehushaven; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: identificere den historiske pavillon og tælle hovedfacaderne rundt om kroppen. Ignorér tagflader, stolper, trapper, nyere terrassefag og musikpavillonen hvis separat.
3. **Hint 3 — “Næsten løsningen” — 5 %:** En ottekant har dobbelt så mange sider som en firkant.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste otte sider på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Den historiske dansepavillon ved fjorden bliver håndgribelig, fordi I selv fandt den gamle pavillons ottekantede hovedform.
- `historyFact`: Den ottekantede dansepavillon dateres til 1868. [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Den gamle ottekant i Skyttehushaven`
- `postalCode`: `7100`
- `address`: `Skyttehushaven ved Tirsbæk Strandvej, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — området har offentlig parkhistorie, men aktuel bygnings-/eventadgang er ikke dokumenteret i de brugte kilder. [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `crowding`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; undgå kø, events og blokering af passage; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** parksti og belægning ved pavillon
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentligt parkareal rundt om bygningen, væk fra servering, scene, cykelrute og fjordkant.

**Kandidatspecifik feltcheckliste**

- Identificér entydigt den bevarede ottekantede bygning.
- Bekræft at otte hovedsider kan tælles uden privat/eventområde.
- Kontrollér sti, vand, cykler, arrangementer og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Skyttehuset_%282420%29
- Motiv: et oversigts- eller detaljefoto af den gamle pavillons ottekantede hovedform; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlestadsarkiv.dk/dk/se-hoer/maanedens-billede/luftfoto-af-hurodde-og-skyttehuset-1935-39/
- Motiv: et oversigts- eller detaljefoto af den gamle pavillons ottekantede hovedform; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Skyttehuset
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Skyttehuset_%282420%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: pavillonens ottekant, årstal og offentlig historie

**Kilde 2**
- `title`: Luftfoto af Hurodde og Skyttehuset, 1935–39
- `publisher`: Vejle Stadsarkiv
- `url`: https://www.vejlestadsarkiv.dk/dk/se-hoer/maanedens-billede/luftfoto-af-hurodde-og-skyttehuset-1935-39/
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: historisk placering og anlæg

**Kilde 3**
- `title`: Byvandring ved Vejles havn og fjord
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: fjordrutekontekst


### 24 — Midgårdsbrønden

#### Identitet og prioritering

- **rangnummer:** `24`
- **samlet score:** **74/100** — Børnenær kunst, klart tal og central placering; vandfunktion, legende børn og naboværker kan forstyrre afgrænsningen.
- **stedets officielle eller mest præcise navn:** Midgårdsbrønden
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Torvegade ved Orla Lehmannsgade, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Danmarks tre løveunger
- **kort titel:** Tre løveunger
- **spillerrettet beskrivelse:** Tre små løver er flyttet fra våbenskjoldets alvor til byens leg. Find alle unger, der hører til brønden.
- **tags:** `kunst`, `løver`, `rigsvåben`, `midtby`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 05 Rådhustorvet, 31 brandtavlen, 33 runefliserne og 36 Himmelstigen

#### Dokumenteret historie

**Centrale fakta**

- Midgårdsbrønden blev indviet i 2001. [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)
- Værket viser tre løveunger som børneudgaver af de tre løver i Danmarks rigsvåben. [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)
- De nærliggende værker Englekatten og Bænken kom til i henholdsvis 2002 og 2003. [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)
- Midgårdsbrønden indgår i den officielle historiske byvandring. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Dyrefigurer og heraldik gør national symbolhistorie til en leg i børnehøjde.
- **Sikkert dokumenteret:** Indvielsesår, antal og koblingen til rigsvåbnets tre løver er arkivdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Vanddrift og løse installationer varierer; kunstens fortolkning ud over den dokumenterede reference er åben.
- **Kildekritisk vurdering:** Den specifikke arkivartikel bærer facit; byvandringen er en supplerende, men ikke uafhængig, lokal kilde.

#### Stedet som spil

- **Konkret observerbar invariant:** de tre løveungefigurer omkring brøndskulpturen.
- **Hvorfor permanent/helårsrobust:** Løverne er permanente skulpturdele; vand og midlertidigt byrumsinventar er ikke facit.
- **Spilleren skal konkret:** gå rundt om brøndværket og tælle løvefigurerne.
- **Spilleren skal eksplicit ignorere:** Englekatten, andre dyr, våbenskjolde på skilte, mennesker og vanddyser.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de tre løveungefigurer omkring brøndskulpturen; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** En løve kan skjules af personer/vand, og Englekatten kan blive talt som fjerde dyr.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange løveunger hører til Midgårdsbrønden?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Gå rundt om hele brønden – én unge kan stå på den anden side.
- `4` → Englekatten er et andet værk og tæller ikke med.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Midgårdsbrønden** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Værket viser tre løveunger som børneudgaver af de tre løver i Danmarks rigsvåben. [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)
3. Udfør kun denne observation: gå rundt om brøndværket og tælle løvefigurerne; udelad Englekatten, andre dyr, våbenskjolde på skilte, mennesker og vanddyser.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de tre løveungefigurer omkring brøndskulpturen ved Midgårdsbrønden; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå rundt om brøndværket og tælle løvefigurerne. Ignorér Englekatten, andre dyr, våbenskjolde på skilte, mennesker og vanddyser.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Rigsvåbenets tre løver er her blevet til tre unger.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre løveunger på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En legende omskrivning af rigsvåbnets løver bliver håndgribelig, fordi I selv fandt de tre løveungefigurer omkring brøndskulpturen.
- `historyFact`: De tre løveunger er skabt som børneudgaver af rigsvåbnets tre løver. [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Midgårdsbrønden`
- `postalCode`: `7100`
- `address`: `Torvegade ved Orla Lehmannsgade, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Midgårdsbrønden, Englekatten og Bænken](https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — fast værk i offentligt byrum; eventuelle midlertidige afspærringer skal kontrolleres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `crowding`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; undgå kø, events og blokering af passage; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** gågade/torvebelægning; mulig våd zone
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den tørre belægningsring rundt om værket uden at træde i bassin eller blokere passage.

**Kandidatspecifik feltcheckliste**

- Bekræft tre intakte løver og afgrænsning fra Englekatten.
- Test ved både tændt og slukket vand.
- Kontrollér glathed, crowding, cykler og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29
- Motiv: et oversigts- eller detaljefoto af de tre løveungefigurer omkring brøndskulpturen; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af de tre løveungefigurer omkring brøndskulpturen; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Midgårdsbrønden, Englekatten og Bænken
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Midg%C3%A5rdsbr%C3%B8nden%2C_Englekatten_og_B%C3%A6nken_%282331%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: titel, datering, tre løveunger og naboværker

**Kilde 2**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: byrutekontekst


### 25 — Vildtbanestenene ved den tidligere Amtsgård

#### Identitet og prioritering

- **rangnummer:** `25`
- **samlet score:** **73/100** — Tre individuelt registrerede monumenter giver stærkt facit og kongehistorie; den konkrete nutidige placering/adresse skal bekræftes.
- **stedets officielle eller mest præcise navn:** Vildtbanestenene ved den tidligere Amtsgård
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Foran den tidligere Amtsgård, Damhaven 12, 7100 Vejle; adressen skal feltbekræftes
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Tre kongelige grænsesten
- **kort titel:** Tre sten
- **spillerrettet beskrivelse:** Kongens jagtgrænse er flyttet ind til byen. Find hele den lille gruppe af høje granitsten og tæl dem.
- **tags:** `vildtbane`, `Frederik V`, `grænsesten`, `1760`
- **klynge/rute:** Vejle centrum vest
- **nærliggende kandidater:** 30 Spinderihallerne og 49 Bygningen

#### Dokumenteret historie

**Centrale fakta**

- Sten N12 er registreret med krone, F5, teksten WILD BANE og årstallet 1760. [Vildtbaneafmærkning, Vejle – #1](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%231)
- Sten N15 er en selvstændig registreret vildtbaneafmærkning i den nuværende gruppe. [Vildtbaneafmærkning, Vejle – #2](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%232)
- Sten N11 er den tredje registrerede vildtbaneafmærkning i gruppen. [Vildtbaneafmærkning, Vejle – #3](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%233)
- Vejles officielle byvandring omtaler de flyttede vildtbanesten som et historisk byspor. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Stenene viser, hvordan magt og jagt kunne tegne usynlige grænser i landskabet.
- **Sikkert dokumenteret:** Tre konkrete registerobjekter N12, N15 og N11 er dokumenteret; mindst én bærer F5/WILD BANE/1760.
- **Usikkert, omstridt, sagn eller fortolkning:** Den præcise aktuelle opstilling foran Amtsgården og om alle tre står samlet i 2026 er ikke bekræftet af et dateret nutidsfoto.
- **Kildekritisk vurdering:** De tre poster kommer fra samme autoritative register, men dokumenterer hver sin fysiske sten; byvandringen supplerer gruppens byplacering.

#### Stedet som spil

- **Konkret observerbar invariant:** de tre registrerede vildtbanegrænsesten opstillet som gruppe.
- **Hvorfor permanent/helårsrobust:** Granitstenene er registrerede kulturminder, men kan flyttes ved anlægsarbejde.
- **Spilleren skal konkret:** identificere sten med vildtbaneinskription og tælle hele gruppen.
- **Spilleren skal eksplicit ignorere:** moderne pullerter, kunststen, skiltestolper og løse granitblokke.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de tre registrerede vildtbanegrænsesten opstillet som gruppe; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Byrums-pullerter kan ligne stenene; kun registrerede, inskriberede vildtbanesten tæller.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange gamle vildtbanesten er samlet foran den tidligere Amtsgård?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Se om en tredje inskriberet sten står lidt forskudt fra de to første.
- `4` → Moderne pullerter og andre granitblokke tæller ikke.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Vildtbanestenene ved den tidligere Amtsgård** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Sten N15 er en selvstændig registreret vildtbaneafmærkning i den nuværende gruppe. [Vildtbaneafmærkning, Vejle – #2](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%232)
3. Udfør kun denne observation: identificere sten med vildtbaneinskription og tælle hele gruppen; udelad moderne pullerter, kunststen, skiltestolper og løse granitblokke.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vildtbaneafmærkning, Vejle – #1](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%231)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de tre registrerede vildtbanegrænsesten opstillet som gruppe ved Vildtbanestenene ved den tidligere Amtsgård; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: identificere sten med vildtbaneinskription og tælle hele gruppen. Ignorér moderne pullerter, kunststen, skiltestolper og løse granitblokke.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Registrene beskriver tre forskellige sten: N12, N15 og N11.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre sten på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Frederik 5.s vildtbanegrænse samlet i byen bliver håndgribelig, fordi I selv fandt de tre registrerede vildtbanegrænsesten opstillet som gruppe.
- `historyFact`: En af stenene bærer Frederik 5.s F5, WILD BANE og årstallet 1760. [Vildtbaneafmærkning, Vejle – #1](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%231)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Vildtbanestenene ved den tidligere Amtsgård`
- `postalCode`: `7100`
- `address`: `Foran den tidligere Amtsgård, Damhaven 12, 7100 Vejle; adressen skal feltbekræftes`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vildtbaneafmærkning, Vejle – #1](https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%231)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — byvandringen angiver en byplacering, men ejerskel og præcis gruppeposition skal verificeres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** bybelægning/forplads
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentlig fortovs-/forpladszone uden at gå ind på kontorareal eller kørevej.

**Kandidatspecifik feltcheckliste**

- Find og fotografér N12, N15 og N11 med deres indskrifter.
- Bekræft adresse, ejerskel og at de tre kan observeres samlet.
- Kontrollér trafik, byggerier, GPS og forveksling med pullerter.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%231
- Motiv: et oversigts- eller detaljefoto af de tre registrerede vildtbanegrænsesten opstillet som gruppe; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Slots- og Kulturstyrelsens register eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Slots- og Kulturstyrelsens register / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%232
- Motiv: et oversigts- eller detaljefoto af de tre registrerede vildtbanegrænsesten opstillet som gruppe; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Slots- og Kulturstyrelsens register eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Slots- og Kulturstyrelsens register / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vildtbaneafmærkning, Vejle – #1
- `publisher`: Trap Danmark / Slots- og Kulturstyrelsens register
- `url`: https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%231
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: registerdata for N12 og inskription 1760

**Kilde 2**
- `title`: Vildtbaneafmærkning, Vejle – #2
- `publisher`: Trap Danmark / Slots- og Kulturstyrelsens register
- `url`: https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%232
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: registerdata for N15

**Kilde 3**
- `title`: Vildtbaneafmærkning, Vejle – #3
- `publisher`: Trap Danmark / Slots- og Kulturstyrelsens register
- `url`: https://trap.lex.dk/Vildtbaneafm%C3%A6rkning%2C_Vejle_-_%233
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: registerdata for N11

**Kilde 4**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: samlet nutidig placering i byruten

**Sjælden kildeundtagelse:** Samme registermyndighed bruges tre gange, fordi hver URL er en særskilt genstandsregistrering; gruppens eksistens skal stadig feltbevises.


### 26 — Lille Tycho Brahe

#### Identitet og prioritering

- **rangnummer:** `26`
- **samlet score:** **72/100** — Meget klart objekttal og nysgerrigt perspektiv; deler klynge og terrænrisiko med Tørskind-mand.
- **stedets officielle eller mest præcise navn:** Lille Tycho Brahe
- **postnummer:** `6040`
- **adresse/stedbeskrivelse:** Tørskindvej 98A, 6040 Egtved
- **område/by:** Tørskind
- **foreslået opgavetitel:** To rør mod jord og himmel
- **kort titel:** To rør
- **spillerrettet beskrivelse:** En jordkikkert og en himmelkikkert mødes i ét værk. Tæl de store rør uden at klatre eller kigge ind, hvis underlaget er glat.
- **tags:** `kunst`, `astronomi`, `landskab`, `Tørskind`
- **klynge/rute:** Tørskind Landskabsskulptur
- **nærliggende kandidater:** 10 Tørskind-mand

#### Dokumenteret historie

**Centrale fakta**

- Lille Tycho Brahe består af to store rør, der peger i modsatte retninger – opad og nedad. [Lille Tycho Brahe](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/)
- Værkets navn henviser til astronomen Tycho Brahe og inviterer til at se både himmel og jord. [Lille Tycho Brahe](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/)
- Værket er del af det ni-delte landskabsskulpturanlæg i en tidligere grusgrav. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)
- Anlægget er gratis og døgnåbent, men ikke kørestolsegnet. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)

- **Hvorfor interessant for en familie:** Modsatte retninger skaber en kropslig leg om astronomens blik og landskabets detaljer.
- **Sikkert dokumenteret:** To rør, deres retninger og navnehenvisningen er museumsdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Om man må nærme sig/benytte rørene som kikkert, og hvor glat zonen er, skal afgøres lokalt; berøring er ikke nødvendig.
- **Kildekritisk vurdering:** Museet forvalter værket og er stærk primærkilde; der er ikke fundet en uafhængig katalogpost.

#### Stedet som spil

- **Konkret observerbar invariant:** de to store rør, der peger i modsatte retninger.
- **Hvorfor permanent/helårsrobust:** De to rør er værkets primære permanente bestanddele.
- **Spilleren skal konkret:** identificere begge store rør fra den etablerede sti og sammenligne deres retninger.
- **Spilleren skal eksplicit ignorere:** åbninger som separate dele, drænrør, rækværk og andre skulpturers stål.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de to store rør, der peger i modsatte retninger; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Hvert rør har to ender og kan derfor fejltælles som fire; spørgsmålet siger ‘store rør’.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange store rør udgør Lille Tycho Brahe?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `2`
- **Accepterede svarformer, facit først:** `2`, `to`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `1` → Se på den modsatte retning – et andet rør fortsætter værket.
- `4` → Tæl hele rør, ikke deres åbne ender.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Lille Tycho Brahe** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Værkets navn henviser til astronomen Tycho Brahe og inviterer til at se både himmel og jord. [Lille Tycho Brahe](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/)
3. Udfør kun denne observation: identificere begge store rør fra den etablerede sti og sammenligne deres retninger; udelad åbninger som separate dele, drænrør, rækværk og andre skulpturers stål.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 2 mappes til decimaltallet `2` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`2`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Lille Tycho Brahe](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de to store rør, der peger i modsatte retninger ved Lille Tycho Brahe; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: identificere begge store rør fra den etablerede sti og sammenligne deres retninger. Ignorér åbninger som separate dele, drænrør, rækværk og andre skulpturers stål.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Ét rør peger op, og ét peger ned.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste to rør på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Jean Clareboudts landskabskikkert bliver håndgribelig, fordi I selv fandt de to store rør, der peger i modsatte retninger.
- `historyFact`: Navnet kobler værkets dobbelte blik til astronomen Tycho Brahe. [Lille Tycho Brahe](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Lille Tycho Brahe`
- `postalCode`: `6040`
- `address`: `Tørskindvej 98A, 6040 Egtved`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Lille Tycho Brahe](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — gratis og døgnåbent; terrænet er ikke kørestolsegnet. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `darkness`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** ujævnt grus/jord/græs med hældning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `no`
- **Tilgængelighed — barnevogn:** `no`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et stabilt punkt på den etablerede rute med begge rør synlige; ingen klatring på værket.

**Kandidatspecifik feltcheckliste**

- Find sikker, tør vinkel med begge rør synlige.
- Test at rør ikke tælles som fire ender.
- Registrér hældning, GPS, dagslys og skiltning om berøring.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/
- Motiv: et oversigts- eller detaljefoto af de to store rør, der peger i modsatte retninger; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/
- Motiv: et oversigts- eller detaljefoto af de to store rør, der peger i modsatte retninger; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Lille Tycho Brahe
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/toerskind-guide/lille-tycho-brahe/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: værkets navn, to rør og retninger

**Kilde 2**
- `title`: Robert Jacobsen–Jean Clareboudt Landskabsskulptur
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: anlæg, adresse, adgang og terræn

**Sjælden kildeundtagelse:** Objekt- og driftskilder er fra samme museum; antal rør er dog en enkel fysisk invariant, som feltkontrolleres.


### 27 — Skolestenen ved Kellers Minde

#### Identitet og prioritering

- **rangnummer:** `27`
- **samlet score:** **71/100** — Et entydigt ord findes kun ved nær aflæsning og åbner en vigtig socialhistorie; institutionens historie kræver varsom sprogbrug.
- **stedets officielle eller mest præcise navn:** Skolestenen ved Kellers Minde
- **postnummer:** `7080`
- **adresse/stedbeskrivelse:** H.O. Wildenskovsvej 10, 7080 Børkop
- **område/by:** Brejning
- **foreslået opgavetitel:** Skole og hvad?
- **kort titel:** HJEM
- **spillerrettet beskrivelse:** En gammel pædagogisk sætning er bevaret ved museet. Find stenen og udfyld præcis det ord, der følger efter ‘Skole og’.
- **tags:** `Kellers Minde`, `skole`, `socialhistorie`, `inskription`
- **klynge/rute:** Børkop–Brejning
- **nærliggende kandidater:** 18 Your Perception og 29 Ene Øjesten

#### Dokumenteret historie

**Centrale fakta**

- Den tidligere skolebygning blev opført i 1901 i røde sten med grønne tage. [Skolen](https://www.kellersminde.dk/bygningerne/skolen)
- Skolestenen bærer teksten om at opdrage barnet ‘i Skole og Hjem’. [Skolen](https://www.kellersminde.dk/bygningerne/skolen)
- Stenen står nu ved indgangen til Kellers Minde. [Skolen](https://www.kellersminde.dk/bygningerne/skolen)
- Kellers Minde indgår i en gratis, cirka tre kilometer lang historisk rute med 15 formidlingsstop. [Historisk vandrerute ved Kellers Minde](https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491)

- **Hvorfor interessant for en familie:** Børn kan sammenligne deres egen skole/hjem-verden med et historisk institutionsideal.
- **Sikkert dokumenteret:** Byggeår, ordlyd og stenens flytning til museumsindgangen er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Historiske betegnelser om beboere og handicap kan være forældede eller stigmatiserende; belønningsteksten skal redaktionelt sensitivitetstjekkes.
- **Kildekritisk vurdering:** Kellers Mindes egen bygningshistorie er den direkte kildeside; VisitVejle bekræfter den offentlige rutes struktur.

#### Stedet som spil

- **Konkret observerbar invariant:** ordet HJEM i den bevarede skoleindskrift.
- **Hvorfor permanent/helårsrobust:** Teksten er hugget i en bevaret sten, men mos/slid kan svække læsbarhed.
- **Spilleren skal konkret:** finde skolestenen ved indgangen og læse det manglende ord.
- **Spilleren skal eksplicit ignorere:** museets navn, nyere skilte, hele resten af citatet og ord på bygningen.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop ordet HJEM i den bevarede skoleindskrift; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Gammel typografi kan få H til at ligne et andet tegn; stenens flyttede placering kan være uklar.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `freeText`
- **Præcist spillerrettet spørgsmål:** “Læs indskriften på skolestenen: ‘Her opdrages Barnet i Skole og ___’. Hvilket ord mangler?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `HJEM`
- **Accepterede svarformer, facit først:** `HJEM`, `Hjem`, `hjem`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `HEJM` → Læs de to midterste bogstaver i rækkefølge – moderne stavning er også den indhuggede.
- `BARN` → Det ord står tidligere i sætningen; find ordene lige efter ‘Skole og’. 

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Skolestenen ved Kellers Minde** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Skolestenen bærer teksten om at opdrage barnet ‘i Skole og Hjem’. [Skolen](https://www.kellersminde.dk/bygningerne/skolen)
3. Udfør kun denne observation: finde skolestenen ved indgangen og læse det manglende ord; udelad museets navn, nyere skilte, hele resten af citatet og ord på bygningen.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`HJEM`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Skolen](https://www.kellersminde.dk/bygningerne/skolen)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find ordet HJEM i den bevarede skoleindskrift ved Skolestenen ved Kellers Minde; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde skolestenen ved indgangen og læse det manglende ord. Ignorér museets navn, nyere skilte, hele resten af citatet og ord på bygningen.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Det er stedet, hvor familien normalt bor.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste hjem på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Kellers institutionshistorie skrevet i sten bliver håndgribelig, fordi I selv fandt ordet HJEM i den bevarede skoleindskrift.
- `historyFact`: Stenens sætning forbinder ‘Skole og Hjem’; den står nu ved Kellers Mindes indgang. [Skolen](https://www.kellersminde.dk/bygningerne/skolen)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Skolestenen ved Kellers Minde`
- `postalCode`: `7080`
- `address`: `H.O. Wildenskovsvej 10, 7080 Børkop`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Skolen](https://www.kellersminde.dk/bygningerne/skolen)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — den historiske rute beskrives som gratis; museumsbygningens tider er ikke nødvendige, hvis stenen er ude. [Historisk vandrerute ved Kellers Minde](https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`crowding`]
- **Foreløbige sikkerhedsnoter:** undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** adgangsbelægning ved museum; detaljer ukendte
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den offentlige indgangszone med fri passage og respekt for museumsdrift.

**Kandidatspecifik feltcheckliste**

- Bekræft at stenen står udendørs og kan læses uden åbningstid.
- Test typografi, mos, lys og facitvarianter.
- Få et sensitivitetstjek af den historiske ramme; registrér GPS og adgang.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.kellersminde.dk/bygningerne/skolen
- Motiv: et oversigts- eller detaljefoto af ordet HJEM i den bevarede skoleindskrift; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Kellers Minde eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Kellers Minde / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491
- Motiv: et oversigts- eller detaljefoto af ordet HJEM i den bevarede skoleindskrift; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Skolen
- `publisher`: Kellers Minde
- `url`: https://www.kellersminde.dk/bygningerne/skolen
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: skolebygning, indskrift og stenens nuværende placering

**Kilde 2**
- `title`: Historisk vandrerute ved Kellers Minde
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: adresse, offentlig rute og 15 stop


### 28 — Solhjul

#### Identitet og prioritering

- **rangnummer:** `28`
- **samlet score:** **70/100** — Monumental og unik form med stærk kunstnerkilde; lille hældning er svær at se, og rundkørslen gør sikkerheden ikke-forhandlingsbar.
- **stedets officielle eller mest præcise navn:** Solhjul
- **postnummer:** `7323`
- **adresse/stedbeskrivelse:** Rundkørslen ved Vejlevej/Herningvej i Give; observation kun fra ydersiden
- **område/by:** Give
- **foreslået opgavetitel:** Hjulet der læner sig ind
- **kort titel:** Ind mod midten
- **spillerrettet beskrivelse:** Det enorme hjul står ikke helt lodret. Afgør hældningen fra ydersiden – midterøen må aldrig betrædes.
- **tags:** `kunst`, `Give`, `oldtid`, `geometri`
- **klynge/rute:** Give kunst og Hærvej
- **nærliggende kandidater:** 21 vejviseren som udflugtsstop; ingen sikker gåkobling angivet

#### Dokumenteret historie

**Centrale fakta**

- Solhjul er cirka 11 meter højt over terræn og udført i glas og stål. [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)
- De store ringe hælder syv grader ind mod værkets centrum. [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)
- Værket er inspireret af to cirka 5.000 år gamle hjulfund og blev indviet 12. maj 2015. [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)
- Give formidles som skulpturby med kunst i offentlige udearealer. [Skulpturbyen Give – Danmarks største galleri i det fri](https://www.visitvejle.dk/vejle/planlaeg-ferien/skulpturbyen-give-danmarks-stoerste-galleri-i-det-fri-gdk1077759)

- **Hvorfor interessant for en familie:** Skala, balance og et næsten usynligt ‘snyd’ i geometrien inviterer til fælles iagttagelse.
- **Sikkert dokumenteret:** Højde, materialer, syv graders indadhældning og inspirationskilder er dokumenteret af værkets formidlingsside.
- **Usikkert, omstridt, sagn eller fortolkning:** Om hældningen kan ses tydeligt fra et lovligt fortov uden telelinse er ubekræftet; ingen opgave må lokke ind i rundkørslen.
- **Kildekritisk vurdering:** Skulpturby Give er værknær hovedkilde; VisitVejle støtter kun den offentlige kunstkontekst, ikke hældningsfacit.

#### Stedet som spil

- **Konkret observerbar invariant:** stålringenes dokumenterede syv graders hældning ind mod centrum.
- **Hvorfor permanent/helårsrobust:** Hældningen er konstruktiv for de store stål-/glasringe.
- **Spilleren skal konkret:** sammenligne toppen og bunden af ringene fra et markeret, sikkert ydre udsigtspunkt.
- **Spilleren skal eksplicit ignorere:** vejens fald, perspektiv i kamera, små stag og trafikskilte.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop stålringenes dokumenterede syv graders hældning ind mod centrum; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Perspektiv kan få hældningen til at vende; hvis den ikke er aflæselig uden at krydse vej, skal kandidaten udgå.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Betragt Solhjul fra et sikkert fortov uden for rundkørslen. Hvilken vej hælder de store ringe?”
- **Svarmuligheder ved `singleChoice`:** `Ind mod midten` **(korrekt)**; `Ud fra midten`; `De står helt lodret`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Ind mod midten`
- **Accepterede svarformer, facit først:** `Ind mod midten`, `indad`, `ind mod centrum`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Ud fra midten` → Sammenlign ringens top med dens fod i forhold til centrum.
- `De står helt lodret` → Hældningen er lille; brug de lodrette bygninger/master i baggrunden som kontrol.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Solhjul** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: De store ringe hælder syv grader ind mod værkets centrum. [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)
3. Udfør kun denne observation: sammenligne toppen og bunden af ringene fra et markeret, sikkert ydre udsigtspunkt; udelad vejens fald, perspektiv i kamera, små stag og trafikskilte.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Ind mod midten`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find stålringenes dokumenterede syv graders hældning ind mod centrum ved Solhjul; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: sammenligne toppen og bunden af ringene fra et markeret, sikkert ydre udsigtspunkt. Ignorér vejens fald, perspektiv i kamera, små stag og trafikskilte.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Toppen af hver ring søger lidt nærmere værkets centrum end foden.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste ind mod midten på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et monumentalt solhjul inspireret af oldtidsfund bliver håndgribelig, fordi I selv fandt stålringenes dokumenterede syv graders hældning ind mod centrum.
- `historyFact`: Ringene er konstrueret med en syv graders hældning ind mod centrum. [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Solhjul`
- `postalCode`: `7323`
- `address`: `Rundkørslen ved Vejlevej/Herningvej i Give; observation kun fra ydersiden`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [11 meter højt SOLHJUL i Give](https://www.skulpturby.dk/solhjul)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja til visning fra offentligt byrum uden for rundkørslen; midterøen er ikke et godkendt besøgsareal. [Skulpturbyen Give – Danmarks største galleri i det fri](https://www.visitvejle.dk/vejle/planlaeg-ferien/skulpturbyen-give-danmarks-stoerste-galleri-i-det-fri-gdk1077759)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** fortov/cykelsti ved trafikeret rundkørsel
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et feltgodkendt ydre fortovspunkt med rækværk/rabat og klart nej til at krydse kørebaner.

**Kandidatspecifik feltcheckliste**

- Find mindst ét punkt hvor indadhældning ses uden vej-/cykelkryds.
- Solve-test uden zoom og under flere lysforhold.
- Kortlæg trafik, GPS, fortovsbredde og formulér eksplicit sikkerhedsstop.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.skulpturby.dk/solhjul
- Motiv: et oversigts- eller detaljefoto af stålringenes dokumenterede syv graders hældning ind mod centrum; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Skulpturby Give eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Skulpturby Give / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/skulpturbyen-give-danmarks-stoerste-galleri-i-det-fri-gdk1077759
- Motiv: et oversigts- eller detaljefoto af stålringenes dokumenterede syv graders hældning ind mod centrum; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: 11 meter højt SOLHJUL i Give
- `publisher`: Skulpturby Give
- `url`: https://www.skulpturby.dk/solhjul
- `kind`: `architectPrimary`
- `accessed`: `2026-08-03`
- `supports`: mål, materiale, syv graders hældning, inspiration og indvielse

**Kilde 2**
- `title`: Skulpturbyen Give – Danmarks største galleri i det fri
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/skulpturbyen-give-danmarks-stoerste-galleri-i-det-fri-gdk1077759
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: offentlig kunstkontekst i Give


### 29 — Ene Øjesten

#### Identitet og prioritering

- **rangnummer:** `29`
- **samlet score:** **69/100** — Meget børnevenligt og visuelt særpræg; træværk kan repareres, og skovrute/klatring skal afgrænses sikkert.
- **stedets officielle eller mest præcise navn:** Ene Øjesten
- **postnummer:** `7080`
- **adresse/stedbeskrivelse:** Skovstien ved Børkop Vandmølle, nær Vandmøllevej 4, 7080 Børkop; præcis rute skal feltfastlægges
- **område/by:** Børkop
- **foreslået opgavetitel:** Troldens stenøje
- **kort titel:** Et hul
- **spillerrettet beskrivelse:** Trolden vogter noget, man både kan se på og se igennem. Undersøg stenen med øjnene – klatring er ikke nødvendig.
- **tags:** `trold`, `genbrugskunst`, `skov`, `Børkop`
- **klynge/rute:** Børkop–Brejning
- **nærliggende kandidater:** 11 Børkop Vandmølle; 18 og 27 i Brejning

#### Dokumenteret historie

**Centrale fakta**

- Ene Øjesten er en troldeskulptur fra 2021, bygget af genbrugstræ. [Trolden Ene Øjesten](https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235)
- Trolden holder en flad sten med et hul, der fungerer som dens særlige ‘øjesten’. [Ene Øjesten](https://www.thomasdambo.com/works/ene-ojesten)
- Skulpturen findes på en skovrute i området ved Børkop Vandmølle. [Trolden Ene Øjesten](https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235)

- **Hvorfor interessant for en familie:** En stor trold giver umiddelbar fantasi, mens et enkelt fysisk hul skaber et sikkert facit.
- **Sikkert dokumenteret:** År, genbrugsmateriale, kunstner og stenen med gennemgående hul er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Skulpturens aktuelle reparationsstand og om stenen altid sidder samme sted er ikke onlinegaranteret.
- **Kildekritisk vurdering:** Kunstnerens side er nær-primær på motivet; VisitVejle supplerer med lokal adgang, men præcis sti kræver feltarbejde.

#### Stedet som spil

- **Konkret observerbar invariant:** det gennemgående hul i den flade sten, som trolden holder.
- **Hvorfor permanent/helårsrobust:** Stenen og hullet er et centralt identitetstræk, men træskulpturer vedligeholdes og kan midlertidigt afspærres.
- **Spilleren skal konkret:** finde stenen i troldens hænder og identificere dens midte uden berøring.
- **Spilleren skal eksplicit ignorere:** huller mellem træbrædder, troldens øjenhuler, knaster og skovens åbninger.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det gennemgående hul i den flade sten, som trolden holder; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Spillere kan svare ‘øje’, fordi navnet leder dem; spørgsmålet skal fastholde den fysiske sten.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvad er der midt i den flade sten, som Ene Øjesten holder?”
- **Svarmuligheder ved `singleChoice`:** `Et hul` **(korrekt)**; `En stjerne`; `Et ansigt`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Et hul`
- **Accepterede svarformer, facit først:** `Et hul`, `hul`, `et gennemgående hul`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `En stjerne` → Se på stenens virkelige åbning, ikke en tænkt magisk form.
- `Et ansigt` → Ansigtet tilhører trolden; spørgsmålet handler om stenen i hænderne.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Ene Øjesten** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Trolden holder en flad sten med et hul, der fungerer som dens særlige ‘øjesten’. [Ene Øjesten](https://www.thomasdambo.com/works/ene-ojesten)
3. Udfør kun denne observation: finde stenen i troldens hænder og identificere dens midte uden berøring; udelad huller mellem træbrædder, troldens øjenhuler, knaster og skovens åbninger.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Et hul`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Trolden Ene Øjesten](https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det gennemgående hul i den flade sten, som trolden holder ved Ene Øjesten; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde stenen i troldens hænder og identificere dens midte uden berøring. Ignorér huller mellem træbrædder, troldens øjenhuler, knaster og skovens åbninger.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Du kan se landskabet gennem det, der er midt i stenen.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste et hul på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Thomas Dambos genbrugstrold med en magisk sten bliver håndgribelig, fordi I selv fandt det gennemgående hul i den flade sten, som trolden holder.
- `historyFact`: Ene Øjesten blev bygget af genbrugstræ i 2021. [Trolden Ene Øjesten](https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Ene Øjesten`
- `postalCode`: `7080`
- `address`: `Skovstien ved Børkop Vandmølle, nær Vandmøllevej 4, 7080 Børkop; præcis rute skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Trolden Ene Øjesten](https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — VisitVejle anviser skovområdet, men præcis offentlig sti, helårsadgang og driftsstatus skal verificeres. [Trolden Ene Øjesten](https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `darkness`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** skovsti med rødder, mudder og mulig hældning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den etablerede sti foran trolden; ingen klatring på værk, skrænt eller sten.

**Kandidatspecifik feltcheckliste**

- Gå hele lovlige rute og registrér præcist GPS-startpunkt.
- Kontrollér værkets tilstand, skiltning og udsyn til stenen.
- Test mudder, hældning, cykler, mobildækning og anti-klatretekst.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235
- Motiv: et oversigts- eller detaljefoto af det gennemgående hul i den flade sten, som trolden holder; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.thomasdambo.com/works/ene-ojesten
- Motiv: et oversigts- eller detaljefoto af det gennemgående hul i den flade sten, som trolden holder; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Thomas Dambo eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Thomas Dambo / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Trolden Ene Øjesten
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/trolden-ene-oejesten-gdk1141235
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: år, materiale og praktisk område

**Kilde 2**
- `title`: Ene Øjesten
- `publisher`: Thomas Dambo
- `url`: https://www.thomasdambo.com/works/ene-ojesten
- `kind`: `architectPrimary`
- `accessed`: `2026-08-03`
- `supports`: kunstnerens værkbeskrivelse og stenen med hul


### 30 — Spinderihallerne

#### Identitet og prioritering

- **rangnummer:** `30`
- **samlet score:** **68/100** — Stærk industrihistorie og nemt tekstfacit, men selve skiltets ordlyd/placering er endnu kun en felt-hypotese.
- **stedets officielle eller mest præcise navn:** Spinderihallerne
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Spinderigade 11E, 7100 Vejle
- **område/by:** Vejle Midtby vest
- **foreslået opgavetitel:** Navnet på tekstilbyen
- **kort titel:** SPINDERIHALLERNE
- **spillerrettet beskrivelse:** En hel industribygning har fået sit gamle arbejde med ind i det nye navn. Find hovedindgangen og skriv det lange ord på facaden.
- **tags:** `tekstil`, `industri`, `transformation`, `midtby`
- **klynge/rute:** Vejle centrum vest
- **nærliggende kandidater:** 25 vildtbanestenene og 49 Bygningen

#### Dokumenteret historie

**Centrale fakta**

- De Danske Bomuldsspinderiers anlæg ved Vardevej/Spinderigade voksede frem som del af Vejles tekstilindustri. [De Danske Bomuldsspinderier, Vardevej (Spinderihallerne)](https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29)
- De markante industribygninger knyttes til etableringen i 1896. [De Danske Bomuldsspinderier, Vardevej (Spinderihallerne)](https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29)
- Spinderihallerne er omdannet til et kreativt kultur- og erhvervsmiljø med den historiske industrikarakter bevaret. [Spinderihallerne i Vejle](https://realdania.dk/projekter/spinderihallerne-i-vejle)
- Den officielle byvandring forbinder området med fortællingen om Vejle som tekstilby. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Det lange ord kan deles i ‘spinderi’ og ‘haller’ og gør byens industrielle identitet læsbar.
- **Sikkert dokumenteret:** Anlæggets tekstilhistorie, datering og nutidige transformation er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Det foreslåede facit forudsætter, at det præcise permanente facadeskilt ‘SPINDERIHALLERNE’ er synligt fra offentlig ankomst; det er ikke dokumenteret i tekstkilderne.
- **Kildekritisk vurdering:** Historien er stærkt underbygget af arkiv og Realdania; selve invariantens nutidige typografi kræver feltfoto og må ikke publiceres før det.

#### Stedet som spil

- **Konkret observerbar invariant:** det permanente navneskilt på hovedfacaden ved den offentlige ankomst.
- **Hvorfor permanent/helårsrobust:** Et bygningsnavn ved hovedindgang er normalt stabilt, men branding/skiltning kan ændres.
- **Spilleren skal konkret:** finde den officielle hovedindgang og afskrive hele navnet fra det permanente bygningsskilt.
- **Spilleren skal eksplicit ignorere:** eventplakater, virksomhedslogoer, vejskilte og ord inde i bygningen.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det permanente navneskilt på hovedfacaden ved den offentlige ankomst; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Der kan være flere indgange og flere versioner af navnet; store/små bogstaver og mellemrum skal registreres.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `freeText`
- **Præcist spillerrettet spørgsmål:** “Hvilket langt ord står som navn på de gamle industribygninger ved hovedindgangen?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `SPINDERIHALLERNE`
- **Accepterede svarformer, facit først:** `SPINDERIHALLERNE`, `Spinderihallerne`, `spinderihallerne`, `SPINDERI HALLERNE`, `Spinderi hallerne`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `SPINDERIHALERNE` → Det lange ord har dobbelt l i ‘hallerne’.
- `BOMULDSSPINDERIET` → Det er den historiske funktion; skriv det nutidige navn på hovedindgangen.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Spinderihallerne** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: De markante industribygninger knyttes til etableringen i 1896. [De Danske Bomuldsspinderier, Vardevej (Spinderihallerne)](https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29)
3. Udfør kun denne observation: finde den officielle hovedindgang og afskrive hele navnet fra det permanente bygningsskilt; udelad eventplakater, virksomhedslogoer, vejskilte og ord inde i bygningen.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`SPINDERIHALLERNE`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [De Danske Bomuldsspinderier, Vardevej (Spinderihallerne)](https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det permanente navneskilt på hovedfacaden ved den offentlige ankomst ved Spinderihallerne; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde den officielle hovedindgang og afskrive hele navnet fra det permanente bygningsskilt. Ignorér eventplakater, virksomhedslogoer, vejskilte og ord inde i bygningen.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Ordet består af ‘spinderi’ + ‘hallerne’ skrevet sammen.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste spinderihallerne på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Bomuldsindustriens store haller genbrugt til kultur bliver håndgribelig, fordi I selv fandt det permanente navneskilt på hovedfacaden ved den offentlige ankomst.
- `historyFact`: Anlægget er omdannet, så de gamle industribygninger kan bruges til kreative og kulturelle formål. [Spinderihallerne i Vejle](https://realdania.dk/projekter/spinderihallerne-i-vejle)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Spinderihallerne`
- `postalCode`: `7100`
- `address`: `Spinderigade 11E, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [De Danske Bomuldsspinderier, Vardevej (Spinderihallerne)](https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — centeret er besøgsrettet, men en facadeobservation uafhængig af åbningstid er ikke dokumenteret i kilderne. [Spinderihallerne i Vejle](https://realdania.dk/projekter/spinderihallerne-i-vejle)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** bybelægning/gårdrum; mulig brosten
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentlig ankomstforplads ved den dokumenterede hovedindgang, uden at stå i køre-/varezone.

**Kandidatspecifik feltcheckliste**

- Bekræft eksakt permanent ordlyd og hovedindgang med foto.
- Kortlæg offentlig facadezone, åbningstid og leverancetrafik.
- Test stavning, GPS, brosten og alternative skilte; forkast hvis navnet er variabelt.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29
- Motiv: et oversigts- eller detaljefoto af det permanente navneskilt på hovedfacaden ved den offentlige ankomst; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://realdania.dk/projekter/spinderihallerne-i-vejle
- Motiv: et oversigts- eller detaljefoto af det permanente navneskilt på hovedfacaden ved den offentlige ankomst; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Realdania eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Realdania / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: De Danske Bomuldsspinderier, Vardevej (Spinderihallerne)
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/De_Danske_Bomuldsspinderier%2C_Vardevej_%28Spinderihallerne%29_%281984%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: industrihistorie, bygninger og datering

**Kilde 2**
- `title`: Spinderihallerne i Vejle
- `publisher`: Realdania
- `url`: https://realdania.dk/projekter/spinderihallerne-i-vejle
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: transformation og nutidig identitet

**Kilde 3**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: byrutekontekst


### 31 — Brandtavlen for katastrofen i 1786

#### Identitet og prioritering

- **rangnummer:** `31`
- **samlet score:** **67/100** — Præcist historisk år og god mikrolokation; tavlens aktuelle placering, permanente status og ordlyd kræver feltbevis.
- **stedets officielle eller mest præcise navn:** Brandtavlen for katastrofen i 1786
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Passagen mellem parkeringsarealet ved Vedelsgade og Nørregade, 7100 Vejle; præcis facade skal feltfastlægges
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Året da midtbyen brændte
- **kort titel:** 1786
- **spillerrettet beskrivelse:** En lille passage fortæller om den dag, hvor byen ændrede sig voldsomt. Find tavlen og aflæs katastrofens år.
- **tags:** `brand`, `1786`, `byhistorie`, `inskription`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 08 Kanonkuglehuset, 12 Den Smidtske Gård, 32 vejmontrerne og 33 runefliserne

#### Dokumenteret historie

**Centrale fakta**

- Den officielle byvandring peger på en tavle i passagen fra Vedelsgade til gågaden om brand- og eksplosionskatastrofen i 1786. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- En stor brand ramte Vejle i 1786 og indgår som et afgørende brud i købstadens historie. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)
- Det nuværende rådhus er senere, fra 1879, og skal ikke forveksles med brandens årstal. [Vejle Rådhus](https://historiskatlas.dk/Vejle_R%C3%A5dhus_%282394%29)

- **Hvorfor interessant for en familie:** Et enkelt årstal kan sammenholdes med husene omkring og åbne en samtale om, hvorfor ældre bydele ser ud som de gør.
- **Sikkert dokumenteret:** Branden i 1786 og en formidlingstavle på byruten er kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Tavlens helt præcise nutidige placering, om ‘eksplosion’ og ‘brand’ står som én begivenhed, og andre årstal på tavlen skal kontrolleres.
- **Kildekritisk vurdering:** Historien har to lokale kilder; den konkrete tavle er kun beskrevet af den officielle byvandring og kan være flyttet.

#### Stedet som spil

- **Konkret observerbar invariant:** det firecifrede årstal 1786 på den permanente minde-/informationstavle.
- **Hvorfor permanent/helårsrobust:** En fastgjort historietavle kan være flerårig, men er mindre robust end indhugget murværk og skal versionskontrolleres.
- **Spilleren skal konkret:** finde den specificerede tavle og aflæse året knyttet direkte til katastrofen.
- **Spilleren skal eksplicit ignorere:** adressedata, copyrightår, andre historiske år og parkeringsskilte.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det firecifrede årstal 1786 på den permanente minde-/informationstavle; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Tavlen kan indeholde flere årstal; spilleren skal matche 1786 med brand/eksplosion, ikke bare finde et tal.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Find tavlen om den store brand og eksplosion. Hvilket firecifret årstal står som katastrofeåret?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `4`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Aflæs det trykte/indhuggede tal fra venstre mod højre. Cifrene mappes én-til-én som `1`→`1`, `7`→`7`, `8`→`8`, `6`→`6` og samles uden mellemrum til `1786`. Kodelængden er 4, og eventuelle foranstillede nuller skulle bevares.
- **Kanonisk facit:** `1786`
- **Accepterede svarformer, facit først:** `1786`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `1879` → Det er rådhusets byggeår. Find året ved selve brand-/eksplosionsteksten.
- `1864` → Det år hører til krigen; denne katastrofe skete i 1700-tallet.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Brandtavlen for katastrofen i 1786** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: En stor brand ramte Vejle i 1786 og indgår som et afgørende brud i købstadens historie. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)
3. Udfør kun denne observation: finde den specificerede tavle og aflæse året knyttet direkte til katastrofen; udelad adressedata, copyrightår, andre historiske år og parkeringsskilte.
4. Anvend den eksplicitte regel: Aflæs det trykte/indhuggede tal fra venstre mod højre. Cifrene mappes én-til-én som `1`→`1`, `7`→`7`, `8`→`8`, `6`→`6` og samles uden mellemrum til `1786`. Kodelængden er 4, og eventuelle foranstillede nuller skulle bevares.
5. Observation og regel giver facit **`1786`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det firecifrede årstal 1786 på den permanente minde-/informationstavle ved Brandtavlen for katastrofen i 1786; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde den specificerede tavle og aflæse året knyttet direkte til katastrofen. Ignorér adressedata, copyrightår, andre historiske år og parkeringsskilte.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Koden begynder med 17 og ender på 86.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste 1786 på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Brand- og eksplosionskatastrofen der ændrede Vejle bliver håndgribelig, fordi I selv fandt det firecifrede årstal 1786 på den permanente minde-/informationstavle.
- `historyFact`: Den store brand i 1786 er et centralt brud i Vejles købstadshistorie. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Brandtavlen for katastrofen i 1786`
- `postalCode`: `7100`
- `address`: `Passagen mellem parkeringsarealet ved Vedelsgade og Nørregade, 7100 Vejle; præcis facade skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — passagen omtales på en offentlig byvandring, men konkret ejerskel og døgnadgang skal verificeres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `darkness`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; publicér kun til dagslys, medmindre belysning er fysisk godkendt; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** bybelægning i passage
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den åbne passagezone med ryggen mod væggen og uden at blokere biler/cykler.

**Kandidatspecifik feltcheckliste**

- Find tavlen og registrér fuld ordlyd, alle tal og fastgørelse.
- Bekræft lovlig døgnpassage og belysning.
- Test trafik, GPS, læsbarhed og facitafgrænsning.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af det firecifrede årstal 1786 på den permanente minde-/informationstavle; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- Motiv: et oversigts- eller detaljefoto af det firecifrede årstal 1786 på den permanente minde-/informationstavle; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: tavlens placering og katastrofeåret

**Kilde 2**
- `title`: Vejle Købstad
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: branden i 1786 og byhistorisk betydning

**Kilde 3**
- `title`: Vejle Rådhus
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_R%C3%A5dhus_%282394%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: afgrænsning fra rådhusets senere årstal


### 32 — Glasmontrerne over middelaldervejen

#### Identitet og prioritering

- **rangnummer:** `32`
- **samlet score:** **66/100** — Et stærkt lag-på-lag byspor med præcist tal; glas kan være tildækket, glat eller ombygget.
- **stedets officielle eller mest præcise navn:** Glasmontrerne over middelaldervejen
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Nørregade i gågadeforløbet, 7100 Vejle; præcist segment skal feltfastlægges
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Tre vinduer ned i gaden
- **kort titel:** Tre glasfelter
- **spillerrettet beskrivelse:** Under jeres fødder ligger en ældre gade. Find alle de særlige vinduer i belægningen, men træd ikke på dem hvis de er glatte.
- **tags:** `middelalder`, `arkæologi`, `gågade`, `glas`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 12 Den Smidtske Gård, 31 brandtavlen og 33 runefliserne

#### Dokumenteret historie

**Centrale fakta**

- Ved gågadens renovering 1999–2001 blev en omtrent 700 år gammel stenlagt vej fundet. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Tre glasmontrer/-felter blev indrettet, så den gamle vej kan ses under den moderne belægning. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Vejle udviklede sig som middelalderlig købstad omkring de lave ådale og gadeforløb. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)

- **Hvorfor interessant for en familie:** Det bogstavelige kig ned gennem tiden gør byarkæologi sanselig.
- **Sikkert dokumenteret:** Fund under 1999–2001-renoveringen, omtrent alder og antal montrer er beskrevet af den officielle byvandring.
- **Usikkert, omstridt, sagn eller fortolkning:** Nøjagtig placering, aktuel gennemsigtighed og om alle tre stadig er eksponerede i 2026 er ikke uafhængigt dokumenteret.
- **Kildekritisk vurdering:** Kun én konkret onlinekilde beskriver montrerne; byhistoriekilden støtter kontekst, ikke facit. Kandidaten er betinget af feltbevis.

#### Stedet som spil

- **Konkret observerbar invariant:** de tre faste glasmontrer/felter, der viser den gamle vejbelægning.
- **Hvorfor permanent/helårsrobust:** Nedbyggede glasfelter er normalt permanente, men gågaderenovering kan fjerne eller dække dem.
- **Spilleren skal konkret:** følge det definerede gågadesegment og tælle nedbyggede glasfelter med synlig gammel stenvej.
- **Spilleren skal eksplicit ignorere:** butiksvinduer, afløbsriste, almindelige kældervinduer, løse glasplader og refleksioner.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de tre faste glasmontrer/felter, der viser den gamle vejbelægning; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Et felt kan bestå af flere ruder; der skal tælles installationer, ikke enkelte glaspaneler.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange glasfelter i gågaden lader dig se ned på den gamle stenvej?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `3`
- **Accepterede svarformer, facit først:** `3`, `tre`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2` → Fortsæt hele det feltgodkendte segment – én montre kan ligge forskudt.
- `4` → Tæl komplette installationer, ikke ruderne i én ramme.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Glasmontrerne over middelaldervejen** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Tre glasmontrer/-felter blev indrettet, så den gamle vej kan ses under den moderne belægning. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
3. Udfør kun denne observation: følge det definerede gågadesegment og tælle nedbyggede glasfelter med synlig gammel stenvej; udelad butiksvinduer, afløbsriste, almindelige kældervinduer, løse glasplader og refleksioner.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 3 mappes til decimaltallet `3` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`3`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de tre faste glasmontrer/felter, der viser den gamle vejbelægning ved Glasmontrerne over middelaldervejen; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: følge det definerede gågadesegment og tælle nedbyggede glasfelter med synlig gammel stenvej. Ignorér butiksvinduer, afløbsriste, almindelige kældervinduer, løse glasplader og refleksioner.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Byvandringen beskriver en trio af kig ned til vejen.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tre glasfelter på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Den middelalderlige stenvej under nutidens gågade bliver håndgribelig, fordi I selv fandt de tre faste glasmontrer/felter, der viser den gamle vejbelægning.
- `historyFact`: Vejen blev fundet under gågaderenoveringen 1999–2001 og vurderes til omtrent 700 år. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Glasmontrerne over middelaldervejen`
- `postalCode`: `7100`
- `address`: `Nørregade i gågadeforløbet, 7100 Vejle; præcist segment skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — gågade, men glasfelternes tilstand og eventuelle arbejder skal kontrolleres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`cyclePath`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** placér ophold uden for cykelflow; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** gågadebelægning med potentielt glatte glasfelter
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** ved siden af hvert glasfelt i gågadens gangzone; ingen opfordring til at stå på glasset.

**Kandidatspecifik feltcheckliste**

- Geolokalisér og fotografér præcis tre installationer.
- Afklar om felter eller ruder tælles og kontrollér gennemsigtighed.
- Test glathed, cykler, crowding, GPS og anlægsplaner.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af de tre faste glasmontrer/felter, der viser den gamle vejbelægning; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- Motiv: et oversigts- eller detaljefoto af de tre faste glasmontrer/felter, der viser den gamle vejbelægning; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: fundet, dateringen og de tre glasfelter

**Kilde 2**
- `title`: Vejle Købstad
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: middelalderlig bykontekst

**Sjælden kildeundtagelse:** Facit 3 hviler på den officielle byvandring; den sjældne undtagelse er kun acceptabel i kladden, fordi hvert glasfelt skal fotograferes og geolokaliseres før publicering.


### 33 — Runefliserne i Vejles gågade

#### Identitet og prioritering

- **rangnummer:** `33`
- **samlet score:** **65/100** — God skattejagt og stærk regional runeidentitet; lang strækning, slid, torveinventar og tællefejl gør den feltkrævende.
- **stedets officielle eller mest præcise navn:** Runefliserne i Vejles gågade
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Gågadeforløbet Søndergade–Torvegade–Nørregade, 7100 Vejle; fuld strækning skal feltfastlægges
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Tretten runer i belægningen
- **kort titel:** Tretten fliser
- **spillerrettet beskrivelse:** Runerne er ikke kun i Jelling: moderne spor er lagt mellem helt almindelige fliser. Find dem alle på den godkendte strækning.
- **tags:** `runer`, `gågade`, `skattejagt`, `midtby`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 12 Den Smidtske Gård, 31 brandtavlen og 32 middelaldervejen

#### Dokumenteret historie

**Centrale fakta**

- Vejles officielle historiske byvandring beskriver 13 særlige fliser med runetekst i gågadebelægningen. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Runer er et centralt regionalt kulturspor gennem de to Jellingsten, men gågadefliserne er moderne formidling. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- Gågadeforløbet ligger i den historiske købstads centrale gadenet. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)

- **Hvorfor interessant for en familie:** En seriejagt holder børn aktive og kobler Vejle by med Jellings runeidentitet.
- **Sikkert dokumenteret:** Den officielle byrute angiver 13 runetekstfliser.
- **Usikkert, omstridt, sagn eller fortolkning:** Deres præcise koordinater, hele strækning, udskiftninger og læsbarhed er ikke dokumenteret; fliserne er moderne, ikke vikingetid.
- **Kildekritisk vurdering:** Facit har kun én genstandsnær kilde; de øvrige kilder giver kontekst. Opgaven må udgå, hvis feltoptælling ikke giver 13 robust.

#### Stedet som spil

- **Konkret observerbar invariant:** de 13 særlige runetekst-fliser i det definerede gågadeforløb.
- **Hvorfor permanent/helårsrobust:** Indbyggede belægningsfliser kan være flerårige, men er udsatte for slid og kommunal udskiftning.
- **Spilleren skal konkret:** gå en præcist afgrænset rute én vej og registrere hver flise med runetegn én gang.
- **Spilleren skal eksplicit ignorere:** dekorative standardfliser, dæksler, Jelling-referencer på skilte og gentagelser på returvej.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de 13 særlige runetekst-fliser i det definerede gågadeforløb; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Ruten kan krydse sig, en flise kan være dækket af bod, og flere runeord kan stå på samme flise.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Følg den feltmarkerede gågadestrækning. Hvor mange særlige fliser med runetekst finder I?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `2`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 13 skrives i decimalform; læs tiercifret `1` først og enercifret `3` bagefter. Indtast `13` uden mellemrum eller bindestreg.
- **Kanonisk facit:** `13`
- **Accepterede svarformer, facit først:** `13`, `tretten`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `12` → Se ved torveinventar og kanter efter en flise, der kan være delvist skjult.
- `14` → Kontrollér at ingen flise er talt både ud og hjem.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Runefliserne i Vejles gågade** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Runer er et centralt regionalt kulturspor gennem de to Jellingsten, men gågadefliserne er moderne formidling. [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
3. Udfør kun denne observation: gå en præcist afgrænset rute én vej og registrere hver flise med runetegn én gang; udelad dekorative standardfliser, dæksler, Jelling-referencer på skilte og gentagelser på returvej.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 13 skrives i decimalform; læs tiercifret `1` først og enercifret `3` bagefter. Indtast `13` uden mellemrum eller bindestreg.
5. Observation og regel giver facit **`13`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de 13 særlige runetekst-fliser i det definerede gågadeforløb ved Runefliserne i Vejles gågade; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå en præcist afgrænset rute én vej og registrere hver flise med runetegn én gang. Ignorér dekorative standardfliser, dæksler, Jelling-referencer på skilte og gentagelser på returvej.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Det korrekte antal er lige over et dusin.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste tretten fliser på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Moderne runetekster som byens skjulte spor bliver håndgribelig, fordi I selv fandt de 13 særlige runetekst-fliser i det definerede gågadeforløb.
- `historyFact`: Fliserne er moderne byformidling; de historiske runesten findes i Jelling. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel) [Jelling-monumenterne](https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Runefliserne i Vejles gågade`
- `postalCode`: `7100`
- `address`: `Gågadeforløbet Søndergade–Torvegade–Nørregade, 7100 Vejle; fuld strækning skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentligt gågadeforløb; konkrete fliser og cykelregler skal kortlægges. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`cyclePath`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** placér ophold uden for cykelflow; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** gågadebelægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret; strækningen skal opmåles
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den definerede ganglinje langs facader/torve, med pauser uden for cykelstrøm.

**Kandidatspecifik feltcheckliste**

- Lav nummereret foto- og GPS-log for alle 13 fliser.
- Definér start/slut og én læseretning uden dobbeltoptælling.
- Test torvedage, sne, slid, cykler, distance og solve-tid.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af de 13 særlige runetekst-fliser i det definerede gågadeforløb; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- Motiv: et oversigts- eller detaljefoto af de 13 særlige runetekst-fliser i det definerede gågadeforløb; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Slots- og Kulturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Slots- og Kulturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: antal runefliser og deres placering i gågaden

**Kilde 2**
- `title`: Jelling-monumenterne
- `publisher`: Slots- og Kulturstyrelsen
- `url`: https://slks.dk/omraader/kulturarv/verdensarv/jelling-monumenterne
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: historisk rune-kontekst; ikke flisernes alder

**Kilde 3**
- `title`: Vejle Købstad
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: byhistorisk gadenet

**Sjælden kildeundtagelse:** Det officielle rutetal 13 accepteres kun som researchhypotese; produktion kræver en nummereret fotolog med alle 13.


### 34 — Sct. Pouls Kirke

#### Identitet og prioritering

- **rangnummer:** `34`
- **samlet score:** **64/100** — Tydelig arkitektur og enkel geometri; perspektiv, trafik og forskellen på tårn/kuppel kræver solve-test.
- **stedets officielle eller mest præcise navn:** Sct. Pouls Kirke
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Vissingsgade 15A, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Tårnet med otte sider
- **kort titel:** Otte sider
- **spillerrettet beskrivelse:** Se op på tårnet uden at træde tilbage i vejen. Tæl de lodrette hovedflader lige under den runde kuppel.
- **tags:** `kirke`, `katolsk`, `arkitektur`, `geometri`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 36 Himmelstigen, 43 Mølleå-broerne og 44 Tróndur

#### Dokumenteret historie

**Centrale fakta**

- Det katolske kapel blev opført i 1876, og kirken blev udvidet/etableret i sin senere form i 1892. [Sct. Pouls Kirke i Vejle](https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29)
- Kirken har et ottekantet tårn med kuppelformet spir. [Sct. Pouls Kirke i Vejle](https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29)
- Sct. Pouls Kirke indgår i den officielle historiske byvandring gennem centrum. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Kirken viser, hvordan en ottekant kan bære en næsten rund kuppel.
- **Sikkert dokumenteret:** Bygningshistorie og ottekantet tårn er arkivdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvilke kanter der er synlige fra et sikkert fortovspunkt, og om tilbygninger skjuler bagsiden, er feltspørgsmål.
- **Kildekritisk vurdering:** Historisk Atlas er stærk genstandskilde; byvandringen bekræfter placering, men ikke sideantallet uafhængigt.

#### Stedet som spil

- **Konkret observerbar invariant:** det ottekantede tårns otte hovedsider under kuppelspiret.
- **Hvorfor permanent/helårsrobust:** Tårnets hovedform er konstruktiv og permanent.
- **Spilleren skal konkret:** finde et sikkert skråt udsyn og følge tårnets lodrette hjørner rundt mentalt/fysisk.
- **Spilleren skal eksplicit ignorere:** kuplens buede felter, tagflader, vinduer, spir og kirkeskibets sider.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det ottekantede tårns otte hovedsider under kuppelspiret; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Fra én vinkel ses kun tre-fire flader; en ren tælleopgave kan kræve en kort lovlig bevægelse rundt om hjørnet.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange hovedsider har Sct. Pouls Kirkes tårn lige under kuplen?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 8 mappes til decimaltallet `8` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `8`
- **Accepterede svarformer, facit først:** `8`, `otte`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `6` → Fortsæt rundt på fortovet – nogle sider ligger bag de første.
- `10` → Tæl ikke kuplens felter eller tagflader.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Sct. Pouls Kirke** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Kirken har et ottekantet tårn med kuppelformet spir. [Sct. Pouls Kirke i Vejle](https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29)
3. Udfør kun denne observation: finde et sikkert skråt udsyn og følge tårnets lodrette hjørner rundt mentalt/fysisk; udelad kuplens buede felter, tagflader, vinduer, spir og kirkeskibets sider.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 8 mappes til decimaltallet `8` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`8`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Sct. Pouls Kirke i Vejle](https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det ottekantede tårns otte hovedsider under kuppelspiret ved Sct. Pouls Kirke; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde et sikkert skråt udsyn og følge tårnets lodrette hjørner rundt mentalt/fysisk. Ignorér kuplens buede felter, tagflader, vinduer, spir og kirkeskibets sider.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Tårnet er en ottekant, altså dobbelt så mange sider som et kvadrat.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste otte sider på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Vejles katolske kirke med en usædvanlig kuppel bliver håndgribelig, fordi I selv fandt det ottekantede tårns otte hovedsider under kuppelspiret.
- `historyFact`: Arkivkilden beskriver et ottekantet tårn med kuppelformet spir. [Sct. Pouls Kirke i Vejle](https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Sct. Pouls Kirke`
- `postalCode`: `7100`
- `address`: `Vissingsgade 15A, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Sct. Pouls Kirke i Vejle](https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja til facadeobservation fra offentligt fortov; kirkelige handlinger og gårdareal respekteres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `crowding`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fortov/bybelægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** fortovet på en feltvalideret side med tilstrækkelig afstand til facade og uden at træde i vej/cykelspor.

**Kandidatspecifik feltcheckliste**

- Find sikker rute der afslører tårnets form.
- Test om otte kan udledes uden forkundskab.
- Kontrollér trafik, kirkehandlinger, GPS og facade-/stilladsstatus.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29
- Motiv: et oversigts- eller detaljefoto af det ottekantede tårns otte hovedsider under kuppelspiret; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af det ottekantede tårns otte hovedsider under kuppelspiret; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Sct. Pouls Kirke i Vejle
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Sct._Pouls_Kirke_i_Vejle_%282333%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: adresse, datering og ottekantet tårn

**Kilde 2**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: byrutekontekst


### 35 — Det Pressede Hjerte

#### Identitet og prioritering

- **rangnummer:** `35`
- **samlet score:** **63/100** — Visuelt tilgængeligt motiv og god museumsforankring; værkidentitet og præcis form skal bekræftes med en bedre værkkatalogkilde.
- **stedets officielle eller mest præcise navn:** Det Pressede Hjerte
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Foran Vejle Kunstmuseum, Flegborg 16–18, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Kroppen i stenen
- **kort titel:** Et hjerte
- **spillerrettet beskrivelse:** Stenen ser ud, som om noget levende er blevet klemt ind i den. Se på hovedformen og vælg kropsdelen.
- **tags:** `kunst`, `krop`, `museum`, `midtby`
- **klynge/rute:** Vejle centrum vest
- **nærliggende kandidater:** 50 Villa Flegborg, 30 Spinderihallerne og 49 Bygningen

#### Dokumenteret historie

**Centrale fakta**

- Vejle Kunstmuseum ligger på Flegborg 16–18 og formidler kunst fra ældre grafik til moderne værker. [Vejle Kunstmuseum](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-kunstmuseum-gdk1077812)
- Museet er en del af Vejlemuseerne og har kunst i og omkring museumsbygningen. [Vejle Kunstmuseum](https://www.vejlemuseerne.dk/besoeg-os/vejle-kunstmuseum/)
- Den historiske byvandring peger på skulpturen Det Pressede Hjerte som et udendørs kunstspor ved museet. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** En genkendelig kropsform inviterer til at beskrive materiale, tryk og følelse uden kunstfaglige forkundskaber.
- **Sikkert dokumenteret:** Museets identitet og placering er dokumenteret; værkets titel/udendørs stop fremgår af den officielle byvandring.
- **Usikkert, omstridt, sagn eller fortolkning:** Kunstner, år og den præcise værkbeskrivelse er ikke dokumenteret i de fundne kilder og må ikke opfindes.
- **Kildekritisk vurdering:** Kilderne er myndigheds-/turismestærke på stedet, men svage på værkkataloget; facit er foreløbigt baseret på titel plus fysisk form.

#### Stedet som spil

- **Konkret observerbar invariant:** den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte.
- **Hvorfor permanent/helårsrobust:** En udendørs skulpturs hovedform er stabil, men værker kan flyttes under vedligehold.
- **Spilleren skal konkret:** identificere skulpturen ved titel/placering og se efter dens dominerende kropsform.
- **Spilleren skal eksplicit ignorere:** museumlogo, anatomiske former i andre værker, graffiti og løse dekorationer.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Titlen kan afsløre svaret før observation; produktionsversionen bør vise titel først efter solve eller spørge til et konkret hul/tryk, hvis feltet giver bedre invariant.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken kropsdel har givet den udendørs skulptur sit navn og sin hovedform?”
- **Svarmuligheder ved `singleChoice`:** `Et hjerte` **(korrekt)**; `En hånd`; `Et øre`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Et hjerte`
- **Accepterede svarformer, facit først:** `Et hjerte`, `hjerte`, `hjertet`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `En hånd` → Se på hele værkets centrale omrids, ikke mindre aftryk.
- `Et øre` → Sammenlign med symbolet, vi bruger for kærlighed.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Det Pressede Hjerte** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Museet er en del af Vejlemuseerne og har kunst i og omkring museumsbygningen. [Vejle Kunstmuseum](https://www.vejlemuseerne.dk/besoeg-os/vejle-kunstmuseum/)
3. Udfør kun denne observation: identificere skulpturen ved titel/placering og se efter dens dominerende kropsform; udelad museumlogo, anatomiske former i andre værker, graffiti og løse dekorationer.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Et hjerte`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejle Kunstmuseum](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-kunstmuseum-gdk1077812)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte ved Det Pressede Hjerte; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: identificere skulpturen ved titel/placering og se efter dens dominerende kropsform. Ignorér museumlogo, anatomiske former i andre værker, graffiti og løse dekorationer.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Formen er også det klassiske symbol for kærlighed.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste et hjerte på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Samtidskunst ved Vejle Kunstmuseum bliver håndgribelig, fordi I selv fandt den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte.
- `historyFact`: Værket indgår som et udendørs stop ved Vejle Kunstmuseum. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Det Pressede Hjerte`
- `postalCode`: `7100`
- `address`: `Foran Vejle Kunstmuseum, Flegborg 16–18, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejle Kunstmuseum](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-kunstmuseum-gdk1077812)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — facadezonen er besøgsrettet, men værkets permanente udendørs adgang og placering skal bekræftes. [Vejle Kunstmuseum](https://www.vejlemuseerne.dk/besoeg-os/vejle-kunstmuseum/)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** fortov/museumsforplads
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** museets offentlige forplads med fri passage og afstand til Flegborgs trafik.

**Kandidatspecifik feltcheckliste**

- Bekræft værk, titel, kunstner og nuværende placering.
- Vurder om spørgsmålet er for selvafslørende; find evt. bedre onsite-detalje.
- Kontrollér trafik, adgang, GPS, underlag og mediekatalog.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-kunstmuseum-gdk1077812
- Motiv: et oversigts- eller detaljefoto af den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlemuseerne.dk/besoeg-os/vejle-kunstmuseum/
- Motiv: et oversigts- eller detaljefoto af den tydelige hjerteform i den udendørs skulptur Det Pressede Hjerte; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejlemuseerne eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejlemuseerne / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejle Kunstmuseum
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-kunstmuseum-gdk1077812
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: museum, adresse og kunstkontekst

**Kilde 2**
- `title`: Vejle Kunstmuseum
- `publisher`: Vejlemuseerne
- `url`: https://www.vejlemuseerne.dk/besoeg-os/vejle-kunstmuseum/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: kommunal museumsforvaltning

**Kilde 3**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: værkets titel og udendørs placering


### 36 — Himmelstigen

#### Identitet og prioritering

- **rangnummer:** `36`
- **samlet score:** **62/100** — Elegant moderne runelæsning med entydigt navn; bogstavform, vand og stationsmylder kræver fair hint og sikker zone.
- **stedets officielle eller mest præcise navn:** Himmelstigen
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Banegårdspladsen 8, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Hvem gjorde stenen?
- **kort titel:** BJØRN
- **spillerrettet beskrivelse:** En nutidig kunstner har signeret som en runemester. Find sætningen, og aflæs kun fornavnet lige efter ‘Jeg’.
- **tags:** `kunst`, `runer`, `Bjørn Nørgaard`, `banegård`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 24 Midgårdsbrønden, 34 Sct. Pouls Kirke, 43 Mølleå-broerne og 44 Tróndur

#### Dokumenteret historie

**Centrale fakta**

- Himmelstigen er et cirka 8,5 meter højt værk af granit, støbejern og vand fra 1999. [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)
- Tallet 12 gentages som kompositorisk idé i værket. [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)
- En runeinskription gengiver sætningen ‘Jeg Bjørn gjorde ... denne sten’ og peger på kunstneren Bjørn Nørgaard. [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)
- Værket indgår som centralt stop på den officielle byvandring. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Opgaven forbinder Jellings gamle runer med en levende kunstners moderne signatur.
- **Sikkert dokumenteret:** År, kunstner, materialer, højde, runeformulering og 12-motiv er arkivdokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Rimelig translitteration, diakritik og den præcise synlighed af navnet i vådt/tørt vejr skal testes.
- **Kildekritisk vurdering:** Historisk Atlas giver detaljeret værkbeskrivelse; byvandringen bekræfter sted, men ikke uafhængig inskriptionsaflæsning.

#### Stedet som spil

- **Konkret observerbar invariant:** kunstnerens fornavn BJØRN skrevet med runer i værkets signatur.
- **Hvorfor permanent/helårsrobust:** Signaturen er indarbejdet i det permanente værk; vanddrift er irrelevant.
- **Spilleren skal konkret:** finde runesætningen og aflæse/translitterere fornavnet efter ‘Jeg’.
- **Spilleren skal eksplicit ignorere:** kunstnerens efternavn på skilte, tallet 12, øvrige ord og stationsinformation.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop kunstnerens fornavn BJØRN skrevet med runer i værkets signatur; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Rune-B kan forveksles, og spillere kan svare hele navnet ‘Bjørn Nørgaard’; begge bør håndteres hjælpsomt.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `freeText`
- **Præcist spillerrettet spørgsmål:** “Find runesætningen på Himmelstigen. Hvilket fornavn står efter ordet ‘Jeg’?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `BJØRN`
- **Accepterede svarformer, facit først:** `BJØRN`, `Bjørn`, `bjørn`, `BJOERN`, `Bjoern`, `bjoern`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `BJØRN NØRGAARD` → Du har den rigtige person; indtast kun fornavnet efter ‘Jeg’.
- `JEG` → Det er ordet før navnet. Læs det næste ord.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Himmelstigen** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Tallet 12 gentages som kompositorisk idé i værket. [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)
3. Udfør kun denne observation: finde runesætningen og aflæse/translitterere fornavnet efter ‘Jeg’; udelad kunstnerens efternavn på skilte, tallet 12, øvrige ord og stationsinformation.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`BJØRN`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find kunstnerens fornavn BJØRN skrevet med runer i værkets signatur ved Himmelstigen; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde runesætningen og aflæse/translitterere fornavnet efter ‘Jeg’. Ignorér kunstnerens efternavn på skilte, tallet 12, øvrige ord og stationsinformation.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Fornavnet er også navnet på et stort nordisk rovdyr.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste bjørn på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En moderne runesten mellem banegård og by bliver håndgribelig, fordi I selv fandt kunstnerens fornavn BJØRN skrevet med runer i værkets signatur.
- `historyFact`: Værket fra 1999 er skabt af Bjørn Nørgaard, og 12-tallet gentages i kompositionen. [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Himmelstigen`
- `postalCode`: `7100`
- `address`: `Banegårdspladsen 8, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Himmelstigen](https://historiskatlas.dk/Himmelstigen_%288854%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentligt byrum ved Banegårdspladsen; bygge- og stationsforhold skal kontrolleres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `water`, `cyclePath`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; fastlæg afstand/værn ved vand; placér ophold uden for cykelflow; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** stationsplads/bybelægning, mulig våd zone
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et plant punkt på pladsen med fri passage, væk fra bus-/taxakørsel og vandkant.

**Kandidatspecifik feltcheckliste**

- Fotografér runesætningen og valider translitteration med ekspert.
- Test læsbarhed med/uden vand og i dagslys.
- Kortlæg busser, cykler, trængsel, byggeri og GPS-afvigelse.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Himmelstigen_%288854%29
- Motiv: et oversigts- eller detaljefoto af kunstnerens fornavn BJØRN skrevet med runer i værkets signatur; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af kunstnerens fornavn BJØRN skrevet med runer i værkets signatur; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Himmelstigen
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Himmelstigen_%288854%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: materialer, højde, år, tallet 12 og rune-signaturen

**Kilde 2**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: placering og byrutekontekst


### 37 — Firehøje

#### Identitet og prioritering

- **rangnummer:** `37`
- **samlet score:** **61/100** — Navn og fysisk gruppe giver selvkontrol og stærk oldtidshistorie; vegetation, gravfred og utydelige højgrænser gør facit sårbart.
- **stedets officielle eller mest præcise navn:** Firehøje
- **postnummer:** `7183`
- **adresse/stedbeskrivelse:** Firehøje nord for Randbøl Kirke, nær Randbølvej 69, 7183 Randbøl; stiadgang skal verificeres
- **område/by:** Randbøl
- **foreslået opgavetitel:** Højene der tæller sig selv
- **kort titel:** Fire høje
- **spillerrettet beskrivelse:** Et stednavn kan være en ledetråd, men I skal bevise det med landskabet. Find og afgræns hver stor gravhøj uden at gå uden for stien.
- **tags:** `bronzealder`, `gravhøje`, `natur`, `Randbøl`
- **klynge/rute:** Randbøl–Tinnet Hærvejen
- **nærliggende kandidater:** 04 Randbølstenen, 16 St. Peders Kilde og 39 Margrethediget

#### Dokumenteret historie

**Centrale fakta**

- Firehøje registreres som en gruppe på fire gravhøje fra bronzealderen. [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)
- Udinaturen angiver offentlig vejvisning til kulturmindet og oplyser, at stedet ikke er handicapegnet. [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)
- Højgruppen ligger i det kulturhistoriske landskab omkring Randbøl og Kong Rans Høj. [Firehøje og Kong Rans Høj](https://historiskatlas.dk/Fireh%C3%B8je_og_Kong_Rans_H%C3%B8j_%282252%29)

- **Hvorfor interessant for en familie:** Børn får øje på menneskeskabte former i naturen og lærer at færdes respektfuldt ved grave.
- **Sikkert dokumenteret:** Gruppen består af fire bronzealderhøje; manglende handicapegnethed er oplyst.
- **Usikkert, omstridt, sagn eller fortolkning:** Om alle fire er synlige fra offentlig sti gennem sommervegetation, og præcis hvor gruppen slutter, skal feltbevises.
- **Kildekritisk vurdering:** Udinaturen/Naturstyrelsen er god på friluftsdata; Historisk Atlas supplerer historisk landskab, men ingen kilde garanterer nutidigt udsyn.

#### Stedet som spil

- **Konkret observerbar invariant:** de fire store gravhøje, der udgør den navngivne gruppe Firehøje.
- **Hvorfor permanent/helårsrobust:** Højene er fredede jordværker, men deres visuelle konturer påvirkes af bevoksning.
- **Spilleren skal konkret:** følge den skiltede sti og identificere fire separate, store højprofiler.
- **Spilleren skal eksplicit ignorere:** små jordbunker, Kong Rans Høj hvis uden for gruppen, trærodsknolde og markkanter.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de fire store gravhøje, der udgør den navngivne gruppe Firehøje; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** To høje kan smelte visuelt sammen; navnet afslører facit og kan gøre opgaven hjemme-løselig, så onsite-bevis skal kræve en ekstra rækkefølge/foto i senere design.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Hvor mange gravhøje udgør den samlede gruppe, som stedet er opkaldt efter?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `4`
- **Accepterede svarformer, facit først:** `4`, `fire`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `3` → Se bag den nærmeste høj efter endnu en selvstændig profil.
- `5` → Afgræns gruppen Firehøje; nabohøje uden for gruppen tæller ikke.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Firehøje** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Udinaturen angiver offentlig vejvisning til kulturmindet og oplyser, at stedet ikke er handicapegnet. [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)
3. Udfør kun denne observation: følge den skiltede sti og identificere fire separate, store højprofiler; udelad små jordbunker, Kong Rans Høj hvis uden for gruppen, trærodsknolde og markkanter.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`4`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de fire store gravhøje, der udgør den navngivne gruppe Firehøje ved Firehøje; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: følge den skiltede sti og identificere fire separate, store højprofiler. Ignorér små jordbunker, Kong Rans Høj hvis uden for gruppen, trærodsknolde og markkanter.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Stedets navn bruger det danske talord for facit.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fire høje på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En samlet gruppe bronzealderhøje bliver håndgribelig, fordi I selv fandt de fire store gravhøje, der udgør den navngivne gruppe Firehøje.
- `historyFact`: Gruppen registreres som fire gravhøje fra bronzealderen. [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Firehøje`
- `postalCode`: `7183`
- `address`: `Firehøje nord for Randbøl Kirke, nær Randbølvej 69, 7183 Randbøl; stiadgang skal verificeres`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja som skiltet kulturhistorisk naturfacilitet, men den nøjagtige stizone skal kontrolleres. [Firehøje](https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `darkness`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** natursti/græs med ujævnheder
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `no`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den skiltede offentlige sti ved højgruppen; ingen vandring på højtoppe eller over dyrket mark.

**Kandidatspecifik feltcheckliste**

- Bekræft alle fire fra lovlig sti i både løv- og vinterforhold.
- Afgræns gruppen mod Kong Rans Høj/nabohøje.
- Registrér GPS, underlag, parkering og grav-/naturhensyn.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C
- Motiv: et oversigts- eller detaljefoto af de fire store gravhøje, der udgør den navngivne gruppe Firehøje; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Udinaturen.dk / Naturstyrelsen eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Udinaturen.dk / Naturstyrelsen / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Fireh%C3%B8je_og_Kong_Rans_H%C3%B8j_%282252%29
- Motiv: et oversigts- eller detaljefoto af de fire store gravhøje, der udgør den navngivne gruppe Firehøje; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Firehøje
- `publisher`: Udinaturen.dk / Naturstyrelsen
- `url`: https://udinaturen.dk/facilitet/kulturhistorie/?id=F8FF8568-0549-4912-B728-9640B5E5014C
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: antal, periode, adgangsindikation og tilgængelighed

**Kilde 2**
- `title`: Firehøje og Kong Rans Høj
- `publisher`: Historisk Atlas
- `url`: https://historiskatlas.dk/Fireh%C3%B8je_og_Kong_Rans_H%C3%B8j_%282252%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: lokal landskabskontekst


### 38 — Det gamle badeland ved Tinnet Krat

#### Identitet og prioritering

- **rangnummer:** `38`
- **samlet score:** **60/100** — Overraskende nyere historie og stærk formkontrast; ruiner, vand og tilgroning kan gøre identifikationen usikker.
- **stedets officielle eller mest præcise navn:** Det gamle badeland ved Tinnet Krat
- **postnummer:** `7173`
- **adresse/stedbeskrivelse:** Ved Gudenåens udspring/Tinnet Krat nær Hærvejen 317, 7173 Vonge; ruinens stiadgang skal feltfastlægges
- **område/by:** Tinnet Krat
- **foreslået opgavetitel:** Svømmebassinet i skoven
- **kort titel:** Et rektangel
- **spillerrettet beskrivelse:** Skoven skjuler rester af et sted, hvor man engang svømmede. Find det største bassin og genkend kun dets overordnede grundform.
- **tags:** `badeland`, `1930'erne`, `ruin`, `Tinnet Krat`
- **klynge/rute:** Randbøl–Tinnet Hærvejen
- **nærliggende kandidater:** 16 St. Peders Kilde, 21 vejviseren og 39 Margrethediget

#### Dokumenteret historie

**Centrale fakta**

- Et badeland blev anlagt ved Tinnet Krat i 1930'erne og lukkede i 1947. [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)
- Det største bassin målte cirka 9 × 25 meter og havde rektangulær form. [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)
- Anlægget rummede også et mindre bassin, en rund fontæne og et rundt motorbådsbassin; betonrester kan stadig ses. [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)
- Tinnet Krat og Gudenåens udspring er et formidlet naturområde med etablerede ruter. [Rørbæk Sø, Tinnet Krat og Gudenåens udspring](https://www.visitvejle.dk/vejle/planlaeg-ferien/roerbaek-soe-tinnet-krat-og-gudenaaens-udspring-gdk608061)

- **Hvorfor interessant for en familie:** Et glemt badeland udfordrer forventningen om, hvad der kan gemme sig i en skov.
- **Sikkert dokumenteret:** Driftsperiode, det store bassins 9 × 25 meter og de forskellige runde/rektangulære anlæg er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvilke betonrester der er synlige i 2026, og om det store bassin kan skelnes sikkert fra de runde, er ukendt.
- **Kildekritisk vurdering:** Historisk Atlas er eneste anlægsspecifikke kilde; VisitVejle bekræfter kun naturdestinationen, så ruinfacit er betinget.

#### Stedet som spil

- **Konkret observerbar invariant:** betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform.
- **Hvorfor permanent/helårsrobust:** Betonfundament er mere stabilt end skiltning, men kan blive skjult, erodere eller sikres af hensyn til naturen.
- **Spilleren skal konkret:** fra den etablerede sti identificere den største bassinramme og følge dens lange, rette sider.
- **Spilleren skal eksplicit ignorere:** den runde fontæne, det runde bådbassin, moderne vandløb, grøfter og tilfældige betonstumper.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Flere anlæg ligger tæt, og vegetation kan skjule hjørner; opgaven skal udgå, hvis spillere må klatre i ruinen.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken grundform har betonresterne efter det største gamle bassin?”
- **Svarmuligheder ved `singleChoice`:** `Et rektangel` **(korrekt)**; `En cirkel`; `En trekant`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Et rektangel`
- **Accepterede svarformer, facit først:** `Et rektangel`, `rektangel`, `rektangulært`, `aflang firkant`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `En cirkel` → Det runde anlæg er et af de mindre bassiner/fontænen. Find den største ramme.
- `En trekant` → Se efter parallelle lange sider og fire hjørner.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Det gamle badeland ved Tinnet Krat** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Det største bassin målte cirka 9 × 25 meter og havde rektangulær form. [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)
3. Udfør kun denne observation: fra den etablerede sti identificere den største bassinramme og følge dens lange, rette sider; udelad den runde fontæne, det runde bådbassin, moderne vandløb, grøfter og tilfældige betonstumper.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Et rektangel`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform ved Det gamle badeland ved Tinnet Krat; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra den etablerede sti identificere den største bassinramme og følge dens lange, rette sider. Ignorér den runde fontæne, det runde bådbassin, moderne vandløb, grøfter og tilfældige betonstumper.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Det største bassin var 25 meter langt og kun 9 meter bredt.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste et rektangel på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: 1930'ernes badeland ved Gudenåens spæde løb bliver håndgribelig, fordi I selv fandt betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform.
- `historyFact`: Badelandet lukkede i 1947; det store bassin målte cirka 9 × 25 meter. [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Det gamle badeland ved Tinnet Krat`
- `postalCode`: `7173`
- `address`: `Ved Gudenåens udspring/Tinnet Krat nær Hærvejen 317, 7173 Vonge; ruinens stiadgang skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — naturdestinationen er formidlet, men den konkrete ruin og sikker nærhed er ikke adgangsgodkendt online. [Rørbæk Sø, Tinnet Krat og Gudenåens udspring](https://www.visitvejle.dk/vejle/planlaeg-ferien/roerbaek-soe-tinnet-krat-og-gudenaaens-udspring-gdk608061)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `steepSlope`, `darkness`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt.
- **Tilgængelighed — underlag:** skovsti, mulig mudder/rødder og ruin-kanter
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et etableret stiforløb med udsyn til formen; ingen adgang ned i bassin, på betonkanter eller gennem vegetation.

**Kandidatspecifik feltcheckliste**

- Match ruinen sikkert til det historiske store bassin.
- Kontrollér vand, faldkanter, tilgroning og lovlig sti.
- Test formgenkendelse, GPS, mobildækning og sæsonvariation.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29
- Motiv: et oversigts- eller detaljefoto af betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/roerbaek-soe-tinnet-krat-og-gudenaaens-udspring-gdk608061
- Motiv: et oversigts- eller detaljefoto af betonresterne efter det store 9 × 25 meter svømmebassins rektangulære grundform; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Gudenåen – Badelandet ved Tinnet Krat
- `publisher`: Historisk Atlas
- `url`: https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: badelandets periode, bassiner, mål og betonrester

**Kilde 2**
- `title`: Rørbæk Sø, Tinnet Krat og Gudenåens udspring
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/roerbaek-soe-tinnet-krat-og-gudenaaens-udspring-gdk608061
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: naturområde og rutekontekst

**Sjælden kildeundtagelse:** Facitformen stammer fra én lokalhistorisk artikel; feltbesøg skal matche ruinen med historiske billeder/plan før brug.


### 39 — Margrethediget

#### Identitet og prioritering

- **rangnummer:** `39`
- **samlet score:** **59/100** — God fysisk rækkefølge og ægte kildekritik; orientering, vegetation og sikker krydsning er svære og gør kandidaten betinget.
- **stedets officielle eller mest præcise navn:** Margrethediget
- **postnummer:** `7173`
- **adresse/stedbeskrivelse:** Ved Hærvejen nær Hærvejen 317, 7173 Vonge; præcist krydsningspunkt skal feltfastlægges
- **område/by:** Tinnet/Vonge
- **foreslået opgavetitel:** Grøft før vold
- **kort titel:** Grøft → vold
- **spillerrettet beskrivelse:** Et gammelt forsvarsværk består af to jordformer. Kom kun fra den anviste sydlige sti og læg mærke til rækkefølgen.
- **tags:** `jernalder`, `jordværk`, `Hærvejen`, `kildekritik`
- **klynge/rute:** Randbøl–Tinnet Hærvejen
- **nærliggende kandidater:** 16 St. Peders Kilde, 21 vejviseren og 38 badelandet

#### Dokumenteret historie

**Centrale fakta**

- Margrethediget er et jernalderligt jordværk med vold og grøft. [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29)
- Den bevarede strækning beskrives som cirka 250 meter, mens det oprindelige anlæg var mindst 500 meter. [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29)
- Grøften ligger syd for volden; navnet Margrethe er senere tradition og ikke sikker bygherre. [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29)
- Vejle Kommunes Hærvejsside omtaler en bevaret strækning på cirka 150 meter, hvilket afviger fra Historisk Atlas' 250 meter. [Hærvejen](https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/)

- **Hvorfor interessant for en familie:** Børn kan mærke, hvordan vold og grøft virker sammen, samtidig med at to forskellige længdetal lærer dem kildekritik.
- **Sikkert dokumenteret:** Jernalderdatering, vold/grøft og grøftens sydlige placering er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Kilderne er uenige om bevaret længde (ca. 150 mod 250 m); navnet er tradition, og den præcise stiretning er ukendt.
- **Kildekritisk vurdering:** Historisk Atlas er detaljekilden; kommunens ruteside er autoritativ på rute, men viser en reel længdekonflikt. Facit bruger hverken længde eller sagn.

#### Stedet som spil

- **Konkret observerbar invariant:** rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd.
- **Hvorfor permanent/helårsrobust:** Jordværkets relative vold/grøft-ordning er landskabsfast, men kan være visuelt udjævnet og tilgroet.
- **Spilleren skal konkret:** bekræfte kompas-/ruteretning og registrere hvilken jordform stien passerer først.
- **Spilleren skal eksplicit ignorere:** moderne drængrøfter, hjulspor, vejvolde og længdetallene i kilderne.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Hvis ruten kommer fra nord eller snor sig, vendes facit; grøften kan ligne en moderne lavning.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Når I nærmer jer det markerede jordværk fra syd ad den godkendte sti, hvad møder I først?”
- **Svarmuligheder ved `singleChoice`:** `Grøften før volden` **(korrekt)**; `Volden før grøften`; `Kun én flad jordryg`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Grøften før volden`
- **Accepterede svarformer, facit først:** `Grøften før volden`, `grøft først`, `grøften`, `grøft og så vold`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Volden før grøften` → Kontrollér at du virkelig nærmer dig fra syd som opgaven kræver.
- `Kun én flad jordryg` → Se efter en lavning umiddelbart syd for jordryggen.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Margrethediget** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Den bevarede strækning beskrives som cirka 250 meter, mens det oprindelige anlæg var mindst 500 meter. [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29)
3. Udfør kun denne observation: bekræfte kompas-/ruteretning og registrere hvilken jordform stien passerer først; udelad moderne drængrøfter, hjulspor, vejvolde og længdetallene i kilderne.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Grøften før volden`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd ved Margrethediget; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: bekræfte kompas-/ruteretning og registrere hvilken jordform stien passerer først. Ignorér moderne drængrøfter, hjulspor, vejvolde og længdetallene i kilderne.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Den historiske grøft ligger på anlæggets sydside.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste grøft → vold på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et jernalderjordværk på tværs af Hærvejslandskabet bliver håndgribelig, fordi I selv fandt rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd.
- `historyFact`: Kilderne angiver forskellig bevaret længde; det ændrer ikke, at grøften beskrives syd for volden. [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29) [Hærvejen](https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Margrethediget`
- `postalCode`: `7173`
- `address`: `Ved Hærvejen nær Hærvejen 317, 7173 Vonge; præcist krydsningspunkt skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Margrethediget](https://historiskatlas.dk/Margrethediget_%282502%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — Hærvejen er offentlig rute, men det præcise jordværkspunkt og krydsningsretning skal godkendes. [Hærvejen](https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`steepSlope`, `darkness`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** brug kun stabil sti og aldrig sværhedsgrad gennem hældning; publicér kun til dagslys, medmindre belysning er fysisk godkendt; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** natursti og jordværk med ujævnt/muligt vådt underlag
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et skiltet sydligt stiforløb, hvor begge former kan ses uden at forlade stien eller bestige volden.

**Kandidatspecifik feltcheckliste**

- Fastslå syd/nord med GPS/kompas og vælg entydig ankomst.
- Skeln historisk grøft fra moderne dræn med fagperson.
- Kontrollér vegetation, underlag, cykler, mobildækning og naturhensyn.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Margrethediget_%282502%29
- Motiv: et oversigts- eller detaljefoto af rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/
- Motiv: et oversigts- eller detaljefoto af rækkefølgen grøft først, derefter jordvold ved en kontrolleret tilgang fra syd; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Kommune eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Kommune / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Margrethediget
- `publisher`: Historisk Atlas
- `url`: https://historiskatlas.dk/Margrethediget_%282502%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: periode, vold/grøft, orientering, længde og navnetradition

**Kilde 2**
- `title`: Hærvejen
- `publisher`: Vejle Kommune
- `url`: https://www.vejle.dk/da/oplevelser/natur-og-udeliv/ruter-i-naturen/vandreruter/haervejen/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: rutekontekst og modstridende længdeangivelse


### 40 — Stokbro over Højen Å

#### Identitet og prioritering

- **rangnummer:** `40`
- **samlet score:** **58/100** — Meget præcist registerfacit og flot brohistorie; adgang, trafik, vand og skel er så usikre, at kandidaten er feltbetinget.
- **stedets officielle eller mest præcise navn:** Stokbro over Højen Å
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Stokbro over Højen Å ved Højen, 7100 Vejle; sikker offentlig ankomst skal dokumenteres
- **område/by:** Højen
- **foreslået opgavetitel:** Syv gamle rækværksstolper
- **kort titel:** Syv granitstolper
- **spillerrettet beskrivelse:** Broens to sider er ikke ens. Tæl de gamle granitstolper på begge rækværk – men kun fra et godkendt fortov/stipunkt.
- **tags:** `bro`, `granit`, `Højen Å`, `infrastruktur`
- **klynge/rute:** Højen og Vejle syd
- **nærliggende kandidater:** 15 Vejle Vindmølle som separat bystop

#### Dokumenteret historie

**Centrale fakta**

- Stokbro er en konkavt hvælvet granitbro over Højen Å. [Stokbro](https://trap.lex.dk/Stokbro)
- Broen har tre granitstolper på indløbssiden og fire på udløbssiden. [Stokbro](https://trap.lex.dk/Stokbro)
- Det samlede registrerede antal oprindelige rækværksstolper er derfor syv. [Stokbro](https://trap.lex.dk/Stokbro)
- Vejleområdet rummer formidlede natur- og vandreruter, men den brugte oversigt dokumenterer ikke specifikt sikker adgang til Stokbro. [Idylliske ruter i naturen](https://www.visitvejle.dk/vejle/outdoor/ruter-i-naturen)

- **Hvorfor interessant for en familie:** Fordelingen 3 + 4 giver en lille matematisk opdagelse knyttet til håndværk og vandløb.
- **Sikkert dokumenteret:** Brotype og præcis fordeling tre/fire er registreret.
- **Usikkert, omstridt, sagn eller fortolkning:** Offentlig adgang, kørende trafik, rækværkets nuværende komplethed og hvilke nyere elementer der er tilføjet er ikke dokumenteret.
- **Kildekritisk vurdering:** Registerposten er autoritativ på konstruktionen, men der er ikke fundet en brugbar Stokbro-specifik adgangskilde. Kandidaten må falde ud ved enhver sikkerhedstvivl.

#### Stedet som spil

- **Konkret observerbar invariant:** de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden.
- **Hvorfor permanent/helårsrobust:** Originale granitstolper er tunge og stedfaste, men restaurering eller moderne rækværk kan ændre tællebilledet.
- **Spilleren skal konkret:** fra en sikker side identificere gamle granitstolper på begge rækværk og lægge 3 + 4 sammen.
- **Spilleren skal eksplicit ignorere:** moderne metaldele, vejkantspæle, brosten, gelænderfelter og træer.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Nyere stolper kan ligne de gamle; ‘indløb’/‘udløb’ kræver vandretning og begge sider kan være utilgængelige.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Tæl kun de oprindelige granitstolper langs begge sider af Stokbro. Hvor mange er der tilsammen?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 7 mappes til decimaltallet `7` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `7`
- **Accepterede svarformer, facit først:** `7`, `syv`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `6` → Kontrollér begge sider; den ene har én stolpe mere end den anden.
- `8` → En moderne vej-/rækværksdel kan være talt med. Brug kun granitstolperne.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Stokbro over Højen Å** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Broen har tre granitstolper på indløbssiden og fire på udløbssiden. [Stokbro](https://trap.lex.dk/Stokbro)
3. Udfør kun denne observation: fra en sikker side identificere gamle granitstolper på begge rækværk og lægge 3 + 4 sammen; udelad moderne metaldele, vejkantspæle, brosten, gelænderfelter og træer.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 7 mappes til decimaltallet `7` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`7`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Stokbro](https://trap.lex.dk/Stokbro)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden ved Stokbro over Højen Å; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra en sikker side identificere gamle granitstolper på begge rækværk og lægge 3 + 4 sammen. Ignorér moderne metaldele, vejkantspæle, brosten, gelænderfelter og træer.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Registeret fordeler stolperne som 3 på den ene side og 4 på den anden.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste syv granitstolper på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: En hvælvet granitbro med bevaret rækværksrytme bliver håndgribelig, fordi I selv fandt de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden.
- `historyFact`: Den registrerede asymmetri er tre stolper på indløbssiden og fire på udløbssiden. [Stokbro](https://trap.lex.dk/Stokbro)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Stokbro over Højen Å`
- `postalCode`: `7100`
- `address`: `Stokbro over Højen Å ved Højen, 7100 Vejle; sikker offentlig ankomst skal dokumenteres`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Stokbro](https://trap.lex.dk/Stokbro)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — ingen brugt autoritativ kilde dokumenterer et offentligt og sikkert observationspunkt; publicering blokeres indtil lokalt samtykke/adgangsbevis.
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `water`, `privateProperty`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; fastlæg afstand/værn ved vand; afklar skel og ejer-/driftshensyn; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** bro-/vejkant; ukendt fortov og værn
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** kun et efterfølgende feltgodkendt fortov eller separat sti; hvis observation kræver kørebane, rabat eller lænen over vand, fravælges stedet.

**Kandidatspecifik feltcheckliste**

- Afklar ejerskab, vejstatus og offentlig adgang før solve-test.
- Identificér originalt 3+4 mod nyere stolper med kulturmyndighed.
- Mål trafik, fortov, vandværn, GPS og vendemulighed; fravælg ved risiko.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://trap.lex.dk/Stokbro
- Motiv: et oversigts- eller detaljefoto af de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Trap Danmark / Slots- og Kulturstyrelsens register eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Trap Danmark / Slots- og Kulturstyrelsens register / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/outdoor/ruter-i-naturen
- Motiv: et oversigts- eller detaljefoto af de syv oprindelige granitstolper i broens to rækværkssider, tre på indløbssiden og fire på udløbssiden; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Stokbro
- `publisher`: Trap Danmark / Slots- og Kulturstyrelsens register
- `url`: https://trap.lex.dk/Stokbro
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: brotype, vandløb og fordelingen 3+4 stolper

**Kilde 2**
- `title`: Idylliske ruter i naturen
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/outdoor/ruter-i-naturen
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: generel ruteinfrastruktur; ikke Stokbro-adgang

**Sjælden kildeundtagelse:** Kun én kilde understøtter selve broen; den anden viser ikke adgang. Derfor er dette en betinget researchkandidat, ikke en publiceringsanbefaling.


### 41 — Nørup Kirke

#### Identitet og prioritering

- **rangnummer:** `41`
- **samlet score:** **57/100** — Meget synlig silhuet og tydelig bygningshistorie; ordet ‘løgkuppel’ kræver børnevenlige svarmuligheder og sikkert udsyn.
- **stedets officielle eller mest præcise navn:** Nørup Kirke
- **postnummer:** `7182`
- **adresse/stedbeskrivelse:** De Lichtenbergs Vej 32, 7182 Bredsten
- **område/by:** Nørup
- **foreslået opgavetitel:** Løgkuplen på kirketårnet
- **kort titel:** En løgkuppel
- **spillerrettet beskrivelse:** Tårnet har fået en top, der buer som en køkkenurt. Se på hele silhuetten fra kirkepladsen og vælg formen.
- **tags:** `kirke`, `barok`, `løgkuppel`, `Nørup`
- **klynge/rute:** Engelsholm–Nørup
- **nærliggende kandidater:** 14 Engelsholm Slot

#### Dokumenteret historie

**Centrale fakta**

- Nørup Kirke har romansk skib og kor fra 1200-tallet samt et senmiddelalderligt tårn. [Nørup Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933)
- Gerhard de Lichtenberg lod kirken ombygge i 1730'erne og tilføjede løgkuplede afslutninger. [Nørup Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933)
- Nørup Kirke hører sammen med Randbøl Kirke under det lokale menighedsråd. [Randbøl og Nørup Kirker](https://www.randboel-noerupkirker.dk/)
- Kirken fremhæves blandt de seværdige kirker i Vejleområdet. [Seværdige kirker i Vejle](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/sevaerdige-kirker)

- **Hvorfor interessant for en familie:** En let genkendelig silhuet gør arkitekturordet ‘løgkuppel’ konkret og huskbart.
- **Sikkert dokumenteret:** Middelalderlige bygningsdele, 1730'er-ombygning og løgkuppel er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Om børn ser tårnkuplen eller andre tagafslutninger først, og hvilken offentlig vinkel er bedst, kræver feltprøve.
- **Kildekritisk vurdering:** VisitVejle er detaljeret på arkitekturen; menighedsrådet bekræfter aktuel institution, ikke facitformen.

#### Stedet som spil

- **Konkret observerbar invariant:** tårnets karakteristiske løgformede kuppel.
- **Hvorfor permanent/helårsrobust:** Kuplen er en konstruktiv del af kirkens tårn.
- **Spilleren skal konkret:** observere tårnets øverste hovedform fra lovligt kirkeareal.
- **Spilleren skal eksplicit ignorere:** korset/vejrhane, små spir, trætoppe, kapellets tag og Engelsholms tårne.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop tårnets karakteristiske løgformede kuppel; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** ‘Løg’ kan opleves subjektivt; singleChoice gør svaret fair, men silhuetten kan skjules af løv.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken form har afslutningen på Nørup Kirkes tårn?”
- **Svarmuligheder ved `singleChoice`:** `En løgkuppel` **(korrekt)**; `Et fladt tag`; `En spids pyramide`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `En løgkuppel`
- **Accepterede svarformer, facit først:** `En løgkuppel`, `løgkuppel`, `løgformet kuppel`, `løgformet`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Et fladt tag` → Se helt op over tårnmurene.
- `En spids pyramide` → Toppen buer ud og ind, før den ender i spidsen.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Nørup Kirke** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Gerhard de Lichtenberg lod kirken ombygge i 1730'erne og tilføjede løgkuplede afslutninger. [Nørup Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933)
3. Udfør kun denne observation: observere tårnets øverste hovedform fra lovligt kirkeareal; udelad korset/vejrhane, små spir, trætoppe, kapellets tag og Engelsholms tårne.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`En løgkuppel`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Nørup Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find tårnets karakteristiske løgformede kuppel ved Nørup Kirke; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: observere tårnets øverste hovedform fra lovligt kirkeareal. Ignorér korset/vejrhane, små spir, trætoppe, kapellets tag og Engelsholms tårne.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Profilen ligner et løg med rund bug og smal top.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste en løgkuppel på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Middelalderkirken omformet af en 1700-tals godsejer bliver håndgribelig, fordi I selv fandt tårnets karakteristiske løgformede kuppel.
- `historyFact`: Den løgkuplede omformning knyttes til Gerhard de Lichtenbergs arbejde i 1730'erne. [Nørup Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Nørup Kirke`
- `postalCode`: `7182`
- `address`: `De Lichtenbergs Vej 32, 7182 Bredsten`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Nørup Kirke](https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — kirken er besøgsformidlet, men udendørs adgang, handlinger og kirkegårdsregler skal kontrolleres. [Randbøl og Nørup Kirker](https://www.randboel-noerupkirker.dk/)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `crowding`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** kirkeplads/kirkegårdssti; trin og grus ukendt
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentlig kirkeplads uden for gravfelter og med afstand til vej/handlinger.

**Kandidatspecifik feltcheckliste**

- Bekræft helårssynslinje uden løvskjul.
- Afklar adgang og hensyn med menighedsrådet.
- Test svarmuligheder, underlag, parkering og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933
- Motiv: et oversigts- eller detaljefoto af tårnets karakteristiske løgformede kuppel; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.randboel-noerupkirker.dk/
- Motiv: et oversigts- eller detaljefoto af tårnets karakteristiske løgformede kuppel; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Randbøl-Nørup Menighedsråd eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Randbøl-Nørup Menighedsråd / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Nørup Kirke
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/noerup-kirke-gdk607933
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: adresse, bygningsperioder og løgkuppel

**Kilde 2**
- `title`: Randbøl og Nørup Kirker
- `publisher`: Randbøl-Nørup Menighedsråd
- `url`: https://www.randboel-noerupkirker.dk/
- `kind`: `other`
- `accessed`: `2026-08-03`
- `supports`: aktuel kirkelig forvaltning

**Kilde 3**
- `title`: Seværdige kirker i Vejle
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/sevaerdige-kirker
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: regional besøgsrelevans


### 42 — Tirsbæk Gods set fra den offentlige fjordsti

#### Identitet og prioritering

- **rangnummer:** `42`
- **samlet score:** **56/100** — Stærk herregårdsgeografi og offentlig rutealternativ til parken; facit må kun bruges, hvis vandet ses sikkert fra ruten.
- **stedets officielle eller mest præcise navn:** Tirsbæk Gods set fra den offentlige fjordsti
- **postnummer:** `7120`
- **adresse/stedbeskrivelse:** Offentlig sti/eng ved Tirsbækvej 135, 7120 Vejle Øst; ingen adgang til privat hovedbygning
- **område/by:** Tirsbæk
- **foreslået opgavetitel:** Vandet omkring herregårdsholmen
- **kort titel:** En voldgrav
- **spillerrettet beskrivelse:** I må ikke gå ind til slottet. Brug kun den offentlige sti og se, hvad der gør hovedbygningen til en ø i miniature.
- **tags:** `herregård`, `voldgrav`, `fjord`, `offentlig sti`
- **klynge/rute:** Vejle fjord og Tirsbæk
- **nærliggende kandidater:** 23 Skyttehushaven som separat fjordstop

#### Dokumenteret historie

**Centrale fakta**

- Tirsbæk Gods er en historisk herregård ved Vejle Fjord, og hovedbygningen er privat. [Tirsbæk Gods](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949)
- Hovedbygningen ligger på en holm, der er adskilt fra omgivelserne af voldgrav/vand. [Tirsbæk Gods](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949)
- Den historiske slotspark har særlige adgangsforhold og må ikke antages åbent hele året. [Tirsbæk Slotspark](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-slotspark-gdk607960)
- En offentlig formidlet rute ved Tirsbæk, Ulbækhus og Daugårdstrand giver mulighed for oplevelse i fjordlandskabet. [Vejle Fjord – Tirsbæk, Ulbækhus og Daugårdstrand](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-fjord-tirsbaek-ulbaekhus-og-daugaardstrand-gdk607967)

- **Hvorfor interessant for en familie:** En ‘borg på en ø’ er let at forstå, og opgaven lærer samtidig tydelige private grænser.
- **Sikkert dokumenteret:** Privat hovedbygning, holm/voldgrav og offentlig fjordrute er kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Om voldgraven faktisk er synlig fra den offentlige sti året rundt, og parkens aktuelle sæsonregler, skal verificeres.
- **Kildekritisk vurdering:** VisitVejles separate sted-, park- og rutesider gør adgangskonflikten tydelig; samme udgiver kræver dog lokal ejer-/rutebekræftelse.

#### Stedet som spil

- **Konkret observerbar invariant:** voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne.
- **Hvorfor permanent/helårsrobust:** Voldgraven og holmen er permanente landskabs-/bygningsstrukturer; vegetation og vandstand påvirker udsyn.
- **Spilleren skal konkret:** fra den offentlige sti identificere vandet omkring hovedbygningens holm.
- **Spilleren skal eksplicit ignorere:** fjorden, havedamme, grøfter langs stien, parkkanaler og broer inde på privat område.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Fjordvand eller en grøft kan forveksles med voldgraven; udsigten kan kræve zoom eller privat nærhed og er da uegnet.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvad adskiller hovedbygningens lille holm fra det nærmeste land?”
- **Svarmuligheder ved `singleChoice`:** `En voldgrav` **(korrekt)**; `Et stengærde`; `En jernbane`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `En voldgrav`
- **Accepterede svarformer, facit først:** `En voldgrav`, `voldgrav`, `vand`, `en grav med vand`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Et stengærde` → Se lige foran hovedbygningens holm efter vandfladen.
- `En jernbane` → Ruten ligger i fjordlandskabet; find den smalle vandadskillelse.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Tirsbæk Gods set fra den offentlige fjordsti** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Hovedbygningen ligger på en holm, der er adskilt fra omgivelserne af voldgrav/vand. [Tirsbæk Gods](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949)
3. Udfør kun denne observation: fra den offentlige sti identificere vandet omkring hovedbygningens holm; udelad fjorden, havedamme, grøfter langs stien, parkkanaler og broer inde på privat område.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`En voldgrav`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Tirsbæk Gods](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne ved Tirsbæk Gods set fra den offentlige fjordsti; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra den offentlige sti identificere vandet omkring hovedbygningens holm. Ignorér fjorden, havedamme, grøfter langs stien, parkkanaler og broer inde på privat område.
3. **Hint 3 — “Næsten løsningen” — 5 %:** En klassisk herregårdsholm er omgivet af en grav fyldt med vand.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste en voldgrav på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Renæssanceherregården mellem skov, eng og fjord bliver håndgribelig, fordi I selv fandt voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne.
- `historyFact`: Hovedbygningen er privat og ligger på en holm adskilt af vand/voldgrav. [Tirsbæk Gods](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Tirsbæk Gods set fra den offentlige fjordsti`
- `postalCode`: `7120`
- `address`: `Offentlig sti/eng ved Tirsbækvej 135, 7120 Vejle Øst; ingen adgang til privat hovedbygning`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Tirsbæk Gods](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — kun den offentligt formidlede fjordsti kan bruges; park og gods er ikke helårsforudsætninger. [Vejle Fjord – Tirsbæk, Ulbækhus og Daugårdstrand](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-fjord-tirsbaek-ulbaekhus-og-daugaardstrand-gdk607967) [Tirsbæk Slotspark](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-slotspark-gdk607960)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`privateProperty`, `water`, `cyclePath`]
- **Foreløbige sikkerhedsnoter:** afklar skel og ejer-/driftshensyn; fastlæg afstand/værn ved vand; placér ophold uden for cykelflow.
- **Tilgængelighed — underlag:** kyst-/skovsti med mulig mudder og hældning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret fra offentlig ankomst til udsigt
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et skiltet punkt på den offentlige rute med tydelig afstand til gods, parkgrænse og vandkant.

**Kandidatspecifik feltcheckliste**

- Gå ruten med matrikel-/skiltehensyn og find lovligt udsyn.
- Bekræft at voldgrav kan skelnes fra fjord og grøft uden zoom.
- Kontrollér vandkant, underlag, sæsonløv, GPS og ejerhensyn; fravælg ved tvivl.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949
- Motiv: et oversigts- eller detaljefoto af voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-slotspark-gdk607960
- Motiv: et oversigts- eller detaljefoto af voldgraven/vandløbet, der fysisk adskiller hovedbygningens holm fra omgivelserne; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Tirsbæk Gods
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-gods-gdk607949
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: herregård, holm/voldgrav og privat hovedbygning

**Kilde 2**
- `title`: Tirsbæk Slotspark
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-slotspark-gdk607960
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: parkens begrænsede adgang

**Kilde 3**
- `title`: Vejle Fjord – Tirsbæk, Ulbækhus og Daugårdstrand
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-fjord-tirsbaek-ulbaekhus-og-daugaardstrand-gdk607967
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: offentlig fjordrute

**Sjælden kildeundtagelse:** Tre relevante sider har samme officielle turismeudgiver; kandidaten accepteres kun som ekstern observation og aldrig som tilladelse til godsets private areal.


### 43 — Kunstbroerne over Mølleåen

#### Identitet og prioritering

- **rangnummer:** `43`
- **samlet score:** **55/100** — En god serieopgave med kunstvariation og byvandring; eneste konkrete facitkilde er samlet, og byggearbejder kan ændre ruten.
- **stedets officielle eller mest præcise navn:** Kunstbroerne over Mølleåen
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Mølleå-forløbet mellem Dæmningen og Vissingsgade, 7100 Vejle; præcis start/slut skal feltfastlægges
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Otte broer, otte rækværker
- **kort titel:** Otte broer
- **spillerrettet beskrivelse:** Hver overgang over åen har fået sit eget kunstneriske håndtryk. Tæl broer – ikke rækværkssider – på én fast rute.
- **tags:** `broer`, `kunst`, `Mølleåen`, `byvandring`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 34 Sct. Pouls Kirke, 36 Himmelstigen og 44 Tróndur

#### Dokumenteret historie

**Centrale fakta**

- Den officielle byvandring beskriver otte broer ved Mølleåen med rækværker formgivet af forskellige internationale kunstnere. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Broerne indgår i byens nyere bearbejdning af åforløbet i centrum. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Vejles købstad er historisk formet af ådalene og vandløbene gennem den lave by. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)

- **Hvorfor interessant for en familie:** Børn kan sammenligne mønstre og materialer, mens et gentaget ruteformat holder gruppen i bevægelse.
- **Sikkert dokumenteret:** Den officielle byvandring angiver otte kunstneriske broer/rækværker.
- **Usikkert, omstridt, sagn eller fortolkning:** Start/slut, hvilke overgangstyper der tæller, kunstnernavne og den aktuelle status efter byarbejde er ikke fuldt dokumenteret.
- **Kildekritisk vurdering:** Én konkret turismekilde bærer facit; byhistorien støtter kun vandløbskontekst. En nummereret feltlog er obligatorisk.

#### Stedet som spil

- **Konkret observerbar invariant:** de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb.
- **Hvorfor permanent/helårsrobust:** Broer og faste rækværker er normalt stabile, men centrumombygning eller værnarbejde kan ændre serien.
- **Spilleren skal konkret:** gå én defineret retning og registrere hver selvstændig åkrydsning med kunstnerisk rækværk én gang.
- **Spilleren skal eksplicit ignorere:** to rækværkssider på samme bro, almindelige broer, gangplanker, rør/overdækning og returpassager.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** En bro har to rækværker, og åen kan være overdækket; familier kan få 16 eller inkludere sidegrene.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Følg den godkendte rute langs Mølleåen én vej. Hvor mange broer har et særskilt kunstnerdesignet rækværk?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 8 mappes til decimaltallet `8` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `8`
- **Accepterede svarformer, facit først:** `8`, `otte`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `7` → Kontrollér begge ender af den fastlagte rute efter en sidste kunstbro.
- `16` → Tæl broer, ikke rækværkssider – én overgang er én.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Kunstbroerne over Mølleåen** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Broerne indgår i byens nyere bearbejdning af åforløbet i centrum. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
3. Udfør kun denne observation: gå én defineret retning og registrere hver selvstændig åkrydsning med kunstnerisk rækværk én gang; udelad to rækværkssider på samme bro, almindelige broer, gangplanker, rør/overdækning og returpassager.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 8 mappes til decimaltallet `8` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`8`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb ved Kunstbroerne over Mølleåen; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: gå én defineret retning og registrere hver selvstændig åkrydsning med kunstnerisk rækværk én gang. Ignorér to rækværkssider på samme bro, almindelige broer, gangplanker, rør/overdækning og returpassager.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Den officielle rute beskriver fire par kunstbroer.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste otte broer på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Kunstnerdesignede passager over den genåbnede byå bliver håndgribelig, fordi I selv fandt de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb.
- `historyFact`: Byvandringen beskriver otte broer med rækværker af forskellige internationale kunstnere. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Kunstbroerne over Mølleåen`
- `postalCode`: `7100`
- `address`: `Mølleå-forløbet mellem Dæmningen og Vissingsgade, 7100 Vejle; præcis start/slut skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentligt byforløb, men konkrete afspærringer og ruteændringer skal kontrolleres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`water`, `cyclePath`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** fastlæg afstand/værn ved vand; placér ophold uden for cykelflow; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** bybelægning langs å; broer og mulige ramper
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret; hele serien skal opmåles
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** den offentlige promenade med opholdslommer væk fra broernes cykel-/gangstrøm og uden at læne over åen.

**Kandidatspecifik feltcheckliste**

- Lav en 1–8 foto/GPS-log og definer én rute.
- Skeln bro fra to rækværker og fra almindelige overgange.
- Kontrollér vandværn, byggearbejde, distance, tilgængelighed og GPS.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- Motiv: et oversigts- eller detaljefoto af de otte broer med hver sit kunstnerdesignede rækværk langs det definerede Mølleå-forløb; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: antal broer og kunstnerdesignede rækværker

**Kilde 2**
- `title`: Vejle Købstad
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: vandløbenes byhistoriske kontekst

**Sjælden kildeundtagelse:** Otte-tallet er en researchhypotese fra officiel byvandring; publicering kræver fotos, position og afgrænsning af alle otte.


### 44 — Tróndur – Vejles P-hus

#### Identitet og prioritering

- **rangnummer:** `44`
- **samlet score:** **54/100** — Markant, centralt og veldokumenteret kunstbygning; etagetælling kan blive tvetydig ved ramper/sokkel.
- **stedets officielle eller mest præcise navn:** Tróndur – Vejles P-hus
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Volmers Plads, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Seks lag af glas
- **kort titel:** Seks etager
- **spillerrettet beskrivelse:** Farverne skjuler et meget praktisk hus. Følg de vandrette lag bag glasset og tæl bygningens niveauer.
- **tags:** `glaskunst`, `parkering`, `arkitektur`, `Tróndur Patursson`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 34 Sct. Pouls Kirke, 36 Himmelstigen og 43 Mølleå-broerne

#### Dokumenteret historie

**Centrale fakta**

- Parkeringshuset Tróndur stod færdigt 1. oktober 2005. [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)
- Bygningen har seks etager og plads til cirka 270 biler. [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)
- Glasudsmykningen er skabt af den færøske kunstner Tróndur Patursson. [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)
- P-huset indgår som moderne kunst-/arkitekturstop på byvandringen. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Et hverdagsligt parkeringshus bliver til en farveoplevelse og en øvelse i at aflæse etager.
- **Sikkert dokumenteret:** Dato, seks etager, kapacitet og kunstner er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvilke facadebånd spillere spontant tæller som etager, og om stue/sokkel er visuelt særskilt, skal testes.
- **Kildekritisk vurdering:** Historisk Atlas giver en detaljeret bygningsrecord; byvandringen bekræfter relevans, men ikke uafhængigt etagetal.

#### Stedet som spil

- **Konkret observerbar invariant:** parkeringshusets seks tydelige bygningsniveauer bag glasfacaden.
- **Hvorfor permanent/helårsrobust:** Etageantallet er konstruktivt stabilt; facadeglas kan være midlertidigt dækket.
- **Spilleren skal konkret:** fra modsatte/tilstødende fortov følge de seks vandrette parkeringsniveauer.
- **Spilleren skal eksplicit ignorere:** rampeforløb, glasfarvefelter, kælder, tagkant, biler og nabobygninger.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop parkeringshusets seks tydelige bygningsniveauer bag glasfacaden; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Halvniveauramper kan give flere linjer end etager; en godkendt facadevinkel er nødvendig.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Se på Tróndurs farvede facade fra fortovet. Hvor mange etager/niveauer har parkeringshuset?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 6 mappes til decimaltallet `6` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `6`
- **Accepterede svarformer, facit først:** `6`, `seks`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `5` → Se om stueplanet også er en del af de seks registrerede etager.
- `7` → En tagkant eller rampe er ikke en ekstra etage.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Tróndur – Vejles P-hus** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Bygningen har seks etager og plads til cirka 270 biler. [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)
3. Udfør kun denne observation: fra modsatte/tilstødende fortov følge de seks vandrette parkeringsniveauer; udelad rampeforløb, glasfarvefelter, kælder, tagkant, biler og nabobygninger.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 6 mappes til decimaltallet `6` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`6`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find parkeringshusets seks tydelige bygningsniveauer bag glasfacaden ved Tróndur – Vejles P-hus; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra modsatte/tilstødende fortov følge de seks vandrette parkeringsniveauer. Ignorér rampeforløb, glasfarvefelter, kælder, tagkant, biler og nabobygninger.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Kilden beskriver et halvt dusin etager.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste seks etager på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Færøsk glaskunst omkring et parkeringshus bliver håndgribelig, fordi I selv fandt parkeringshusets seks tydelige bygningsniveauer bag glasfacaden.
- `historyFact`: Glasfacaden er skabt af den færøske kunstner Tróndur Patursson. [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Tróndur – Vejles P-hus`
- `postalCode`: `7100`
- `address`: `Volmers Plads, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Tróndur – Vejles P-hus](https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja til facadeobservation fra offentligt fortov; man behøver ikke gå ind i P-huset. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `crowding`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; undgå kø, events og blokering af passage.
- **Tilgængelighed — underlag:** fortov/bybelægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** et bredt feltgodkendt fortov med helfacadeudsyn, væk fra P-husets ind-/udkørsel.

**Kandidatspecifik feltcheckliste**

- Find facade hvor seks niveauer kan tælles uden rampeforvirring.
- Kortlæg ind-/udkørsel, cykler og opholdsplads.
- Test GPS, refleksioner, mørke og stue-/tagdefinition.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29
- Motiv: et oversigts- eller detaljefoto af parkeringshusets seks tydelige bygningsniveauer bag glasfacaden; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af parkeringshusets seks tydelige bygningsniveauer bag glasfacaden; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Tróndur – Vejles P-hus
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Tr%C3%B3ndur_-_Vejles_P-hus_%282287%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: færdiggørelse, seks etager, kapacitet og kunstner

**Kilde 2**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: byrutekontekst


### 45 — Den skæve lysmast på Nørretorv

#### Identitet og prioritering

- **rangnummer:** `45`
- **samlet score:** **53/100** — Hurtig perspektivopgave og interessant nyere byrumsfortælling; masten kan udskiftes, og hældning kan forveksles med perspektiv.
- **stedets officielle eller mest præcise navn:** Den skæve lysmast på Nørretorv
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Nørretorv, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Masten der ikke står lige
- **kort titel:** Den hælder
- **spillerrettet beskrivelse:** Noget på torvet ser forkert ud med vilje. Brug en huskant som lodlinje og afgør, om den høje mast står lige.
- **tags:** `byrum`, `lys`, `perspektiv`, `Nørretorv`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 08 Kanonkuglehuset, 31 brandtavlen og 33 runefliserne

#### Dokumenteret historie

**Centrale fakta**

- Den officielle byvandring beskriver en cirka 16 meter høj, skæv lysmast på Nørretorv. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Nørretorv lå ved den gamle nordlige bygrænse, og området knyttes til byens første trafiklys i 1961. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- Nørregade/Nørretorv indgår i Vejles historiske købstadsudvikling mod nord. [Vejle Købstad](https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29)

- **Hvorfor interessant for en familie:** En optisk kontrol med lodrette huskanter gør designintentionen til en lille videnskabsøvelse.
- **Sikkert dokumenteret:** Byvandringen beskriver den skæve mast, dens omtrentlige højde og torvets historiske rolle.
- **Usikkert, omstridt, sagn eller fortolkning:** Den aktuelle mast kan være udskiftet eller rettet ved byrumsarbejde; ‘skæv’ kan være visuelt synspunkt-afhængigt.
- **Kildekritisk vurdering:** Kun én kilde er genstandsspecifik; byhistoriekilden støtter ikke mastens nutidige tilstand. Feltbevis er afgørende.

#### Stedet som spil

- **Konkret observerbar invariant:** den permanent konstruerede skæve/hældende lysmast på torvet.
- **Hvorfor permanent/helårsrobust:** Hvis masten er den oprindeligt designede faste installation, er hældningen konstruktiv; lysmaster kan dog udskiftes.
- **Spilleren skal konkret:** sammenligne mastens akse med mindst to tydeligt lodrette bygningskanter fra godkendt punkt.
- **Spilleren skal eksplicit ignorere:** flagstænger, træstammer, kameraets hældning, vejens fald og andre lamper.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop den permanent konstruerede skæve/hældende lysmast på torvet; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Et skævt kamera kan skabe svaret; spørgsmålet skal løses med blotte øjne og lodrette referencer.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Sammenlign den høje mast med husenes lodrette kanter. Hvordan står masten?”
- **Svarmuligheder ved `singleChoice`:** `Den hælder` **(korrekt)**; `Den står helt lodret`; `Den er vandret`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `Den hælder`
- **Accepterede svarformer, facit først:** `Den hælder`, `hælder`, `skæv`, `den er skæv`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Den står helt lodret` → Brug en lodret huskant i baggrunden som sammenligning.
- `Den er vandret` → Se på mastens lange hovedretning fra fod til top.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Den skæve lysmast på Nørretorv** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Nørretorv lå ved den gamle nordlige bygrænse, og området knyttes til byens første trafiklys i 1961. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
3. Udfør kun denne observation: sammenligne mastens akse med mindst to tydeligt lodrette bygningskanter fra godkendt punkt; udelad flagstænger, træstammer, kameraets hældning, vejens fald og andre lamper.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`Den hælder`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find den permanent konstruerede skæve/hældende lysmast på torvet ved Den skæve lysmast på Nørretorv; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: sammenligne mastens akse med mindst to tydeligt lodrette bygningskanter fra godkendt punkt. Ignorér flagstænger, træstammer, kameraets hældning, vejens fald og andre lamper.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Toppen ligger bevidst forskudt i forhold til foden.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste den hælder på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et moderne pejlemærke ved den gamle bygrænse bliver håndgribelig, fordi I selv fandt den permanent konstruerede skæve/hældende lysmast på torvet.
- `historyFact`: Byvandringen kobler torvet til Vejles gamle nordgrænse og et første trafiklys i 1961. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Den skæve lysmast på Nørretorv`
- `postalCode`: `7100`
- `address`: `Nørretorv, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja — offentligt torv; installationens status og anlægsarbejde kontrolleres. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** torvebelægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** torvets opholdszone med lodret facadebaggrund, uden at gå ud i Nørrebrogade/cykelspor.

**Kandidatspecifik feltcheckliste**

- Bekræft at den beskrevne skæve mast stadig findes.
- Fastlæg perspektiv med to lodrette referencer.
- Kontrollér trafik, torveevents, GPS og kommunale anlægsplaner.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- Motiv: et oversigts- eller detaljefoto af den permanent konstruerede skæve/hældende lysmast på torvet; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- Motiv: et oversigts- eller detaljefoto af den permanent konstruerede skæve/hældende lysmast på torvet; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: mastens skæve form, omtrent højde og torvehistorie

**Kilde 2**
- `title`: Vejle Købstad
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_K%C3%B8bstad_%282038%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: købstadens udviklingskontekst

**Sjælden kildeundtagelse:** Den officielle byvandring er eneste kilde til masten; et dateret feltfoto og kommunal anlægsbekræftelse er påkrævet før produktion.


### 46 — Det gamle Vejle Bomuldsspinderi

#### Identitet og prioritering

- **rangnummer:** `46`
- **samlet score:** **52/100** — Stærk industrihistorie og stor bygningsinvariant, men det foreslåede vinduesmønster er ikke tilstrækkeligt tekstkilde-dokumenteret.
- **stedets officielle eller mest præcise navn:** Det gamle Vejle Bomuldsspinderi
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** De bevarede industribygninger øst for Vejle Station mellem banen og Havnegade, 7100 Vejle; præcis facade skal feltfastlægges
- **område/by:** Vejle Havn
- **foreslået opgavetitel:** Spinderiets taktfaste vinduer
- **kort titel:** Den lange række
- **spillerrettet beskrivelse:** En fabrik gentager ofte den samme rytme igen og igen. Find den gamle spinderifacade og vælg det mest tydelige gentagne element.
- **tags:** `bomuld`, `industri`, `Danmarks Manchester`, `havn`
- **klynge/rute:** Vejle havn og industri
- **nærliggende kandidater:** 47 Det Kgl. Toldkammer og 44 Tróndur mod centrum

#### Dokumenteret historie

**Centrale fakta**

- Vejle Bomuldsspinderi begyndte produktion 1. oktober 1892 og var blandt de tidlige store anlæg i dansk bomuldsindustri. [Vejle Bomuldsspinderi](https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29)
- Anlægget voksede fra omkring 1.000 til cirka 12.000 spindler og omfattede flere fabriksbygninger. [Vejle Bomuldsspinderi](https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29)
- Vejle Kommune formidler tekstilindustrien som baggrunden for tilnavnet ‘Danmarks Manchester’. [Tekstilbyen Vejle – Danmarks Manchester](https://www.vejle.dk/da/erhvervsudstilling/tekstilbyen-vejle-danmarks-manchester/)
- Den historiske havnerute peger på de bevarede spinderibygninger i området ved station og havn. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)

- **Hvorfor interessant for en familie:** Vinduesrytmen gør masseproduktionens skala synlig, før familien hører om tusinder af spindler.
- **Sikkert dokumenteret:** Produktionsstart, industriel vækst og den bevarede bygnings historiske funktion er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Det præcise vinduesformat, facadeafsnit og offentlige udsigt er en researchhypotese fra visuelle kilder, ikke tekstbelagt invariant.
- **Kildekritisk vurdering:** Historien er kilde-stærk; opgavegrebet er kilde-svagt. Kandidaten må omskrives til en dokumenteret facadeinskription eller udgå efter feltbesøg.

#### Stedet som spil

- **Konkret observerbar invariant:** en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade.
- **Hvorfor permanent/helårsrobust:** Bygningsvinduer er konstruktive, men ombygning, tilmuring og nye facadepartier kan ændre rytmen.
- **Spilleren skal konkret:** på den feltgodkendte historiske facade identificere det dominerende gentagne bygningsled.
- **Spilleren skal eksplicit ignorere:** nyere bygninger, parkerede tog/biler, indvendige vinduer, ventilationsgitre og tilfældige lamper.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** ‘Lang række’ er subjektivt, og facaden kan have flere vinduestyper; singleChoice er kun acceptabel med et præcist markeret facadefelt.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Se på den feltmarkerede gamle fabriksfacade. Hvilket mønster gentages tydeligst?”
- **Svarmuligheder ved `singleChoice`:** `En lang række ens vinduer` **(korrekt)**; `Store runde kupler`; `Udskårne træfigurer`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `En lang række ens vinduer`
- **Accepterede svarformer, facit først:** `En lang række ens vinduer`, `vinduer`, `vinduesrækken`, `række af vinduer`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Store runde kupler` → Se på fabrikkens lange murflade, ikke byens nyere vartegn.
- `Udskårne træfigurer` → Industrifacaden bruger gentagelse frem for figurskæring.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Det gamle Vejle Bomuldsspinderi** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Anlægget voksede fra omkring 1.000 til cirka 12.000 spindler og omfattede flere fabriksbygninger. [Vejle Bomuldsspinderi](https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29)
3. Udfør kun denne observation: på den feltgodkendte historiske facade identificere det dominerende gentagne bygningsled; udelad nyere bygninger, parkerede tog/biler, indvendige vinduer, ventilationsgitre og tilfældige lamper.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`En lang række ens vinduer`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejle Bomuldsspinderi](https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade ved Det gamle Vejle Bomuldsspinderi; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: på den feltgodkendte historiske facade identificere det dominerende gentagne bygningsled. Ignorér nyere bygninger, parkerede tog/biler, indvendige vinduer, ventilationsgitre og tilfældige lamper.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Produktionen krævede dagslys gennem mange gentagne åbninger.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste den lange række på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Danmarks tidlige bomuldsspinderi ved jernbanen bliver håndgribelig, fordi I selv fandt en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade.
- `historyFact`: Spinderiet begyndte produktion 1. oktober 1892 og voksede til cirka 12.000 spindler. [Vejle Bomuldsspinderi](https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Det gamle Vejle Bomuldsspinderi`
- `postalCode`: `7100`
- `address`: `De bevarede industribygninger øst for Vejle Station mellem banen og Havnegade, 7100 Vejle; præcis facade skal feltfastlægges`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejle Bomuldsspinderi](https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — havneruten placerer bygningen, men et sikkert offentligt facadepunkt mellem bane og vej er ikke dokumenteret. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `construction`, `privateProperty`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; kontrollér aktuelle anlægs-/stilladsforhold; afklar skel og ejer-/driftshensyn.
- **Tilgængelighed — underlag:** fortov/bybelægning nær vej og bane
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** kun en offentlig fortovs-/promenadezone med afstand til bane, parkering og varekørsel; ingen jernbanearealer.

**Kandidatspecifik feltcheckliste**

- Identificér original hovedfacade med bygningshistoriker.
- Find en objektiv, dokumenterbar invariant – ellers fravælg.
- Kontrollér bane/vej, ejerskel, anlægsarbejde, GPS og tilgængelighed.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29
- Motiv: et oversigts- eller detaljefoto af en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejle.dk/da/erhvervsudstilling/tekstilbyen-vejle-danmarks-manchester/
- Motiv: et oversigts- eller detaljefoto af en permanent, feltudvalgt gentagelse af ens højbuede industrivinduer på den historiske hovedfacade; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Kommune eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Kommune / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejle Bomuldsspinderi
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_Bomuldsspinderi_%282005%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: startdato, produktion, spindler og bygningsanlæg

**Kilde 2**
- `title`: Tekstilbyen Vejle – Danmarks Manchester
- `publisher`: Vejle Kommune
- `url`: https://www.vejle.dk/da/erhvervsudstilling/tekstilbyen-vejle-danmarks-manchester/
- `kind`: `municipal`
- `accessed`: `2026-08-03`
- `supports`: tekstilbyens betydning

**Kilde 3**
- `title`: Byvandring ved Vejles havn og fjord
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: nutidig placering på havneruten


### 47 — Det Kongelige Toldkammer

#### Identitet og prioritering

- **rangnummer:** `47`
- **samlet score:** **51/100** — God havnefortælling og bevaringskontrol via før/nu; kronedetaljen skal aflæses i original opløsning og fysisk bekræftes.
- **stedets officielle eller mest præcise navn:** Det Kongelige Toldkammer
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Havnepladsen 2, 7100 Vejle
- **område/by:** Vejle Havn
- **foreslået opgavetitel:** Kronen ved tolden
- **kort titel:** En krone
- **spillerrettet beskrivelse:** Staten satte sit mærke på varer, der kom gennem havnen. Find det kongelige symbol på den gamle toldbygning fra fortovet.
- **tags:** `told`, `havn`, `skibsfart`, `1907`
- **klynge/rute:** Vejle havn og industri
- **nærliggende kandidater:** 46 Bomuldsspinderiet; havnefrontens ekskluderede steder må ikke genbruges

#### Dokumenteret historie

**Centrale fakta**

- Vejle Toldkammer ligger på Havnepladsen 2 og dokumenteres i arkivets før-og-nu-sammenstilling fra 1909 og 2021. [Vejle Toldkammer set fra Havnepladsen, 1909 og 2021](https://www.vejlestadsarkiv.dk/dk/se-hoer/foer-og-nu/vejle-toldkammer-set-fra-havnepladsen-1909-og-2021/)
- Toldkammerbygningen dateres til 1907 og fortæller om told, skibsfart og den ældre havneplads. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)
- Bygningen indgår i den officielle historiske rute ved Vejles havn og fjord. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)

- **Hvorfor interessant for en familie:** Et lille magtsymbol åbner historien om, hvorfor varer blev kontrolleret og beskattet ved havnen.
- **Sikkert dokumenteret:** Adresse, bygningens toldfunktion, 1907-datering og facadebevaring på tværs af før/nu-billeder er kildebelagt.
- **Usikkert, omstridt, sagn eller fortolkning:** Kronesymbolets præcise placering og aktuelle synlighed er udledt af facadebilleder og skal fysisk verificeres; hvis det mangler, skal opgaven omskrives.
- **Kildekritisk vurdering:** Stadsarkivets før/nu-side er stærk visuel dokumentation; turismeruten understøtter historie og lokation, men facitdetaljen kræver nærkontrol.

#### Stedet som spil

- **Konkret observerbar invariant:** det faste kronesymbol ved den historiske toldkammerfacades navn/portal.
- **Hvorfor permanent/helårsrobust:** Et arkitektonisk facade-/portalsymbol kan være stabilt, men restaurering eller skiltning kan skjule det.
- **Spilleren skal konkret:** fra offentligt fortov finde den historiske portal/navnezone og identificere kronen.
- **Spilleren skal eksplicit ignorere:** firmalogoer, flag, skibsmaster, kommunevåben og kroner på midlertidige skilte.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det faste kronesymbol ved den historiske toldkammerfacades navn/portal; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Der kan være flere kroner/logoer på Havnepladsen; det konkrete facadefelt skal være entydigt markeret.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilket kongeligt symbol ses ved den historiske toldkammerfacades navn eller portal?”
- **Svarmuligheder ved `singleChoice`:** `En krone` **(korrekt)**; `Et anker`; `Et tandhjul`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `En krone`
- **Accepterede svarformer, facit først:** `En krone`, `krone`, `kronen`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `Et anker` → Ankeret passer til havnen, men se på statens symbol ved toldfacaden.
- `Et tandhjul` → Det hører snarere til industrien; se over/ved den historiske portaltekst.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Det Kongelige Toldkammer** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Toldkammerbygningen dateres til 1907 og fortæller om told, skibsfart og den ældre havneplads. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)
3. Udfør kun denne observation: fra offentligt fortov finde den historiske portal/navnezone og identificere kronen; udelad firmalogoer, flag, skibsmaster, kommunevåben og kroner på midlertidige skilte.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`En krone`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejle Toldkammer set fra Havnepladsen, 1909 og 2021](https://www.vejlestadsarkiv.dk/dk/se-hoer/foer-og-nu/vejle-toldkammer-set-fra-havnepladsen-1909-og-2021/)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det faste kronesymbol ved den historiske toldkammerfacades navn/portal ved Det Kongelige Toldkammer; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra offentligt fortov finde den historiske portal/navnezone og identificere kronen. Ignorér firmalogoer, flag, skibsmaster, kommunevåben og kroner på midlertidige skilte.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Symbolet viser, at toldkammeret var kongeligt/statligt.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste en krone på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: 1900-tallets port mellem havn, skibe og stat bliver håndgribelig, fordi I selv fandt det faste kronesymbol ved den historiske toldkammerfacades navn/portal.
- `historyFact`: Toldkammeret fra 1907 knyttede Havnepladsen til told og skibsfart. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Det Kongelige Toldkammer`
- `postalCode`: `7100`
- `address`: `Havnepladsen 2, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejle Toldkammer set fra Havnepladsen, 1909 og 2021](https://www.vejlestadsarkiv.dk/dk/se-hoer/foer-og-nu/vejle-toldkammer-set-fra-havnepladsen-1909-og-2021/)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** ja til facadeobservation fra Havnepladsens offentlige areal; ejendommen indvendigt er ikke del af opgaven. [Byvandring ved Vejles havn og fjord](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord)
- `publicAccess`: `true` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `cyclePath`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; placér ophold uden for cykelflow; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** havne-/fortovsbelægning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `yes`
- **Tilgængelighed — barnevogn:** `yes`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentligt fortov/forplads med afstand til kørespor og uden adgang til bygningen.

**Kandidatspecifik feltcheckliste**

- Bekræft kronen, præcis placering og permanent karakter.
- Sammenhold 1909/2021-billeder med 2026-facaden.
- Kontrollér trafik, havnearbejde, GPS, lys og alternative symboler.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlestadsarkiv.dk/dk/se-hoer/foer-og-nu/vejle-toldkammer-set-fra-havnepladsen-1909-og-2021/
- Motiv: et oversigts- eller detaljefoto af det faste kronesymbol ved den historiske toldkammerfacades navn/portal; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord
- Motiv: et oversigts- eller detaljefoto af det faste kronesymbol ved den historiske toldkammerfacades navn/portal; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VisitVejle eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VisitVejle / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: nutidigt dokumentations-/formidlingsmateriale.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejle Toldkammer set fra Havnepladsen, 1909 og 2021
- `publisher`: Vejle Stadsarkiv
- `url`: https://www.vejlestadsarkiv.dk/dk/se-hoer/foer-og-nu/vejle-toldkammer-set-fra-havnepladsen-1909-og-2021/
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: adresse, bygningsidentitet og før/nu-facade

**Kilde 2**
- `title`: Byvandring ved Vejles havn og fjord
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-ved-vejles-havn-og-fjord
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: 1907, told-/skibsfartshistorie og rute


### 48 — Mamrelund

#### Identitet og prioritering

- **rangnummer:** `48`
- **samlet score:** **50/100** — Fin genbrugshistorie og tydelig formhypotese; privat bolig og facadeændringer gør felt- og beboerhensyn afgørende.
- **stedets officielle eller mest præcise navn:** Mamrelund
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Jacob Gades Stræde 2, 7100 Vejle
- **område/by:** Vejle Midtby
- **foreslået opgavetitel:** Buen i missionshuset
- **kort titel:** En spidsbue
- **spillerrettet beskrivelse:** Et gammelt samlingshus er blevet bolig, men en kirkelig inspireret form sidder stadig i facaden. Se udefra og vælg buen.
- **tags:** `missionshus`, `genbrug`, `facade`, `arkitektur`
- **klynge/rute:** Vejle historiske centrum
- **nærliggende kandidater:** 36 Himmelstigen, 44 Tróndur og 47 Toldkammeret mod havnen

#### Dokumenteret historie

**Centrale fakta**

- Missionshuset Mamrelund i Jacob Gades Stræde blev indviet i 1885. [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)
- Bygningen blev udvidet i 1905 efter tidlige konstruktionsproblemer. [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)
- Den tidligere missionshusbygning blev omdannet til ungdomsboliger omkring 2001. [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)
- Et arkivfoto identificerer Mamrelund på Jacob Gades Stræde 2 og dokumenterer facaden historisk. [Missionshuset Mamrelund, Jacob Gades Stræde 2](https://arkiv.dk/vis/2246951)

- **Hvorfor interessant for en familie:** Børn kan opdage, at bygninger skifter funktion, mens former fra den gamle brug kan overleve.
- **Sikkert dokumenteret:** Indvielse, 1905-udvidelse, senere boligomdannelse og historisk facade er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Den store spidsbues aktuelle bevaring og præcise afgrænsning fra vindue/portal er primært visuelt, ikke tekstligt dokumenteret.
- **Kildekritisk vurdering:** Historisk Atlas og Arkiv.dk/Vejle Stadsarkiv er stærke på historie og billeder; nutidig facade skal sammenholdes fysisk.

#### Stedet som spil

- **Konkret observerbar invariant:** den store spidsbuede facadeåbning på det tidligere missionshus.
- **Hvorfor permanent/helårsrobust:** En muret hovedbue forventes bygningsfast, men boligrenovering kan ændre åbningen.
- **Spilleren skal konkret:** fra offentligt stræde identificere den største gamle bue i facaden og sammenligne dens topform.
- **Spilleren skal eksplicit ignorere:** almindelige rektangulære vinduer, dørens glas, taggavl og nabobygninger.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop den store spidsbuede facadeåbning på det tidligere missionshus; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Gavlen selv kan være trekantet, mens spørgsmålet søger åbningens spidsbue; flere buer kan findes.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `singleChoice`
- **Præcist spillerrettet spørgsmål:** “Hvilken form har den store historiske bue i Mamrelunds facade?”
- **Svarmuligheder ved `singleChoice`:** `En spidsbue` **(korrekt)**; `En rundbue`; `En helt firkantet åbning`
- **Kodelængde ved `numericCode`:** `ikke relevant`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Ikke relevant for denne opgavetype.
- **Kanonisk facit:** `En spidsbue`
- **Accepterede svarformer, facit først:** `En spidsbue`, `spidsbue`, `spidsbuet`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `En rundbue` → Se helt op i buens top – mødes siderne i en spids?
- `En helt firkantet åbning` → Se på den historiske store åbning, ikke de nyere standardvinduer.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Mamrelund** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Bygningen blev udvidet i 1905 efter tidlige konstruktionsproblemer. [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)
3. Udfør kun denne observation: fra offentligt stræde identificere den største gamle bue i facaden og sammenligne dens topform; udelad almindelige rektangulære vinduer, dørens glas, taggavl og nabobygninger.
4. Anvend den eksplicitte regel: vælg eller skriv den betegnelse, der direkte beskriver den observerede egenskab; ingen skjult omkodning eller ekstra regel bruges.
5. Observation og regel giver facit **`En spidsbue`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find den store spidsbuede facadeåbning på det tidligere missionshus ved Mamrelund; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra offentligt stræde identificere den største gamle bue i facaden og sammenligne dens topform. Ignorér almindelige rektangulære vinduer, dørens glas, taggavl og nabobygninger.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Buens to sider mødes i et punkt i toppen.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste en spidsbue på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Vejles gamle missionshus genbrugt som boliger bliver håndgribelig, fordi I selv fandt den store spidsbuede facadeåbning på det tidligere missionshus.
- `historyFact`: Mamrelund blev indviet som missionshus i 1885 og senere omdannet til boliger. [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Mamrelund`
- `postalCode`: `7100`
- `address`: `Jacob Gades Stræde 2, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Vejle Missionshus ‘Mamrelund’](https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — facadeobservation fra strædet virker sandsynlig, men kilden dokumenterer ikke udtrykkeligt offentligt observationsareal; bygningen er bolig og må ikke betrædes eller fotograferes ind gennem vinduer. [Missionshuset Mamrelund, Jacob Gades Stræde 2](https://arkiv.dk/vis/2246951)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`privateProperty`, `traffic`]
- **Foreløbige sikkerhedsnoter:** afklar skel og ejer-/driftshensyn; hold familien helt uden for køreareal.
- **Tilgængelighed — underlag:** smalt byfortov/stræde
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentligt fortov med kort ophold og uden at blokere beboerindgang eller rette kamera mod boliger.

**Kandidatspecifik feltcheckliste**

- Bekræft nutidig spidsbue mod arkivfoto.
- Vurder privatliv, fortovsbredde og om opgaven kan løses uden foto.
- Kontrollér trafik, GPS og alternative buer.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29
- Motiv: et oversigts- eller detaljefoto af den store spidsbuede facadeåbning på det tidligere missionshus; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://arkiv.dk/vis/2246951
- Motiv: et oversigts- eller detaljefoto af den store spidsbuede facadeåbning på det tidligere missionshus; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Arkiv.dk / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Arkiv.dk / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Vejle Missionshus ‘Mamrelund’
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/Vejle_Missionshus_%22Mamrelund%22_%287040%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: indvielse, udvidelse, ombygning og adresse

**Kilde 2**
- `title`: Missionshuset Mamrelund, Jacob Gades Stræde 2
- `publisher`: Arkiv.dk / Vejle Stadsarkiv
- `url`: https://arkiv.dk/vis/2246951
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: historisk facadefoto og adresse


### 49 — Bygningen – Arbejdernes Forsamlingsbygning

#### Identitet og prioritering

- **rangnummer:** `49`
- **samlet score:** **49/100** — Stærk socialhistorie og præcist år; det er endnu ikke bevist, at 1920 står som permanent, offentligt synlig facadeinvariant.
- **stedets officielle eller mest præcise navn:** Bygningen – Arbejdernes Forsamlingsbygning
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Ved Anlæget 14, 7100 Vejle
- **område/by:** Vejle Midtby vest
- **foreslået opgavetitel:** Arbejdernes årstal
- **kort titel:** 1920
- **spillerrettet beskrivelse:** Huset blev bygget til fællesskab. Find årstallet på den historiske facade eller faste plade – ikke et arrangementsår.
- **tags:** `arbejderhistorie`, `forsamlingshus`, `1920`, `Flegborg`
- **klynge/rute:** Vejle centrum vest
- **nærliggende kandidater:** 25 vildtbanestenene, 30 Spinderihallerne, 35 Kunstmuseet og 50 Villa Flegborg

#### Dokumenteret historie

**Centrale fakta**

- Arbejdernes Forsamlingsbygning på Ved Anlæget 14 blev taget i brug 24. oktober 1920. [Arbejdernes Forsamlingsbygning](https://historiskatlas.dk/_%289967%29)
- Vejle Stadsarkiv markerede bygningens 100-årshistorie i 2020. [Bygningen i Vejle fylder 100 år](https://www.vejlestadsarkiv.dk/dk/om-os/aktuelt/bygningen-i-vejle-fylder-100-aar-og-vejle-stadsarkiv-indsamler-materiale-om-bygningens-historie/)
- Huset blev skabt som samlingssted for arbejderbevægelsens møder og aktiviteter. [Arbejdernes Forsamlingsbygning](https://historiskatlas.dk/_%289967%29)
- Området omkring Anlægget og Flegborg indgår i Vejles historiske byvandring. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel)

- **Hvorfor interessant for en familie:** Et lokalt mødehus gør demokrati, foreningsliv og arbejdsliv konkret.
- **Sikkert dokumenteret:** Adresse, indvielsesdato og arbejderbevægelsens funktion er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** At 1920 er synligt på en permanent udendørs plade/facade i 2026 er en felt-hypotese; events viser mange andre årstal.
- **Kildekritisk vurdering:** To arkivkilder giver stærk historie; selve facitbæreren mangler tekstlig dokumentation og skal erstattes, hvis feltet ikke bekræfter den.

#### Stedet som spil

- **Konkret observerbar invariant:** det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade.
- **Hvorfor permanent/helårsrobust:** En indhugget/fikseret byggeplade kan være stabil; en plakat eller digital skærm er uacceptabel.
- **Spilleren skal konkret:** finde en fast historisk facadeplade/inskription og knytte 1920 til bygningens indvielse.
- **Spilleren skal eksplicit ignorere:** plakater, koncertdatoer, 100-årsmarkeringens 2020, husnummer 14 og copyrightår.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** 1920 og 2020 optræder begge naturligt i formidlingen; kun en permanent onsite-inskription kan bære facit.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Find det historiske årstal, der hører til Arbejdernes Forsamlingsbygning. Hvilke fire cifre står der?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `4`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Aflæs det trykte/indhuggede tal fra venstre mod højre. Cifrene mappes én-til-én som `1`→`1`, `9`→`9`, `2`→`2`, `0`→`0` og samles uden mellemrum til `1920`. Kodelængden er 4, og eventuelle foranstillede nuller skulle bevares.
- **Kanonisk facit:** `1920`
- **Accepterede svarformer, facit først:** `1920`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `2020` → Det er 100-årsmarkeringen; selve bygningen blev taget i brug hundrede år tidligere.
- `1919` → Kontrollér det sidste ciffer på den faste historiske markering.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Bygningen – Arbejdernes Forsamlingsbygning** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Vejle Stadsarkiv markerede bygningens 100-årshistorie i 2020. [Bygningen i Vejle fylder 100 år](https://www.vejlestadsarkiv.dk/dk/om-os/aktuelt/bygningen-i-vejle-fylder-100-aar-og-vejle-stadsarkiv-indsamler-materiale-om-bygningens-historie/)
3. Udfør kun denne observation: finde en fast historisk facadeplade/inskription og knytte 1920 til bygningens indvielse; udelad plakater, koncertdatoer, 100-årsmarkeringens 2020, husnummer 14 og copyrightår.
4. Anvend den eksplicitte regel: Aflæs det trykte/indhuggede tal fra venstre mod højre. Cifrene mappes én-til-én som `1`→`1`, `9`→`9`, `2`→`2`, `0`→`0` og samles uden mellemrum til `1920`. Kodelængden er 4, og eventuelle foranstillede nuller skulle bevares.
5. Observation og regel giver facit **`1920`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Arbejdernes Forsamlingsbygning](https://historiskatlas.dk/_%289967%29)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade ved Bygningen – Arbejdernes Forsamlingsbygning; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: finde en fast historisk facadeplade/inskription og knytte 1920 til bygningens indvielse. Ignorér plakater, koncertdatoer, 100-årsmarkeringens 2020, husnummer 14 og copyrightår.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Bygningen fyldte 100 år i 2020.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste 1920 på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: Et hundrede år gammelt samlingssted for arbejderbevægelsen bliver håndgribelig, fordi I selv fandt det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade.
- `historyFact`: Forsamlingsbygningen blev taget i brug 24. oktober 1920. [Arbejdernes Forsamlingsbygning](https://historiskatlas.dk/_%289967%29)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Bygningen – Arbejdernes Forsamlingsbygning`
- `postalCode`: `7100`
- `address`: `Ved Anlæget 14, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Arbejdernes Forsamlingsbygning](https://historiskatlas.dk/_%289967%29)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `standard` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — facade fra offentligt fortov, men en egnet fast årstalsmarkering og eventdrift skal bekræftes. [Arbejdernes Forsamlingsbygning](https://historiskatlas.dk/_%289967%29)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `crowding`, `construction`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; undgå kø, events og blokering af passage; kontrollér aktuelle anlægs-/stilladsforhold.
- **Tilgængelighed — underlag:** fortov/forplads
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentligt fortov ved hovedfacaden uden at blokere indgang, kø eller varelevering.

**Kandidatspecifik feltcheckliste**

- Bekræft om 1920 findes fast og udendørs; ellers omskriv/forkast.
- Registrér alle konkurrerende årstal og eventskilte.
- Kontrollér fortov, eventtrængsel, GPS og ejeraccept.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/_%289967%29
- Motiv: et oversigts- eller detaljefoto af det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlestadsarkiv.dk/dk/om-os/aktuelt/bygningen-i-vejle-fylder-100-aar-og-vejle-stadsarkiv-indsamler-materiale-om-bygningens-historie/
- Motiv: et oversigts- eller detaljefoto af det firecifrede bygnings-/indvielsesår på eller ved den historiske hovedfacade; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Arbejdernes Forsamlingsbygning
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/_%289967%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: adresse, dato, funktion og bygningshistorie

**Kilde 2**
- `title`: Bygningen i Vejle fylder 100 år
- `publisher`: Vejle Stadsarkiv
- `url`: https://www.vejlestadsarkiv.dk/dk/om-os/aktuelt/bygningen-i-vejle-fylder-100-aar-og-vejle-stadsarkiv-indsamler-materiale-om-bygningens-historie/
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: 100-årsmarkering og fortsat kulturhistorisk betydning

**Kilde 3**
- `title`: Byvandring i Vejles gamle bydel
- `publisher`: VisitVejle
- `url`: https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel
- `kind`: `officialTourism`
- `accessed`: `2026-08-03`
- `supports`: områderute


### 50 — Villa Flegborg

#### Identitet og prioritering

- **rangnummer:** `50`
- **samlet score:** **48/100** — God kobling mellem bolig og industri med kildefast etagetal; visuelt facit er let tvetydigt ved kælder/tag og privat brug.
- **stedets officielle eller mest præcise navn:** Villa Flegborg
- **postnummer:** `7100`
- **adresse/stedbeskrivelse:** Flegborg 6, 7100 Vejle
- **område/by:** Vejle Midtby vest
- **foreslået opgavetitel:** Fire etager til støberiejeren
- **kort titel:** Fire etager
- **spillerrettet beskrivelse:** En industrimands bolig skulle kunne ses. Følg den godkendte tælleregel på hovedfacaden og find husets etager uden at gå ind på grunden.
- **tags:** `villa`, `C.M. Hess`, `industri`, `Flegborg`
- **klynge/rute:** Vejle centrum vest
- **nærliggende kandidater:** 35 Vejle Kunstmuseum og 49 Bygningen

#### Dokumenteret historie

**Centrale fakta**

- Villa Flegborg på Flegborg 6 blev opført omkring 1905–1906. [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
- Villaen er cirka 1.600 kvadratmeter stor og beskrives med fire etager. [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
- Mange oprindelige bygningsdetaljer er bevaret. [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
- C.M. Hess etablerede sit jernstøberi i Vejle i 1876; virksomheden lukkede i 1975. [C. M. Hess’ Jernstøberi](https://historiskatlas.dk/C._M._Hess%E2%80%99_Jernst%C3%B8beri_%282045%29)

- **Hvorfor interessant for en familie:** Villaen gør forskellen mellem fabriksejerens hjem og arbejdernes forsamlingshus synlig i samme kvarter.
- **Sikkert dokumenteret:** Adresse, byggeår, omtrent størrelse, fire etager og forbindelse til C.M. Hess er dokumenteret.
- **Usikkert, omstridt, sagn eller fortolkning:** Hvordan fire etager kan aflæses på facaden – især høj kælder og tagetage – kræver en eksplicit felttegnet tælleregel.
- **Kildekritisk vurdering:** VejleWiki/Stadsarkiv er genstandsspecifik; Historisk Atlas understøtter industrimanden, men ikke villaens etagetal uafhængigt.

#### Stedet som spil

- **Konkret observerbar invariant:** villaens fire bygningsetager efter en feltfastlagt tælleregel.
- **Hvorfor permanent/helårsrobust:** Bygningens etager er permanente, men facadens visuelle bånd kan være tvetydige.
- **Spilleren skal konkret:** fra offentligt fortov matche fire vindues-/gulvniveauer efter en illustreret, fair tælleregel.
- **Spilleren skal eksplicit ignorere:** kælderåbninger hvis tællereglen udelukker dem, tagkviste, skorsten, nabohuse og terrænets fald.
- **Hvorfor ikke hjemmefra alene:** Det kan være muligt at opsøge baggrund eller endda gætte facit online, men en gyldig løsning kræver aktivering på stedet og fysisk identifikation af netop villaens fire bygningsetager efter en feltfastlagt tælleregel; opgaven må ikke godkende ren forhåndsviden.
- **Foreløbig lokationsrelevans:** **4/5** — observationen er knyttet til selve stedet og kan ikke flyttes til et generisk kort-/quizspørgsmål uden at miste hovedpointen.
- **Sandsynlig tvetydighed/fejlkilde:** Kilden siger fire etager, men almindelige spillere kan få tre eller fem afhængigt af kælder/loft; kandidaten kan kræve et andet facit.

#### Opgaveudkast

- `status`: `draft`
- `difficulty`: `2` af 5 — kognitiv udfordring; fysisk risiko må aldrig øge sværhedsgraden
- `estimatedMinutes`: `3`
- `basePoints`: `100`
- `fictionLabel`: `Fiktiv ramme — historiske fakta og facit er dokumenteret nedenfor.`
- **Fiktiv ramme:** En budbringer fra fortiden beder familien aflæse det spor, som stadig kan ses på stedet.
- `questionKind`: `numericCode`
- **Præcist spillerrettet spørgsmål:** “Se på Villa Flegborgs hovedfacade fra fortovet. Hvor mange etager har bygningen, når kælder/stue-tællereglen på stedet følges?”
- **Svarmuligheder ved `singleChoice`:** Ikke relevant.
- **Kodelængde ved `numericCode`:** `1`
- **Fuld mapping/læserækkefølge ved `numericCode`:** Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
- **Kanonisk facit:** `4`
- **Accepterede svarformer, facit først:** `4`, `fire`

**Sandsynlige nærved-svar og hjælpsom feedback**

- `3` → Kontrollér om det nederste beboede niveau indgår i stedets fire etager.
- `5` → En tagkvist eller kælderåbning er ikke nødvendigvis en ekstra etage; følg den viste tælleregel.

**Fuldt løsningsbevis**

1. Gå til den feltgodkendte aktiveringszone ved **Villa Flegborg** og find det objekt/forløb, som spørgsmålet navngiver; andre objekter på stedet er ude af scope.
2. Kildekontrollen etablerer den forventede fysiske egenskab: Villaen er cirka 1.600 kvadratmeter stor og beskrives med fire etager. [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
3. Udfør kun denne observation: fra offentligt fortov matche fire vindues-/gulvniveauer efter en illustreret, fair tælleregel; udelad kælderåbninger hvis tællereglen udelukker dem, tagkviste, skorsten, nabohuse og terrænets fald.
4. Anvend den eksplicitte regel: Tæl kun de afgrænsede objekter. Totalen 4 mappes til decimaltallet `4` og indtastes som ét ciffer; ingen mellemrum, fortegn eller ekstra nul.
5. Observation og regel giver facit **`4`**. Før publicering skal et menneske gentage samme bevis i felt; onlinekilden alene er ikke et solve-bevis. Hovedkilde: [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)

**Præcis tre progressive hints**

1. **Hint 1 — “Hvor” — 3 %:** Find villaens fire bygningsetager efter en feltfastlagt tælleregel ved Villa Flegborg; bliv i det foreslåede sikre observationsområde.
2. **Hint 2 — “Hvordan” — 4 %:** Brug denne metode: fra offentligt fortov matche fire vindues-/gulvniveauer efter en illustreret, fair tælleregel. Ignorér kælderåbninger hvis tællereglen udelukker dem, tagkviste, skorsten, nabohuse og terrænets fald.
3. **Hint 3 — “Næsten løsningen” — 5 %:** Kilden beskriver villaen som fireetagers; find fire gennemgående gulvniveauer.

**Belønningstekster**

- `headline`: **Hemmeligheden er fundet!**
- `subheadline`: I aflæste fire etager på det rigtige sted.
- `messageLabel`: **Stedets spor**
- `message`: C.M. Hess' store villa ved det gamle industrikvarter bliver håndgribelig, fordi I selv fandt villaens fire bygningsetager efter en feltfastlagt tælleregel.
- `historyFact`: Villaen fra cirka 1905–1906 beskrives som en fireetagers bygning på omkring 1.600 m². [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
- **Foreløbig entydighed:** **4/5** — kanonisk facit og tælleregel er eksplicitte, men den beskrevne feltfejl skal være løst før publicering.

#### Stedsdata og feltbesøg

- `name`: `Villa Flegborg`
- `postalCode`: `7100`
- `address`: `Flegborg 6, 7100 Vejle`
- `researchCoordinate`: **ikke fundet — der er ikke fundet et autoritativt punktkoordinat, og decimaler må ikke opfindes**. De brugte sider dokumenterer sted/adresse, men ikke et præcist, autoritativt decimalpunkt for den sikre observation. **IKKE FELTVERIFICERET STARTSTED.** [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
- `latitude`: `null`
- `longitude`: `null`
- `activationRadiusMetres`: `45` — standardforslag, skal feltverificeres
- `maxAcceptableAccuracyMetres`: `40` — standardforslag, skal feltverificeres; overstiger ikke aktiveringsradius
- `dwellSeconds`: `20`
- `accuracyProfile`: `urbanCanyon` — foreløbigt; bygningsmasse, trædække og faktisk GPS-spredning skal måles
- **Foreløbig offentlig adgang:** usikker — facadeobservation fra fortov virker sandsynlig, men den brugte kilde dokumenterer ikke udtrykkeligt offentligt observationsareal; grunden og bygningen må behandles som privat. [Villa Flegborg](https://www.vejlewiki.dk/index.php?title=Villa_Flegborg)
- `publicAccess`: `false` — kladdeværdi; `true` kun hvor den citerede autoritative kilde faktisk dokumenterer offentlig adgang
- **Foreløbige sikkerhedsflag:** [`traffic`, `privateProperty`]
- **Foreløbige sikkerhedsnoter:** hold familien helt uden for køreareal; afklar skel og ejer-/driftshensyn.
- **Tilgængelighed — underlag:** fortov ved gade med mulig hældning
- **Tilgængelighed — hældning/trin:** ukendt — skal feltverificeres, også hvor onlinekilden antyder plant areal
- **Tilgængelighed — kørestol:** `unknown`
- **Tilgængelighed — barnevogn:** `unknown`
- **Tilgængelighed — afstand fra adgang:** ikke dokumenteret
- **Tilgængelighedsnoter:** Onlinevurderingen er ikke et løfte; mål bredde, kanter, hvilemulighed og alternativ solve-vinkel med brugerrepræsentanter.
- `fieldVerified`: `false`
- `lastPhysicallyVerified`: `null`
- **Forslag til sikkert observationsområde — ikke godkendt:** offentligt fortov på modsatte/egen side efter trafikvurdering; ingen indgang på grund eller fotografering ind i boliger.

**Kandidatspecifik feltcheckliste**

- Tegn og solve-test en entydig fire-etagers tælleregel.
- Bekræft offentlig synslinje og aktuel privat anvendelse.
- Kontrollér trafik, terrænfald, GPS, privatliv og evt. bedre facadeinvariant.

**Mennesket skal færdiggøre**

- **Fakta:** sammenhold alle væsentlige påstande og eventuelle kildekonflikter med lokalt arkiv/ejer; ret intet lydløst.
- **Opgavetekst:** redigér i børnehøjde og solve-test, at spørgsmålet hverken afslører facit eller kræver forkundskab.
- **Facit:** fotografér invariant og alle forvekslingsobjekter; dokumentér accepterede og afviste svar.
- **Feltforhold:** registrér fysisk GPS-startpunkt, radius, nøjagtighed, dwell, adgang, åbningstid, sikkerhed og tilgængelighed.
- **Medier:** vælg højst nødvendige medier, som ikke afslører løsningen; registrér rigtige media-id'er senere.
- **Rettigheder:** indhent skriftlig licens, ejer, fotograf og kreditering; ellers behold alle mediereferencer som `null`.
- **Test:** gennemfør mindst én familie-solve-test og én tilgængeligheds-/sikkerhedsgennemgang; behold `draft`, `fieldVerified: false` og `lastPhysicallyVerified: null` indtil fysisk godkendelse.

#### Medier og rettigheder

Teknisk kan kandidaten oprettes med alle mediareferencer som `null` og `cards: []`. Følgende er kun steder at begynde en rettighedsforespørgsel:

**Medieforslag 1 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://www.vejlewiki.dk/index.php?title=Villa_Flegborg
- Motiv: et oversigts- eller detaljefoto af villaens fire bygningsetager efter en feltfastlagt tælleregel; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis VejleWiki / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `VejleWiki / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**Medieforslag 2 — rettighedsforespørgsel, ikke et godkendt aktiv**
- URL: https://historiskatlas.dk/C._M._Hess%E2%80%99_Jernst%C3%B8beri_%282045%29
- Motiv: et oversigts- eller detaljefoto af villaens fire bygningsetager efter en feltfastlagt tælleregel; billedet må ikke vise facit på en måde, der gør onsite-observation overflødig.
- Ejer: sandsynligvis Historisk Atlas / Vejle Stadsarkiv eller den fotograf, siden krediterer; ejer skal identificeres direkte.
- Licens/tilladelse: rettigheder ikke afklaret — må ikke bruges.
- Kreditering: foreløbigt `Historisk Atlas / Vejle Stadsarkiv / fotograf ikke fundet`; må først fastsættes efter skriftlig tilladelse.
- Begrænsninger: webpublicering er ikke en genbrugslicens; beskæring, appbrug, varighed og territorium skal aftales. Type: historisk eller blandet historisk/nutidigt.

**AI-mediegrænse:** Et eventuelt AI-genereret stemningsbillede må ikke ligne et autentisk historisk fotografi og må aldrig bære den observation, der løser opgaven.

#### Kildedata

**Kilde 1**
- `title`: Villa Flegborg
- `publisher`: VejleWiki / Vejle Stadsarkiv
- `url`: https://www.vejlewiki.dk/index.php?title=Villa_Flegborg
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: adresse, byggeår, størrelse, fire etager og bevaring

**Kilde 2**
- `title`: C. M. Hess’ Jernstøberi
- `publisher`: Historisk Atlas / Vejle Stadsarkiv
- `url`: https://historiskatlas.dk/C._M._Hess%E2%80%99_Jernst%C3%B8beri_%282045%29
- `kind`: `archive`
- `accessed`: `2026-08-03`
- `supports`: ejerens industrihistoriske kontekst


## 6. Foreslåede klynger og ruter

Ingen afstand eller rejsetid i denne sektion er fremsat som kontrolleret fakta. ‘Rute’ betyder en redaktionel gruppering, indtil en feltperson har gået/kørt den lovlige forbindelse.

| Klynge / udflugt | Kandidater | Praktisk idé | Feltforbehold |
|---|---|---|---|
| Jelling-monumenterne | 01, 06, 09, 13, 19 | Én samlet verdensarvsrunde med høj variation: sten, geometri og landskab. | Den reelle solve-rute, højdeforskelle og eventtrængsel skal måles; ingen gangtid oplyses som fakta. |
| Vejle historiske centrum | 03, 05, 07, 08, 12, 24, 31–36, 43–45, 48 | Deles redaktionelt i to eller tre korte gåruter, så børn ikke skal gennemføre alle stop i én mission. | Cyklister, gågadeevents, GPS mellem huse, kirkelige handlinger og byarbejde. |
| Vejle centrum vest / Flegborg | 25, 30, 35, 49, 50 | Industri, kunst, arbejderhistorie og villa kan danne en kontrast-rute. | Flere invariants er felt-hypoteser; privatliv og eventdrift skal afklares. |
| Vejle havn og industri | 46, 47 | En kort industri-/toldfortælling, der ikke genbruger de eksplicit ekskluderede havnevartegn. | Vej, bane, byggerier og objektiv facadeafgrænsning. |
| Vejle Ådal vest | 02, 17, 20 | Tre selvstændige udflugtsstop om vikingeteknik, jernbane og bronzealder. | Ikke fremsat som gåafstand; transport og faktisk besøgsafstand skal planlægges. |
| Tørskind Landskabsskulptur | 10, 26 | To korte kunstsolve på samme døgnåbne anlæg. | Ujævnt/stejlt terræn; kun dagslys og separat adgangsvurdering. |
| Børkop–Brejning | 11, 18, 27, 29 | Mølleteknik, samtidskunst, socialhistorie og trold kan fordeles på familieudflugt. | Ingen påstået gåtid; hotelgrund, museumsdrift, vand og skovsti skal tjekkes. |
| Randbøl–Tinnet Hærvejen | 04, 16, 21, 37–39 | Kulturspor fra vikingetid, jernalder, bronzealder og 1900-tal langs Hærvejsområdet. | Naturpunkterne må ikke kædes sammen før lovlig rute, distance, underlag og mobildækning er feltmålt. |
| Engelsholm–Nørup | 14, 41 | To stærke silhuetter: fire slottårne og kirkens løgkuppel. | Privat slot/skole, parkregler og kirkelige hensyn. |
| Vejle fjord og Tirsbæk | 23, 42 | Rekreativ pavillon og herregårdslandskab som separate fjordstop. | Tirsbæk kun fra offentlig rute; park eller privat gods er ikke en genvej. |
| Grejsdalen | 22 | Et selvstændigt arkitekturstop, indtil en sikker kobling til andre steder er dokumenteret. | Trafik, dalskråning og kirkeadgang. |
| Give | 28 | Solhjul som selvstændigt kunststop. | Observation må kun ske uden for rundkørslen; ingen afstand til andre stop er lovet. |
| Højen / Vejle syd | 15, 40 | Møllesilhuet og historisk bro kan kun kobles efter sikkerhedsreview. | Stokbro fravælges, hvis den kræver vejkant, privat areal eller risikabel vandnærhed. |

## 7. Fravalgte næsten-kandidater

| Næsten-kandidat | Konkret fravalgsgrund |
|---|---|
| Bølgen | Eksplicit ekskluderet af bestilleren; dubletkontrollen må heller ikke genbruge dens bølge-/altanmotiv. |
| Fjordenhus | Eksplicit ekskluderet af bestilleren; ingen skjult variant i havneklyngen. |
| Den gamle bro i Tirsbæk Bakker | Eksplicit ekskluderet; andre broopgaver er kontrolleret for andet sted, historie og invariant. |
| Vera ved Frydenlund 98 | Eksplicit ekskluderet. |
| Søen ved Frydenlund og generiske sø-pladsholdere | Eksplicit ekskluderet; vand alene er desuden for variabelt som facit. |
| Højen i Tirsbæk Bakker | Eksplicit ekskluderet. |
| Munkenes Teglovn som indendørs-/ovnrumssolve | Stærk middelalderhistorie, men adgang og sæson/åbning er for snæver til den ønskede helårs-udeportefølje; byvandringen dokumenterer konteksten. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel) |
| Ravningbroens udstilling | Udstillingen har særskilt åbningstid, mens udeanlægget er døgnåbent; den udendørs broende-opgave blev valgt. [Ravningbroen](https://www.vejlemuseerne.dk/besoeg-os/ravningbroen/) |
| Vejle Vindmølles indre maskineri | Museumsåbning er mere begrænset end udvendig silhuet; de fire ydre vinger blev valgt. [Vejle Vindmølle](https://www.vejlemuseerne.dk/besoeg-os/vejle-vindmoelle/) |
| Engelsholm Slotspark som internt solve | Park-/slotadgang kan ikke behandles som fri helårsadgang, og hovedbygningen er ikke offentlig; ekstern tårnobservation blev valgt. [Engelsholm Slot](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slot-gdk608111) [Engelsholm Slotspark](https://www.visitvejle.dk/vejle/planlaeg-ferien/engelsholm-slotspark-gdk608070) |
| Tirsbæk Slotspark som renæssancehave-solve | Særlige adgangsvilkår og privat gods; kun en betinget observation fra offentlig fjordrute er med. [Tirsbæk Slotspark](https://www.visitvejle.dk/vejle/planlaeg-ferien/tirsbaek-slotspark-gdk607960) [Vejle Fjord – Tirsbæk, Ulbækhus og Daugårdstrand](https://www.visitvejle.dk/vejle/planlaeg-ferien/vejle-fjord-tirsbaek-ulbaekhus-og-daugaardstrand-gdk607967) |
| Egtved gravhøj som selvstændigt jordtælle-stop | Historisk meget stærk, men overlapper Egtvedpigens Verden, og høj-/gravhensyn giver et svagere nyt facit. [Egtved gravhøj](https://slks.dk/doil/stederne/egtved-gravhoej) |
| Kellers Mindes indendørs samling | Åbningstidsafhængig og mindre robust end den udendørs skolesten; den gratis historiske rute bruges kun som adgangskontekst. [Historisk vandrerute ved Kellers Minde](https://www.visitvejle.dk/vejle/planlaeg-ferien/historisk-vandrerute-ved-kellers-minde-gdk1158491) |
| Flere Tørskind-delværker | Ni værker giver mange muligheder, men flere næsten ens kunststops ville svække geografisk variation; kun to klart forskellige facitter blev valgt. [Robert Jacobsen–Jean Clareboudt Landskabsskulptur](https://www.vejlemuseerne.dk/besoeg-os/landskabsskulptur/) |
| Gudenåens udspring som vandmængde-/retningstal | Vandføring, vegetation og små løb er variable; det historiske betonbassin er en mere stabil, om end feltbetinget, invariant. [Rørbæk Sø, Tinnet Krat og Gudenåens udspring](https://www.visitvejle.dk/vejle/planlaeg-ferien/roerbaek-soe-tinnet-krat-og-gudenaaens-udspring-gdk608061) [Gudenåen – Badelandet ved Tinnet Krat](https://historiskatlas.dk/Guden%C3%A5en_-_Badelandet_ved_Tinnet_Krat_%2810482%29) |
| Skyttehusets separate musikpavillon | Risiko for forveksling med den ottekantede dansepavillon og eventinventar; kun én bygningsopgave beholdes. [Skyttehuset](https://historiskatlas.dk/Skyttehuset_%282420%29) |
| Nørretorvsmastens højde på 16 meter | Højden kan ikke meningsfuldt måles onsite af familien; den direkte observerbare hældning blev valgt i stedet. [Byvandring i Vejles gamle bydel](https://www.visitvejle.dk/vejle/oplevelser/det-historiske-vejle/byvandring-i-vejles-gamle-bydel) |

## 8. Samlet feltplan

**Fase 1 — rang 01–10.** Besøg Jelling som én samlet arbejdsdag, men solve-test hver invariant separat. Kombinér derefter Ravning/Randbøl efter en faktisk transportplan og Vejle centrum for kranier, rådhus, Sønderbro og Kanonkuglehuset. Prioritér: (1) foto af facit og alle lookalikes, (2) præcist GPS-punkt med mindst fem målinger, (3) sikker familiezone, (4) kørestol/barnevognsvinkel, (5) én solve-test med børn og (6) lokal ejer-/forvalterkontakt, hvor relevant.

**Fase 2 — rang 11–25.** Saml Børkop–Brejning, Vejle Ådal og centrum vest i egne ture. Test især helårssynlighed, park-/kirke-/museumsgrænser, vandværn, cykelstrøm og om tallet kan tælles uden at læse et facitskilt. Kandidat 21 skal have en komplet fototransskription af alle vejviserflader; kandidat 25 skal have særskilte fotos af N12, N15 og N11.

**Fase 3 — rang 26–50.** Start med de sikre, offentlige byrum og slut med natur/private kanttilfælde. Kandidater 32, 33 og 43 kræver nummererede GPS-/fotologs for hele serier. Kandidat 40 Stokbro har en stopgate før solve-test. Kandidater 46–50 skal først bevise deres foreslåede facadeinvariant; ellers omskrives eller fravælges de uden at forsvare den nuværende rangliste.

**Gentagen checkliste for hvert feltbesøg**

1. Registrér ankomst, præcis observationszone, `latitude`, `longitude`, fem GPS-prøver, radius, accuracy og dwell i samme skema.
2. Dokumentér offentlig adgang, ejer/skel, relevante tider og en lovlig retræte-/alternativ rute.
3. Gennemgå alle relevante flag: `traffic`, `water`, `steepSlope`, `darkness`, `privateProperty`, `cyclePath`, `construction`, `crowding`.
4. Mål underlag, fri bredde, maksimal hældning, trin/kanter, afstand og løsning fra kørestol/barnevogn.
5. Fotografér invariant, startpunkt, 360° omgivelser, lookalikes, skiltning og eventuelle sæsonhindringer; fotos er internt bevis, ikke automatisk publiceringsmedie.
6. Kør solve med mindst én familie, registrér alle svar, tidsforbrug og hintbrug, og kontrollér at 3/4/5 %-hints er progressive.
7. Verificér historie og ordlyd mod lokal forvalter/arkiv, og eskalér konflikter i stedet for at skjule dem.
8. Afklar medieejer, fotograf, licens, kreditering, varighed og app/web-rettigheder eller behold alle media-id'er `null`.
9. Sæt først `fieldVerified: true` og en faktisk dato, når hele kandidaten er godkendt; denne rapport gør det ikke.

## 9. Kvalitetskontrol af leverancen

Tabellen kontrollerer **rapportens kladdekomplethed**, ikke fysisk sandhed. ‘Onlinekontrol’ betyder, at URL'en blev brugt under research 2026-08-03; det er ikke en garanti for fremtidig URL-stabilitet. ‘Betinget felt-hypotese’ er bevidst ikke et grønt publiceringssignal.

| # | ≥2 kilder / begrundelse | Autoritativ historie | Links | Stabil invariant | Rel. ≥4 | Entyd. ≥4 | Facit+svar | Bevis | 3 hints 3/4/5 | 5 completion | draft | fieldVerified | lastVerified |
|---:|---|---|---|---|:---:|:---:|---|---|---|---|:---:|:---:|:---:|
| 01 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 02 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 03 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 04 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 05 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 06 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 07 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 08 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 09 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 10 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 11 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 12 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 13 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 14 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 15 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 16 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 17 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 18 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 19 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 20 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 21 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 22 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 23 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 24 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 25 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 26 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 27 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 28 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 29 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 30 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 31 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 32 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 33 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 34 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 35 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 36 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 37 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 38 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 39 | Ja | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 40 | Begrundet draft-undtagelse | Ja | onlinekontrol | Ja, feltcheck | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 41 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 42 | Begrundet draft-undtagelse | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 43 | Begrundet draft-undtagelse | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 44 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 45 | Begrundet draft-undtagelse | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 46 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 47 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 48 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 49 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
| 50 | Ja | Ja | onlinekontrol | Betinget felt-hypotese | 4/5 | 4/5 | Ja | Ja | Ja | Ja | `draft` | `false` | `null` |
