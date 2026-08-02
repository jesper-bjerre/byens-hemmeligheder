# ADR 0007 — Blob nu, relationelt når der er konti

**Status**: Foreslået
**Dato**: 2026-08-02
**Ændrer**: Forfatningens afsnit **Tekniske rammer** (afsnittet om data)
**Berører**: [ADR 0004](./0004-serverbaaret-indhold.md),
[ADR 0005](./0005-blob-er-kilden-til-indholdet.md),
[feature 003](../../specs/003-indholdslager/research.md)

> **Ikke accepteret og under revurdering.** Feature 003's research blev
> genåbnet 2. august 2026, da partnerretning og flere quizmastere blev en del af
> forudsætningen. Den nye anbefaling er Azure SQL som redaktionel kilde og blob
> som læsemodel. Accepteres den, markeres denne ADR som afvist og erstattes af
> en ny beslutning.

## Kontekst

Forfatningens tekniske rammer siger:

> Relationel database er den primære domænedatabase for indhold, versioner,
> progression og point. Table Storage anvendes kun til simple sidebehov.
> JSON-filer anvendes kun til engangsprototyper eller seed-data.

Stakken nævner **Azure SQL Database**, og Blob Storage kun til medier.

Indholdet ligger i dag som JSON i blob, og [ADR 0005](./0005-blob-er-kilden-til-indholdet.md)
gjorde blobben til kilden. **Ingen af de to ADR'er nævnte, at det var en
afvigelse.** Rammerne må kun ændres gennem en forfatningsændring eller en ADR,
der eksplicit henviser til afsnittet. Det er ikke sket. Denne ADR lukker den
mangel og tager stilling frem for at lade tilstanden fortsætte i tavshed.

## Beslutning

**Indholdet ligger i blob, indtil der findes konti, roller eller
serverbåret progression. Så flytter sandheden til en relationel database, og
blobben bliver læsemodellen.**

Konkret nu (feature 003):

- Én blob pr. opgave er kilden.
- `content-pack.json` genereres af de spilbare opgaver og er det, spillerne
  henter.
- Table Storage bruges ikke til indhold. Forfatningens "kun til simple
  sidebehov" står ved magt.

Betingelsen for at flytte er skrevet ned med vilje. Den udløses af **det
første** af:

1. Brugerkonti for quizmastere med roller håndhævet server-side (princip IV).
2. Progression eller point, der skal overleve en telefon (i dag lokalt, ADR 0002).
3. Indhold, der skal kunne forespørges på tværs — flere sprog, flere byer.

## Begrundelse

**Læsevejen og skrivevejen vil ikke det samme.** Læsningen er mange, anonyme og
hyppige og vil have noget statisk med `ETag` og `304`. Skrivningen er få,
sjældne og fra en telefon i felten og vil have små enheder med samtidighed pr.
opgave. En database løser den anden, ikke den første — man ville alligevel
generere en pakke og lægge den i blob.

**Rammernes begrundelse er endnu ikke indtruffet.** Sætningen taler om
"indhold, versioner, progression og point". Der er ingen konti (princip VI),
progression skrives lokalt (ADR 0002), og det eneste serverdata er ét dokument.
En database ville i dag holde nul relationer.

**Kontrakten er dokumentformet.** Kort, hints og accepterede svar er indlejrede
lister. At mappe dem til tabeller trækker mod ADR 0001, hvor kontrakttyperne
*er* API'ets DTO'er, og gør hver ny felttilføjelse til en migrering, hvor den i
dag koster ingenting.

**"Engangsprototype" er ikke længere en dækkende beskrivelse**, og det er netop
derfor, dette skal skrives ned frem for at blive læst som en midlertidighed, der
bare varede ved.

## Konsekvenser

**Grænsen skal trækkes nu, ikke ved flytningen.** Genereringen af pakken skal
fra dag ét være et selvstændigt skridt med en egen indgang, så kilden kan skiftes
ud under den. Bliver genereringen flettet ind i gemningen, bliver flytningen til
SQL en omskrivning frem for en udskiftning.

**Spillerappen må ikke kende kilden.** Den henter `GET /content/{locale}/pack`
og skal blive ved med det. Den er allerede sådan i dag, og den egenskab er
grunden til, at beslutningen kan udskydes uden at det koster.

**Der findes ikke serverside-rettigheder, før databasen kommer.** Princip IV
kræver, at rolle- og rettighedsmodellen håndhæves server-side. Indtil da er
adgangskontrollen en delt nøgle — en spærring mod tilfældige, ikke en
rettighedsmodel. Det er registreret som en afvigelse i
[feature 002's plan](../../specs/002-quizmaster-app/plan.md) og i
[udrulning.md](../drift/udrulning.md).

**Forfatningen rettes ikke.** Rammerne beskriver, hvor produktet skal hen, og de
er stadig rigtige. Denne ADR er den registrerede afvigelse, rammerne selv
foreskriver — ikke en ændring af målet.

## Alternativer

**Azure SQL nu.** Ville følge rammerne uden at skulle begrundes. Men den løser
ikke læsevejen, koster en skema-migrering ved hver kontraktændring, og ville i
dag holde ét dokument uden relationer. Arbejdet ville skulle gøres om, når
kontrakten alligevel ændrer sig, mens quizmasterne finder ud af, hvad de har
brug for.

**Table Storage.** Køber ETag pr. entitet, som en blob pr. opgave også giver, og
punktopslag, ingen har brug for. Betaler med læsevejens cacheegenskab. Se
[research.md](../../specs/003-indholdslager/research.md) afsnit C.

**Lade være med at skrive noget ned.** Tilstanden ville fortsætte, og den næste,
der læser forfatningen, ville tro, at indholdet lå i Azure SQL.
