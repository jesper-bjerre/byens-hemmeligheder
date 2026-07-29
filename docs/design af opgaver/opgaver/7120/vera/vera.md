# Frydenlund 98 – Opgave 3

## Vera og de fire huller

**Status:** Udkast – afventer felttest og endelig godkendelse  
**Lokation:** Frydenlund 98  
**GPS-koordinat:** `55.734897, 9.620270`  
**Aktiveringsradius:** `10 meter`  
**Opgavetype:** Logisk gåde med spor  
**Målgruppe:** Børn og familier  
**Sværhedsgrad:** 2  
**Forventet varighed:** 3–6 minutter  
**Svarformat:** Multiple choice med fire valgmuligheder  
**Korrekt svar:** `Hul 3`

---

# 1. Kortbeskrivelse

> I haven bor kaninen Vera.  
> I nat har fire kaniner gravet hvert sit hul, men alle sporene er blevet blandet sammen.  
> Kan I finde ud af, hvilket hul der tilhører Vera?

Denne tekst kan vises på kortets overlay, før spilleren starter opgaven.

---

# 2. Spillerens ankomst

Opgaven aktiveres ved:

> **55.734897, 9.620270**

Fra det offentligt tilgængelige standpunkt kan spillerne se området, hvor Vera bor.

Spillerne skal blive på det offentlige standpunkt. De må ikke gå ind på grunden, røre ved indhegningen, kalde på Vera eller forsøge at fodre hende.

Opgaven skal kunne løses ud fra billedet og sporene i appen, også når Vera ikke er synlig i virkeligheden.

---

# 3. Introduktion til text-to-speech

> I haven bor kaninen Vera.  
> Men i nat er der sket noget mærkeligt.
>
> Fire kaniner har gravet hvert sit hul, og nu er alle spor blevet blandet sammen.
>
> Ingen kan længere huske, hvilket hul der tilhører hvem.
>
> Kun nogle få ledetråde er tilbage.
>
> Brug sporene. Tænk jer godt om. Og find ud af, hvilket hul Vera bor i.
>
> Når I har valgt det rigtige hul, er Veras hemmelighed afsløret.

**Anbefalet oplæsning:** Roligt tempo med en kort pause mellem afsnittene.  
**Forventet varighed:** Cirka 25–35 sekunder.

---

# 4. Gåden

Fire kaniner bor i hvert sit hul.

Hullerne er nummereret fra venstre mod højre:

> **Hul 1 – Hul 2 – Hul 3 – Hul 4**

Kaninerne hedder:

- Vera
- Plet
- Sne
- Skygge

## Spor

1. Vera bor hverken i hul 1 eller hul 4.
2. Plet bor i hullet lige til venstre for Vera.
3. Sne bor i hul 4.
4. Skygge bor til venstre for Plet.

## Spørgsmål

> **Hvilket hul bor Vera i?**

---

# 5. Svarmuligheder

- Hul 1
- Hul 2
- Hul 3
- Hul 4

**Korrekt svar:** `Hul 3`

---

# 6. Løsningsbevis

Sne bor i hul 4.

Vera kan derfor ikke bo i hul 4. Ifølge det første spor bor Vera heller ikke i hul 1.

Plet skal bo lige til venstre for Vera:

- Hvis Vera boede i hul 2, skulle Plet bo i hul 1. Så kunne Skygge ikke bo til venstre for Plet.
- Derfor kan Vera ikke bo i hul 2.
- Vera må bo i hul 3.
- Plet bor dermed i hul 2.
- Skygge bor i hul 1.
- Sne bor i hul 4.

Den eneste mulige rækkefølge er:

| Hul | Kanin |
|---:|---|
| 1 | Skygge |
| 2 | Plet |
| 3 | Vera |
| 4 | Sne |

---

# 7. Hints

## Hint 1 – Start med det sikre

> Én kanin har allerede fået et bestemt hul. Placer Sne først.

## Hint 2 – Find parret

> Plet skal bo lige til venstre for Vera. De to skal derfor stå ved siden af hinanden.

## Hint 3 – Næsten løsningen

> Vera kan ikke bo i hul 1 eller hul 4. Prøv derefter hul 2 og undersøg, om Skygge stadig kan bo til venstre for Plet.

Hints bør kun reducere spillerens point en smule. Tid er ikke den afgørende faktor.

---

# 8. Besked ved korrekt svar

> **I fandt Veras hul!**
>
> Vera bor i **hul 3**.
>
> Skygge bor i hul 1, Plet i hul 2 og Sne i hul 4. Alle fire kaniner har nu fundet hjem.

---

# 9. Besked ved forkert svar

> Det hul passer ikke med alle sporene.
>
> Husk, at Plet skal bo lige til venstre for Vera, og at Skygge skal bo til venstre for Plet.

