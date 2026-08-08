# Authentication og roller — plan for version 1

**Status:** Authentication aktiv og smoke-testet i PROD; iOS-builds uploadet
**Dato:** 6. august 2026
**Senest verificeret:** 8. august 2026
**Første administrator:** sættes som ikke-sporet Azure-konfiguration

## Resultat af valideringen

Version 1 kan bruge **Log ind med Apple direkte** uden Azure AD B2C, Microsoft
Entra External ID eller en anden identitetsbroker. Det undgår en pris, der
vokser med månedligt aktive brugere, og passer til en iPhone-først udgivelse.

Løsningen er korrekt med disse præciseringer:

1. **E-mail er ikke brugerens tekniske id.** Apple kan udlevere en privat
   relay-adresse, og navn/e-mail må kun forventes ved den første godkendelse.
   Kontoen får derfor et internt `accountId`; loginidentiteten er
   `(provider, providerSubject)`, hvor Apples stabile `sub` er subject.
2. **API'et udsteder sin egen session efter Apple-validering.** Apples token
   valideres server-side med signatur, `iss`, `aud`, `exp` og nonce. Roller
   læses altid server-side og accepteres aldrig fra klienten.
3. **De to native apps og web-login skal høre til samme Apple-login-gruppe.**
   Spillerappens App ID er primær; admin-appens App ID grupperes med den, og
   websidens Services ID knyttes til samme primære App ID. Ellers kan den samme
   Apple-konto få forskellige subject-værdier på tværs af klienterne.
4. **Andre identitetsudstedere bliver separate konti.** Android kan senere
   tilføje Google og web kan tilføje Google/Facebook. Der implementeres ikke
   automatisk eller manuel kontosammenkædning. Samme menneske med Apple- og
   Google-login har derfor to konti, også når e-mailadressen er den samme.
5. **Gæstespil forbliver muligt.** Gæster kan hente og spille frigivne opgaver,
   men kan ikke indsende til highscore eller synkronisere en profil.

Direkte login fjerner abonnementsprisen til en broker, men flytter ansvaret for
tokenvalidering, sessioner, spærring, sletning og nøglehåndtering til projektet.
Det er en acceptabel pris i version 1, hvis nedenstående gates implementeres og
testes samlet.

## Forfatningsgate godkendt

Product owner godkendte den 6. august 2026, at e-mail + engangskode erstattes af
dataminimeret ekstern identitet, internt konto-id og egne sessioner.
Forfatningens princip VI og afsnittet Identitet er derfor ændret i version
4.0.0.

Ændringen:

- erstatter e-mail + engangskode med dataminimeret ekstern identitet og session
- fastholder, at e-mail aldrig er offentlig eller teknisk primærnøgle
- dokumenterer formål og slettefrist for konto, identity og session
- fastholder gæstespil og ingen særskilt børnekontotype i version 1

Den konkrete privatlivstekst og interesseafvejning skal have menneskeligt review
før offentlig release. Det blokerer ikke implementering og DEV-test.

Princip I, III og IV gælder uændret: authentication gør ikke en opgave fysisk
verificeret eller rettighedsgodkendt. De aktuelle demoopgaver må derfor ikke
betragtes som App Store-produktionsklare alene, fordi deres status er
`published`.

## Begreber og status

De kanoniske wire-værdier er:

| Wire-værdi | Dansk UI | Hvem må se opgaven? |
|---|---|---|
| `draft` | Kladde | Designer og Admin i authoring |
| `fieldTestReady` | Klar til udgivelse | Designer og Admin i preview/authoring |
| `published` | Frigivet | Alle, inklusive gæster |

Den offentlige indholdspakke må kun indeholde `published`. Den tidligere værdi
`publishReady` accepteres midlertidigt som en ældre alias, så nuværende
TestFlight-klienter og PROD-data ikke mister frigivne opgaver under migrationen.
Nye admin-klienter skriver kun `published`. Designer-preview skal læse fra det
beskyttede authoring-API og må ikke genbruge den offentlige pakke.

Under udrulningen oversætter pakkegeneratoren `published` til `publishReady` i
den offentlige pakke. Det er kun en kompatibilitetsbro for eksisterende
TestFlight-builds; authoring-lager og nye admin-klienter bruger `published`.
Når alle aktive spillerklienter kan læse det nye navn, fjernes oversættelsen,
PROD-data migreres, og til sidst fjernes legacy-værdien fra kontrakten.

## Roller og rettigheder

