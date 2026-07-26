import BHContracts
import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

@Suite("Point")
struct ScoreLedgerTests {

    let ledger = ScoreLedger()

    // MARK: - Afrundingsvektorer

    struct RoundingVector: Sendable, CustomStringConvertible {
        let name: String
        let base: Int
        let percent: Double
        let expected: Int

        var description: String { name }
    }

    static let roundingVectors: [RoundingVector] = {
        guard let json = try? ContractFixtures.specJSON("scoring-testvectors.json"),
              let raw = json["rounding"] as? [[String: Any]]
        else { return [] }

        return raw.compactMap { entry in
            guard let name = entry["name"] as? String,
                  let base = entry["base"] as? Int,
                  let percent = entry["percent"] as? NSNumber,
                  let expected = entry["expected"] as? Int
            else { return nil }
            return RoundingVector(
                name: name, base: base, percent: percent.doubleValue, expected: expected
            )
        }
    }()

    @Test("Vektorfilen er fundet og ikke tom")
    func vectorsAreLoaded() {
        #expect(!Self.roundingVectors.isEmpty)
    }

    @Test("Afrunding følger vektoren", arguments: roundingVectors)
    func rounds(_ vector: RoundingVector) {
        let actual = ScoreLedger.penalty(base: vector.base, percent: vector.percent)
        #expect(actual == vector.expected, "\(vector.name): fik \(actual)")
    }

    @Test("Afrunding er half-away-from-zero, ikke bankers")
    func roundingIsAwayFromZero() {
        // 50 × 5 % = 2,5. Bankers rounding ville give 2.
        #expect(ScoreLedger.penalty(base: 50, percent: 5) == 3)
        // 150 × 5 % = 7,5. Bankers rounding ville give 8 her — men 7,5 → 8
        // begge veje, så den afgørende er den ovenfor.
        #expect(ScoreLedger.penalty(base: 150, percent: 5) == 8)
    }

    // MARK: - SC-005

    /// Hintfradragene kommer fra den pakke, der shipper — ikke fra tal skrevet
    /// ind i testen. Ændrer nogen en procent i indholdet, fejler denne test.
    func boelgenHints() throws -> [Hint] {
        let pack = try ContractFixtures.contentPack()
        let mission = try #require(pack.mission(id: "mission.boelgen.den-femte-besked"))
        return mission.orderedHints
    }

    @Test("0, 1, 2 og 3 hints giver 100, 97, 93 og 88 point")
    func hintCountsProduceExpectedTotals() throws {
        let hints = try boelgenHints()
        let expected = [100, 97, 93, 88]

        for count in 0...3 {
            let used = hints.prefix(count).enumerated().map { index, hint in
                ScoreLedger.UsedHint(hint: hint, eventId: "event-\(index)")
            }
            let transactions = ledger.transactions(
                missionId: "mission.boelgen.den-femte-besked",
                basePoints: 100,
                usedHints: Array(used),
                completionEventId: "completion"
            )
            #expect(
                ledger.total(of: transactions) == expected[count],
                "\(count) hints gav \(ledger.total(of: transactions)), forventede \(expected[count])"
            )
        }
    }

    @Test("Hvert hint er sin egen transaktion med en begrundelse")
    func everyMovementIsExplained() throws {
        let hints = try boelgenHints()
        let used = hints.enumerated().map { index, hint in
            ScoreLedger.UsedHint(hint: hint, eventId: "event-\(index)")
        }
        let transactions = ledger.transactions(
            missionId: "mission.boelgen.den-femte-besked",
            basePoints: 100,
            usedHints: used,
            completionEventId: "completion"
        )

        // Én for gennemførelsen plus én pr. hint.
        #expect(transactions.count == 4)
        #expect(transactions.allSatisfy { !$0.explanation.isEmpty })
        #expect(transactions.filter { $0.reason == .hintUsed }.map(\.points) == [-3, -4, -5])
    }

    @Test("Genåbning af et hint koster ikke igen")
    func reopeningAHintIsFree() throws {
        let hints = try boelgenHints()
        let first = try #require(hints.first)
        let used = [
            ScoreLedger.UsedHint(hint: first, eventId: "event-a"),
            ScoreLedger.UsedHint(hint: first, eventId: "event-b"),
        ]
        let transactions = ledger.transactions(
            missionId: "mission.boelgen.den-femte-besked",
            basePoints: 100,
            usedHints: used,
            completionEventId: "completion"
        )
        #expect(ledger.total(of: transactions) == 97)
    }

    /// Fradragene skal summe til præcis 12 % (V-04, FR-045).
    @Test("Hintfradragene i indholdet summer til 12")
    func penaltiesSumToTwelve() throws {
        for mission in try ContractFixtures.contentPack().missions {
            let sum = mission.hints.reduce(0) { $0 + $1.penaltyPercent }
            #expect(sum == 12, "\(mission.id) summer til \(sum)")
        }
    }

    /// SC-005: tid indgår ikke i point.
    @Test("Ledgeren har ingen indgang for tid")
    func timeIsNotPartOfTheCalculation() throws {
        let hints = try boelgenHints()
        let used = hints.map { ScoreLedger.UsedHint(hint: $0, eventId: "e-\($0.id)") }

        // Samme input, kaldt to gange med vilkårlig tid imellem, giver samme tal.
        // Signaturen tager ingen dato — det er selve pointen, og denne test er
        // dokumentationen af det.
        let first = ledger.transactions(
            missionId: "m", basePoints: 100, usedHints: used, completionEventId: "c"
        )
        let second = ledger.transactions(
            missionId: "m", basePoints: 100, usedHints: used, completionEventId: "c"
        )
        #expect(first == second)
        #expect(ledger.total(of: first) == 88)
    }
}
