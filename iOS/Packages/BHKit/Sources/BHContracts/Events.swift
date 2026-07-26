import Foundation

// Kørselsmodellen (data-model.md, del 2).
//
// Den forlader aldrig enheden i feature 001, men bor alligevel i BHContracts,
// fordi den *er* formet som det, en fremtidig `POST` sender: klientgenererede
// UUID'er, monotont sekvensnummer og en payload, der tåler at blive læst af en
// nyere eller ældre version end den, der skrev den (R-005, FR-033).

/// Den eneste skrivbare tilstand i appen. Append-only, én JSON pr. linje.
///
/// Alt andet — point, gennemførte missioner, brugte hints — er en ren fold over
/// denne log og har ingen selvstændig sandhed (FR-034).
public struct GameEvent: Codable, Hashable, Sendable, Identifiable {
    /// Klientgenereret idempotensnøgle. En server kan senere deduplikere på den
    /// uden at kende til klientens rækkefølge (FR-033).
    public let id: UUID
    /// Monotont pr. enhed. Giver en total orden, når to hændelser deler tidsstempel.
    public let sequence: Int
    public let occurredAt: Date
    /// Hvilken pakkeversion hændelsen skete under (FR-035).
    public let contentVersion: String
    public let kind: Tolerant<GameEventKind>
    public let payload: GameEventPayload

    public init(
        id: UUID = UUID(),
        sequence: Int,
        occurredAt: Date,
        contentVersion: String,
        kind: Tolerant<GameEventKind>,
        payload: GameEventPayload
    ) {
        self.id = id
        self.sequence = sequence
        self.occurredAt = occurredAt
        self.contentVersion = contentVersion
        self.kind = kind
        self.payload = payload
    }
}

public enum GameEventKind: String, TolerantEnum {
    case missionOpened
    case presenceVerified
    case stepViewed
    case answerSubmitted
    case hintUsed
    case missionCompleted
}

/// Kind-specifikke felter, alle optional.
///
/// Bevidst ikke en diskrimineret union. Loggen er append-only og skal kunne
/// læses af enhver senere version af appen — også en, der møder en `kind`, den
/// ikke kender. En flad struct med optionals taber aldrig en linje, hvor en
/// streng union ville kaste og gøre hele filen ulæselig.
public struct GameEventPayload: Codable, Hashable, Sendable {
    public var missionId: String?
    public var stepId: String?
    public var hintId: String?
    /// Det normaliserede svar. Rå input gemmes ikke — det kan indeholde
    /// utilsigtet indtastet tekst (forfatningens princip VI).
    public var answer: String?
    /// `correct` \| `nearMiss` \| `incorrect` \| `malformed`.
    public var outcome: String?
    public var nearMissId: String?
    public var presence: PresenceEvidence?

    public init(
        missionId: String? = nil,
        stepId: String? = nil,
        hintId: String? = nil,
        answer: String? = nil,
        outcome: String? = nil,
        nearMissId: String? = nil,
        presence: PresenceEvidence? = nil
    ) {
        self.missionId = missionId
        self.stepId = stepId
        self.hintId = hintId
        self.answer = answer
        self.outcome = outcome
        self.nearMissId = nearMissId
        self.presence = presence
    }
}

/// Hvordan opgaven blev åbnet.
///
/// **Blokerer aldrig.** Den registrerer kun, så en fremtidig server kan holde
/// en highscore ærlig uden nogensinde at have straffet nogen (FR-028, R-007).
public struct PresenceEvidence: Codable, Hashable, Sendable {
    public let method: Tolerant<PresenceMethod>
    public let accuracyMetres: Double?
    public let dwellSeconds: Double
    public let verifiedAt: Date

    public init(
        method: Tolerant<PresenceMethod>,
        accuracyMetres: Double?,
        dwellSeconds: Double,
        verifiedAt: Date
    ) {
        self.method = method
        self.accuracyMetres = accuracyMetres
        self.dwellSeconds = dwellSeconds
        self.verifiedAt = verifiedAt
    }
}

public enum PresenceMethod: String, TolerantEnum {
    /// Normal verifikation inden for radius og præcision.
    case gps
    /// Verificeret, men på et bredere accept-vindue end normalt (FR-026).
    case gpsLowConfidence
    /// Spilleren bekræftede selv efter for lang tid uden fix (FR-027).
    case softOverride
    /// Demotilstand uden position.
    case demo
    /// `CLLocation.sourceInformation` meldte simuleret. Verifikationen lykkes
    /// stadig — flaget registreres kun (FR-028).
    case simulated
}

/// Spillerens igangværende opgave.
public struct GameSession: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let missionId: String
    /// Bundet ved start og ændrer sig ikke undervejs (FR-035). En
    /// indholdsopdatering midt i en tur skifter ikke facit under spilleren.
    public let contentVersion: String
    public let startedAt: Date
    public var currentStepId: String?
    public var presenceEvidence: PresenceEvidence?

    public init(
        id: UUID = UUID(),
        missionId: String,
        contentVersion: String,
        startedAt: Date,
        currentStepId: String? = nil,
        presenceEvidence: PresenceEvidence? = nil
    ) {
        self.id = id
        self.missionId = missionId
        self.contentVersion = contentVersion
        self.startedAt = startedAt
        self.currentStepId = currentStepId
        self.presenceEvidence = presenceEvidence
    }
}
