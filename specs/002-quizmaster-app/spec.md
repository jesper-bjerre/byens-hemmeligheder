# Feature 002 — Quizmaster-appen

**Status:** Under udarbejdelse
**Aftalt:** 30. juli 2026
**Kode:** `iOS-admin/ByensGaaderAdmin`, backend i `backend/`

Formålet er at komme væk fra håndredigeret JSON. En quizmaster skal kunne stå på
stedet, fotografere, aflæse sin position og oprette eller rette en opgave fra
telefonen.

## Hvorfor den er sin egen app

Spillerappen skal være stabil og sjældent opdateret — familier har den
installeret i månedsvis. Admin-appen skal kunne rettes samme dag, en quizmaster
finder noget, der driller. Ligger de i samme binære, arver spillerne enhver
hastværksudgivelse.

Det er også det, der gør det muligt at slukke `BH_DEV_TOOLS` i spillerappens
Release igen, når GPS-simulering og nulstilling er flyttet herover.

## Roller

Alle quizmastere har **samme rettigheder til indhold** og kan flytte enhver
opgave mellem statusser. Der er ingen godkendelsesgang. Admin-rollen styrer kun
brugere.

Fordi alle kan rette i alt, er **et spor over hvem der ændrede hvad og hvornår**
vigtigere, ikke mindre. Det bør bygges ind fra start.

## Rettelser, der venter

- **FR-101**: Pakke-sektionen på forsiden MUST fjernes.
- **FR-102**: Serveradressen MUST være en app-konfiguration og ikke et felt i
  UI'et. I Debug MUST den kunne overstyres af en konfiguration.
- **FR-103**: Knappen "Hent" MUST hedde "Genindlæs opgaver".
- **FR-104**: Statusværdier MUST oversættes i UI'et. `fieldTestReady` vises som
  "Frigivet".
- **FR-105**: Opgaverne MUST vises i et hierarki: landsdel → postnummer →
  opgaver. Se blokeringen nedenfor.
- **FR-106**: Quizmasteren MUST kunne oprette en ny opgave.
- **FR-107**: Titel og GPS-koordinater MUST kunne redigeres. En knap MUST
  indsætte quizmasterens nuværende position — hen står typisk på stedet.
- **FR-108**: Kortenes billeder MUST kunne ses, fjernes og erstattes med et nyt
  upload.
- **FR-109**: Hints MUST kunne redigeres.
- **FR-110**: Alle quizmastere MUST kunne flytte enhver opgave mellem statusser.
  Der er ingen godkendelsesgang.
- **FR-111**: Ændringer MUST efterlade et spor over hvem, hvornår, fra og til
  hvilken status. Begrundelse: når alle kan rette i alt, er sporet det eneste,
  der kan svare på hvorfor noget blev udgivet.

## Faneblade

Du foreslog tre — *Opgaven, Kort, Hints*. Feltoptællingen nedenfor viser, at det
ikke rækker. **Fem** dækker det:

| Faneblad | Indhold |
|---|---|
| Opgaven | titel, kort titel, teaser, sværhedsgrad, tid, point, status, tags |
| Stedet | adresse, GPS, aktiveringsradius, standpunkt, sikkerhed, tilgængelighed |
| Kort | billeder og tekst, tilføj/fjern/omarranger |
| Spørgsmål | svartype, spørgsmål, facit, accepterede svar, feedback |
| Hints | tre hints med titel, tekst og fradrag |

## Felter, en ny opgave kræver

Optalt fra `contracts/content/da-DK/content-pack.json`.

**Opgaven:** `id`, `slug`, `title`, `shortTitle`, `teaser`, `status`,
`difficulty` (1–5), `estimatedMinutes`, `basePoints`, `tags`, `locationId`

**Stedet** — en egen post i `locations`: `name`, `address`, `latitude`,
`longitude`, `activationRadiusMetres`, `maxAcceptableAccuracyMetres`,
`dwellSeconds`, `vantagePoint` (koordinat, retning, instruktion),
`publicAccess`, `safety`, `accessibility`

**Spørgsmålet:** `kind` (`singleChoice`, `numericCode`, `freeText`), `title`,
`question`, `answerRule` med `canonicalAnswer`, `acceptedAnswers`,
`nearMissResponses`, `genericIncorrectFeedback`

**Belønningen:** `headline`, `subheadline`, `messageLabel`, `message`,
`historyFact`

**Hvert billede:** `altText`, `owner`, `licence`, `credit`, `creditLine`,
`kind`, `manipulation`

## Blokering: hierarkiet kan ikke bygges endnu

Pakken har `areas`, men **hverken landsdel eller postnummer findes som felter**.
Postnummeret ligger inde i `address` som fritekst: `"Frydenlund 98, 7120 Vejle"`.

Enten parser appen adressen — skrøbeligt — eller `Area` får `region` og
`postalCode`. Det sidste er det rigtige, og det er en kontraktændring, der skal
ske **før** editoren bygges.

## Rækkefølge

1. `Area` får `region` og `postalCode`
2. De små rettelser: fjern Pakke- og Server-UI, konfiguration i stedet,
   "Genindlæs opgaver", statusnavne
3. Editoren med fem faneblade
4. Opret ny opgave
5. Kamera og GPS

## Om App Store

Appen skal bygges efter Apples retningslinjer, men den bliver **svær at få
godkendt som offentlig app**: den har intet formål for en almindelig bruger og
rammer *Guideline 4.2, Minimum Functionality*.

Til fem quizmastere hører den hjemme på **TestFlight intern test**, hvor der
ingen review er. Det fjerner en blokering, man ellers først opdager til sidst.

## Designvalg, der allerede er truffet

**Appen modellerer ikke kontrakten.** `PackDocument` henter pakken som JSON,
retter enkeltfelter og sender den tilbage. Felter, appen ikke kender, overlever
en gemning uændret. Havde den haft Swift-modeller, ville den tabe ethvert nyt
felt i det øjeblik, den gemte.

**Gemning bruger `If-Match`.** Alle quizmastere kan rette i alt; uden det taber
den, der gemmer sidst, den andens arbejde i tavshed.

**Medier overskrives aldrig.** Serveren svarer `409` på et kendt filnavn.
Billeder sendes med et års cache, så en fil, der skifter indhold uden at skifte
navn, står gammel på telefonerne i et år. Nummeret i `boelgen-001` **er**
versionen.
