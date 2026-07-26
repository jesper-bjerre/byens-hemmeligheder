# ADR 0002 — Append-only hændelseslog frem for SwiftData

**Status**: Vedtaget
**Dato**: 2026-07-26
**Kontekst**: Feature 001 — fundament og lodret snit
**Kilder**: [research.md R-005](../../specs/001-fundament-og-lodret-snit/research.md)

## Kontekst

Spillerens progression skal overleve, at appen bliver dræbt midt i en opgave ved
en havnekant, og den skal senere kunne synkroniseres til en server uden at nogen
mister point eller får dem to gange.

SwiftData er Apples anbefalede svar på "gem lokal tilstand". Vi valgte det ikke.

## Beslutning

Progression gemmes som en **append-only hændelseslog** i JSON Lines:
`Application Support/BH/events-v1.jsonl`.

- Hver hændelse har et **klientgenereret UUID** og et monotont `sequence`.
- Al afledt tilstand — point, gennemførte opgaver, brugte hints — er en **ren
  fold** over loggen (`StateProjection`). Der findes ingen skrivbar kopi.
- Skrivning er **atomisk**: hele filen skrives til en midlertidig fil og
  erstattes.
- `@AppStorage` bruges udelukkende til præferencer og navigationsgenoptagelse,
  aldrig til progression.

## Begrundelse

**Domænet er allerede en ledger.** Projektgrundlaget navngiver `Attempt`,
`Completion` og `ScoreTransaction`. At modellere en ledger som en ledger er ikke
et arkitektonisk valg, det er at lade være med at oversætte.

**Idempotens bliver gratis.** Forfatningens princip V kræver, at synkronisering
kan gentages uden skade. Med klientgenererede UUID'er bliver sync senere en
`POST` af det ubekræftede suffiks, og serveren deduplikerer på `id`. Med en
mutérbar model ville den samme egenskab kræve en separat outbox.

**Forklarligheden bliver gratis.** Princip V kræver, at pointtransaktioner kan
forklares. Belønningsskærmens pointopdeling *er* loggen filtreret på missionen —
ikke en parallel model, der kan nå at komme til at lyve.

**Testbarheden bliver gratis.** Foldet er en ren funktion. `StateProjectionTests`
bygger hændelser i hukommelsen og folder dem; ingen persistens involveret, ingen
disk, ingen mock.

**Atomiciteten er ikke til forhandling.** En halv linje i en JSON Lines-fil er en
korrupt log, og en korrupt log er en tabt tur. Fuld genskrivning er O(n) pr.
hændelse, hvilket ved nogle hundrede hændelser er ligegyldigt — og det er den
eneste form, der overlever, at appen dræbes midt i en skrivning.

## Konsekvenser

**Gode.** Progression kan ikke gå tabt eller tælles dobbelt. Loggen kan
inspiceres i en teksteditor under felttest. Afledt tilstand kan altid kasseres og
genopbygges.

**Dårlige.** Ingen forespørgsler. Skal vi en dag vise "alle opgaver løst i
oktober", kræver det en projektion, ikke en `FetchDescriptor`. Loggen vokser
ubegrænset — ved nogle tusinde hændelser skal der komprimeres til et snapshot.
Ingen af delene er nært forestående med to opgaver.

**Ikke en blindgyde.** SwiftData kan senere indføres som en *projektion* af
loggen, hvis en visning får brug for forespørgsler. Retningen er envejs og
bevidst: loggen er sandheden, alt andet er cache.

## Alternativer

**SwiftData som primær model.** Afvist: det ville tilføje en tredje
repræsentation (DTO ↔ `@Model` ↔ afledt tilstand) stik imod [ADR
0001](./0001-kontrakter-er-api-dtoer.md), og idempotent sync ville skulle bygges
oveni alligevel.

**`UserDefaults` med en kodet tilstandsstruktur.** Afvist: ingen historik, ingen
idempotensnøgle, og et tab ved samtidig skrivning er stille.

**SQLite direkte.** Afvist: forespørgsler er ikke problemet, og en fil, et
menneske kan læse under felttest, er mere værd end en indeksering, vi ikke
mangler.
