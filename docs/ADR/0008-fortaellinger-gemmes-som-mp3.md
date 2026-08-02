# ADR 0008 — Fortællinger gemmes som MP3

**Status**: Accepteret

**Dato**: 2026-08-02

**Berører**: [ADR 0005](./0005-blob-er-kilden-til-indholdet.md)

## Kontekst

En quizmaster skal kunne vælge en indtalt fortælling uden først at kende det
format, telefonen eller optageren har lavet. Spillerappen bruger AVAudioPlayer,
webappen browserens indbyggede lydafspiller, og mediet hentes direkte fra blob.
Det lagrede format skal derfor virke begge steder og være lille nok til
mobilnettet.

Kontrakten har allerede `narrationMediaId`. Der er ingen grund til at gøre
filformat eller uploadtilstand til en del af opgaven: feltet skal fortsat pege
på et almindeligt mediaasset.

## Beslutning

API'et får en særskilt rå uploadrute til fortællinger. Den accepterer MP3, M4A,
AAC, WAV, AIFF, CAF, OGG, Opus og FLAC og konverterer altid til MP3 med mono,
44,1 kHz og 64 kbit/s. Output gemmes i det eksisterende medielager, og
admin-appene sætter det nye mediaassets id i `narrationMediaId`.

Konverteringen køres som en separat FFmpeg-proces. Produktionsartefaktet bærer
en fastlåst GPL-build med kendt SHA-256-checksum og licenstekst. Lokalt kan
stien til en installeret FFmpeg sættes i konfigurationen.

## Begrundelse

MP3 kan afspilles af både iOS og de relevante browsere uden en egen decoder.
Mono og 64 kbit/s er tilstrækkeligt til tale; det svarer til omtrent 0,5 MB pr.
minut. Genkodning på serveren giver samme resultat fra begge admin-apps og
forhindrer, at en stor WAV-fil bliver permanent indhold.

En separat uploadrute holder den eksisterende mediarute bagudkompatibel og gør
det umuligt for admin-appene at springe konverteringen over ved en fejl.

## Konsekvenser

En upload bruger CPU og midlertidig diskplads på API'et. Input begrænses derfor
til 25 MB, output til 10 MB, og processen til to minutter. Der kan kun uploades
én fil pr. HTTP-kald og køres én konvertering ad gangen; et samtidigt forsøg
får `429` frem for at presse den lille App Service-plan.

Backendens udrulningsartefakt bliver markant større, fordi FFmpeg-buildet er
statisk. Til gengæld afhænger driften ikke af, hvilke pakker Azure App Service
har installeret. En opdatering af FFmpeg er en bevidst kodeændring: URL,
checksum og kildehenvisning skal ændres sammen.

Fortællinger genkodes også, når kilden allerede er MP3. Det koster lidt kvalitet
og CPU, men sikrer den aftalte størrelse og ens kanalantal. De oprindelige
uploads gemmes ikke.

## Alternativer

**Gem kildefilen uændret.** Billigst på serveren, men flytter formatproblemet
til spillerne og kan efterlade meget store WAV-filer i blob.

**AAC i M4A.** Kan give lidt bedre kvalitet ved samme størrelse og virker godt
på iOS. MP3 har den mindst overraskende browserunderstøttelse og blev derfor
valgt som fællesnævner.

**Konverter i hver admin-app.** Ville fjerne CPU-arbejdet fra API'et, men kræve
to implementationer, give forskellige resultater og gøre webklienten afhængig
af en tung codec i browseren.

**En ekstern medietjeneste.** Giver køer og skalering, men tilføjer betaling,
credentials og drift til et internt testforløb, hvor lyd uploades sjældent.
