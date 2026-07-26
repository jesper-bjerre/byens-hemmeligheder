import BHTestSupport
import Foundation
import Testing

/// User Story 2, gjort maskinel.
///
/// SC-002 kræver, at den anden opgave blev tilføjet **uden opgavespecifik
/// programlogik**. Det er normalt et review-spørgsmål: "kig på ændringssættet
/// og vurdér". Et review glider, når nogen har travlt.
///
/// Testen scanner derfor kildekoden for opgavespecifikke navne. Skriver nogen
/// `if mission.id == "mission.boelgen..."` for at få en enkelt opgave til at
/// opføre sig anderledes, fejler den her — og pointen med feature 001 er reddet,
/// mens designet stadig er friskt.
@Suite("Motoren er indholdsdrevet")
struct EngineIsContentDrivenTests {

    /// Navne, der kun må findes i indhold og i tests — aldrig i produktionskode.
    static let missionSpecificTerms = [
        "boelgen", "bølgen", "fjordenhus", "592", "428",
        "bølgetop", "cylinder", "fjordsegl", "femte signal",
    ]

    /// Mapper med produktionskode. Testmapper er bevidst ikke med — testene
    /// *skal* kende opgaverne.
    static let productionDirectories = [
        "iOS/Packages/BHKit/Sources",
        "iOS/App",
    ]

    struct Offence: CustomStringConvertible {
        let file: String
        let line: Int
        let term: String
        let text: String

        var description: String { "\(file):\(line) indeholder '\(term)' → \(text)" }
    }

    @Test("Ingen opgavespecifikke navne i produktionskoden — SC-002")
    func noMissionSpecificLogicInSources() throws {
        var offences: [Offence] = []

        for directory in Self.productionDirectories {
            let root = ContractFixtures.repositoryRoot.appending(path: directory)
            guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
            else { continue }

            for case let url as URL in enumerator where url.pathExtension == "swift" {
                let relative = url.path().replacingOccurrences(
                    of: ContractFixtures.repositoryRoot.path(),
                    with: ""
                )
                guard let contents = try? String(contentsOf: url, encoding: .utf8) else { continue }

                for (index, line) in contents.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                    // Kommentarer må gerne nævne opgaverne — det er dér,
                    // begrundelserne står. Kun kode tæller.
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("//") || trimmed.hasPrefix("///") || trimmed.hasPrefix("*") {
                        continue
                    }
                    let lowercased = trimmed.lowercased()
                    for term in Self.missionSpecificTerms where lowercased.contains(term) {
                        offences.append(
                            Offence(file: relative, line: index + 1, term: term, text: trimmed.prefix(120).description)
                        )
                    }
                }
            }
        }

        #expect(offences.isEmpty, """
            Produktionskoden nævner konkrete opgaver:

            \(offences.map(\.description).joined(separator: "\n"))

            Motoren skal drives af kontrakten. Kræver en opgave programlogik, er
            det kontrakten, der er utilstrækkelig — ikke motoren (SC-002).
            """)
    }

    /// Begge opgaver skal have samme form, så den ene ikke er et særtilfælde.
    @Test("Begge missioner har samme struktur")
    func bothMissionsShareTheSameShape() throws {
        let pack = try ContractFixtures.contentPack()
        #expect(pack.missions.count == 2)

        let shapes = pack.missions.map { mission in
            mission.orderedSteps.map(\.kind).joined(separator: ",")
        }
        #expect(
            Set(shapes).count == 1,
            "Opgaverne har forskellig trinstruktur: \(shapes). Så er den ene ikke bevis for den anden"
        )

        for mission in pack.missions {
            #expect(mission.hints.count == 3)
            #expect(mission.basePoints == 100)
        }
    }
}
