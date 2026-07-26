# Svarnormalisering

Denne fil er sprogneutral med vilje. Den beskriver en regel, ikke en
Swift-implementering, fordi den samme regel senere skal gælde i en ASP.NET
Core-backend. Testvektorerne i `answer-testvectors.json` er den eksekverbare
udgave og køres i dag af `DanishTextNormalizerTests`.

## Rækkefølgen er en del af kontrakten

Skridtene udføres i denne rækkefølge. Bytter man om på dem, ændrer facit sig.

1. **NFC.** Samler `a` + kombinerende ring til ét `å`, så de følgende skridt
   arbejder på hele tegn frem for på fragmenter.
2. **Små bogstaver med `da_DK`.** Locale er ikke ligegyldigt — tyrkisk `I`
   folder anderledes, og en fremtidig lokalisering må ikke arve den fejl.
3. **Typografiske look-alikes.** Dansk autokorrektur sender krøllede
   apostroffer og tankestreger, som brugeren opfatter som de tegn, de ligner:
   - `’ ‘ ʼ ´ ′` → `'`
   - `“ ” ″` → `"`
   - `‐ ‑ ‒ – — ― −` → `-`
   - NBSP, figure space, thin space, narrow NBSP, ideografisk mellemrum → ` `
   - nul-bredde-tegn og BOM → fjernes
   - ikke-ASCII-cifre (fx fuldbredde `５`) → ASCII
4. **Dansk foldning**, når reglen slår den til: `æ→ae`, `ø→oe`, `å→aa`.
5. **Kassering** af tegn, svaret ikke må afhænge af (se profilerne nedenfor).
6. **Trim** af mellemrum i begge ender.

## Hvorfor ikke `diacriticInsensitive`

Foundations `folding(options: .diacriticInsensitive)` må **ikke** bruges.
`å` folder til `a`, mens `ø` og `æ` opfører sig inkonsistent på tværs af
ICU-versioner. Konsekvensen er en fejl, der består på udviklerens maskine og
fejler på en brugers telefon med en anden iOS-version — den dyreste slags.

Derfor er tabellen i skridt 4 skrevet ud i hånden.

## Profiler

| `answerRule.kind` | Foldning | Mellemrum | Skilletegn | Andet |
|---|---|---|---|---|
| `exact` | ja | fjernes | `- _ . , / \ : ;` fjernes | resten bevares |
| `digitsOnly` | — | fjernes | fjernes | alt andet end cifre kasseres |

## Cifferkoder sammenlignes som streng

Aldrig som heltal. `007` og `7` er **ikke** samme kode — foranstillede nuller
er betydende. En talkonvertering ville tabe dem lydløst, og fejlen ville først
vise sig den dag, en opgave får en kode, der begynder med nul.

Bølgens accepterede former er `592`, `5 9 2` og `5-9-2`. De er alle tre den
samme kode, fordi skridt 5 fjerner mellemrum og bindestreger — ikke fordi de er
opremset som alternativer.

## Rækkefølgen af udfald

Bedømmelsen prøver i denne rækkefølge:

1. Tomt svar → `malformed`
2. Accepteret svar → `correct`
3. Registreret fejlsvar → `nearMiss`
4. Forkert længde → `malformed`
5. Ellers → `incorrect`

At **3 ligger før 4** er bevidst. Opgavedokumenterne registrerer fejlsvar med
afvigende længde — fx Bølgens `5918`, hvor spilleren har brugt årstallet 2018 i
stedet for antallet af bølger. Lå længdekontrollen først, ville netop den
vejledning aldrig nå frem til spilleren, der havde mest brug for den.

At **2 ligger før 3** betyder, at et svar registreret begge steder bedømmes som
korrekt. Det er en forfatterfejl, og selvkonsistenstesten afviser pakken, før
den kan shippe (V-03, FR-044).

`malformed` tæller **ikke** som fejlforsøg (FR-014). "Koden er tre cifre" er
ikke et forkert svar, det er et ufærdigt.
