import BHContracts
import Foundation

/// Én pointbevægelse med sin begrundelse.
///
/// Ledgeren er ikke en implementeringsdetalje bag et tal — den *er*
/// forklaringen, belønningsskærmen viser (FR-020). Derfor bærer hver
/// transaktion sin egen danske begrundelse.
public struct ScoreTransaction: Identifiable, Hashable, Sendable {
    /// Udledt af den hændelse, transaktionen stammer fra. Deterministisk, så en
    /// gentaget fold giver samme id og aldrig dobbeltpoint (FR-023, FR-033).
    public let id: String
    public let missionId: String
    public let reason: ScoreReason
    /// Fortegnsbærende: `+100` for gennemførelse, `-3` for et hint.
    public let points: Int
    public let hintId: String?
    public let explanation: String

    public init(
        id: String,
        missionId: String,
        reason: ScoreReason,
        points: Int,
        hintId: String?,
        explanation: String
    ) {
        self.id = id
        self.missionId = missionId
        self.reason = reason
        self.points = points
        self.hintId = hintId
        self.explanation = explanation
    }
}

public enum ScoreReason: String, Hashable, Sendable {
    case missionCompleted
    case hintUsed
    case wrongAnswer
}

/// Beregner point som en liste af transaktioner frem for ét tal.
///
/// **Tid indgår ikke.** Forfatningens princip VII forbyder tidspres, og SC-005
/// gør det målbart: to spillere med samme hintforbrug får samme point, uanset
/// om de brugte fire minutter eller fyrre.
public struct ScoreLedger: Sendable {

    public init() {}

    /// Afrundingsreglen. Klient og en fremtidig server skal være enige til
    /// pointet, så den er skrevet ud og dækket af testvektorer
    /// (`contracts/spec/scoring.md`).
    ///
    /// `round(base × pct / 100)` med half-away-from-zero — ikke Swifts
    /// default-banker­afrunding, som ville give 2 for 2,5.
    public static func penalty(base: Int, percent: Double) -> Int {
        let raw = Double(base) * percent / 100
        return Int(raw.rounded(.toNearestOrAwayFromZero))
    }

    // MARK: - Hvad et forkert svar koster

    /// Det samlede budget for både hints og forkerte svar — hver for sig.
    ///
    /// De tre hints summer til præcis 12 (V-04). Forkerte svar har sit eget
    /// loft på det samme tal, så en spiller, der både gætter og læser hints,
    /// i værste fald ender på 76 af 100. Under det bliver en opgave, familien
    /// har brugt en halv time på, til en straf.
    public static let budgetPercent: Double = 12

    /// Hvad ét forkert svar koster på dette trin.
    ///
    /// ## Valg koster mere end tekst
    ///
    /// Med fire svarmuligheder kan man klikke sig frem til facit på tre
    /// forsøg. Derfor koster hvert forkert valg `12 / (N − 1)` procent: at
    /// eliminere sig hele vejen frem koster præcis lige så meget som at læse
    /// alle tre hints. Ingen af de to genveje er billigere end den anden, og
    /// det er hele pointen.
    ///
    /// En kode eller et fritekstsvar kan ikke brute-forces — der er tusind
    /// trecifrede koder — så et forkert svar dér er næsten altid et ægte
    /// forsøg. Det koster 2 procent: mindre end hint 1, så det aldrig kan
    /// betale sig at springe gætteriet over af frygt for prisen.
    public static func wrongAnswerPercent(for step: Step) -> Double {
        switch step {
        case .singleChoice(let choice):
            let wrongOptions = Double(choice.options.count - 1)
            // Under to muligheder er der intet at vælge imellem. Pakken er
            // ugyldig, men et svar skal stadig kunne bedømmes.
            return wrongOptions >= 1 ? budgetPercent / wrongOptions : budgetPercent
        case .numericCode, .freeText:
            return 2
        case .narrative, .unknown:
            // Der er intet at svare forkert på.
            return 0
        }
    }

    /// Et forkert svar, spilleren har afgivet.
    public struct WrongAnswer: Hashable, Sendable {
        public let stepId: String
        /// Det normaliserede svar. Bruges til at genkende det samme fejlsvar
        /// afgivet to gange.
        public let answer: String
        public let percent: Double
        public let eventId: String

        public init(stepId: String, answer: String, percent: Double, eventId: String) {
            self.stepId = stepId
            self.answer = answer
            self.percent = percent
            self.eventId = eventId
        }
    }

    /// Bygger transaktionerne for én gennemført mission.
    ///
    /// - Parameters:
    ///   - usedHints: hints i den rækkefølge, de faktisk blev åbnet, hver med
    ///     id'et på den hændelse, der åbnede dem. Et hint åbnet to gange
    ///     optræder kun én gang — genåbning er gratis (FR-019).
    ///   - completionEventId: hændelsen, der afsluttede missionen.
    ///   - wrongAnswers: forkerte svar i den rækkefølge, de blev afgivet. Det
    ///     samme forkerte svar to gange koster kun én gang — som med hints.
    public func transactions(
        missionId: String,
        basePoints: Int,
        usedHints: [UsedHint],
        wrongAnswers: [WrongAnswer] = [],
        completionEventId: String
    ) -> [ScoreTransaction] {
        var result: [ScoreTransaction] = [
            ScoreTransaction(
                id: "\(completionEventId):missionCompleted",
                missionId: missionId,
                reason: .missionCompleted,
                points: basePoints,
                hintId: nil,
                explanation: "Opgave løst"
            )
        ]

        var seenHintIds = Set<String>()
        for used in usedHints {
            // Genåbning koster ikke igen (FR-019).
            guard seenHintIds.insert(used.hint.id).inserted else { continue }

            let deduction = Self.penalty(base: basePoints, percent: used.hint.penaltyPercent)
            result.append(
                ScoreTransaction(
                    id: "\(used.eventId):hintUsed",
                    missionId: missionId,
                    reason: .hintUsed,
                    points: -deduction,
                    hintId: used.hint.id,
                    explanation: "Hint \(used.hint.order): \(used.hint.title)"
                )
            )
        }

        var spent: Double = 0
        var seenAnswers = Set<String>()
        for wrong in wrongAnswers {
            // Det samme fejlsvar to gange koster én gang. Et gentaget svar
            // fortæller spilleren intet nyt, og et net, der sender den samme
            // hændelse to gange, må ikke koste point.
            guard seenAnswers.insert("\(wrong.stepId)|\(wrong.answer)").inserted else { continue }

            // Loftet skæres på procenten og ikke på pointene, så regnestykket
            // ser ens ud, uanset hvad grundpointene er.
            let percent = Swift.min(wrong.percent, Self.budgetPercent - spent)
            guard percent > 0 else { break }
            spent += percent

            let deduction = Self.penalty(base: basePoints, percent: percent)
            result.append(
                ScoreTransaction(
                    id: "\(wrong.eventId):wrongAnswer",
                    missionId: missionId,
                    reason: .wrongAnswer,
                    points: -deduction,
                    hintId: nil,
                    explanation: "Forkert svar"
                )
            )
        }

        return result
    }

    public func total(of transactions: [ScoreTransaction]) -> Int {
        transactions.reduce(0) { $0 + $1.points }
    }

    /// Et hint, spilleren har åbnet, parret med hændelsen der gjorde det.
    public struct UsedHint: Hashable, Sendable {
        public let hint: Hint
        public let eventId: String

        public init(hint: Hint, eventId: String) {
            self.hint = hint
            self.eventId = eventId
        }
    }
}
