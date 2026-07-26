import BHContracts
import BHGameCore
import Foundation

/// Alt, appen viser om spillerens fremdrift.
///
/// Har ingen selvstændig sandhed. Den er resultatet af at folde loggen og kan
/// altid kasseres og genopbygges (FR-034).
public struct PlayerState: Hashable, Sendable {
    public var completedMissionIds: Set<String> = []
    /// Hints spilleren har åbnet, pr. mission. Genåbning tæller ikke med igen.
    public var usedHintIds: [String: [String]] = [:]
    public var transactions: [ScoreTransaction] = []
    /// Hvor spilleren var, da appen sidst blev lukket. Bruges til genoptagelse (FR-036).
    public var currentStepId: [String: String] = [:]
    public var presence: [String: PresenceEvidence] = [:]

    /// Den tomme tilstand — en spiller, der aldrig har åbnet en opgave.
    public init() {}

    public var totalPoints: Int { transactions.reduce(0) { $0 + $1.points } }

    /// Pointopdelingen for én mission — præcis dét, belønningsskærmen viser (FR-020).
    public func transactions(forMission missionId: String) -> [ScoreTransaction] {
        transactions.filter { $0.missionId == missionId }
    }

    public func points(forMission missionId: String) -> Int {
        transactions(forMission: missionId).reduce(0) { $0 + $1.points }
    }
}

/// Folder hændelsesloggen til ``PlayerState``.
///
/// Ren funktion. Ingen persistens, ingen ur, ingen I/O — hvilket er dét, der
/// gør den testbar uden at røre disken, og som gør et replay af en fremmed log
/// til en triviel øvelse.
public enum StateProjection {

    public static func fold(_ events: [GameEvent], pack: ContentPack) -> PlayerState {
        var state = PlayerState()
        let ledger = ScoreLedger()

        // Hændelserne i deres kanoniske orden. Loggen er append-only, men en
        // fremtidig sync kan levere dem i vilkårlig rækkefølge.
        let ordered = events.sorted { $0.sequence < $1.sequence }

        // Første gennemløb: saml rå fakta pr. mission.
        var hintsPerMission: [String: [ScoreLedger.UsedHint]] = [:]
        var seenHintKeys: Set<String> = []
        var completionEventId: [String: String] = [:]

        for event in ordered {
            guard let missionId = event.payload.missionId else { continue }

            switch event.kind.known {
            case .stepViewed:
                if let stepId = event.payload.stepId {
                    state.currentStepId[missionId] = stepId
                }

            case .presenceVerified:
                if let evidence = event.payload.presence {
                    // Første verifikation vinder. En senere må ikke kunne
                    // omskrive, hvordan opgaven blev åbnet.
                    if state.presence[missionId] == nil {
                        state.presence[missionId] = evidence
                    }
                }

            case .hintUsed:
                guard let hintId = event.payload.hintId,
                      let mission = pack.mission(id: missionId),
                      let hint = mission.hint(id: hintId)
                else { continue }
                // Genåbning er gratis (FR-019), og et gentaget hændelses-id
                // giver aldrig dobbeltfradrag (FR-023).
                guard seenHintKeys.insert("\(missionId)|\(hintId)").inserted else { continue }
                hintsPerMission[missionId, default: []].append(
                    ScoreLedger.UsedHint(hint: hint, eventId: event.id.uuidString)
                )

            case .missionCompleted:
                guard state.completedMissionIds.insert(missionId).inserted else { continue }
                completionEventId[missionId] = event.id.uuidString

            case .missionOpened, .answerSubmitted, nil:
                continue
            }
        }

        // Andet gennemløb: omsæt fakta til point.
        for missionId in state.completedMissionIds.sorted() {
            guard let mission = pack.mission(id: missionId),
                  let eventId = completionEventId[missionId]
            else { continue }

            let used = hintsPerMission[missionId] ?? []
            state.usedHintIds[missionId] = used.map(\.hint.id)
            state.transactions.append(
                contentsOf: ledger.transactions(
                    missionId: missionId,
                    basePoints: mission.basePoints,
                    usedHints: used,
                    completionEventId: eventId
                )
            )
        }

        // Hints brugt i en mission, der endnu ikke er gennemført, skal stadig
        // kunne vises som "åbnet" — de koster bare først point ved afslutning.
        for (missionId, used) in hintsPerMission where state.usedHintIds[missionId] == nil {
            state.usedHintIds[missionId] = used.map(\.hint.id)
        }

        return state
    }
}
