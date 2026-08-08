# Data model: Authentication og roller

## Account

| Felt | Type | Regel |
|---|---|---|
| `accountId` | UUID | Permanent intern nøgle; tilfældig |
| `email` | string? | Verificeret fra Apple; aldrig offentlig eller opslagsnøgle |
| `publicName` | string? | 3–20 synlige tegn efter normalisering |
| `publicNameChangedAt` | tidspunkt? | UTC; bruges til serverstyret rate limit |
| `nameModerationState` | enum | `Visible` eller `Hidden`; tomt navn er aldrig offentligt |
| `nameModerationReason` | string? | Kun Admin; udleveres ikke på highscore |
| `stateReason`, `stateChangedAt` | string?/tidspunkt? | Beskyttet begrundelse og tidspunkt for blokering |
| `role` | enum | `User`, `Designer`, `Admin` |
| `state` | enum | `Active`, `Blocked`, `Deleted` |
| `createdAt` | tidspunkt | UTC, uforanderlig |
| `lastSignedInAt` | tidspunkt | UTC |
| `deletedAt` | tidspunkt? | UTC; sat ved anonymisering |
| `version` | ETag | Optimistisk samtidighed |

Transitioner:

```text
User ⇄ Designer
Admin ──(kun auditeret drift; aldrig UI)──> Admin
Active → Blocked → Active
User/Designer: Active|Blocked → Deleted
```

Sidste Admin kan ikke degraderes, blokeres eller slettes. En Designer skal
degraderes til User før selvbetjent sletning.

## NameReport

| Felt | Type | Regel |
|---|---|---|
| `reportId` | UUID | Tilfældig nøgle |
| `reporterAccountId` | UUID | Kun beskyttet Admin-visning |
| `reportedName` | string | Det viste normaliserede navn; intet mål-konto-id i klientrequest |
| `category` | enum | `Offensive`, `PersonalInfo`, `Impersonation`, `Other` |
| `createdAt` | tidspunkt | UTC |

Rapporter slettes efter 90 dage. Rapportering matcher ikke automatisk en konto:
Admin søger efter det rapporterede navn og vælger den konkrete konto. Dermed
udleverer highscore hverken internt konto-id eller en ny stabil offentlig
identifikator.

## ExternalIdentity

| Felt | Type | Regel |
|---|---|---|
| `provider` | string | `apple` i version 1 |
| `providerSubjectHash` | SHA-256 | Punktnøgle; rå subject udleveres aldrig |
| `accountId` | UUID | Reference til Account |
| `createdAt` | tidspunkt | UTC |
| `lastValidatedAt` | tidspunkt | UTC |
| `encryptedProviderRefreshToken` | string? | AES-GCM; krypteringsnøglen ligger kun i miljø/Key Vault |
| `providerClientId` | string? | App ID/Services ID som provider-tokenet er udstedt til; nødvendigt for revocation |
| `revokedAt` | tidspunkt? | Sat ved Apple-tilbagekaldelse eller sletning |

Unikhed: `(provider, providerSubjectHash)` må kun pege på én Account. Det rå
subject bruges kun under den aktuelle request og persisteres ikke.

## Session

Tokenformat er `<sessionId>.<secret>`. `sessionId` er opslaget; kun hash af
`secret` gemmes.

| Felt | Type | Regel |
|---|---|---|
| `sessionId` | tilfældig id | Punktnøgle |
| `accountId` | UUID | Reference til Account |
| `clientKind` | enum | `iOSPlayer`, `iOSAdmin`, `WebPlayer`, `WebAdmin` |
| `accessSecretHash` | SHA-256 | Råt access-token gemmes aldrig |
| `accessExpiresAt` | tidspunkt | 15 min native, højst 30 min web |
| `refreshSecretHash` | SHA-256? | Kun native |
| `previousRefreshHash` | SHA-256? | Replay-detektion under rotation |
| `refreshExpiresAt` | tidspunkt? | Højst 30 dage |
| `createdAt`, `rotatedAt` | tidspunkt | UTC |
| `revokedAt`, `revokeReason` | nullable | Tilbagekaldelse er endelig |

Transitioner:

```text
Active → Rotated → Active
Active|Rotated → Revoked
Expired → Deleted (senest 7 dage efter udløb)
Rotated token genbrugt → hele sessionsfamilien Revoked
```

## OneTimeGrant

| Felt | Type | Regel |
|---|---|---|
| `grantHash` | SHA-256 | Punktnøgle; rå kode gemmes aldrig |
| `kind` | enum | `AppleAuthorizationCode`, `WebExchange` |
| `nonceHash`, `pkceChallenge` | string? | Binding til oprindeligt flow |
| `returnOrigin` | string? | Skal være allowlistet |
| `createdAt`, `expiresAt` | tidspunkt | Webkode højst 2 minutter |
| `consumedAt` | tidspunkt? | Betinget engangs-transition |

## RoleChangeAudit

| Felt | Type | Regel |
|---|---|---|
| `at` | tidspunkt | UTC |
| `actorAccountId` | UUID | Verificeret Admin |
| `targetAccountId` | UUID | Berørt konto |
| `fromRole`, `toRole` | enum | Kun User/Designer i UI |
| `reason` | string? | Kort administrativ note |

## Partitionering

- Accounts: partition `accounts`, row `accountId`.
- Identities: partition `apple`, row `providerSubjectHash`.
- Sessions: partition efter de første to tegn i `sessionId`, row `sessionId`.
- Grants: partition efter udløbsdato (`yyyyMMdd`), row `grantHash`.
- Rolleaudit: partition efter mål-konto, row omvendt timestamp + tilfældig id.
- Navnerapporter: partition efter måned, row er et hash af rapportør, dato og
  navn. Det gør en gentaget rapport samme dag idempotent uden at udlevere
  rapportørens konto-id i URL eller klientrespons.

Kryds-partition-operationer gøres idempotente og genoptagelige; ingen request
må stole på en ikke-atomisk fler-række-transaktion for at give adgang.
