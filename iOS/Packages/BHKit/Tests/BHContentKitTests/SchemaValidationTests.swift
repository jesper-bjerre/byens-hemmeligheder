import BHContracts
import BHGameCore
import BHTestSupport
import Foundation
import Testing

@testable import BHContentKit

/// Publiceringsporten, del 1: skemaet.
///
/// Skemaet fanger struktur — manglende felter, forkerte typer, ukendte nøgler.
/// `ContentConsistencyTests` fanger betydning — at facit rent faktisk bedømmes
/// korrekt af sin egen regel. Der skal begge dele til, og ingen af dem kan
/// erstatte den anden.
@Suite("Skemavalidering")
struct SchemaValidationTests {

    let validator: JSONSchemaValidator

    init() throws {
        validator = try JSONSchemaValidator(schema: Data(contentsOf: ContractFixtures.schemaURL))
    }

    @Test("Den shippende pakke validerer mod skemaet")
    func shippingPackValidates() throws {
        let errors = try validator.validate(try ContractFixtures.contentPackData())
        #expect(errors.isEmpty, """
            Indholdspakken bryder skemaet:
            \(errors.map(\.description).joined(separator: "\n"))
            """)
    }

    @Test("Skemaet i contracts/ er identisk med det i specs/")
    func schemaCopiesAreIdentical() throws {
        let implementation = try Data(contentsOf: ContractFixtures.schemaURL)
        let specification = try Data(
            contentsOf: ContractFixtures.repositoryRoot.appending(
                path: "specs/001-fundament-og-lodret-snit/contracts/bh-content-v1.schema.json"
            )
        )
        #expect(implementation == specification, """
            Skemaet er drevet fra specifikationen. Kopiér den ene over den anden,
            og afgør bevidst hvilken der er kilden.
            """)
    }

    // MARK: - De syv defekter fra quickstart, lag 1

    /// SC-007. Hver defekt indføres enkeltvis i en kopi af den rigtige pakke, og
    /// hver enkelt skal afvises. En defekt, der slipper igennem, er en fejl i
    /// valideringen — ikke i indholdet.
    ///
    /// Fixturerne bygges i hukommelsen frem for at ligge som filer på disken.
    /// Filer ville drive fra den rigtige pakke, og så ville testen bevise noget
    /// om et forældet dokument.
    struct Defect: Sendable, CustomStringConvertible {
        let name: String
        let expectation: String
        let mutate: @Sendable (inout [String: Any]) -> Void

        var description: String { name }
    }

    static let defects: [Defect] = [
        Defect(
            name: "Manglende safety.notes",
            expectation: "Skema: manglende obligatorisk felt"
        ) { pack in
            mutateFirstLocation(&pack) { location in
                var safety = location["safety"] as! [String: Any]
                safety.removeValue(forKey: "notes")
                location["safety"] = safety
            }
        },
        Defect(
            name: "Facit som svarreglen ikke accepterer",
            expectation: "evaluate(canonicalAnswer) != .correct"
        ) { pack in
            mutateCodeStep(&pack) { rule in
                rule["canonicalAnswer"] = "777"
                rule["acceptedAnswers"] = ["592"]
            }
        },
        Defect(
            name: "Facit registreret som near-miss",
            expectation: "En near-miss evaluerer korrekt"
        ) { pack in
            mutateCodeStep(&pack) { rule in
                var nearMisses = rule["nearMissResponses"] as! [[String: Any]]
                nearMisses.append(["answer": "592", "feedback": "Denne burde aldrig vises."])
                rule["nearMissResponses"] = nearMisses
            }
        },
        Defect(
            name: "Hintfradrag ændret fra 4 til 5",
            expectation: "Hintsum er 13, ikke 12"
        ) { pack in
            mutateFirstMission(&pack) { mission in
                var hints = mission["hints"] as! [[String: Any]]
                hints[1]["penaltyPercent"] = 5
                mission["hints"] = hints
            }
        },
        Defect(
            name: "heroMediaId peger på et ikke-eksisterende medie",
            expectation: "Reference resolver ikke"
        ) { pack in
            mutateFirstMission(&pack) { mission in
                mission["heroMediaId"] = "media.findes.ikke"
            }
        },
        Defect(
            name: "Den forbudte kode 541 i en hinttekst",
            expectation: "Forbudt kode fundet"
        ) { pack in
            mutateFirstMission(&pack) { mission in
                var hints = mission["hints"] as! [[String: Any]]
                hints[0]["text"] = "Koden er 541."
                mission["hints"] = hints
            }
        },
        Defect(
            name: "Medie uden kind",
            expectation: "Medie mangler mærkning"
        ) { pack in
            pack["media"] = [[
                "id": "media.umaerket",
                "filename": "umaerket.jpg",
                "altText": "Et billede uden mærkning.",
                "owner": "Ukendt",
                "licence": "Ukendt",
                "credit": "Ukendt",
            ]]
        },
    ]

    @Test("Hver defekt afvises — SC-007", arguments: defects)
    func defectIsRejected(_ defect: Defect) throws {
        var mutated = try Self.mutablePack()
        defect.mutate(&mutated)
        let data = try JSONSerialization.data(withJSONObject: mutated)

        let rejections = try Self.reasonsForRejection(of: data, using: validator)

        #expect(!rejections.isEmpty, """
            Defekten '\(defect.name)' slap gennem porten.
            Forventet afvisning: \(defect.expectation)

            En defekt, der ikke afvises, er en fejl i valideringen — ikke i indholdet.
            """)
    }

    @Test("Den urørte pakke afvises ikke — kontrollen er ikke bare altid rød")
    func untouchedPackIsAccepted() throws {
        let data = try JSONSerialization.data(withJSONObject: try Self.mutablePack())
        #expect(try Self.reasonsForRejection(of: data, using: validator).isEmpty)
    }

    // MARK: - Porten, samlet

    /// Kører hele porten: skema, afkodning, selvkonsistens og forbudte koder.
    /// Det er præcis den kæde, `defectIsRejected` måler imod.
    static func reasonsForRejection(
        of data: Data,
        using validator: JSONSchemaValidator
    ) throws -> [String] {
        var reasons = try validator.validate(data).map(\.description)

        guard case .pack(let pack, _) = try? BundledContentPackSource.decode(data) else {
            reasons.append("Pakken kunne ikke afkodes")
            return reasons
        }

        let evaluator = AnswerEvaluator()
        let mediaIds = Set(pack.media.map(\.id))
        let sourceIds = Set(pack.sources.map(\.id))

        for mission in pack.missions {
            // V-04
            let penaltySum = mission.hints.reduce(0) { $0 + $1.penaltyPercent }
            if penaltySum != 12 {
                reasons.append("\(mission.id): hintfradrag summer til \(penaltySum), ikke 12")
            }
            // V-05
            if let heroMediaId = mission.heroMediaId, !mediaIds.contains(heroMediaId) {
                reasons.append("\(mission.id): heroMediaId '\(heroMediaId)' resolver ikke")
            }
            for sourceId in mission.sourceIds where !sourceIds.contains(sourceId) {
                reasons.append("\(mission.id): kilde '\(sourceId)' resolver ikke")
            }
            // V-02 og V-03
            for step in mission.orderedSteps {
                guard let rule = step.answerRule else { continue }
                if !evaluator.evaluate(rule.canonicalAnswer, rule: rule).isCorrect {
                    reasons.append("\(step.id): facit '\(rule.canonicalAnswer)' bedømmes ikke som korrekt")
                }
                for nearMiss in rule.nearMissResponses
                where evaluator.evaluate(nearMiss.answer, rule: rule).isCorrect {
                    reasons.append("\(step.id): near-miss '\(nearMiss.answer)' evaluerer til korrekt")
                }
            }
        }

        // V-07
        for asset in pack.media where !asset.kind.isKnown {
            reasons.append("\(asset.id): medie mangler gyldig kind")
        }

        // V-06
        let raw = String(decoding: data, as: UTF8.self)
        for code in ForbiddenCodeTests.forbiddenCodes where !ForbiddenCodeTests.occurrences(of: code, in: raw).isEmpty {
            reasons.append("Den forbudte kode '\(code)' forekommer i pakken")
        }

        return reasons
    }

    // MARK: - Fixturebyggeri

    static func mutablePack() throws -> [String: Any] {
        let data = try ContractFixtures.contentPackData()
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    static func mutateFirstMission(_ pack: inout [String: Any], _ change: (inout [String: Any]) -> Void) {
        var missions = pack["missions"] as! [[String: Any]]
        var first = missions[0]
        change(&first)
        missions[0] = first
        pack["missions"] = missions
    }

    static func mutateFirstLocation(_ pack: inout [String: Any], _ change: (inout [String: Any]) -> Void) {
        var locations = pack["locations"] as! [[String: Any]]
        var first = locations[0]
        change(&first)
        locations[0] = first
        pack["locations"] = locations
    }

    /// Muterer svarreglen på Bølgens kodetrin.
    static func mutateCodeStep(_ pack: inout [String: Any], _ change: (inout [String: Any]) -> Void) {
        mutateFirstMission(&pack) { mission in
            var steps = mission["steps"] as! [[String: Any]]
            guard let index = steps.firstIndex(where: { $0["kind"] as? String == "numericCode" }) else { return }
            var rule = steps[index]["answerRule"] as! [String: Any]
            change(&rule)
            steps[index]["answerRule"] = rule
            mission["steps"] = steps
        }
    }
}