| Handling | Gæst | User | Designer | Admin |
|---|---:|---:|---:|---:|
| Hente/spille `published` | Ja | Ja | Ja | Ja |
| Se `fieldTestReady` | Nej | Nej | Ja | Ja |
| Indsende score til highscore | Nej | Ja | Ja | Ja |
| Redigere opgaver og medier | Nej | Nej | Ja | Ja |
| Oprette, pause og frigive opgaver | Nej | Nej | Ja | Ja |
| Se brugerliste | Nej | Nej | Nej | Ja |
| Gøre User til Designer og tilbage | Nej | Nej | Nej | Ja |
| Moderere offentligt profilnavn | Nej | Nej | Nej | Ja |

Admin kan alt, en Designer kan. Version 1 giver ikke Admin mulighed for at
udnævne andre Admins i UI'et. Yderligere Admins kræver en særskilt, auditeret
driftshandling. Sidste Admin må aldrig kunne slettes eller degraderes.

## Konto- og identitetsmodel

Bruger- og sessionsdata gemmes i Azure Table Storage i den eksisterende
storage account. Det er et særskilt domæne fra opgaveindholdets blobs og kræver
ingen ny fast databasepris.

### Account

- `accountId`: tilfældig UUID; intern og permanent nøgle
- `email`: verificeret værdi fra IDP, eventuelt Apple relay; aldrig offentlig
- `publicName`: valgfrit navn til highscore
- `role`: `User`, `Designer` eller `Admin`
- `state`: `Active`, `Blocked` eller `Deleted`
- `createdAt`, `lastSignedInAt`
- `nameModerationState`, `nameModerationReason`

### ExternalIdentity

- `provider`: først `apple`; senere eksempelvis `google` eller `facebook`
- `providerSubject`: IDP'ens stabile subject
- `accountId`
- `createdAt`, `lastValidatedAt`

Der er en unik indeksnøgle på `(provider, providerSubject)`. E-mail bruges ikke
til opslag eller automatisk sammenlægning.

### Session

- tilfældig, højentropisk access-/refresh-identifikator; kun hash gemmes
- `accountId`, udløbstid, oprettelsestid og seneste rotation
- klienttype og tilbagekaldelsesstatus

Access-sessioner lever som udgangspunkt 15 minutter. Native refresh-sessioner
lever højst 30 dage, roteres ved hver anvendelse og tilbagekaldes ved genbrug af
et allerede roteret token. Oprydning af udløbne sessionrækker er fortsat en
driftsopgave før vedvarende produktion. Web-admin får i version 1 højst 30 minutters session uden
refresh-token og kræver derefter nyt Apple-login.

Native refresh-token gemmes i Keychain. Web-admin får ingen langlivet token i
`localStorage`. Apples webpopup returnerer en kortlivet engangskode bundet med
state og nonce; Angular veksler den til et kortlivet bearer-token i hukommelsen.
Ved reload eller udløb logger quizmasteren ind igen i version 1. Det undgår
afhængighed af tredjepartscookies mellem `azurestaticapps.net` og
`azurewebsites.net`.

## Første Admin

`Authentication__Apple__BootstrapAdminEmail=<første-admin-email>` sættes som en Azure
App Service-indstilling og ikke i en fil i repoet. Den konkrete e-mail er
persondata i dette offentlige repository og må ikke stå i Git-historikken.

Ved første Apple-login gælder:

1. Apple-tokenet er fuldt valideret, inklusive verificeret e-mail-claim.
2. Brugeren vælger **Del min e-mail**; en relay-adresse matcher ikke bootstrap.
3. Hvis der endnu ikke findes en Admin, og e-mailen matcher konfigurationen
   normaliseret, oprettes kontoen atomisk som Admin.
4. Når bootstrap er gennemført, kan konfigurationen ikke oprette flere Admins.

Den atomiske engangsgate skal dækkes af en samtidighedstest, så to samtidige
førstegangslogin ikke kan skabe to Admins.

## Loginflow

### Native iOS

1. Appen bruger `AuthenticationServices` med state og nonce.
2. Apple-credential sendes til `POST /auth/apple/native/exchange`.
3. API'et validerer Apple-tokenet og authorization code server-side.
4. API'et opretter eller finder kontoen og udsteder egen kort access-session og
   roterbar refresh-session.
5. Access-token sendes som bearer-token. Refresh-token ligger kun i Keychain.

Spillerapps på iOS og web starter som gæst. Login tilbydes, når spilleren vil
oprette et profilnavn, synkronisere eller komme på highscore. Begge admin-apps
kræver login, før indhold kan læses eller ændres.

### Web-admin

1. Angular opretter state og nonce og starter Apples officielle popup-flow.
2. Angular kontrollerer state i popup-svaret og sender identity-token,
   authorization code og den rå nonce til API'et.
