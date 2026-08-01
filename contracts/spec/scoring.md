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

## Et forkert svar koster også

Et gæt var gratis indtil feature 002. Det gjorde den billigste vej gennem en
opgave med fire svarmuligheder til at klikke sig igennem dem — og den, der
tænkte sig om, fik ikke mere for det end den, der ikke gjorde.

### Satsen afhænger af, hvad man svarer på

| Svartype | Fradrag pr. forkert svar |
|---|---|
| `singleChoice` med `N` muligheder | `12 / (N − 1)` % |
| `numericCode`, `freeText` | `2` % |
| `narrative` | intet — der er intet at svare på |

Formlen for `singleChoice` er valgt, så det koster **præcis 12 %** at eliminere
sig hele vejen frem til facit: det samme som at læse alle tre hints. Ingen af de
to genveje er billigere end den anden.

| Muligheder | Pr. fejl | Alle forkerte valg |
|---:|---:|---:|
| 2 | 12 % | 12 % |
| 3 | 6 % | 12 % |
| 4 | 4 % | 12 % |
| 5 | 3 % | 12 % |

En kode eller et fritekstsvar kan ikke brute-forces — der er tusind trecifrede
koder — så et forkert svar dér er næsten altid et ægte forsøg. De 2 % er
bevidst mindre end hint 1's 3 %, så det aldrig kan betale sig at lade være med
at gætte af frygt for prisen.

### Loftet er 12 %

Forkerte svar kan tilsammen højst koste 12 % — samme budget som de tre hints,
og de to lofter er uafhængige. En spiller, der både gætter og læser alt, ender
i værste fald på 76 af 100.

Loftet skæres på **procenten** og ikke på pointene, så regnestykket ser ens ud,
uanset grundpointene. Rammer et fradrag loftet, skrives den afkortede procent —
og bliver den nul, skrives ingen transaktion.

### Hvad der ikke koster

- **Ufuldstændige svar.** Et tomt felt eller en tocifret kode i en trecifret
  opgave er `malformed` og er ikke et forsøg. Det er en finger, der gled.
- **Det samme forkerte svar to gange.** Samme regel som genåbning af et hint:
  et gentaget svar fortæller spilleren intet nyt, og en hændelse, der leveres to
  gange af en sync, må ikke koste point.
- **Registrerede fejlsvar** koster som ethvert andet forkert svar. De giver
  bedre vejledning, men de er stadig forkerte, og at gøre dem dyrere ville
  straffe den, der kom tættest på.

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
