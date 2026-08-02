# Webadmin — Byens Gåder

Angular-udgaven af quizmaster-appen. Den redigerer den samme indholdspakke som
iOS-admin og bevarer ukendte JSON-felter ved gemning.

## Kør lokalt

Start backenden fra repoets rod i den første terminal:

```bash
./backend/run.sh
```

Start webappen i den anden:

```bash
cd webApps/webadmin
npm install
npm start
```

Åbn [http://localhost:4200](http://localhost:4200). På localhost tillader
browseren GPS uden HTTPS. Webappen vælger automatisk den lokale backend på
`http://localhost:5199`; serveren kan skiftes til Drift under quizmasterens
menu.

## Funktioner

- opret, redigér og slet opgaver;
- samme fem afsnit som iOS-admin;
- browserens aktuelle GPS-position og read-only OpenStreetMap-kort;
- foto fra kamera eller fil, nedskaleret til 2048 px og JPEG-kvalitet 0,85;
- lokale kladder efter hvert ændringsforløb;
- ETag og trevejsfletning ved samtidige rettelser;
- revisionssporet over hvem, der har rettet hvad;
- responsivt layout til telefon, tablet og computer.

Authentication og authorization er bevidst ikke implementeret under den
interne test.

## Kontrol

```bash
npm test -- --watch=false
npm run build
```

Produktionsfilerne lander i `dist/webadmin/browser/`.

## Senere: Azure Static Web Apps

Appen vælger automatisk drift-API'et, når værtsnavnet ikke er localhost. Når
Azure Static Web Apps-adressen er kendt, tilføjes den til backendens
app-indstillinger:

```text
Cors__AllowedOrigins__3=https://<navn>.azurestaticapps.net
```

`public/staticwebapp.config.json` sørger for fallback til Angulars `index.html`.
Der skal ikke lægges nøgler eller andre hemmeligheder i webappens filer.

## Postnumre

`public/postnumre.txt` er en mekanisk kopi af data i iOS-adminens
`Postnumre.swift`. Begge kommer fra Dataforsyningens officielle registre og
skal opdateres sammen.