---

# 10. Billede

## Primært opgavebillede

Det mørke, mystiske portrætbillede af Vera anvendes som opgavens hero-billede:

```text
nattens_kanin_i_det_blå_skur.png
```

Billedet kan bruges både:

- på kortets overlay sammen med kortbeskrivelsen
- som det store billede på selve opgaveskærmen

Billedet må ikke vise facit, pile eller tekst med løsningen.

## Beskæring

- Format: iPhone portrait
- Motiv: Vera skal være tydelig og centralt placeret
- Der skal være plads omkring motivet, så billedet kan beskæres på forskellige iPhone-skærme
- Vigtige detaljer må ikke ligge helt ude ved kanten

---

# 11. Enkel appvisning

Opgaven skal bruge appens almindelige, datadrevne skærm:

1. Titel
2. Ét billede
3. Introduktion og spor som tekst
4. Fire multiple-choice-svar
5. Knap til at afgive svar
6. Mulighed for at åbne hints

Der kræves ingen særlig interaktion, animation eller specialbygget brugergrænseflade.

---

# 12. Sikkerhed og hensyn

- Spillerne skal blive ved det angivne offentlige standpunkt.
- De må ikke gå ind på privat grund.
- De må ikke røre ved indhegningen eller buret.
- De må ikke fodre Vera.
- De må ikke råbe, banke eller forsøge at få Veras opmærksomhed.
- Opgaven skal kunne gennemføres, selv når Vera gemmer sig.
- Billedet i appen skal gøre det tydeligt, hvilken kanin fortællingen handler om.
- Ejeren skal have godkendt brugen af lokationen og billedet.

---

# 13. Felttest før publicering

- [ ] GPS-koordinatet aktiverer opgaven fra det ønskede standpunkt.
- [ ] En aktiveringsradius på 10 meter fungerer i praksis.
- [ ] Spillerne kan stå sikkert uden at blokere trafik eller adgang.
- [ ] Opgaven kræver ikke adgang til privat grund.
- [ ] Hero-billedet fungerer både på kortet og på opgaveskærmen.
- [ ] Vera kan genkendes på billedet.
- [ ] Opgaven fungerer, selv når Vera ikke er synlig.
- [ ] Alle fire spor bliver forstået af målgruppen.
- [ ] Gåden har kun én mulig løsning.
- [ ] Alle tre hints er testet.
- [ ] Ejeren har godkendt lokation og foto.

---

# 14. App-data

```yaml
id: frydenlund-98-opgave-3-vera
title: Vera og de fire huller
location:
  name: Frydenlund 98
  latitude: 55.734897
  longitude: 9.620270
  activationRadiusMeters: 10

difficulty: 2
estimatedDurationMinutes: 5
taskType: multipleChoice
image: nattens_kanin_i_det_blå_skur.png

mapDescription: >
  I haven bor kaninen Vera. Fire kaniner har gravet hvert sit hul,
  men alle sporene er blevet blandet sammen. Kan I finde Veras hul?

introductionTts: >
  I haven bor kaninen Vera. Men i nat er der sket noget mærkeligt.
  Fire kaniner har gravet hvert sit hul, og nu er alle spor blevet
  blandet sammen. Ingen kan længere huske, hvilket hul der tilhører hvem.
  Kun nogle få ledetråde er tilbage. Brug sporene. Tænk jer godt om.
  Og find ud af, hvilket hul Vera bor i. Når I har valgt det rigtige hul,
  er Veras hemmelighed afsløret.

question: Hvilket hul bor Vera i?

clues:
  - Vera bor hverken i hul 1 eller hul 4.
  - Plet bor i hullet lige til venstre for Vera.
  - Sne bor i hul 4.
  - Skygge bor til venstre for Plet.

answerOptions:
  - id: hole-1
    text: Hul 1
  - id: hole-2
    text: Hul 2
  - id: hole-3
    text: Hul 3
  - id: hole-4
    text: Hul 4

correctAnswerId: hole-3

hints:
  - Én kanin har allerede fået et bestemt hul. Placer Sne først.
  - Plet skal bo lige til venstre for Vera. De to skal stå ved siden af hinanden.
  - Vera kan ikke bo i hul 1 eller hul 4. Undersøg, om hul 2 kan passe med Skygges spor.

correctFeedback: >
  I fandt Veras hul! Vera bor i hul 3. Skygge bor i hul 1,
  Plet i hul 2 og Sne i hul 4.

incorrectFeedback: >
  Det hul passer ikke med alle sporene. Husk, at Plet skal bo lige
  til venstre for Vera, og at Skygge skal bo til venstre for Plet.

status: draft
```
