# byens-hemmeligheder
Byens Hemmeligheder. Find spor. Løs gåder. Oplev historien.

**Hvad der arbejdes på nu:** [docs/plans/koereplan.md](./docs/plans/koereplan.md)

## Hvor tingene ligger

| Mappe | Hvad |
|---|---|
| `iOS/` | Spillerappen og `BHKit` |
| `iOS-admin/` | Quizmaster-appen |
| `webApps/webadmin/` | Angular-udgaven af quizmaster-appen — se [README](./webApps/webadmin/README.md) |
| `webApps/byensgaaderweb/` | Angular-udgaven af spillerappen — se [README](./webApps/byensgaaderweb/README.md) |
| `backend/` | ASP.NET Core-API'et — se [backend/README.md](./backend/README.md) |
| `contracts/` | Skema, golden-filer, testvektorer og en fixtur af indholdet |
| `docs/` | Beslutninger, drift og arkiv |
| `specs/` | Feature-specifikationer og planer |

**Indholdet ejes af Azure Blob Storage, ikke af dette repo.**
`contracts/content/` er en fixtur, testene læser — se
[ADR 0005](./docs/ADR/0005-blob-er-kilden-til-indholdet.md).

## Hvorfor tingene er, som de er

[`.specify/memory/constitution.md`](./.specify/memory/constitution.md) er
projektets øverste normative dokument. Alt andet skal kunne stå sig over for
den.

**Arkitekturbeslutninger** — [`docs/ADR/`](./docs/ADR/)

1. [Kontrakter er API-DTO'er](./docs/ADR/0001-kontrakter-er-api-dtoer.md)
2. [Hændelseslog frem for SwiftData](./docs/ADR/0002-haendelseslog-frem-for-swiftdata.md)
3. [Detektivstemning som gennemgående ramme](./docs/ADR/0003-detektivstemning-som-gennemgaaende-ramme.md)
4. [Serverbåret indhold](./docs/ADR/0004-serverbaaret-indhold.md)
5. [Blob er kilden til indholdet](./docs/ADR/0005-blob-er-kilden-til-indholdet.md)
6. [Kontrakten forenklet](./docs/ADR/0006-kontrakten-forenklet.md)
7. [Blob nu, relationelt når der er konti](./docs/ADR/0007-blob-nu-relationelt-naar-der-er-konti.md) — *foreslået*

**Features**

- 001 — [Fundament og lodret snit](./specs/001-fundament-og-lodret-snit/plan.md)
- 002 — [Quizmaster-appen](./specs/002-quizmaster-app/plan.md)
- 003 — [Indholdslageret](./specs/003-indholdslager/spec.md) — *foreslået*,
  med [analysen af blob, Table Storage og Azure SQL](./specs/003-indholdslager/research.md)

**Drift** — [Udrulning af backenden](./docs/drift/udrulning.md)
