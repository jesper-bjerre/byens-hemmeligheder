# ADR 0003 — Detektivstemning som gennemgående ramme

**Status**: Vedtaget
**Dato**: 2026-07-27
**Gælder**: Alt indhold — fortælling, fotografier og indtalt fortællerstemme
**Kilder**: `.specify/memory/constitution.md` princip I, II, III og VII

## Kontekst

Opgaverne havde indtil nu hver sin tone. Bølgen er "en glemt besked", Fjordenhus
"en arkitektnote", Frydenlund 98 "Sag 07" med lup og notesbog. Tonen var ved at
opstå af sig selv, opgave for opgave, uden at nogen havde valgt den.

Samtidig skal to nye materialetyper indføres: fotografier taget af quizmasteren
og en indtalt fortællerstemme pr. opgave. Begge former stemning stærkere end
brødtekst gør, og begge er dyre at lave om bagefter.

De oplagte alternativer var eventyr (Hobbitten) eller Disney-agtig magi.

## Beslutning

**Detektivrammen er den gennemgående tone.** Spilleren undersøger noget
virkeligt. Sagen er opdigtet; sporene er det ikke.

Konkret betyder det:

- Opgaven præsenteres som en **undersøgelse**: et spor, et vidnesbyrd, en sag.
- Fortællingen må opfinde **anledningen** — en glemt besked, en efterforsker,
  en forsvunden person — men aldrig **kendsgerningerne**.
- Rekvisitter og stemning må gerne være filmiske: mørke, regn, lup, notesbog.
- Ingen magi, ingen fabelvæsener, ingen overnaturlig årsagsforklaring.

## Begrundelse

Valget er ikke smag. Det er den eneste af de tre rammer, der ikke arbejder mod
forfatningen.

**Princip II kræver et bevisbart facit.** Bølgens kode kan bevises: fem bølger,
ni etager, to før pausen. En detektivramme belønner præcis den adfærd — observér,
tæl, læs kilden. Den er formen, gåden allerede har.

**Princip III forbyder at fremstille fiktion som virkelig historie.** En
detektivramme siger til spilleren, at det undersøgte er virkeligt, og at kun
sagen er opdigtet. Det er en ærlig kontrakt. Et eventyr siger det modsatte og
lægger et vedvarende pres på forfatteren for at pynte: bliver Fjordenhus til et
fortryllet tårn, er princip III under angreb ved hver eneste opgave.

**Princip I gør stedet til spillet.** En detektiv skal se efter. En eventyrhelt
skal føle. Kun den første mekanik kræver, at spilleren står det rigtige sted.

**Målgruppen er 10–15 år.** Detektivrammen er den, der bedst tåler at blive
spillet af en familie med spredt alder: et barn kan lede efter noget konkret,
mens en voksen kan læse kilden.

## Fortællerstemme

Hver opgave får en indtalt introduktion — AI-genereret, afspillet når spilleren
starter opgaven.

**Stemmen er stemning, aldrig indhold.** Alt, hvad der skal til for at løse
opgaven, står på skærmen som tekst. Stemmen må uddybe, farve og sætte scenen,
men den må ikke bære et eneste spor, teksten ikke også bærer.

Reglen har tre grunde, og kun den ene handler om tilgængelighed:

1. Begge opgavedokumenter kræver allerede, at opgaven ikke afhænger af lyd.
2. En familie ved en havnekant i blæsevejr hører ikke en fortællerstemme.
3. Lyd, der bærer indhold, kan ikke oversættes eller rettes uden ny indtaling.

**Stemmen er AI-genereret og skal mærkes som sådan** (princip III). Det gælder
også, selvom den ikke udgiver sig for at være en bestemt person.

**Afspilningen er spillerens valg.** Den starter ikke af sig selv med lyd på et
sted, hvor andre står omkring — og den kan altid stoppes.

## Fotografier

Quizmasteren tager fotografierne, og de må **manipuleres for stemningens skyld**:
farvegradering, mørke, regn, lys, beskæring, fjernelse af personer og
nummerplader.

Der går én linje, og den er ikke til forhandling:

> **Manipulationen må aldrig røre det, spilleren skal observere.**

Bølgen har fem bølgetoppe. Tages der en top fra eller lægges en til, er facit
`592` ikke længere bevisbart — og spilleren tæller på fotografiet, ikke på
bygningen. Det ville bryde princip II direkte og princip I indirekte, fordi
turen så kunne løses hjemmefra.

Praktisk regel: **er detaljen en del af løsningsbeviset, er den fredet.** Alt
andet er stemning.

Fotografier af den slags er ikke længere `contemporary` i almindelig forstand.
De skal mærkes særskilt, og manipulationen skal beskrives i medieposten, så en
senere redaktør kan se hvad der er rørt.

## Konsekvenser

**Gode.** Én tone på tværs af opgaver. Forfatteren har et svar på "må jeg
opfinde dette?" — ja til anledningen, nej til kendsgerningerne. Fotografier kan
gøres smukke uden at gøre gåden utroværdig.

**Dårlige.** Detektivrammen er smallere end et eventyr. Nogle lokationer egner
sig dårligt til en sag, og de vil kræve mere arbejde eller bør vælges fra.
Fortællerstemme fordobler produktionsarbejdet pr. opgave og skal genindtales,
hver gang en tekst rettes.

**Kontraktændringer, der følger.** Begge additive, som `freeText` var det:

- `MediaAsset` antager i dag billeder. Lyd kræver en medietype.
- `MediaKind` har `historical | contemporary | aiGenerated`. Et manipuleret
  fotografi er ingen af delene og kræver en fjerde værdi.
- Manipulationen skal kunne beskrives i medieposten.

## Alternativer

**Eventyrstemning (Hobbitten, Disney).** Afvist: den inviterer til at pynte på
fakta og sætter princip III under pres ved hver opgave. Den ville også gøre
observationsmekanikken til pynt frem for til selve spillet.

**Ingen fælles ramme — hver opgave sin tone.** Afvist: fotografier og
fortællerstemme gør tonen dyr at ændre bagefter. Uden et valg driver opgaverne
fra hinanden, og en ny forfatter har intet at rette sig efter.

**Fortællerstemme som bærer af spor.** Afvist: se ovenfor. Det ville gøre lyd
til en forudsætning og bryde med det, opgavedokumenterne allerede lover.
