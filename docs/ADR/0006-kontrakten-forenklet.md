# ADR 0006 — Kontrakten forenklet, da quizmasterne fik en app

**Status**: Vedtaget
**Dato**: 2026-08-01
**Ændrer**: Forfatningens princip I og VII (version 3.0.0)
**Berører**: [ADR 0005](./0005-blob-er-kilden-til-indholdet.md)

## Kontekst

Kontrakten blev skrevet, mens indholdspakken blev redigeret i hånden af den, der
også havde skrevet skemaet. Felter, der krævede omtanke, var gratis: der var én
forfatter, og hen kendte dem alle.

Feature 002 gav fem quizmastere en app og en telefon. Hvert felt i kontrakten
blev til et felt på en skærm, der skal udfyldes stående udendørs — eller til et
felt, der bliver udfyldt skødesløst, fordi det spørger om noget, svaret allerede
er givet på.

## Beslutning

Seks ændringer. Alle er brud på wire-formatet og blev lavet i én omgang, fordi
ingen klient var udgivet endnu.

### `Area` fjernet — `location.postalCode`

Kvartererne var en liste med id, navn, landsdel og postnummer, som nogen skulle
vedligeholde. Postnummeret bestemmer alligevel de to sidste. By og landsdel slås
nu op i en genereret tabel over Danmarks 1089 postnumre
(`iOS-admin/Tools/generate-postnumre.py`, fra Dataforsyningens registre).

Tabellen ligger i koden og ikke bag et netværkskald: appen skal kunne oprette en
opgave i felten uden dækning, og det er præcis dér, den bruges.

### `vantagePoint` fjernet — opgavens koordinat **er** startstedet

Kontrakten bar to koordinater for det samme sted plus en fast kigretning. To
koordinater kan pege hver sin vej uden at nogen opdager det, og den faste
kigretning kunne stå og pege forkert, længe efter at koordinatet var rettet.

Retningspilen regnes nu ud af spillerens position og opgavens koordinat — det
gjorde `PresenceGate` allerede, når spilleren bevægede sig.

**Prisen er ståvejledningen** ("Stå på promenaden med fjorden på din venstre
side"). Skal den tilbage, hører den til som indhold på opgaven og ikke som et
andet koordinat.

### `teaser` → `description`

Engelske attributnavne på wire-formatet, danske tekster i UI'et. Resten af
kontrakten hed allerede `shortTitle`, `basePoints`, `fictionLabel`.

### `genericIncorrectFeedback` fjernet

De fire, der var skrevet, sagde alle det samme med hver sine ord. Et felt, der
skal udfyldes hver gang uden at bære noget nyt, bliver udfyldt skødesløst.
Teksten står nu ét sted: `AnswerOutcome.standardIncorrectFeedback`.

### `sourceIds` må være tom

Ikke enhver opgave er en bærende opgave. En lille gåde på vejen hen til den
næste hviler ikke på noget, der skal dokumenteres. Kravet gælder de bærende
opgaver og håndhæves redaktionelt, ikke af skemaet.

### `canonicalAnswer` redigeres ikke længere

Feltet er der stadig, men quizmasterappen skriver det af det første accepterede
svar. Svarmotoren bedømmer **kun** mod `acceptedAnswers` — facit i sig selv
tæller ikke — og feltet vises ingen steder for spilleren.

To felter, hvor det ene skal være en kopi af en linje i det andet, er to steder
at tage fejl.

## Konsekvenser

**V-02 er svækket.** Selvkonsistenstesten hævder, at
`evaluate(canonicalAnswer) == .correct`. Den fandtes for at fange en forfatter,
der rettede facit uden at rette listen. For indhold skrevet i appen kan fejlen
ikke længere opstå, så testen er sand pr. konstruktion og beviser intet om den
vej. Den holder stadig for indhold, der rettes i hånden.

Byttehandelen er bevidst: fejlen forhindres ved kilden i stedet for at blive
fanget bagefter. Den står skrevet i
[`contracts/spec/answer-normalization.md`](../../contracts/spec/answer-normalization.md),
i svarmotorens egen kommentar og i `data-model.md`, så ingen senere læser V-02
som en garanti, den ikke længere giver.

**Forfatningen måtte rettes, ikke omvendt.** Princip I krævede "GPS +
kigretning + sikker ståflade". Kontrakten kunne ikke længere bære to af de tre,
og forfatningen er projektets øverste dokument — så den blev ændret bevidst og
med begrundelse frem for at stå og love noget, ingen kunne opfylde.

**Et forkert svar koster nu point** (princip VII). Et gæt var gratis, så den
billigste vej gennem en opgave med fire svarmuligheder var at klikke sig igennem
dem. Reglen står i
[`contracts/spec/scoring.md`](../../contracts/spec/scoring.md) med otte
testvektorer: valg koster `12/(N−1)` %, tekst og kode 2 %, loft 12 %, og en
gennemført opgave giver aldrig under 76 af 100.

## Alternativer

**Beholde felterne og skjule dem i appen.** Ville bevare kontrakten uændret,
men efterlade felter, ingen udfylder, og som derfor står med pladsholdere i
udgivet indhold. Et felt, der altid siger "mangler", er værre end intet felt.

**En ny skemaversion.** Ville være det rigtige, hvis en klient var udgivet.
Ingen var, og en `v2` med fem brugere ville koste migrering uden at beskytte
nogen.
