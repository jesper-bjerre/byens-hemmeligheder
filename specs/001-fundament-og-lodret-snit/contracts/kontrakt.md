# Kontrakt: indholdspakken

**Feature**: 001-fundament-og-lodret-snit
**Skema**: [`bh-content-v1.schema.json`](./bh-content-v1.schema.json)

Feature 001 eksponerer ingen netværks-API. Dens eneste eksterne grænseflade er
**indholdspakken** — og den er ikke en intern detalje, den er den kontrakt, en
ASP.NET Core-backend og en quizmasterportal senere skal levere.

Derfor behandles den som et offentligt API fra dag ét, selvom den i fase 1 blot
er en fil i app-bundlet.

## Hvor filerne lever

| Rolle | Sti |
|---|---|
| Designartefakt (denne feature) | `specs/001-fundament-og-lodret-snit/contracts/` |
| Implementering (det der bygges) | `contracts/` i repoets rod |

Skemaet her er kilden. Implementeringsopgaven kopierer det til
`contracts/bh-content-v1.schema.json`, hvor det bliver sidestillet med `iOS/` og
den kommende `backend/` — netop fordi kontrakten ikke ejes af klienten.

## Regler der ikke må brydes

**Kun additive ændringer.** Et felt må tilføjes som optional. Et felt må ikke
omdøbes, fjernes eller skifte type. Golden-serialiseringstesten gør ethvert brud
højlydt i CI med beskeden "dette er en API-ændring".

**camelCase uden konvertering.** Swift-navnene *er* wire-navnene. Ingen
`keyDecodingStrategy`. Det er forudsætningen for, at golden-testen faktisk vagter
noget — med en konverteringsstrategi ville en omdøbning i Swift være usynlig på
wire.

**Ukendte enum-værdier skal degradere.** Aldrig en bar `String`-raw enum. Når
API'et senere sender `kind: "compass"`, skal en allerede installeret app
ignorere det trin frem for at kaste og mure hele pakken. Dette er FR-003, og det
er den vigtigste forward-compatibility-egenskab i hele kontrakten.

**Facit er altid string.** `"07"` er ikke `7`. En talkonvertering ville tabe
foranstillede nuller, og de er betydende i en kode.

**Datoer er ISO 8601 med offset**, afkodet gennem én delt decoder. ASP.NET Core
udsender fraktionelle sekunder, som Foundations `.iso8601`-strategi fejler på —
det skal håndteres ét sted med én test, ikke opdages i felten.

## Kildeabstraktionen

Protokollen findes fra dag 1, selvom der ikke er nogen server at kalde:

```swift
public protocol ContentPackSource: Sendable {
    func fetchPack(locale: String, ifNoneMatch etag: String?) async throws -> ContentPackResponse
}

public struct BundledContentPackSource: ContentPackSource { }   // fase 1
// public struct HTTPContentPackSource: ContentPackSource { }   // fase 2 — DEN nye fil
```

`ifNoneMatch` og `.notModified` er med, selvom den bundlede kilde altid returnerer
`.pack`. Prisen er nul nu; gevinsten er, at ETag-caching og offline-seed senere
ikke kræver en signaturændring.

## Valideringsgates

Skemaet fanger struktur. Selvkonsistenstesten fanger det, skemaet ikke kan se —
og det er der, de fleste indholdsfejl ellers ville slippe igennem til felten.

| Gate | Fanger | Krav |
|---|---|---|
| JSON Schema | Manglende obligatoriske felter, forkerte typer, ugyldige enums, andet end 3 hints | FR-042, FR-048, V-01 |
| `evaluate(canonicalAnswer) == .correct` | En svarregel der ikke accepterer sit eget facit | FR-043 |
| Ingen near-miss evaluerer korrekt | Den klassiske forfatterbug: en distraktor accepteres også | FR-044 |
| Hintsum == 12 % | Fejljusterede fradrag | FR-045 |
| Alle id-referencer resolver | Døde henvisninger til trin, hints, medier, kilder | FR-046 |
| Forbudt kode fraværende | Bølgens ugyldige `541` | FR-047, SC-008 |
| `maxAcceptableAccuracyMetres ≤ activationRadiusMetres` | Et accept-vindue bredere end selve radius | R-010 |
| `published` kræver feltdata | At uverificeret indhold frigives | Princip IV, V-10 |

De to opgaver i feature 001 har status `fieldTestReady`. Den sidste gate blokerer
dem bevidst fra `published`, indtil koordinater, radius og standpunkt er målt
i felten.

## Eksempeldata

Begge missioner udledes af opgavedokumenterne, som er kilden til sandhed:

- `docs/design af opgaver/opgaver/7100/Boelgen_Opgave.md` — facit `592`,
  accepterede former `592`, `5 9 2`, `5-9-2`, fem registrerede near-misses,
  forbudt kode `541`
- `docs/design af opgaver/opgaver/7100/Fjordenhus_Opgave.md` — facit `428`

Uoverensstemmelse mellem dokument og pakke er per definition en fejl i pakken.
