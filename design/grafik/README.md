# Byens Hemmeligheder – TestFlight assetpakke

Denne pakke er opdelt i:

- `AppIcon.appiconset`: kan kopieres til Xcodes Assets.xcassets.
- `Branding`: ikonvarianter, launch screen og specialikoner.
- `MapMarkers`: opgavemarkører i forskellige tilstande.
- `Onboarding`: tre introduktionsskærme.
- `States`: tilladelses-, fejl- og afslutningsillustrationer.
- `TaskIllustrations`: fem eksempelillustrationer til opgaver.
- `AppStoreScreenshots`: seks visuelle screenshot-mockups.
- `Reference`: det samlede designboard.

## Vigtigt før offentlig release

Filerne er fremstillet ud fra det godkendte visuelle designboard og beskåret/opskaleret
til separate assets. De er velegnede til TestFlight-prototypen, men bør kontrolleres
på en fysisk iPhone før indsendelse.

Screenshot-mockups bør til den endelige App Store-udgivelse erstattes af faktiske
screenshots fra den færdige app. Kontroller også rettigheder til fotos, personer,
varemærker og sponsorlogoer i sportsrelaterede illustrationer.

## Appikon

Apple afrunder selv appikonet. Tilføj ikke ekstra afrunding i Xcode.
`AppIcon-1024.png` er den primære fil til asset catalog.

## SF Symbols

Standardikoner som tilbage, kort, lyd, pause, indstillinger og deling bør implementeres
med SF Symbols i selve appen og er derfor ikke inkluderet som separate billedfiler.
