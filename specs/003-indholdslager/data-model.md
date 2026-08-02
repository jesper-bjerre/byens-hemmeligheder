# Datamodel: redaktionelt indhold

## Overblik

```text
Workspace 1 ── * MissionDocument 1 ── * MissionMedia * ── 1 MediaAsset
    │                    │
    │                    └── * MissionSource * ── 1 Source
    ├── * AuditEntry
    ├── * PublicationJob
    └── * PublishedPackState
```

`WorkspaceId` og `Locale` indgår i alle forretningsnøgler. Databasen starter
med ét workspace, men ingen række er global ved et uheld.

## Workspace

En redaktionel ejergrænse. Den er klar til senere partnere, men er ikke en
bruger eller en rettighed.

| Felt | Type | Regler |
|---|---|---|
| Id | uniqueidentifier | Primærnøgle, servergenereret |
| Slug | nvarchar(100) | Unik, lowercase ASCII, uforanderlig efter publicering |
| Name | nvarchar(200) | Påkrævet |
| Status | varchar(20) | `active` eller `paused` |
| CreatedAt | datetimeoffset | UTC, servergenereret |
| UpdatedAt | datetimeoffset | UTC |

Et pauset workspace genererer ingen offentlig pakke, men data slettes ikke.

## MissionDocument

Et aggregate, der kan hentes og gemmes atomisk af én quizmaster.

| Felt | Type | Regler |
|---|---|---|
| WorkspaceId | uniqueidentifier | FK til Workspace, del af forretningsnøglen |
| Locale | varchar(10) | BCP-47, først `da-DK` |
| MissionId | nvarchar(160) | Kontraktens engelske `id`, uforanderligt |
| Slug | nvarchar(140) | Unik pr. workspace/locale |
| Title | nvarchar(240) | Kopi af dokumentfeltet, valideres ved gemning |
| Status | varchar(32) | Kopi af dokumentfeltet, database-check |
| PostalCode | varchar(16) | Kopi af lokationen til hierarki/filter |
| SchemaVersion | varchar(20) | Kontraktversion for dette aggregate |
| Document | nvarchar(max) | Gyldigt JSON med `{ mission, location }` |
| Revision | rowversion | Eksponeres som stærk HTTP-ETag |
| CreatedAt | datetimeoffset | UTC |
| UpdatedAt | datetimeoffset | UTC |
| UpdatedByDisplayName | nvarchar(200) | Eksisterende auditnavn; ingen påstået identitet |

Primærnøgle: `(WorkspaceId, Locale, MissionId)`.

Indekser:

- unik `(WorkspaceId, Locale, Slug)`;
- listeindeks `(WorkspaceId, Locale, Status, PostalCode, Title)`;
- ingen indeks på hele JSON-dokumentet.

`Document` har `CHECK (ISJSON(Document)=1)`. API'et validerer desuden, at de
udtrukne kolonner svarer til JSON-felterne; databasen må aldrig have to titler
for samme revision.

Tilladte statusværdier følger kontrakten. Kun `fieldTestReady` og
`publishReady` indgår foreløbigt i spillerpakken. En pause gemmes som status og
skal udløse publicering på samme måde som øvrige ændringer.

## MediaAsset

Metadata om en uforanderlig fil i Blob Storage.

| Felt | Type | Regler |
|---|---|---|
| WorkspaceId, Locale, MediaId | sammensat nøgle | Media-id er uforanderligt |
| Filename | nvarchar(260) | Unik pr. workspace/locale; filen overskrives aldrig |
| MediaType | varchar(20) | `image` eller `audio` |
| Metadata | nvarchar(max) | Hele MediaAsset-kontrakten, gyldigt JSON |
| Revision | rowversion | Samtidighed på metadata |
| CreatedAt, UpdatedAt | datetimeoffset | UTC |

Selve billedet eller lyden ligger fortsat i Blob Storage. `MissionMedia`
materialiserer referencerne fra missionens kort, thumbnail og fortælling, så en
mediebeskrivelse ikke kan slettes, mens en opgave bruger den.

## Source

Kildemetadata med sammensat nøgle `(WorkspaceId, Locale, SourceId)`, titel,
publisher og JSON-payload. `MissionSource` materialiserer missionens
`sourceIds`. En kilde kan deles af flere opgaver uden duplikering.

## AuditEntry

| Felt | Type | Regler |
|---|---|---|
| Id | bigint identity | Primærnøgle |
| WorkspaceId | uniqueidentifier | Ejerskabsgrænse |
| Locale, MissionId | tekst | MissionId kan være null ved workspaceændringer |
| At | datetimeoffset | UTC, servergenereret |
| ActorDisplayName | nvarchar(200) | Fra nuværende `X-Quizmaster`; ikke identitet |
| ChangeKind | varchar(40) | oprettet, rettet, status, slettet, publiceret |
| FromStatus, ToStatus | varchar(32) | Kun ved statusskift |
| MissionRevision | binary(8) | Revisionen hændelsen vedrører |
| Details | nvarchar(max) | Minimal JSON uden hele facit eller persondata |

Audit slettes ikke sammen med missionen. Når authentication kommer, kan et
nullable `ActorUserId` tilføjes uden at ændre historiske rækker.

## PublicationJob

Transaktionel outboxrække.

| Felt | Type | Regler |
|---|---|---|
| Id | bigint identity | Bevarer rækkefølge |
| WorkspaceId, Locale | nøgle | Hvilken pakke skal gendannes |
| CauseRevision | binary(8) | Revisionen, der udløste jobbet |
| State | varchar(20) | `pending`, `processing`, `completed`, `failed` |
| Attempts | int | Starter 0, begrænset retry/backoff |
| AvailableAt | datetimeoffset | Næste tilladte forsøg |
| LastErrorCode | varchar(80) | Klassifikation, ingen stacktrace eller hemmelighed |
| CreatedAt, CompletedAt | datetimeoffset | UTC |

Flere ventende jobs for samme workspace/locale må samles, fordi generatoren
altid læser den aktuelle databasesnapshot. Jobbet er et signal, ikke en kopi af
indholdet.

## PublishedPackState

Én række pr. workspace/locale med senest publicerede databasevandmærke,
SHA-256/contentVersion, blobsti, publiceringstidspunkt og fejlstatus. Den gør
det muligt for admin at vise “gemt, publicering afventer” uden at gætte.

## Tilstande

```text
Quizmaster gemmer
  → MissionDocument + AuditEntry + PublicationJob committes atomisk
  → publisher tager blob-lease
  → læser aktuel publicerbar snapshot
  → skriver ny pakke med indholdshash
  → markerer job og PublishedPackState
```

Ved fejl efter SQL-commit er opgaven stadig gemt. Jobbet bliver pending/failed
og kan genoptages. Ved konflikt på `Revision` svarer API'et `412`; klienten
henter kun den berørte opgave og fletter den.

## Migration

1. Opret standard-workspace.
2. Split den aktuelle pakke i mission/location-aggregater og globale media- og
   source-rækker i én SQL-transaktion.
3. Materialisér reference-tabeller og afvis manglende eller modstridende id'er.
4. Generér en pakke fra SQL og sammenlign kanonisk JSON med inputpakken.
5. Skift først skrivevejen, når sammenligningen og rollback er godkendt.

Migrationen kan gentages mod en tom database og må ikke ændre blobkilden, før
cutover besluttes.
