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

    // MARK: - Hvad et forkert svar koster

    struct WrongAnswerVector: Sendable, CustomStringConvertible {
        let name: String
        let base: Int
        /// `nil` betyder kode eller fritekst.
        let options: Int?
        let wrongAnswers: Int
        let expectedPercent: Double
        let expectedTotal: Int

        var description: String { name }
    }

    static let wrongAnswerVectors: [WrongAnswerVector] = {
        guard let json = try? ContractFixtures.specJSON("scoring-testvectors.json"),
              let raw = json["wrongAnswers"] as? [[String: Any]]
        else { return [] }

        return raw.compactMap { entry in
            guard let name = entry["name"] as? String,
                  let base = entry["base"] as? Int,
                  let wrongAnswers = entry["wrongAnswers"] as? Int,
                  let expectedPercent = entry["expectedPercent"] as? NSNumber,
                  let expectedTotal = entry["expectedTotal"] as? Int
            else { return nil }
            return WrongAnswerVector(
                name: name,
                base: base,
                options: entry["options"] as? Int,
                wrongAnswers: wrongAnswers,
                expectedPercent: expectedPercent.doubleValue,
                expectedTotal: expectedTotal
            )
        }
    }()

    @Test("Fejlsvarvektorerne er fundet")
    func wrongAnswerVectorsAreLoaded() {
        #expect(!Self.wrongAnswerVectors.isEmpty)
    }

    @Test("Forkerte svar koster det, vektoren siger", arguments: wrongAnswerVectors)
    func wrongAnswersCost(_ vector: WrongAnswerVector) {
        let step = Self.step(options: vector.options)
        let rate = ScoreLedger.wrongAnswerPercent(for: step)

        // Hvert svar er forskelligt — det samme to gange koster kun én gang.
        let wrong = (0..<vector.wrongAnswers).map { index in
            ScoreLedger.WrongAnswer(
                stepId: step.id, answer: "forkert-\(index)", percent: rate, eventId: "e-\(index)")
        }

        let transactions = ledger.transactions(
            missionId: "m", basePoints: vector.base, usedHints: [],
            wrongAnswers: wrong, completionEventId: "c")

        let spent = transactions.filter { $0.reason == .wrongAnswer }
            .reduce(0) { $0 - $1.points }

        #expect(
            ledger.total(of: transactions) == vector.expectedTotal,
            "\(vector.name): fik \(ledger.total(of: transactions))")
        #expect(
            spent == ScoreLedger.penalty(base: vector.base, percent: vector.expectedPercent)
                || spent == Int((Double(vector.base) * vector.expectedPercent / 100).rounded()),
            "\(vector.name): brugte \(spent)")
    }

    /// Den vigtigste af dem: at klikke sig frem må ikke være billigere end at
    /// læse alle tre hints. Er den det, holder ingen op med at gætte.
    @Test("At eliminere sig frem koster præcis det samme som alle hints",
          arguments: [2, 3, 4, 5, 7, 13])
    func eliminatingCostsTheSameAsAllHints(_ options: Int) {
        let step = Self.step(options: options)
        let rate = ScoreLedger.wrongAnswerPercent(for: step)
        let wrong = (0..<(options - 1)).map { index in
            ScoreLedger.WrongAnswer(
                stepId: step.id, answer: "valg-\(index)", percent: rate, eventId: "e-\(index)")
        }
        let transactions = ledger.transactions(
            missionId: "m", basePoints: 100, usedHints: [],
            wrongAnswers: wrong, completionEventId: "c")

        #expect(ledger.total(of: transactions) == 88, "\(options) muligheder gav \(ledger.total(of: transactions))")
    }

    @Test("Det samme forkerte svar to gange koster én gang")
    func repeatingTheSameWrongAnswerIsFree() {
        let step = Self.step(options: nil)
        let wrong = ["592", "592", "592"].enumerated().map { index, answer in
            ScoreLedger.WrongAnswer(
                stepId: step.id, answer: answer, percent: 2, eventId: "e-\(index)")
        }
        let transactions = ledger.transactions(
            missionId: "m", basePoints: 100, usedHints: [],
            wrongAnswers: wrong, completionEventId: "c")

        #expect(ledger.total(of: transactions) == 98)
        #expect(transactions.filter { $0.reason == .wrongAnswer }.count == 1)
    }

    /// Værste tilfælde. En familie, der har brugt en halv time på stedet, må
    /// ikke ende med at have tabt på at prøve.
    @Test("Alle hints og alt gætteri lader stadig 76 af 100 stå")
    func theFloorIsSeventySix() throws {
        let hints = try boelgenHints()
        let step = Self.step(options: nil)
        let wrong = (0..<20).map { index in
            ScoreLedger.WrongAnswer(
                stepId: step.id, answer: "forkert-\(index)", percent: 2, eventId: "e-\(index)")
        }
        let transactions = ledger.transactions(
            missionId: "m",
            basePoints: 100,
            usedHints: hints.enumerated().map { ScoreLedger.UsedHint(hint: $1, eventId: "h-\($0)") },
            wrongAnswers: wrong,
            completionEventId: "c")

        #expect(ledger.total(of: transactions) == 76)
    }

    @Test("Et fortællende trin har intet at svare forkert på")
    func narrativeStepsCostNothing() {
        let narrative = Step.narrative(
            NarrativeStep(id: "step.intro", order: 1, title: "T", body: "B", continueLabel: "Videre"))
        #expect(ScoreLedger.wrongAnswerPercent(for: narrative) == 0)
    }

    /// Et trin at måle satsen på. `options: nil` giver en talkode.
    private static func step(options: Int?) -> Step {
        let rule = AnswerRule(
            kind: .known(.exact), canonicalAnswer: "facit",
            acceptedAnswers: ["facit"], nearMissResponses: [])

        guard let options else {
            return .numericCode(NumericCodeStep(
                id: "step.kode", order: 1, eyebrow: nil, title: "Kode",
                length: 3, answerRule: rule, hintIds: []))
        }

        return .singleChoice(SingleChoiceStep(
            id: "step.valg", order: 1, eyebrow: nil, title: "Valg", question: "Hvilken?",
            options: (0..<options).map { ChoiceOption(id: "o\($0)", label: "\($0)") },
            answerRule: rule, hintIds: []))
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
