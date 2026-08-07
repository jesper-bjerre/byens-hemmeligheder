# ADR 0010 — Direkte Apple-login og egne sessioner

**Status**: Accepteret

**Dato**: 2026-08-06

**Ændrer**: Forfatningens princip VI og afsnittet **Tekniske rammer / Identitet**

**Berører**: [ADR 0007](./0007-blob-nu-relationelt-naar-der-er-konti.md),
[feature 004](../../specs/004-authentication-og-roller/plan.md)

## Kontekst

Version 1 skal lukke det anonyme skrive-API og give spiller-, Designer- og
Admin-rettigheder uden en identitetsbroker med en pris, der vokser med antallet
af månedligt aktive brugere. Begge native apps er iOS-apps nu, mens Android og
webspiller kan komme senere. Spillerens offentlige læseflow skal fortsat fungere
uden konto.

Forfatningen foreskrev e-mail med engangskode. Den model har en løbende
beskedpris, gør e-mail til identitet og udnytter ikke, at iPhone-brugeren
allerede har en Apple-konto. Samtidig kan Apples relay-e-mail ændre den synlige
adresse uden at ændre brugerens stabile identitet.

## Beslutning

Version 1 bruger direkte Log ind med Apple. API'et validerer Apples
identity-token og den engangsbaserede authorization code server-side og
udsteder derefter egne opaque access- og refresh-sessioner.

- Kontoen får et tilfældigt internt `accountId`.
- Identiteten slås op på en hash af `(provider, providerSubject)`; e-mail er
  aldrig primærnøgle.
- Roller og kontotilstand læses fra serverens lager ved hver beskyttet request.
- Native refresh-sessioner roteres og lever højst 30 dage. Web-admin får kun en
  kort session i hukommelsen.
- Konti, identiteter og sessions gemmes i Azure Table Storage i hvert miljøs
  eksisterende Storage Account. Indhold forbliver i Blob Storage.
- Spillerapps kan fortsat hente og spille frigivet indhold som gæst.
- Andre identitetsudstedere kan senere oprette separate konti. Version 1
  sammenkæder ikke konti på tværs af udstedere eller e-mailadresser.

Apples stabile user identifier anvendes som identitet, fordi Apple selv
anbefaler den frem for e-mail. Apples dokumentation beskriver også, at navn kun
udleveres ved første godkendelse, mens brugeren kan vælge en relay-e-mail:
[Receiving a User’s Identity Token](https://developer.apple.com/documentation/signinwithapple/receiving-a-users-identity-token).

## Begrundelse

**Lav fast pris.** Table Storage genbruger eksisterende ressourcer. Der betales
ikke pr. aktiv bruger til en broker, og den meget læsetunge offentlige
indholdsvej kræver fortsat ingen kontoforespørgsel.

**Stabil identitet.** Apple-subject er stabilt inden for den grupperede
appfamilie. E-mail kan være skjult eller ændret og er derfor kun en valgfri
kontakt-/administrationsattribut.

**Serveren er autoritet.** Et klientclaim kan ikke gøre en User til Designer.
Blokering og rolleændring virker ved næste request, fordi kontoen slås op for
hver session.

**Fremtidige platforme er mulige.** Den interne konto og provider-tabellen er
ikke Apple-specifik. Android/web kan få andre udstedere uden at ændre
authorizationmodellen.

## Konsekvenser

**Gevinst:** Admin-API'et kan lukkes uden en dyr broker, og gæstespillet
forbliver friktionsfrit.

**Pris:** Projektet ejer nu tokenvalidering, Apple JWKS-cache, nonce/state,
sessionrotation, spærring, sletning, revocation-notifikationer og
nøglehåndtering. En fejl her er en sikkerhedsfejl, så negative tests og
fail-closed konfiguration er releasekrav.

**Pris:** Web-login kræver Apple Services ID, verificeret domæne og eksakte DEV-
og PROD-return URLs. Native App IDs og Services ID skal grupperes korrekt, hvis
samme Apple-konto skal have samme subject på tværs af klienterne.

**Pris:** Flere IDP'er giver separate konti for samme menneske. Det accepteres i
version 1 for at undgå usikker automatisk sammenlægning på e-mail.

**Privatliv:** Kontoen er frivillig for spillere. Datafelter, formål og
slettefrister følger forfatningens princip VI. Den konkrete privatlivstekst og
interesseafvejning skal reviewes før offentlig release, særligt fordi børn kan
bruge appen. GDPR artikel 6 kræver et gyldigt behandlingsgrundlag og skærper
interesseafvejningen, når den registrerede er et barn:
[forordning (EU) 2016/679](https://eur-lex.europa.eu/legal-content/DA/TXT/?uri=CELEX:32016R0679).

## Alternativer

**E-mail med engangskode.** Platformuafhængigt, men med beskedpris, større
loginfriktion og e-mail som central identifikator.

**Microsoft Entra External ID/Azure AD B2C.** Flytter mere sikkerhedsdrift til
en broker og gør flere IDP'er lettere, men prisen vokser med aktive brugere og
er unødvendig til en iPhone-først pilot.

**Kun Apples token på hvert API-kald.** Færre egne sessionstyper, men gør
rolleændring, global logout, spærring og kontosletning dårligere og binder alle
beskyttede requests direkte til Apple.

**Delt administrationsnøgle.** Hurtigst at bygge, men kan ikke identificere en
ansvarlig bruger, tilbagekaldes kun globalt og giver ingen rollemodel. Det
opfylder ikke kravene.
