# ADR 0007 — Blob som redaktionel kilde, SQL kun ved dokumenteret behov

**Status**: Foreslået
**Dato**: 2026-08-03
**Ændrer**: Forfatningens afsnit **Tekniske rammer** (afsnittet om data)
**Berører**: [ADR 0004](./0004-serverbaaret-indhold.md),
[ADR 0005](./0005-blob-er-kilden-til-indholdet.md),
[feature 003](../../specs/003-indholdslager/research.md)

## Kontekst

Forfatningens tekniske rammer siger, at en relationel database er den primære
domænedatabase, og at JSON kun bruges til prototyper eller seed-data. Projektet
bruger allerede Blob Storage som kilde til indhold efter ADR 0005, men den
afvigelse blev oprindeligt ikke skrevet eksplicit.

Den første genåbning af feature 003 anbefalede Azure SQL ud fra en antagelse om
separate partnerdata og workspaces. Den forudsætning gælder ikke. Partneres
quizmastere skal arbejde i den samme indholdssamling, og cirka 99 % af trafikken
er statiske spillerlæsninger.

De aktuelle problemer er dokumentproblemer: en samlet fil giver unødigt store
uploads, fælles ETag-konflikter og risiko for at udlevere kladder. Der findes
ikke aktuelle behov for joins, rapportering, tværgående transaktioner eller
tenantgrænser.

## Beslutning

**Blob Storage forbliver den redaktionelle kilde til opgaveindhold. Kilden
opdeles til én privat JSON-blob pr. opgave; den offentlige spillerpakke
genereres. Azure SQL indføres kun, hvis et målt eller nyt relationelt behov
udløser et nedenstående kriterium.**

Konkret:

- én privat blob pr. mission/location-aggregate;
- én privat blob pr. medie- og kildemetadataobjekt;
- ETag og betingede writes pr. objekt;
- et privat, regenererbart admin-indeks;
- en kort locale-lease, dirty publication-state og automatisk reconciliation;
- deterministiske, versionsbestemte offentlige pakker samt en stabil latest;
- blob versioning og soft delete, før data ikke længere må smides væk;
- ingen workspace-, tenant- eller partneropdeling.

SQL skal genovervejes, hvis mindst ét af følgende opstår:

1. En handling skal være atomisk på tværs af flere domæneobjekter.
2. Admin kræver vilkårlige tværgående queries eller rapportering, som et
   genereret indeks ikke kan betjene.
3. P95 gem-og-publicér overstiger 2 sekunder eller leasekonflikter overstiger
   1 % over en repræsentativ måned.
4. Fuld regenerering overskrider App Servicens sikre ressourcebudget.
5. Et nyt domæne som serverbåret progression/point kræver stærke relationer.

Konti, roller, flere quizmastere eller flere byer er ikke i sig selv
migrationskriterier. Authentication kan beskytte blobbaserede endpoints.

## Begrundelse

**Lageret matcher dataformen.** Opgaven er et lille JSON-dokument med
indlejrede kort, hints og svar. Én blob pr. aggregate giver præcis den
samtidighedsgrænse, editoren har brug for.

**SQL løser ikke spillerlæsningen.** Selv med SQL skulle der genereres en
statisk pakke til de mange reads. SQL ville kun betjene de få redaktionelle
writes.

**SQL's stærkeste begrundelse bortfalder.** Der skal ikke være adskilte
partnerdata. Der er derfor ingen tenantnøgler, ejerskabsrelationer eller
tenantfiltre at håndhæve relationelt.

**Omkostningen er mere end licensprisen.** Azure SQL Basic er relativt billig,
men tilføjer fast månedspris, server/firewall, databaseidentitet, migrationer,
backup-/restore-procedure og overvågning. Den eksisterende Storage-konto har
ingen ny fast pris og leverer allerede ETags, leases, versioning og soft delete.

**Beslutningen er reversibel.** Spillerapps kender kun den genererede pakke.
Authoring-repository og pakkegenerator holdes adskilt, så en senere relationel
kilde kan erstatte Blob uden at ændre spillerkontrakten.

## Konsekvenser

**Gevinst:** Ingen ny Azure-ressource eller fast databasepris. Små opgavevise
writes, uafhængige ETags og privat kladdelager kan implementeres i den
eksisterende stak.

**Pris:** Gemninger serialiseres kort under publicering, referentiel integritet
håndhæves af applikationen, og hele pakken regenereres. Driftstelemetri skal
vise, om denne pris forbliver acceptabel.

**Fejl mellem blobs er ikke transaktionelle.** Dirty-state og reconciliation
giver eventual consistency. Ved fejl forbliver den tidligere offentlige pakke
hel, mens admin viser, at publicering afventer.

**Forfatningen fraviges bevidst.** Opgaveindhold bruger fortsat JSON som
primær domænekilde. Denne ADR er den eksplicitte, begrundede afvigelse, som de
tekniske rammer kræver. Det relationelle mål gælder fortsat for domæner, der
faktisk har relationelle behov.

## Alternativer

**Azure SQL Basic nu.** Giver transaktionel outbox, constraints og queries, men
ingen af dem er aktuelle krav. Det tilføjer en fast pris og ny driftsoverflade.

**Table Storage.** Har ETag pr. entitet, men opgaven ville stadig være JSON i
en property. Det giver ingen fordel over én blob pr. opgave til denne
arbejdsprofil.

**Cosmos DB Serverless.** Dokumentformen passer, men tjenesten køber query- og
distributionsfunktioner, som spillerne ikke bruger. Blob er enklere og allerede
driftet.

**Behold én samlet blob.** Billigst i kode nu, men løser ikke opgavevise
uploads, uafhængig samtidighed eller sikker adskillelse af kladder.
