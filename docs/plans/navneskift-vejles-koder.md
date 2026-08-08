# Navneskift til Vejles Koder

**Besluttet:** 8. august 2026
**Status:** Implementeret og godkendt i DEV; PROD og TestFlight mangler

## Beslutning

Spillerappen hedder **Vejles Koder** i App Store, TestFlight, på hjemmeskærmen
og i brugerfladen. Admin-appen hedder **Koder Admin**.

De eksisterende tekniske identiteter bevares:

- spiller: `dk.hyldenbrandt.byensgaader`
- admin: `dk.hyldenbrandt.byensgaader.admin`
- Apple Services ID: `dk.hyldenbrandt.byensgaader.webadmin`

Interne target-, mappe- og typenavne omdøbes ikke. De er ikke synlige for
brugeren, og en mekanisk omdøbning vil tilføje signerings- og merge-risiko uden
at forbedre produktet.

## Konsekvenser

- Apple-login-gruppen, eksisterende konti og App Store Connect-posten bevares.
- Den nuværende TestFlight-build beholder sit gamle navn; navnet skifter først
  i en ny uploadet build.
- App Store-navnet rettes på den eksisterende appversion eller den nye versions
  redigerbare metadata. Der oprettes ikke en ny app.
- Historiske analyser, arkivmateriale og eksisterende kildekrediteringer
  omskrives ikke. Nye medieuploads krediteres **Vejles Koder**.
- Launchbilledets gamle bitmap-ordmærke erstattes; de tekstfrie appikoner
  genbruges.

## Releasegate

1. Byg og test begge iOS-apps samt spillerweb.
2. Verificér **Vejles Koder**-login mod DEV i simulatoren. ✅
3. Konfigurér og aktivér PROD gennem den menneskelige releasegate.
4. Upload nye builds med højere buildnumre til TestFlight.
5. Ret App Store-navn, undertitel, beskrivelse og screenshots, så de bruger det
   nye navn, før ekstern TestFlight og App Review.

## Pris

Navneskiftet kræver nye builds, metadata og screenshots. Bevarelsen af de
tekniske id'er betyder til gengæld, at der ikke skal oprettes nye Apple-
identiteter, migrationslogik eller separate brugerkonti.
