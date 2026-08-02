# ADR 0005 — Indholdet ejes af Azure Blob Storage, ikke af repoet

**Status**: Vedtaget
**Dato**: 2026-08-01
**Berører**: [ADR 0004](./0004-serverbaaret-indhold.md), forfatningens princip V

## Kontekst

[ADR 0004](./0004-serverbaaret-indhold.md) flyttede indholdet ud af app-bundlen
og ind på en tjeneste. Men kilden var stadig `contracts/content/` i git: den
blev redigeret i hånden, committet, og derfra lagt op.

Feature 002 gav quizmasterne en app. De retter nu opgaver fra telefonen, i
felten, uden at kende git. Med den ændring findes der to steder, indholdet kan
ændres — og de kan drive fra hinanden uden at nogen opdager det.

## Beslutning

**Azure Blob Storage er kilden. `contracts/content/` er en fixtur.**

- Quizmasterne skriver til blob gennem API'et. Ingen redigerer JSON i git.
- Kopien i repoet bliver liggende, fordi testene skal kunne køre uden en
  Azure-konto og uden net.
- `backend/pull-content.sh` henter kilden ned i fixturen. `seed-content.sh`
  går den anden vej og bruges kun til at fylde en tom container.
- `contracts/arkiver-indhold.py` skriver `docs/arkiv/indholdspakke.md`: en
  læsbar gengivelse af hver opgave plus hele pakken som JSON.

Skemaet, golden-filerne og testvektorerne ejes fortsat af repoet. Kontrakten er
kode og ændres i en pull request.

## Begrundelse

**En kopi, ingen kan rette, driver ikke.** Fixturen opdateres bevidst med et
script, ikke ved et uheld. Det gør driften synlig i en diff frem for usynlig.

**Testene må ikke røre netværket.** `swift test` i BHKit, admin-appens 68 tests
og backendens egne læser alle den samme fil. En test, der henter over nettet,
fejler tilfældigt og bliver slået fra inden for en uge.

**En blob-container har ingen historik, nogen gider bladre i.** Arkivet er
læsbart og ligger i git, så en ændring i indholdet kan ses som en diff — hvem
rettede hvad, og hvordan så gåden ud før.

## Konsekvenser

**Fixturen bliver forældet mellem to `pull-content.sh`.** Det er meningen, men
det betyder, at en grøn testkørsel beviser noget om den udgave, der sidst blev
hentet ned — ikke nødvendigvis om det, quizmasterne arbejder i lige nu.

**Testene så noget, ingen havde bedt om.** Første gang fixturen blev synkroniseret,
fejlede seks tests: en frigivet opgave uden spørgsmål, uden hints og uden tekst
på detaljerne. Den var sluppet ud, fordi serveren bevidst ikke validerer
kontrakten. Fixturen er dermed også en publiceringsport.

**Formkravene måtte skæres til.** Testene krævede detaljer, miniature og præcis
ét trin af **hver** opgave i pakken. Det passede, da pakken blev håndredigeret:
enhver ufærdig opgave var en fejl. Nu er en kladde under arbejde normal, og
spillerappen viser den ikke. Kravene gælder derfor `Mission.isPlayable` — samme
filter, `ContentRepository` allerede brugte.

Referencer, id-entydighed, hints, svarregler og rettigheder holdes stadig for
**alle** opgaver. En kladde med en hængende reference gør pakken ugyldig for
alle, uanset status.

**Revisionssporet forlader aldrig blob.** `audit.jsonl` bærer navne på
quizmastere og tidspunkter for deres arbejde — personoplysninger
(forfatningens princip VI). Den er gitignoreret og hentes ikke af
`pull-content.sh`.

## Alternativer

**Repoet forbliver kilden, og appen laver pull requests.** Ville bevare
historik og review, men kræver, at en quizmaster i felten venter på en merge for
at rette en tastefejl i sin egen opgave. Princip IV kræver, at en opgave kan
pauses øjeblikkeligt.

**Ingen kopi i repoet; testene henter fra blob.** Ville fjerne driften helt, men
gøre hele testsuiten afhængig af en Azure-konto og af netværket. En frisk klon
skal kunne køre `swift test`.
