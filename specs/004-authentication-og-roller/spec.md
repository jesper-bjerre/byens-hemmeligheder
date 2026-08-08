# Feature Specification: Authentication og roller

**Feature Branch**: `main`

**Created**: 6. august 2026

**Status**: Implementering i gang; forfatningsgate godkendt 6. august 2026

**Input**: Authentication skal implementeres og frigives hurtigst muligt med
rollerne User, Designer og Admin. Arbejdet må ikke afhænge af kommunikation med
partnere eller quizmastere.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Beskyt redaktionelt indhold (Priority: P1)

En Designer eller Admin logger ind og kan derefter læse og vedligeholde
redaktionelt indhold. En gæst eller almindelig User kan hverken læse kladder
eller kalde skrivefunktionerne.

**Why this priority**: Det nuværende anonyme skrive-API er den største konkrete
risiko og spærrer for en sikker fortsættelse af testen.

**Independent Test**: Kald alle redaktionelle læse- og skrivefunktioner som
gæst, User, Designer og Admin, og kontroller henholdsvis afvisning eller succes.

**Acceptance Scenarios**:

1. **Given** en request uden gyldig session, **When** en redaktionel funktion
   kaldes, **Then** returneres `401`, og intet indhold ændres.
2. **Given** en aktiv User-session, **When** en redaktionel funktion kaldes,
   **Then** returneres `403`, og intet indhold eller revisionsspor ændres.
3. **Given** en aktiv Designer- eller Admin-session, **When** en tilladt
   redaktionel funktion kaldes, **Then** udføres handlingen, og den verificerede
   konto registreres i revisionssporet.

---

### User Story 2 - Spil som gæst eller Apple-bruger (Priority: P1)

En spiller kan fortsat spille frigivne opgaver uden konto. Spilleren kan vælge
Log ind med Apple for at få en konto og et profilnavn, men login må ikke være en
forudsætning for kerneoplevelsen.

**Why this priority**: Børn og familier skal kunne begynde uden konto, samtidig
med at en verificeret identitet bliver tilgængelig for senere highscore og
synkronisering.

**Independent Test**: Start spillerappen uden konto, spil en frigivet opgave,
log derefter ind og kontroller, at kontoen kan læses og logges ud igen.

**Acceptance Scenarios**:

1. **Given** en spiller uden konto, **When** appen åbnes, **Then** kan spilleren
   se og spille frigivne opgaver uden loginprompt.
2. **Given** en gyldig Apple-identitet, **When** spilleren logger ind, **Then**
   oprettes eller genfindes præcis én intern konto.
3. **Given** en ugyldig, udløbet eller genafspillet Apple-identitet, **When**
   login forsøges, **Then** oprettes ingen konto eller session.

---

### User Story 3 - Log ind i admin-apps (Priority: P1)

En Designer eller Admin skal logge ind med Apple i både iOS-admin og web-admin,
før redaktionelt indhold vises. En User får en tydelig afvisning uden adgang til
data eller redigeringsflader.

**Why this priority**: API'et kan ikke lukkes sikkert, før begge aktuelle
admin-klienter sender den verificerede session.

**Independent Test**: Log ind i hver admin-app med hver rolle og kontroller, at
kun Designer og Admin når indholdslisten, og at alle API-kald bærer sessionen.

**Acceptance Scenarios**:

1. **Given** ingen session, **When** en admin-app åbnes, **Then** vises login og
   intet redaktionelt indhold hentes.
2. **Given** en User-session, **When** login afsluttes, **Then** vises en
   adgangsafvisning og ingen redigeringsfunktioner.
3. **Given** en Designer- eller Admin-session, **When** login afsluttes, **Then**
   indlæses admin-oplevelsen, og sessionudløb sender brugeren tilbage til login
   uden at kassere en lokal kladde.

---

### User Story 4 - Administrer Designers (Priority: P2)

En Admin kan finde konti og ændre en User til Designer eller en Designer til
User. En Designer kan ikke se eller ændre brugerlisten.

**Why this priority**: Serverstyret delegering er nødvendig, men den kan
færdiggøres efter den første Admin er i stand til at arbejde alene.

**Independent Test**: Skift en testkonto mellem User og Designer som Admin,
kontroller øjeblikkelig adgangsændring, og gentag forsøget som Designer.

**Acceptance Scenarios**:

1. **Given** en Admin-session, **When** en User forfremmes, **Then** har kontoen
   Designer-adgang fra næste request, og ændringen auditeres.
2. **Given** en Designer-session, **When** brugeradministration kaldes, **Then**
   returneres `403` uden at afsløre brugerlisten.
3. **Given** den sidste Admin, **When** kontoen forsøges degraderet eller
   slettet, **Then** afvises handlingen.

---

### User Story 5 - Afslut og slet en konto (Priority: P2)

En bruger kan logge ud på sin enhed og kan slette sin spillerkonto. Logout og
sletning skal straks gøre eksisterende sessions ubrugelige.

