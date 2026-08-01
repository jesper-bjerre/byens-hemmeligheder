import BHContracts
import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

@Suite("Svarbedømmelse")
struct AnswerEvaluatorTests {

    let evaluator = AnswerEvaluator()

    // MARK: - Vektorer mod den shippende pakke

    struct Vector: Sendable, CustomStringConvertible {
        let name: String
        let rule: String
        let input: String
        let expected: String

        var description: String { name }
    }

    static let vectors: [Vector] = {
        guard let json = try? ContractFixtures.specJSON("answer-testvectors.json"),
              let raw = json["evaluation"] as? [[String: Any]]
        else { return [] }

        return raw.compactMap { entry in
            guard let name = entry["name"] as? String,
                  let rule = entry["rule"] as? String,
                  let input = entry["input"] as? String,
                  let expected = entry["expected"] as? String
            else { return nil }
            return Vector(name: name, rule: rule, input: input, expected: expected)
        }
    }()

    /// Slår vektorens regelnavn op i den pakke, der faktisk shipper.
    static func step(named rule: String) throws -> Step {
        let pack = try ContractFixtures.contentPack()
        let missionId = rule.hasPrefix("boelgen")
            ? "mission.boelgen.den-femte-besked"
            : "mission.fjordenhus.vandets-tromler"
        let mission = try #require(pack.mission(id: missionId))
        let stepId = rule.hasPrefix("boelgen") ? "step.boelgen.koden" : "step.fjordenhus.koden"
        return try #require(mission.orderedSteps.first { $0.id == stepId })
    }

    @Test("Vektorfilen er fundet og ikke tom")
    func vectorsAreLoaded() {
        #expect(!Self.vectors.isEmpty)
    }

    @Test("Bedømmelse følger vektoren", arguments: vectors)
    func evaluates(_ vector: Vector) throws {
        let step = try Self.step(named: vector.rule)
        let outcome = evaluator.evaluate(vector.input, step: step)

        let actual = switch outcome {
        case .correct: "correct"
        case .nearMiss: "nearMiss"
        case .incorrect: "incorrect"
        case .malformed: "malformed"
        }
        #expect(actual == vector.expected, "\(vector.name): '\(vector.input)' gav \(actual)")
    }

    // MARK: - De fire udfald, eksplicit

    @Test("592 er korrekt, også med mellemrum og bindestreger")
    func canonicalAndAcceptedForms() throws {
        let step = try Self.step(named: "boelgen.kode")
        for form in ["592", "5 9 2", "5-9-2", " 592 "] {
            #expect(evaluator.evaluate(form, step: step).isCorrect, "'\(form)' burde være korrekt")
        }
    }

    @Test("529 er et registreret fejlsvar med sin egen vejledning")
    func nearMissCarriesItsOwnFeedback() throws {
        let step = try Self.step(named: "boelgen.kode")
        guard case .nearMiss(let id, let feedback) = evaluator.evaluate("529", step: step) else {
            Issue.record("529 burde være nearMiss")
            return
        }
        #expect(id == "529")
        #expect(feedback.contains("rækkefølgen"), "Vejledningen skal handle om rækkefølgen")
    }

    /// FR-014. Den vigtigste enkeltstående regel i svarmotoren.
    @Test("59 er ufærdigt og tæller ikke som fejlforsøg")
    func incompleteAnswerIsNotAnAttempt() throws {
        let step = try Self.step(named: "boelgen.kode")
        let outcome = evaluator.evaluate("59", step: step)

        guard case .malformed(let reason) = outcome else {
            Issue.record("59 burde være malformed, var \(outcome)")
            return
        }
        #expect(reason == .tooShort(expected: 3, actual: 2))
        #expect(outcome.countsAsAttempt == false, "Et ufærdigt svar må aldrig tælle som fejlforsøg")
    }

    @Test("Et forkert, men fuldstændigt svar tæller som forsøg")
    func wrongAnswerDoesCountAsAttempt() throws {
        let step = try Self.step(named: "boelgen.kode")
        let outcome = evaluator.evaluate("111", step: step)
        #expect(outcome.countsAsAttempt)
        if case .incorrect = outcome {} else {
            Issue.record("111 burde være incorrect, var \(outcome)")
        }
    }

    /// Registrerede fejlsvar med afvigende længde skal stadig nå frem.
    @Test("5918 får årstals-vejledningen, ikke en længdefejl")
    func registeredNearMissBeatsLengthCheck() throws {
        let step = try Self.step(named: "boelgen.kode")
        guard case .nearMiss(_, let feedback) = evaluator.evaluate("5918", step: step) else {
            Issue.record("5918 er registreret som fejlsvar og skal bedømmes som sådan")
            return
        }
        #expect(feedback.contains("året"))
    }

    @Test("Cifferkoder sammenlignes som streng, aldrig som tal")
    func codesAreComparedAsStrings() {
        let rule = AnswerRule(
            kind: .known(.digitsOnly),
            canonicalAnswer: "007",
            acceptedAnswers: ["007"],
            nearMissResponses: []
        )
        #expect(evaluator.evaluate("007", rule: rule).isCorrect)
        // Ville en talkonvertering være sneget sig ind, ville denne være korrekt.
        #expect(evaluator.evaluate("7", rule: rule).isCorrect == false)
    }

    @Test("En ukendt regeltype degraderer i stedet for at kaste")
    func unknownRuleKindDegrades() {
        let rule = AnswerRule(
            kind: .unknown("fuzzyMatch"),
            canonicalAnswer: "boelgen",
            acceptedAnswers: ["boelgen"],
            nearMissResponses: []
        )
        #expect(evaluator.evaluate("Bølgen", rule: rule).isCorrect)
    }

    /// Facit skal stå i `acceptedAnswers`. Evaluatoren lægger det ikke til
    /// automatisk — netop så V-02 kan fange en forfatter, der retter det ene
    /// uden det andet.
    @Test("Et facit, der ikke står blandt de accepterede svar, bedømmes ikke som korrekt")
    func canonicalAnswerIsNotImplicitlyAccepted() {
        let rule = AnswerRule(
            kind: .known(.digitsOnly),
            canonicalAnswer: "777",
            acceptedAnswers: ["592"],
            nearMissResponses: []
        )
        #expect(evaluator.evaluate("777", rule: rule).isCorrect == false)
    }
}
