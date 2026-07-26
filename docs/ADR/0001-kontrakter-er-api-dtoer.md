# ADR 0001 — Kontrakttyperne *er* API-DTO'erne

**Status**: Vedtaget
**Dato**: 2026-07-26
**Kontekst**: Feature 001 — fundament og lodret snit
**Kilder**: [research.md R-003](../../specs/001-fundament-og-lodret-snit/research.md)

## Kontekst

Feature 001 har ingen backend. Den får en senere: en ASP.NET Core-tjeneste, der
serverer den samme indholdspakke, appen i dag læser fra sin egen bundle.

Det rejser et valg, som er billigt nu og dyrt om et år: skal `BHContracts`-typerne
være wire-typer, domænetyper eller begge dele?

## Beslutning

`BHContracts` indeholder **ét** lag. Typerne er immutable `Codable` structs, der
samtidig er læsemodellen. Der findes ingen mapping fra DTO til domæne, og der
kommer ingen.

Følgekrav, der gør beslutningen sand frem for en hensigt:

1. **Ingen key-konverteringsstrategi.** Swift-navnet *er* wire-navnet.
2. **Golden-serialiseringstest** pr. kontrakttype i `contracts/golden/`.
3. **Kun additive ændringer.** Nye felter er altid optional.
4. **Aldrig bar `String`-raw enum.** Ukendte værdier lander i `.unknown(String)`.
5. **Adfærd bor i `BHGameCore`**, aldrig på kontrakttyperne.

## Begrundelse

Den mellemliggende oversættelse, en DTO→domæne-mapping ville give, køber
fleksibilitet, vi ikke har brug for, og koster den ene egenskab, vi har mest brug
for: at en omdøbning er **synlig**.

Med ét lag fejler `GoldenTests`, når `shortTitle` bliver til `subtitle`, med
beskeden "dette er en API-ændring". Med to lag ville mappingen absorbere
ændringen lydløst, og bruddet ville først vise sig, når en shippet klient mødte
en server, der havde skiftet mening.

Der er også en størrelsesbetragtning. Modellen er lille — ni typer i
indholdsmodellen. En tredobbelt repræsentation af ni typer er ren ceremoni.

## Konsekvenser

**Gode.** Wire-formatet er versionsstyret og testet. Kontrakten kan læses af et
menneske i `contracts/golden/`. En backend kan implementeres mod de samme filer
uden at gætte.

**Dårlige.** Kontrakten kan ikke ændres frit. En omdøbning kræver enten en
tilbagerulning eller en ny skemaversion, og det vil føles stift den dag, et navn
viser sig at være dårligt valgt. Det er den tilsigtede omkostning.

**Grænsen.** Beslutningen gælder wire-typerne. Kørselsmodellen
(`GameEvent`, `GameSession`) ligger samme sted, fordi den er formet som det, en
fremtidig `POST` sender — men den er ikke bundet af skemaet i
`contracts/bh-content-v1.schema.json`.

## Alternativer

**DTO → domæne → viewmodel.** Afvist: tredobbelt repræsentation i denne
størrelse er omkostning uden gevinst, og den ødelægger golden-testens værdi.

**Kodegenerering fra JSON Schema.** Afvist for nu. Det ville binde bygningen til
et værktøj på både macOS og Windows (R-011), og med ni typer er håndskrivning
hurtigere end at vedligeholde en generator.