**Why this priority**: Kontrol over egne data er nødvendig før offentlig
udgivelse af kontooplevelsen.

**Independent Test**: Opret en konto og to sessions, log den ene ud og slet
derefter kontoen; kontroller at alle tokens afvises, og at offentligt navn og
direkte identifikatorer ikke længere udleveres.

**Acceptance Scenarios**:

1. **Given** en aktiv session, **When** brugeren logger ud, **Then** kan dens
   refresh-legitimation ikke bruges igen.
2. **Given** en User-konto, **When** kontoen slettes, **Then** tilbagekaldes alle
   sessions, og direkte identifikatorer fjernes eller anonymiseres.
3. **Given** en Designer- eller Admin-konto, **When** selvbetjent sletning
   forsøges, **Then** afvises den med en forklaring om nødvendig degradering.

---

### User Story 6 - Vælg og moderér profilnavn (Priority: P1)

En indlogget spiller kan aktivt vælge et offentligt profilnavn til highscore.
Andre kan rapportere navnet uden at få adgang til konto-id eller e-mail, og en
Admin kan skjule navnet eller blokere kontoen gennem den beskyttede brugerliste.

**Why this priority**: Highscore er allerede i version 1, og målgruppen omfatter
børn. Et frit offentligt tekstfelt må derfor ikke frigives uden validering,
rapportering og en hurtig moderationsvej.

**Independent Test**: Sæt et gyldigt navn, indsend point og se navnet på
highscore; rapportér det fra en anden konto, skjul det som Admin og kontroller,
at highscore straks viser det neutrale fallbacknavn.

**Acceptance Scenarios**:

1. **Given** en indlogget User uden profilnavn, **When** et gyldigt navn på
   3–20 synlige tegn gemmes, **Then** normaliseres det og vises på highscore.
2. **Given** et navn med kontroltegn, link, kontaktoplysning, reserveret eller
   åbenlyst krænkende tekst, **When** det gemmes, **Then** afvises det uden at
   ændre kontoen.
3. **Given** et synligt navn på highscore, **When** en indlogget spiller
   rapporterer det, **Then** gemmes kategori, navn og tidspunkt uden at et
   internt konto-id udleveres offentligt.
4. **Given** en rapporteret konto, **When** en Admin skjuler navnet, **Then**
   viser highscore straks "Anonym spiller"; en Designer/User får `403` på samme
   handling.
5. **Given** en konto, der misbruger tjenesten, **When** en Admin blokerer den,
   **Then** afvises dens eksisterende sessions ved næste request.

### Edge Cases

- Apple udleverer kun navn og e-mail første gang, eller brugeren vælger Skjul
  min e-mail.
- To samtidige førstegangslogin bruger samme Apple-identitet.
- To samtidige login forsøger at opfylde bootstrap-reglen for første Admin.
- En access-session er gyldig, men kontoen er siden blevet blokeret eller
  degraderet.
- Et refresh-token genbruges efter rotation.
- Apples offentlige signeringsnøgler roterer, mens API'et kører.
- Netværket forsvinder under login, tokenveksling eller gemning i admin-appen.
- En eksisterende TestFlight-klient læser den ældre status `publishReady`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-401**: Frigivne opgaver MUST kunne spilles uden konto.
- **FR-402**: Systemet MUST understøtte Log ind med Apple for spiller- og
  admin-klienterne.
- **FR-403**: Systemet MUST identificere en konto med et internt, tilfældigt id
  og en stabil identitet fra udstederen; e-mail MUST NOT være teknisk nøgle.
- **FR-404**: Systemet MUST validere identitetens signatur, udsteder, modtager,
  udløb, nonce og engangslegitimation før konto eller session oprettes.
- **FR-405**: Systemet MUST afvise genafspilning af engangslegitimation og
  genbrug af roteret refresh-legitimation.
- **FR-406**: Roller MUST være User, Designer og Admin og MUST håndhæves ud fra
  den aktuelle servertilstand på hver beskyttet request.
- **FR-407**: Alle redaktionelle læse- og skrivefunktioner samt mediaupload,
  fortællerupload og revisionsspor MUST kræve Designer eller Admin.
- **FR-408**: Brugeradministration MUST kræve Admin.
- **FR-409**: En Admin MUST kunne forfremme User til Designer og degradere
  Designer til User; rollen Admin kan ikke tildeles gennem brugerfladen.
- **FR-410**: Systemet MUST forhindre, at den sidste Admin degraderes eller
  slettes.
- **FR-411**: Første Admin MUST kunne oprettes præcis én gang fra en verificeret,
  miljøkonfigureret identitet uden at den konkrete identitet spores i repoet.
- **FR-412**: Revisionssporet MUST bruge den verificerede konto og MUST NOT
  stole på et klientleveret quizmasternavn.
