# ADR 0011 — Favoritter og trending i Table Storage

**Status**: Accepteret

**Dato**: 2026-08-07

**Berører**: [ADR 0010](./0010-direkte-apple-login-og-egne-sessioner.md),
forfatningens princip V og VI

## Kontekst

Forsiden skal vise de opgaver, flest spillere har markeret som favorit, og de
opgaver, der har modtaget flest nye favoritter inden for 30 dage. Tallene skal
være virkelige og ikke demo-rangeringer. Samtidig kan børn bruge appen uden
konto, og projektet må ikke opfinde et vedvarende device-id for at kunne tælle
anonyme likes.

## Beslutning

En favorit er en kontofunktion. En verificeret konto kan have højst én aktiv
favorit pr. opgave. `PUT` og `DELETE` er idempotente, og den oprindelige dato
flyttes ikke af et gentaget `PUT`.

- Favoritter gemmes i en separat Azure Table i samme Storage Account som
  konti og sessions.
- Rækken indeholder kun internt `accountId`, `missionId` og oprettelsestid.
- Offentlig læsning returnerer kun `favoriteCount` og `trendingCount` pr.
  opgave. Ingen konti, navne eller tidspunkter udleveres.
- Trending er antallet af aktive favoritter oprettet inden for de seneste 30
  dage.
- Gæster kan se summerne, men kan ikke skrive. Der oprettes intet device-id.
- Serveren cacher de aggregerede summer kortvarigt og rydder cachen efter en
  ændring.
- Favoritrækker skal slettes sammen med kontoen. Dette er en del af den endnu
  udestående kontosletning før offentlig release.

## Begrundelse

Table Storage genbruger den billige, allerede besluttede kontoinfrastruktur og
giver en naturlig unik nøgle for konto/opgave. Serveren kan beregne både den
samlede popularitet og et tidsvindue uden SQL Server eller en ny fast pris.

Kravet om konto gør optællingen mindre nem at manipulere og undgår samtidig en
skjult identifikator på børns telefoner. Gæstespillet forbliver fuldt anvendeligt.

## Konsekvenser

**Gevinst:** Forsidens popularitet er målt, reproducerbar og ens på tværs af
enheder. Like/unlike skaber ikke dobbelttælling ved retries.

**Pris:** Den første version aggregerer favoritrækker ved cache-miss. Det er
enkelt og korrekt til pilotens volumen, men bliver en dyr tabelscan ved mange
hundrede tusinde favoritter. Før den grænse skal målinger afgøre, om der skal
materialiseres totaler og dagsbøtter. Der indføres ikke SQL på forhånd.

**Pris:** En favorit kan kun synkroniseres med forbindelse og konto. UI'et
opdaterer optimistisk, men ruller tilbage ved afvisning.

**Privatliv:** Favoritlisten er kontodata og følger kontoens slettefrist.
Offentligheden ser kun summer. Ingen GPS-position gemmes i denne funktion.

## Alternativer

**Anonyme device-id'er.** Giver gæstelikes, men skaber en vedvarende
identifikator uden et nødvendigt formål og er særligt dårligt for en børneapp.

**Kun lokale favoritter.** Kræver ingen server, men kan ikke drive en fælles
forside og forsvinder ved enhedsskift.

**SQL Server.** Kan aggregere fleksibelt, men giver en unødvendig fast pris og
driftsflade for en enkel, sparsomt skrevet relation.

**Azure Functions/planlagt materialisering fra dag ét.** Skalerer læsninger
bedre, men tilføjer jobdrift og eventual consistency, før volumen begrunder det.
