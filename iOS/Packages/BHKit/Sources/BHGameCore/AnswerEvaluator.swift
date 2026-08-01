import BHContracts
import Foundation

/// Udfaldet af én bedømmelse.
///
/// Fire udfald, ikke to. Skellet mellem ``incorrect`` og ``malformed`` er
/// UX-kritisk: "koden er tre cifre" er ikke et forkert svar, det er et
/// ufærdigt, og det må ikke tælle som fejlforsøg (FR-014).
public enum AnswerOutcome: Hashable, Sendable {
    case correct
    /// Et registreret, forudset fejlsvar med sin egen vejledning.
    /// `id` er det normaliserede svar — svarreglen har ingen selvstændig nøgle,
    /// og den normaliserede form er stabil nok til at føre i hændelsesloggen.
    case nearMiss(id: String, feedback: String)
    /// Uden tekst. Der var tidligere en `genericIncorrectFeedback` pr. opgave,
    /// men de fire, der blev skrevet, sagde alle det samme med hver sine ord —
    /// og et felt, der skal udfyldes hver gang uden at bære noget nyt, bliver
    /// udfyldt skødesløst. Teksten står nu ét sted: ``AnswerOutcome/standardIncorrectFeedback``.
    case incorrect
    case malformed(reason: MalformedReason)

    /// Om udfaldet skal tælle som et fejlforsøg.
    ///
    /// ``malformed`` gør ikke. Det er hele pointen med at have den som eget
    /// udfald (FR-014).
    public var countsAsAttempt: Bool {
        switch self {
        case .correct, .nearMiss, .incorrect: true
        case .malformed: false
        }
    }

    public var isCorrect: Bool {
        if case .correct = self { return true }
        return false
    }
}

/// Hvorfor et svar ikke kunne bedømmes.
extension AnswerOutcome {
    /// Vises, når svaret hverken er rigtigt eller et registreret fejlsvar.
    ///
    /// Ikke-nedgørende (FR-015). Den peger tilbage på stedet i stedet for på
    /// spilleren — det er stedet, svaret findes på.
    public static let standardIncorrectFeedback =
        "Det er ikke rigtigt. Kig en gang til på stedet — svaret er der."
}

public enum MalformedReason: Hashable, Sendable {
    case empty
    case tooShort(expected: Int, actual: Int)
    case tooLong(expected: Int, actual: Int)

    /// Vejledning på almindeligt dansk. Aldrig nedgørende (FR-015).
    public var message: String {
        switch self {
        case .empty:
            "Skriv koden, før du sender."
        case .tooShort(let expected, _):
            "Koden er på \(expected) cifre. Du mangler et par endnu."
        case .tooLong(let expected, _):
            "Koden er på \(expected) cifre. Der er et ciffer for meget."
        }
    }
}

/// Bedømmer et svar mod indholdets egen regel.
///
/// Motoren kender ingen facitter. Alt — kanonisk svar, accepterede former,
/// registrerede fejlsvar og deres vejledning — kommer fra indholdspakken. Det
/// er dét, der gør Fjordenhus til en ren indholdsleverance (US2).
public struct AnswerEvaluator: Sendable {

    public init() {}

    /// Bedømmer mod et trin, så den forventede kodelængde tages med.
    public func evaluate(_ input: String, step: Step) -> AnswerOutcome {
        switch step {
        case .numericCode(let step):
            evaluate(input, rule: step.answerRule, expectedLength: step.length)
        case .singleChoice(let step):
            evaluate(input, rule: step.answerRule, expectedLength: nil)
        case .freeText(let step):
            evaluate(input, rule: step.answerRule, expectedLength: nil)
        case .narrative, .unknown:
            .malformed(reason: .empty)
        }
    }

    public func evaluate(_ input: String, rule: AnswerRule, expectedLength: Int? = nil) -> AnswerOutcome {
        let options = Self.normalizationOptions(for: rule.kind)
        let candidate = DanishTextNormalizer.normalize(input, options: options)

        // 1. Tomt er altid ufærdigt.
        if candidate.isEmpty {
            return .malformed(reason: .empty)
        }

        // 2. Korrekt. Sammenlignes som string — foranstillede nuller er
        //    betydende i en kode og må aldrig gå tabt i en talkonvertering.
        //
        //    Bemærk: **kun** `acceptedAnswers` konsulteres. `canonicalAnswer`
        //    lægges bevidst ikke til automatisk. Gjorde den det, ville V-02
        //    ("hvert facit bedømmes korrekt af sin egen regel") være sand pr.
        //    konstruktion og aldrig kunne fange en forfatter, der retter facit
        //    uden at rette reglen. Kontrakten kræver derfor, at facit også står
        //    i `acceptedAnswers` — og selvkonsistenstesten håndhæver det.
        let accepted = rule.acceptedAnswers
            .map { DanishTextNormalizer.normalize($0, options: options) }
        if accepted.contains(candidate) {
            return .correct
        }

        // 3. Registreret fejlsvar med sin egen vejledning.
        //
        //    Ligger bevidst før længdekontrollen. Et registreret fejlsvar er et
        //    *kendt* svar, ikke et ufærdigt — og opgavedokumenterne registrerer
        //    netop svar med afvigende længde, fx Bølgens `5918`, hvor spilleren
        //    har brugt årstallet. Lå længdekontrollen først, ville den
        //    vejledning aldrig nå frem.
        //
        //    Bemærk også rækkefølgen mod trin 2: accepterede svar er allerede
        //    afgjort. Skulle en forfatter komme til at registrere det samme svar
        //    begge steder, vinder "korrekt" — og selvkonsistenstesten fanger
        //    fejlen før udgivelse (V-03, FR-044).
        for nearMiss in rule.nearMissResponses {
            let normalized = DanishTextNormalizer.normalize(nearMiss.answer, options: options)
            if normalized == candidate {
                return .nearMiss(id: normalized, feedback: nearMiss.feedback)
            }
        }

        // 4. Ufærdigt frem for forkert. "Koden er tre cifre" er ikke et forkert
        //    svar, og må ikke tælle som fejlforsøg (FR-014).
        if let expectedLength, candidate.count != expectedLength {
            return .malformed(
                reason: candidate.count < expectedLength
                    ? .tooShort(expected: expectedLength, actual: candidate.count)
                    : .tooLong(expected: expectedLength, actual: candidate.count)
            )
        }

        // 5. Forkert, men mødt venligt.
        return .incorrect
    }

    /// Ukendte regeltyper behandles som ``AnswerRuleKind/exact``.
    /// At degradere til den strengeste kendte regel er sikrere end at kaste
    /// (FR-003).
    static func normalizationOptions(for kind: Tolerant<AnswerRuleKind>) -> DanishTextNormalizer.Options {
        switch kind.known {
        case .digitsOnly: .numericCode
        case .exact, nil: .text
        }
    }
}