3. API'et validerer nonce, signatur, issuer og audience og veksler derefter
   authorization code server-side med den allowlistede return URL.
4. `.p8`-nøglen og client secret forlader aldrig serveren. Apples kode er
   engangsbrug, og API'et sammenholder identity før og efter vekslingen.
5. Angular holder det udstedte access-token i hukommelsen; der udstedes intet
   refresh-token til web.

Apple dokumenterer ikke PKCE-parametre for dette flow. Derfor bruges PKCE ikke
som et påstået ekstra lag; state, nonce, eksakt return URL, servervalidering og
Apples egen engangskode er de faktiske grænser.

Webflowet kræver et Apple Services ID, registreret domæne og eksakte return
URLs for både DEV og PROD. Kun allowlistede redirect-origins accepteres.

## API-authorization

- Anonyme endpoints: health, offentlig `published`-pakke og publicerede
  medier.
- `User`: egen profil, egne scores og scoreindsendelse.
- `DesignerOrAdmin`: authoring, preview, upload, transkodering, publicering og
  auditlæsning.
- `AdminOnly`: brugerliste, rolleændring, blokering og navnemoderation.
- Alle `PUT`, `POST` og `DELETE` kræver både gyldig session og relevant policy.
- `X-Quizmaster` må ikke længere være identitet. Audit bruger verificeret
  `accountId`, rolle og offentligt navn/e-mail efter dataminimeringsreglerne.
- Rolleændring slår igennem ved næste request; roller må ikke leve længe i et
  selvstændigt klientclaim.

## Profilnavne og highscore

Kun autentificerede konti kan optræde på highscore. Offentligt vises kun
`publicName`; e-mail og provider-id vises aldrig.

Version 1 kræver:

- 3–20 synlige tegn, trimning og Unicode-normalisering
- blokering af kontroltegn, links, kontaktoplysninger og reserverede navne
- dansk blokliste for åbenlyst krænkende navne
- rate limit på navneændringer og scoreindsendelser
- rapportér-navn-funktion
- Admin kan skjule et navn eller sætte kontoen i `Blocked`
- highscore falder tilbage til et neutralt anonymiseret navn efter moderation

Highscore er ikke en antisnydsmekanisme. Gæster kan lære et svar og senere
oprette en konto; det accepteres, fordi spillets kerne er det fysiske sted og
ikke en præmiekonkurrence. Serveren accepterer højst én gældende score pr.
konto og opgave/version.

## Kontosletning og børn

- Offentligt indhold kan bruges uden konto.
- Der oprettes ikke en særskilt kontotype for børn i version 1.
- Kontooprettelse kræver mindst mulige data: ekstern subject, intern id, rolle
  og eventuelt offentligt navn/verificeret e-mail.
- User kan slette kontoen i appen. Sessions tilbagekaldes straks; profilnavn og
  direkte identifikatorer slettes eller anonymiseres efter den dokumenterede
  slettepolitik.
- Designer skal degraderes til User før selvbetjent sletning. Admin slettes kun
  gennem en særskilt driftshandling, og aldrig hvis kontoen er sidste Admin.
- Apple-tilbagekaldelse og server-to-server-notifikationer skal lukke aktive
  sessions og markere identiteten som tilbagekaldt.
- Præcis GPS-historik gemmes fortsat ikke server-side.

## Nøgler og konfiguration

Følgende er hemmeligheder og må aldrig oprettes i en sporet fil:

- Apple Sign in with Apple private key (`.p8`)
- sessionsignerings-/tokenhemmeligheder
- eventuelle client secrets

Apple Team ID, Key ID, Services ID, bundle-id'er og redirect-URL'er er ikke
hemmeligheder, men sættes som Azure/GitHub-konfiguration for at undgå
miljøsammenblanding. DEV og PROD har separate sessions- og bruger-tabeller.

## Implementeringsrækkefølge

### 1. Backendfundament

- Account-, ExternalIdentity- og Session-tabeller
- Apple-tokenvalidator og JWKS-cache
- native exchange, refresh, logout, `/me` og kontosletning
- policies `User`, `DesignerOrAdmin` og `AdminOnly`
- engangsbootstrap af første Admin
- audit baseret på verificeret konto

### 2. Offentlig pakke og Designer-preview

- offentlig pakke filtreres til kun `published` (med midlertidigt legacy-alias)
- beskyttet preview for `fieldTestReady` + `published`
- kontrakt- og regressionstest, der beviser, at User/gæst aldrig får facit fra
  `draft` eller `fieldTestReady`

### 3. Vejles Koder på iOS og web

