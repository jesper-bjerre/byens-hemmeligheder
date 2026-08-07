# Research: Authentication og roller

## Direkte Log ind med Apple

**Decision**: Brug Log ind med Apple direkte. Native klienter sender identity
token, authorization code og rå nonce til API'et. API'et validerer koden mod
Apples token-endpoint og validerer det returnerede identity tokens signatur,
`iss`, `aud`, `exp` og nonce mod allowlistet klientkonfiguration.

**Rationale**: Apple kræver servervalidering af identitetens integritet og
beskriver authorization-code-validering gennem token-endpointet. Direkte login
har ingen brokerpris pr. aktiv bruger. Relaterede App IDs og Services IDs
grupperes under spillerappens primære App ID, så brugeren ikke skal give samme
samtykke flere gange.

**Alternatives considered**: Entra External ID blev fravalgt på pris ved større
brugertal. E-mail + engangskode giver beskedpris og flere trin. Kun lokal
identity-tokenvalidering mangler Apples engangskodekontrol og er ikke nok til
serverlogin.

Kilder: [Apple — Verifying a user](https://developer.apple.com/documentation/signinwithapple/verifying-a-user),
[Apple — Token validation](https://developer.apple.com/documentation/signinwithapplerestapi/generate-and-validate-tokens),
[Apple — Group apps](https://developer.apple.com/help/account/capabilities/group-apps-for-sign-in-with-apple/).

## Egne opaque sessions

**Decision**: API'et udsteder tilfældige opaque access- og refresh-tokens. Kun
SHA-256-hashes gemmes. Access-token lever 15 minutter. Native refresh-token
lever højst 30 dage og roteres atomisk; genbrug tilbagekalder sessionsfamilien.
Web får højst 30 minutters access-session uden refresh-token.

**Rationale**: Rollen skal slå igennem på næste request. Et selvstændigt JWT
med langlivet rolleclaim ville fortsætte efter degradering. Opaque token med
session-id giver punktlookup og øjeblikkelig serverkontrol uden en separat
signeringshemmelighed.

**Alternatives considered**: Egne JWT'er er billige at validere, men kræver
revocation-lager alligevel for blokering og rolleændringer. Cookies på tværs af
Static Web Apps og App Service gør browserflow og CSRF mere komplekst i første
version.

## Azure Table Storage

**Decision**: Genbrug hvert miljøs eksisterende Storage Account med separate
tabeller til konti, eksterne identiteter, sessions og engangsbeviser. Brug
managed identity i Azure og `DefaultAzureCredential` lokalt. Test bruger et
isoleret in-memory repository.

**Rationale**: Domænet er lille og adgangsmønstrene er punktlookups. Der er
ingen rapporterings-, join- eller transaktionskrav, der udløser SQL-kriterierne
i ADR 0007. `TableServiceClient` understøtter token credential og dermed samme
nøglefri adgangsmønster som Blob-lageret.

**Alternatives considered**: Azure SQL tilføjer fast driftsoverflade uden et
aktuelt querybehov. Blob-rækker til sessions giver dårlig punktadgang og
atomisk rotation. Cosmos DB er større end pilotbehovet.

Kilde: [Microsoft — TableServiceClient](https://learn.microsoft.com/dotnet/api/azure.data.tables.tableserviceclient).

## Første Admin og rolleændringer

**Decision**: En verificeret e-mail fra Apple kan kun opfylde en
miljøkonfigureret bootstrapregel, hvis ingen Admin allerede findes. Oprettelsen
sker med betinget insert. Herefter tildeles Admin aldrig fra UI; UI kan kun
skifte User ↔ Designer.

**Rationale**: Repoet forbliver frit for persondata og bootstrap kan ikke
bruges til at skabe flere Admins. Sidste Admin beskyttes server-side.

**Alternatives considered**: Hardkodet e-mail er forbudt i det offentlige
repo. Automatisk Admin til første vilkårlige login er for risikabelt. En delt
adminnøgle giver ingen personbåret audit.

## Web-login

**Decision**: Web-admin bruger Apples officielle popup-flow med state og nonce.
Browseren kontrollerer state, mens API'et validerer nonce i begge signerede
identity-tokens og veksler Apples authorization code én gang. Det udstedte
webtoken lever kun i hukommelsen og har intet refresh-token. PKCE anvendes ikke
mod Apple, fordi Apples dokumenterede authorize-/token-flow ikke tilbyder en
PKCE-parameter; en egen PKCE-omvej ville ikke binde Apples kode stærkere.

**Rationale**: Apple kræver et Services ID knyttet til en primær App ID og
registrerede return URLs. State binder svaret til browserflowet, og nonce
binder de signerede identity-tokens til loginforsøget.

**Alternatives considered**: `localStorage` gør tokenet langlivet og mere
udsat ved XSS. Cross-site auth-cookie kræver en større cookie/CSRF- og
domæneopsætning end nødvendigt for den lille adminversion.

Kilde: [Apple — Configure Sign in with Apple for the web](https://developer.apple.com/help/account/capabilities/configure-sign-in-with-apple-for-the-web/).

## Dataminimering og sletning

**Decision**: Gem kun intern konto-id, hash af provider-subject, verificeret e-mail når
den faktisk leveres, rolle, state, profilnavn og nødvendige sessionstidspunkter.
Udløbne sessions slettes senest syv dage efter udløb. Slettet User anonymiseres
straks; nødvendig sikkerheds-/auditmetadata bevares uden provider-subject og
e-mail efter den godkendte slettepolitik.

**Rationale**: E-mail er kontakt-/bootstrapdata, ikke identitet. GPS-historik
tilføjes ikke. Rå Apple-, access- og refresh-tokens lagres aldrig.

**Alternatives considered**: At gemme alle Apple-claims giver ingen
produktværdi. Permanent sessionshistorik er unødvendig. Den endelige juridiske
behandlingsgrundlagstekst skal godkendes sammen med forfatningsændringen før
aktivering.
