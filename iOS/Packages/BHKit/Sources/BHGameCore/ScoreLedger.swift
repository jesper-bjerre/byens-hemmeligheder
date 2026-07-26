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

    /// Bygger transaktionerne for én gennemført mission.
    ///
    /// - Parameters:
    ///   - usedHints: hints i den rækkefølge, de faktisk blev åbnet, hver med
    ///     id'et på den hændelse, der åbnede dem. Et hint åbnet to gange
    ///     optræder kun én gang — genåbning er gratis (FR-019).
    ///   - completionEventId: hændelsen, der afsluttede missionen.
    public func transactions(
        missionId: String,
        basePoints: Int,
        usedHints: [UsedHint],
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