- **FR-413**: Access-sessioner MUST være kortlivede; native refresh-sessioner
  MUST roteres, kunne tilbagekaldes og have et endeligt udløb.
- **FR-414**: Web-admin MUST NOT gemme en langlivet session i browserens
  permanente lager.
- **FR-415**: Logout, blokering, degradering og kontosletning MUST slå igennem
  senest ved næste beskyttede request.
- **FR-416**: En User MUST kunne slette sin konto; sessions og direkte
  identifikatorer MUST derefter tilbagekaldes eller anonymiseres.
- **FR-417**: Designer/Admin MUST kunne se både `fieldTestReady` og `published`
  med markører, der ikke kun kan skelnes ved farve. Gæst/User MUST kun kunne
  hente frigivet indhold.
- **FR-418**: Hemmeligheder, tokens og konkrete bootstrap-identiteter MUST NOT
  skrives i repository, logs, URL-queryparametre eller offentlige API-svar.
- **FR-419**: Authentication og authorization MUST have automatiske negative
  tests for manglende, ugyldige, udløbne, genafspillede og utilstrækkelige
  legitimationsoplysninger.
- **FR-420**: Aktivering i DEV og PROD MUST være uafhængig af partner- eller
  quizmasterkommunikation og kræver alene teknisk konfiguration, test og
  menneskelig releasegodkendelse.
- **FR-421**: En autentificeret spiller MUST kunne sætte eller fjerne et
  valgfrit offentligt profilnavn; tomt navn er standarden.
- **FR-422**: Profilnavnet MUST Unicode-normaliseres, indeholde 3–20 synlige
  tegn og MUST afvise kontroltegn, links, kontaktoplysninger, reserverede navne
  og en konservativ dansk blokliste.
- **FR-423**: Ikke-tomme navneændringer MUST ratebegrænses server-side; klientens
  skjul eller validering er ikke en sikkerhedsgrænse.
- **FR-424**: Highscore MUST kun vise et godkendt profilnavn og ellers bruge
  det neutrale navn "Anonym spiller". Internt konto-id og e-mail MUST NOT
  udleveres med highscoredata.
- **FR-425**: En autentificeret spiller MUST kunne rapportere et vist navn med
  en fast kategori. Rapporten MUST kunne behandles af Admin uden at konto-id
  udleveres på den offentlige highscore.
- **FR-426**: Admin MUST kunne skjule/genåbne et profilnavn og blokere/aktivere
  en ikke-Admin-konto. Ændringen MUST slå igennem ved næste request og være
  utilgængelig for User og Designer.

### Key Entities

- **Konto**: Den interne bruger med rolle, tilstand, eventuelt offentligt navn
  og livscyklustidspunkter.
- **Ekstern identitet**: Sammenknytningen mellem en konto og Apples stabile
  brugeridentitet; indeholder aldrig en adgangskode.
- **Session**: En kort access-legitimation og eventuel roterbar native
  refresh-legitimation med udløb og tilbagekaldelsesstatus.
- **Engangsgodkendelse**: Kortlivet bevis, der kun må veksles én gang under et
  loginflow.
- **Rolleændring**: Auditeret ændring af en kontos rolle foretaget af en Admin.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-401**: 100 % af redaktionelle endpoints returnerer `401` uden session og
  `403` for User i automatiske integrationstests.
- **SC-402**: En Designer og Admin kan gennemføre login og gemme en opgave i
  begge admin-apps; en User kan ikke nå indholdslisten.
- **SC-403**: Gæstespil af frigivne opgaver fungerer uændret uden login.
- **SC-404**: Samtidige login med samme Apple-identitet skaber præcis én konto,
  og samtidige bootstrapforsøg skaber højst én første Admin.
- **SC-405**: Et roteret refresh-token kan kun bruges én gang, og tilbagekaldte
  sessions afvises ved næste request.
- **SC-406**: Ingen e-mail, provider-identitet, rå token eller hemmelighed
  optræder i highscore, revisionssvar, logs eller repositoryets sporede filer.
- **SC-407**: DEV end-to-end-testen er grøn før en menneskelig godkendelse af
  PROD-release.
- **SC-408**: Alle profilnavnsvalideringsvektorer og rollevariationer er dækket
  af automatiske tests, og moderation ændrer highscore ved næste læsning.

## Assumptions

- Log ind med Apple er eneste identitetsudsteder i version 1; senere udstedere
  bliver separate konti uden sammenkædning.
- Gæster har ingen highscoreidentitet eller serversynkroniseret profil.
- Første Admin konfigureres uden for repositoryet.
- Eksisterende indholds- og medielager genbruges; kontodata holdes logisk og
  miljømæssigt adskilt fra indholdet.
- Der gennemføres ingen partner- eller quizmasterkommunikation som del af
  featuret.
- Forfatningens identitets- og dataminimeringsregel er godkendt i version 4.0.0;
  den konkrete privatlivstekst og interesseafvejning reviewes før offentlig
  release.
