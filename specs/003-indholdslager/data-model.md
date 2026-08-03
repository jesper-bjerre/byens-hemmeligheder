# Datamodel: blobbaseret redaktionelt indhold

## Overblik

```text
MissionDocument ──refererer──> MediaAsset
       │               └──────> Source
       │
       ├──genererer──> AuthoringIndex
       └──genererer──> PublishedPack + PublishedPackVersion

PublicationState beskriver, om de genererede modeller er ajour.
PublicationLock serialiserer ændringer og publicering.
```

Der findes én fælles indholdssamling. `Locale` indgår i blobstien, men der
findes ingen workspace-, tenant- eller partnermodel.

## MissionDocument

Blobsti: `authoring/{locale}/missions/{missionId}.json`

Et kontraktnært aggregate med:

| Felt | Regler |
|---|---|
| `schemaVersion` | Påkrævet kontraktversion |
| `mission` | Én fuld mission fra wire-kontrakten |
| `location` | Missionens eneste sted/startkoordinat |

Blobnavnets `missionId` skal svare til `mission.id`. Missionens reference til
lokation skal svare til `location.id`. API'et validerer hele dokumentet mod
JSON Schema før skrivning.

Blob-ETag er dokumentets revision. Oprettelse bruger `If-None-Match: *`;
rettelse og sletning bruger senest læste `If-Match`.

## MediaAsset

Metadatasti: `authoring/{locale}/media/{mediaId}.json`

Metadata følger kontraktens `mediaAsset`. Selve billedet eller den konverterede
fortælling forbliver en uforanderlig filblob. En ny fil får nyt filnavn/media-id
frem for at overskrive bytes, mens metadata kan rettes med sin egen ETag.

Før sletning scanner API'et missionreferencerne og afviser med `409`, hvis
mediet stadig bruges. Det er applikationsvalidering, ikke en databaseconstraint.

## Source

Blobsti: `authoring/{locale}/sources/{sourceId}.json`

Kilden følger kontraktens `source` og har sin egen ETag. Før sletning scanner
API'et missionernes `sourceIds` og afviser refererede kilder med `409`.

## AuthoringIndex

Blobsti: `authoring/{locale}/index.json`

En regenererbar privat læsemodel:

```json
{
  "schemaVersion": "1",
  "generatedAt": "2026-08-03T10:00:00Z",
  "sourceRequestId": "uuid",
  "missions": [
    {
      "id": "mission.fjordenhus",
      "slug": "fjordenhus",
      "title": "Fjordenhus",
      "status": "fieldTestReady",
      "postalCode": "7100",
      "etag": "opaque-api-etag"
    }
  ]
}
```

Indekset er ikke kilde. En ETag i indekset er kun et hint til klientens cache;
API'et genlæser den rigtige blob og returnerer dens aktuelle ETag før redigering.

## PublicationState

Blobsti: `authoring/{locale}/publication-state.json`

| Felt | Betydning |
|---|---|
| `requestedId` | Seneste ændring, der kræver regenerering |
| `requestedAt` | UTC-tid for ændringen |
| `publishedId` | Seneste request, der er sikkert publiceret |
| `contentVersion` | SHA-256 for den seneste offentlige pakke |
| `publishedAt` | UTC-tid for publiceringen |
| `lastErrorCode` | Stabil fejlkategori, aldrig stacktrace eller hemmelighed |
| `attempts` | Antal mislykkede forsøg for det aktuelle request |

State er dirty, når `requestedId != publishedId`. En ny ændring opdaterer
`requestedId` betinget under publication-leasen, før kilden skrives.

## PublicationLock

Blobsti: `authoring/locks/{locale}`

En eksisterende nul-byte block blob med en 15–60 sekunders lease. Alle
authoring-skrivninger og publiceringsforsøg respekterer leasen. Leasen er
infrastrukturtilstand og må ikke indeholde indhold eller identiteter.

## PublishedPack og versioner

Stabil sti: `content/{locale}/content-pack.json`
Versionssti: `content/{locale}/versions/{contentVersion}.json`

Generatoren medtager kun spilbare statusser, sorterer alle samlinger
deterministisk og beregner SHA-256 over de færdige bytes. Versionsblobben
oprettes idempotent, hvorefter den stabile pakke opdateres. En igangværende
spilsession kan fastholde versionsstien.

## Audit

Det eksisterende `audit.jsonl` fortsætter som append blob. Hændelsen bærer
objekttype, id, tidspunkt, ændringsart, før/efter-ETag og det oplyste
quizmasternavn. Den indeholder ikke hele opgaven, facit eller credentials.

## Tilstande

```text
API tager lease
  → publication-state markeres dirty
  → objektblob skrives med If-Match/If-None-Match
  → indeks og pakke genereres fra aktuel kilde
  → versionspakke skrives idempotent
  → stable pakke opdateres
  → publication-state markeres publiceret
  → lease frigives
```

Ved fejl efter kildeskrivning består den tidligere offentlige pakke uændret.
Reconciler genoptager hele genereringen. Ved fejl før kildeskrivning kan dirty
state stadig regenereres sikkert fra den uændrede kilde.

## Migration

1. Opret tomme private authoring-præfikser i en testcontainer.
2. Split den aktuelle pakke i mission-, media- og source-blobs.
3. Validér alle referencer og afvis modstridende id'er.
4. Generér admin-indeks og spillerpakke.
5. Sammenlign den genererede pakke kanonisk med input.
6. Gentag i den rigtige container først efter godkendt dry-run og rollback.
