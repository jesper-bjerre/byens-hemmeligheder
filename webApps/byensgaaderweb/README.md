# Byens Gåder — web

Angular-udgaven af spillerappen. Den bruger samme indholdspakke, svarregler og
pointmodel som iOS-appen og viser kun opgaver med status `fieldTestReady` eller
`publishReady`.

## Kør lokalt

Start backenden fra repoets rod:

```bash
./backend/run.sh
```

Start webappen i en anden terminal:

```bash
cd webApps/byensgaaderweb
npm install
npm start
```

Åbn [http://localhost:4200](http://localhost:4200). Her bruges den lokale API
på port 5199. På andre værtsnavne bruges drift-API'et automatisk.

På localhost kan en opgave vælges på kortet og knappen **Simulér position ved
stedet** bruges til at simulere positionen ved opgaven. Funktionen findes ikke
på et almindeligt værtsnavn.

## Spillerflow

- kort, afstand og aktuelle opgaver;
- positionssamtykke uden lagring af GPS-historik;
- afstand, retning, nøjagtighed og dvæletid ved stedet;
- sikkerhedsbesked før opgaven;
- fortællekort, billeder, fortællerstemme og stemningslyd;
- enkeltvalg, talkode og fritekst med samme normalisering som iOS;
- tre hints i rækkefølge og identisk pointfradrag;
- lokal append-only hændelseslog, genoptagelse og pointoversigt;
- kilder, kreditering og tydelig markering af opdigtet rangliste.

Progression ligger kun i browserens `localStorage`. Positionen ligger kun i
hukommelsen og skrives ikke til lagring. Indholdspakken gemmes ikke lokalt;
appen kræver forbindelse, så en pauset opgave forsvinder med det samme.

## Kontrol

```bash
npm run check
```

Produktionsfilerne lander i `dist/byensgaaderweb/browser/`.

## Azure Static Web Apps

`public/staticwebapp.config.json` indeholder Angular-fallback og tillader
browserens geolocation. Produktionsadressen er:

<https://agreeable-island-016468f03.7.azurestaticapps.net>

Push til `main`, der ændrer denne mappe, tester, bygger og udruller automatisk.
Backendens CORS-konfiguration tillader produktionsadressen.

Authentication og authorization er bevidst udskudt under den interne test.
