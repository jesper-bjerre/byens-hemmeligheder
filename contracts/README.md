# Kontrakten og indholdet

To ting bor her, og de har hver sin ejer.

| | Ejer | Ændres af |
|---|---|---|
| `bh-content-v1.schema.json` | repoet | en pull request |
| `spec/` | repoet | en pull request |
| `golden/` | repoet | `BH_REGENERATE_GOLDEN=1 swift test` |
| `content/` | **Azure Blob Storage** | quizmasterne gennem appen |

## Indholdet ejes ikke af repoet

Siden feature 002 ligger indholdspakken og medierne i Azure Blob Storage.
Quizmasterne retter gennem admin-appen, ikke gennem git — det var hele
formålet med at komme væk fra håndredigeret JSON.

**`contracts/content/` er derfor en fixtur, ikke kilden.** Den ligger her,
fordi testene skal kunne køre uden en Azure-konto og uden net:

- `swift test` i `iOS/Packages/BHKit` — selvkonsistens, golden-filer, point
- admin-appens 62 tests — dokumentlaget, hierarkiet, postnumrene
- backendens tests — læse- og skrivevejen

En test, der henter over netværket, fejler tilfældigt og bliver slået fra
inden for en uge. Derfor en kopi på disken.

### Hold fixturen i takt med kilden

```bash
./backend/pull-content.sh byensgaaderp content authoring  # PROD-kilden → repoet
python3 contracts/arkiver-indhold.py       # opdatér det læsbare arkiv
```

Kør derefter testene. De siger, om det, quizmasterne har lavet, stadig
overholder kontrakten — og det er den eneste publiceringsport, der findes.

Den modsatte vej findes også, men bruges sjældent:

```bash
./backend/seed-content.sh byensgaaderd content-local authoring-local
```

Den overskriver. Kør den aldrig mod PROD eller en container, quizmasterne
arbejder i.

## Arkivet

`docs/arkiv/indholdspakke.md` er en læsbar gengivelse af hver opgave — gåde,
facit, hints, belønning og rettighedskæde — plus hele pakken som JSON.

Den findes, fordi en blob-container ingen historik har, nogen gider bladre i,
og fordi JSON ikke kan læses hen over skulderen. Genereres den igen efter en
ændring, viser git præcis hvad der ændrede sig.

Det er **ikke** en backup, der kan spilles tilbage. Til det er der
`seed-content.sh`.

## Revisionssporet ligger kun i blob

`audit.jsonl` bærer navne på quizmastere og tidspunkter for deres arbejde.
Det er personoplysninger (forfatningens princip VI), og filen er gitignoreret
og hentes ikke ned af `pull-content.sh`. Den læses gennem
`GET /content/{locale}/audit` eller i admin-appen.

## Skemaet ejes stadig af repoet

Kontrakten er kode. Den ændres i en pull request, med golden-filerne og
testene i samme commit — ikke af nogen, der retter i en opgave.