- gæst som standard
- Log ind med Apple; Keychain-session på iOS og kort hukommelsessession på web
- profilnavn, logout og kontosletning
- highscore kun for autentificerede konti
- Designer/Admin får særskilt kortfilter og forskellige, ikke kun
  farvebaserede markører for `fieldTestReady` og `published`

### 4. iOS-admin

- obligatorisk Log ind med Apple
- afvisningsskærm for User uden Designer/Admin-rolle
- bearer-token på alle authoring-kald
- logout, udløb og tilbagekaldelse uden tab af lokal kladde

### 5. Web-admin og brugeradministration

- Apple Services ID-flow med state, nonce og en kortlivet engangskode
- route guards og bearer-token på API-kald
- Admin-side med søgning, User/Designer-status, blokering og navnemoderation
- rolleændringer kræver bekræftelse og vises i audit

### 6. Fremtidige klienter

- Android tilføjer Google som ny validator/provider
- web kan tilføje Google/Facebook
- hver ny provider kræver issuer-, audience-, signatur- og noncevalidering
- ingen automatisk eller manuel kontosammenkædning

## Test- og release-gates

- manipuleret, udløbet, forkert issuer/audience og replayet Apple-token afvises
- nonce- og state-validering dækkes af negative tests
- første Admin oprettes kun én gang og kun fra verificeret bootstrap-e-mail
- User får `403` på alle authoring- og brugerendpoints
- Designer får `403` på brugeradministration, men kan vedligeholde opgaver
- Admin kan vedligeholde Designers og har alle Designer-rettigheder
- gæst/User kan kun hente `published`
- Designer/Admin ser `fieldTestReady` og `published` med forskellige
  markører, der også kan skelnes uden farvesyn
- degradering/blokering tilbagekalder aktive sessions eller slår igennem straks
- refresh-token kan kun bruges én gang pr. rotation
- webtoken findes ikke i `localStorage`
- kontosletning kan udføres i spillerappen og fjerner highscore-identiteten
- API-tests køres i D og skal være grønne før PROD-deploy
- App Service har `httpsOnly=true`

## Ekstern opsætning før end-to-end-test

1. Aktivér Sign in with Apple på:
   - `dk.hyldenbrandt.byensgaader`
   - `dk.hyldenbrandt.byensgaader.admin`
2. Gør spillerappens App ID primær og gruppér admin-appens App ID med den.
3. Opret Apple Services ID til spillerweb og web-admin, og knyt det til den
   primære App ID.
4. Registrér DEV- og PROD-domæner/return URLs for begge webapps.
5. Opret Apple private key, læg den i Azure Key Vault/App Service-konfiguration
   og kontrollér først `.gitignore` ved enhver lokal nøglefil.
6. Giv API'ets managed identity adgang til de nye Table Storage-tabeller.
7. Sæt bootstrap-e-mail i D og PROD; gennemfør først login i D med
   **Del min e-mail**.

DEV-gaten for web blev gennemført 8. august 2026: Apple-login oprettede den
forventede bootstrap-konto som eneste Admin, webadmin kunne hente opgaver og
brugerlisten viste den serverlagrede rolle. Samme konto kunne derefter logge
ind i iOS-admin, hente alle opgaver og logge ind i spillerappen. Webadmin,
iOS-admin og Vejles Koder er dermed verificeret mod DEV. Den menneskelige
PROD-gate er også gennemført: HTTPS, Table-rolle, Key Vault og Apple-indstillinger
er aktiveret, og smoke-testen gav `200` på health/offentlig pakke, `401` på
anonym authoring og `/auth/me`, samt HTTPS-redirect. Begge iOS-apps er uploadet.

Offentlige profilnavne, rapportering og Admin-moderation er efterfølgende
implementeret og valideret lokalt. Denne udvidelse følger sin egen normale
DEV- og manuelle PROD-gate og kræver en ny spillerbuild.

## Kilder til valideringen

- [Apple: Configure Sign in with Apple for the web](https://developer.apple.com/help/account/capabilities/configure-sign-in-with-apple-for-the-web/)
- [Apple: Group apps for Sign in with Apple](https://developer.apple.com/help/account/capabilities/group-apps-for-sign-in-with-apple/)
- [Apple: Generate and validate tokens](https://developer.apple.com/documentation/signinwithapplerestapi/generate-and-validate-tokens)
- [Apple: Implementing user authentication with Sign in with Apple](https://developer.apple.com/documentation/authenticationservices/implementing-user-authentication-with-sign-in-with-apple)
- [Apple: Offering account deletion in your app](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [OpenID Connect Core: Subject Identifier](https://openid.net/specs/openid-connect-core-1_0.html#SubjectIDTypes)
