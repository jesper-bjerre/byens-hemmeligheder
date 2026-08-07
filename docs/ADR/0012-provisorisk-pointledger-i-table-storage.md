# ADR 0012 — Provisorisk pointledger i Table Storage

**Status**: Accepteret
**Dato**: 2026-08-07
**Ændrer**: Forfatningens afsnit **Tekniske rammer** (data til progression og point)
**Berører**: [ADR 0007](./0007-blob-nu-relationelt-naar-der-er-konti.md),
[authentication-og-roller](../plans/authentication-og-roller.md)

## Kontekst

Spillerappen beregner allerede en forklarlig lokal pointledger ud fra
completion-, hint- og fejlsvarshændelser. Indloggede spillere skal nu kunne få
resultatet på en rigtig highscoreliste. Gæster skal fortsat kunne spille uden
en skjult identitet.

Forfatningens tekniske rammer udpeger en relationel database som mål for
serverbåret progression og point. Den fulde model kræver senere servervalidering
af hele hændelsesstrømmen, genberegning, kontosletning og moderation. Ingen af
disse relationelle workflows er færdigdesignet endnu. At indføre Azure SQL kun
for én idempotent score pr. konto/opgave/version ville gøre den provisoriske
write-model dyrere at drifte uden at gøre pointberegningen autoritativ.

## Beslutning

Versionens første highscorelag gemmer klientens eksisterende, forklarlige
transaktioner i Azure Table Storage:

- kun en verificeret konto kan indsende;
- completion-hændelsens UUID er idempotensnøgle;
- første indrapportering pr. konto, opgave og indholdsversion vinder;
- opgaven skal findes i den offentlige pakke, completion skal svare til dens
  grundpoint, fradrag skal være negative, og totalen skal være positiv og lig
  summen af transaktionerne;
- highscore viser kun valgt `publicName`, ellers den neutrale tekst
  **Anonym spiller**; e-mail og konto-id udleveres aldrig;
- ugevisningen bruger completion-tidspunktet fra den lokale hændelseslog;
- gæstens hændelseslog bliver på telefonen og kan synkroniseres efter senere
  login.

Denne ADR er en eksplicit, tidsbegrænset afvigelse fra forfatningens
relationelle mål. Table-laget må ikke udvides til sessions, achievements,
inventory eller vilkårlige progressionsqueries. Når serveren skal beregne point
fra rå hændelser, genåbnes datavalget; kriterium 5 i ADR 0007 er da udløst.

## Begrundelse

Den aktuelle relation er en entydig nøgle og et append-lignende førsteskriv:
`konto + opgave + indholdsversion`. Den kræver ingen join ved skrivning og kan
lagres på den Storage-konto, platformen allerede driver. Den lokale eventlog
opfylder offline- og retrykravet, fordi samme completion-id kan sendes igen.

## Konsekvenser

**Gevinst:** Rigtige highscores uden opdigtede profiler, ingen ny Azure-ressource
og ingen dobbeltpoint ved retries.

**Pris:** Serveren stoler midlertidigt på klientens pointregnestykke og kan kun
udføre strukturel validering. En modificeret klient kan snyde inden for de
accepterede grænser. Highscore er derfor ikke en præmiekonkurrence.

**Driftspris:** Uge- og totalrangering scanner den lille pilottabel. Før offentlig
skal belastning måles; ved voksende trafik kræves et materialiseret leaderboard
eller den relationelle model.

**Migration:** Table-rækkerne indeholder completion-id, contentVersion og
transaktioner, så de kan importeres eller genafspilles ved et senere skift.

## Alternativer

**Azure SQL nu.** Korrekt slutretning, men giver ikke i sig selv autoritativ
pointberegning og tilføjer fast pris, migrations- og backupdrift nu.

**Fortsat opdigtet highscore.** Afvist. Et ærligt tomt resultat er bedre end at
vise børn personer og point, der ikke findes.

**Kun samlet pointtal.** Afvist. Det bryder kravet om forklarlige transaktioner
og gør senere fejlfinding og migration unødigt svær.
