# Pointberegning

Sprogneutral med vilje, som `answer-normalization.md`. Klienten regner i dag,
og en fremtidig server skal regne det samme — til pointet. Uenighed mellem de
to ville vise sig som en highscore, ingen kan forklare.

## Reglen

For hvert brugt hint:

```
fradrag = round(grundpoint × fradragsprocent / 100)
```

`round` er **half-away-from-zero**. `2,5` bliver til `3`, ikke til `2`.

Det er ikke Swifts standardafrunding, og det er ikke .NETs standard for
`Math.Round(double)` — begge sprog defaulter til bankers rounding, hvor
`2,5` bliver til `2`. Derfor står reglen skrevet ud her, og derfor findes
`scoring-testvectors.json`.

## Én transaktion pr. hændelse

Point lagres aldrig som ét tal. Hver bevægelse er sin egen transaktion med sin
egen begrundelse, og summen udledes. Det er dét, der gør belønningsskærmens
pointopdeling mulig uden en parallel forklaringsmodel (FR-020) — opdelingen
*er* ledgeren filtreret på missionen.

Rækkefølgen for en gennemført mission:

| # | Årsag | Point |
|---|---|---:|
| 1 | `missionCompleted` | `+grundpoint` |
| 2 | `hintUsed` (hint 1) | `−round(100 × 3 / 100)` = `−3` |
| 3 | `hintUsed` (hint 2) | `−round(100 × 4 / 100)` = `−4` |
| 4 | `hintUsed` (hint 3) | `−round(100 × 5 / 100)` = `−5` |
| | **I alt** | **88** |

## Fradragene kommer fra indholdet

Koden kender ingen procenter. `penaltyPercent` står på hvert `Hint` i
indholdspakken (FR-021), og selvkonsistenstesten kræver, at de tre summer til
præcis 12 (V-04, FR-045).

## Genåbning er gratis

Et hint, spilleren allerede har betalt for, koster ikke igen (FR-019). Foldet
over hændelsesloggen deduplikerer på `hintId` pr. mission, ikke på antallet af
`hintUsed`-hændelser — så en spiller kan slå op i hintet så mange gange, det
skal være.

## Tid indgår ikke

Overhovedet. Forfatningens princip VII forbyder tidspres, og SC-005 gør det
målbart: to spillere med samme hintforbrug får samme point, uanset om de brugte
fire minutter eller fyrre. Der findes ingen tidsbonus, ingen tidsstraf og ingen
skjult vægtning.
