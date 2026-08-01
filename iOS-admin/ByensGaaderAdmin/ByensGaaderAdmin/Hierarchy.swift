import Foundation

/// Opgaverne grupperet som landsdel → postnummer → opgaver (FR-105).
struct RegionGroup: Identifiable {
    let region: String
    let places: [PlaceGroup]
    var id: String { region }
}

struct PlaceGroup: Identifiable {
    let postalCode: String
    let missions: [MissionSummary]

    var id: String { postalCode }

    /// "7100 Vejle". Byen kommer fra tabellen og står ikke i pakken.
    var title: String {
        guard !postalCode.isEmpty else { return "Uden postnummer" }
        guard let city = Postnumre.city(postalCode) else { return "\(postalCode) — ukendt" }
        return "\(postalCode) \(city)"
    }
}

extension PackDocument {

    /// Hierarkiet, som forsiden viser det.
    ///
    /// Landsdelen slås op ud fra postnummeret og gemmes ikke i pakken. To kopier
    /// af det samme kunne drive fra hinanden, og postnummeret er det eneste,
    /// nogen taster.
    ///
    /// Opgaver, hvis sted mangler eller bærer et postnummer, der ikke findes,
    /// forsvinder **ikke**. De samles nederst, for en opgave, der ikke kan ses,
    /// kan heller ikke rettes — og det er netop den slags fejl, quizmasteren
    /// skal kunne finde.
    var hierarchy: [RegionGroup] {
        let byRegion = Dictionary(grouping: missions) { mission in
            mission.postalCode.flatMap(Postnumre.region) ?? ""
        }

        return byRegion
            .sorted { Self.regionOrder($0.key) < Self.regionOrder($1.key) }
            .map { region, missions in
                let places = Dictionary(grouping: missions) { $0.postalCode ?? "" }
                    .map { code, missions in
                        PlaceGroup(
                            postalCode: code,
                            missions: missions.sorted { $0.title < $1.title }
                        )
                    }
                    .sorted { $0.postalCode < $1.postalCode }

                return RegionGroup(region: region, places: places)
            }
    }

    /// Danmarks Statistiks rækkefølge. Ukendte landsdele — og opgaver uden —
    /// lægger sig nederst i stedet for at bryde listen op midtvejs.
    private static func regionOrder(_ region: String) -> Int {
        Vocabulary.regions.firstIndex(of: region) ?? Vocabulary.regions.count
    }
}
