#!/usr/bin/env python3
"""Genererer Postnumre.swift fra Dataforsyningens officielle registre.

    python3 iOS-admin/Tools/generate-postnumre.py

Kør den, når Danmark får et nyt postnummer, eller når en kommune flytter
landsdel. Skriver direkte i ByensGaaderAdmin/Postnumre.swift.

## Hvorfor der skal to opslag til

`/postnumre` kender kommunerne bag hvert postnummer, men ikke landsdelen.
`/kommuner` kender ikke landsdelen direkte — den står kun på en adresse. Derfor
hentes én adresse pr. kommune (99 kald), og landsdelen læses derfra.

Et postnummer, der dækker flere kommuner, får den landsdel, flest af dem hører
til. Det er et valg og ikke en sandhed, men et postnummer skal stå ét sted på
listen, ellers kan quizmasteren ikke finde sin opgave igen.
"""

import collections
import json
import pathlib
import sys
import time
import urllib.request

API = "https://api.dataforsyningen.dk"

# Landsdelenes danske navne fra registret → wire-værdien i kontrakten.
SLUG = {
    "Byen København": "byenKoebenhavn",
    "Københavns omegn": "koebenhavnsOmegn",
    "Nordsjælland": "nordsjaelland",
    "Bornholm": "bornholm",
    "Østsjælland": "oestsjaelland",
    "Vest- og Sydsjælland": "vestOgSydsjaelland",
    "Fyn": "fyn",
    "Sydjylland": "sydjylland",
    "Østjylland": "oestjylland",
    "Vestjylland": "vestjylland",
    "Nordjylland": "nordjylland",
}


def fetch(path: str):
    for attempt in range(3):
        try:
            with urllib.request.urlopen(API + path, timeout=30) as response:
                return json.load(response)
        except Exception as error:  # noqa: BLE001 — netværk fejler på mange måder
            if attempt == 2:
                raise
            print(f"  prøver igen ({error})", file=sys.stderr)
            time.sleep(1)


def main() -> int:
    print("Henter postnumre …")
    postnumre = fetch("/postnumre")

    print(f"Henter landsdel for hver kommune ({len(fetch('/kommuner'))} stk.) …")
    kommuner = fetch("/kommuner")
    landsdel_for_kommune = {}
    for index, kommune in enumerate(kommuner):
        adresser = fetch(
            f"/adgangsadresser?kommunekode={kommune['kode']}&struktur=flad&per_side=1")
        if adresser:
            landsdel_for_kommune[kommune["kode"]] = adresser[0]["landsdelsnavn"]
        if index % 20 == 0:
            print(f"  {index}/{len(kommuner)}")

    rows, uden = [], []
    for postnummer in postnumre:
        tællere = collections.Counter(
            landsdel_for_kommune[k["kode"]]
            for k in (postnummer.get("kommuner") or [])
            if k["kode"] in landsdel_for_kommune
        )
        if not tællere:
            uden.append(postnummer["nr"])
            continue
        rows.append(
            (postnummer["nr"], postnummer["navn"], SLUG[tællere.most_common(1)[0][0]]))

    if uden:
        print(f"ADVARSEL: {len(uden)} postnumre uden landsdel: {uden[:10]}", file=sys.stderr)

    rows.sort()
    target = pathlib.Path(__file__).resolve().parents[1] / \
        "ByensGaaderAdmin/ByensGaaderAdmin/Postnumre.swift"
    target.write_text(render(rows), encoding="utf-8")
    print(f"Skrev {len(rows)} postnumre til {target}")
    return 0


def render(rows) -> str:
    lines = "\n".join(f"{nr}|{navn}|{slug}" for nr, navn, slug in rows)
    return HEADER + lines + FOOTER


HEADER = '''import Foundation

/// Danmarks postnumre med by og landsdel.
///
/// Genereret fra Dataforsyningens officielle registre — `/postnumre` joinet med
/// `/kommuner` over kommunens landsdel — den 31. juli 2026. Rediger ikke i
/// hånden; kør `iOS-admin/Tools/generate-postnumre.py` igen.
///
/// ## Hvorfor tabellen ligger i koden
///
/// Quizmasteren vælger landsdel og derefter postnummer, og byen kommer af sig
/// selv. Blev listen hentet fra nettet, kunne appen ikke oprette en opgave i
/// felten uden dækning — og det er præcis dér, den bruges.
///
/// ## Hvorfor det er én tekstblok og ikke 1089 linjer Swift
///
/// En array-literal med tusind elementer koster typechecker-tid ved hver eneste
/// oversættelse. Blokken deles op én gang, første gang nogen slår op.
///
/// ## De postnumre, der ligger i to landsdele
///
/// Et postnummer kan dække flere kommuner. Landsdelen er den, flest af dem
/// hører til. Det er et valg og ikke en sandhed — men et postnummer skal stå ét
/// sted på listen, ellers kan quizmasteren ikke finde sin opgave igen.
///
/// `nonisolated`, fordi tabellen er ren data. Uden det arver den projektets
/// `MainActor`-standard, og hierarkiet — som regnes uden for hovedtråden —
/// kan ikke slå et postnummer op.
nonisolated enum Postnumre {

    /// `postnummer|by|landsdel`, én pr. linje, sorteret efter postnummer.
    private static let raw = """
'''

FOOTER = '''
"""

    struct Sted: Identifiable, Hashable, Sendable {
        let code: String
        let city: String
        let region: String

        var id: String { code }
        /// "7100 Vejle" — sådan som quizmasteren genkender stedet.
        var label: String { "\\(code) \\(city)" }
    }

    /// Alle postnumre, sorteret efter nummer. Bygges én gang.
    static let all: [Sted] = raw.split(separator: "\\n").compactMap { line in
        let parts = line.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        return Sted(code: String(parts[0]), city: String(parts[1]), region: String(parts[2]))
    }

    private static let byCode: [String: Sted] =
        Dictionary(all.map { ($0.code, $0) }, uniquingKeysWith: { first, _ in first })

    /// `nil` for et postnummer, der ikke findes i Danmark.
    static func sted(_ code: String) -> Sted? { byCode[code] }

    static func city(_ code: String) -> String? { byCode[code]?.city }

    static func region(_ code: String) -> String? { byCode[code]?.region }

    /// Postnumrene i én landsdel, sorteret efter nummer.
    static func inRegion(_ region: String) -> [Sted] { all.filter { $0.region == region } }
}
'''


if __name__ == "__main__":
    raise SystemExit(main())
