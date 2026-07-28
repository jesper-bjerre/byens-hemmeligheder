# ADR 0004 — Indhold hentes fra serveren; appen kræver forbindelse

**Status**: Vedtaget
**Dato**: 2026-07-27
**Ændrer**: Forfatningens princip V, som hed *Offline-tolerant afvikling*
**Berører**: [ADR 0001](./0001-kontrakter-er-api-dtoer.md), [ADR 0002](./0002-haendelseslog-frem-for-swiftdata.md)

## Kontekst

Feature 001 bar indholdspakken i app-bundlen, og forfatningens princip V krævede,
at hele sessionen kunne gennemføres uden netværk. Antagelsen var, at spilleren
står udendørs med ustabil dækning.

Der kommer nu en central tjeneste med alle opgaver. Det ændrer regnestykket:
med to kilder til indhold — bundlen og serveren — findes der pr. definition en
version, der kan drive fra den anden.

## Beslutning

**Indhold hentes fra tjenesten. Appen bærer ingen indholdspakke.**

- `ContentPackSource` peger på netværket. Den bundlede kilde bliver et
  udviklingsværktøj, ikke en udgivelsesvej.
- Appen kræver forbindelse for at hente opgaver.
- **Progression skrives fortsat lokalt først** og synkroniseres idempotent.
- En `GameSession` fastholder stadig den indholdsversion, den startede på.

## Begrundelse

**Én kilde til sandhed.** Princip IV kræver, at en opgave kan pauses øjeblikkeligt
uden en udgivelse. Det er umuligt, når facit ligger i en binær på tusind
telefoner. Serverbåret indhold gør pausefunktionen mulig — og den var registreret
som en åben afvigelse i feature 001's Constitution Check.

**Rettelser når frem.** Bølgens ugyldige kode `541` slap engang ud i en
illustration. Med bundlet indhold kræver en rettelse en ny udgivelse og en
opdatering, spilleren selv skal installere.

**Kontrakten var bygget til det.** `ContentPackSource` har haft
`ifNoneMatch`/`notModified` fra første dag, netop for at en netværkskilde kunne
skydes ind uden signaturændring (ADR 0001). Skiftet koster derfor ingen
omskrivning af kaldsteder.

## Konsekvenser

**Prisen er reel, og den skal bæres i brugerfladen.** Spilleren står udendørs.
Mister hen dækningen, må det aldrig ligne, at opgaven er i stykker eller at
svaret var forkert. Manglende forbindelse er en tilstand med en forklaring og en
handling — samme princip som positionsgatens otte tilstande.

**Progression bliver vigtigere, ikke mindre.** Netop fordi indholdet nu kommer
udefra, er den lokale hændelseslog dét, der gør et udfald til ventetid frem for
til en tabt tur. [ADR 0002](./0002-haendelseslog-frem-for-swiftdata.md) står
uændret, og dens begrundelse er blevet stærkere.

**Versionsfastholdelse bliver kritisk.** Med bundlet indhold kunne facit ikke
skifte under en igangværende tur. Nu kan det: en redaktør retter en opgave,
mens en familie står midt i den. `GameSession.contentVersion` er ikke længere en
forberedelse til fremtiden — den er det, der forhindrer, at et svar bliver
forkert, mens det tastes.

**Testene skal vende.** `testFullFlowMakesNoNetworkRequests` hævder i dag, at et
gennemløb ikke rører netværket. Den påstand er nu forkert og skal erstattes af
det modsatte krav: at et udfald midt i en tur ikke koster progression.

**Tabt egenskab.** En tur i et sommerhusområde uden dækning kan ikke længere
gennemføres. Det er en bevidst byttehandel, ikke en forglemmelse.

## Alternativer

**Hent ved start, spil lokalt.** Opgaven downloades komplet, når spilleren
trykker start, og gennemføres derefter uden forbindelse. Bevarer robustheden mod
udfald midt i en gåtur og er stadig serverbåret — men blev fravalgt: den giver
to tilstande at fejlsøge og gør pausefunktionen upålidelig, fordi en hentet
opgave kan spilles færdig, efter den er trukket tilbage.

**Bundlet indhold med serveropdatering.** Afvist: det er de to kilder, hele
problemet handler om.
