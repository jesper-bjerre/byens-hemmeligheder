import BHContracts
import BHGameCore
import BHTestSupport
import Foundation
import Testing

@testable import BHPersistence

/// Foldet over hændelsesloggen.
///
/// Afledt tilstand har ingen selvstændig sandhed (FR-034). Det gør den testbar
/// uden at røre disken — og det er dét, disse tests udnytter: hændelserne
/// bygges i hånden, foldes, og resultatet sammenlignes. Ingen persistens
/// involveret.
@Suite("Tilstandsfold")
struct StateProjectionTests {

    let pack: ContentPack
    let mission: Mission

    init() throws {
        pack = try ContractFixtures.contentPack()
        mission = try #require(pack.mission(id: "mission.boelgen.den-femte-besked"))
    }

    static let epoch = Date(timeIntervalSince1970: 1_800_000_000)

    func event(
        _ kind: GameEventKind,
        sequence: Int,
        id: UUID = UUID(),
        hintId: String? = nil,
        stepId: String? = nil,
        presence: PresenceEvidence? = nil
    ) -> GameEvent {
        GameEvent(
            id: id,
            sequence: sequence,
            occurredAt: Self.epoch.addingTimeInterval(Double(sequence)),
            contentVersion: pack.contentVersion,
            kind: .known(kind),
            payload: GameEventPayload(
                missionId: mission.id,
                stepId: stepId,
                hintId: hintId,
                presence: presence
            )
        )
    }

    // MARK: - Grundlæggende fold

    @Test("En tom log giver en tom tilstand")
    func emptyLogYieldsEmptyState() {
        let state = StateProjection.fold([], pack: pack)
        #expect(state.completedMissionIds.isEmpty)
        #expect(state.transactions.isEmpty)
        #expect(state.totalPoints == 0)
    }

    @Test("En gennemført mission uden hints giver fulde point")
    func completionWithoutHints() {
        let events = [
            event(.missionOpened, sequence: 1),
            event(.missionCompleted, sequence: 2),
        ]
        let state = StateProjection.fold(events, pack: pack)

        #expect(state.completedMissionIds == [mission.id])
        #expect(state.points(forMission: mission.id) == 100)
    }

    @Test("Alle tre hints giver 88 point — SC-005")
    func allThreeHintsLeaveEightyEight() {
        var events = [event(.missionOpened, sequence: 1)]
        for (index, hint) in mission.orderedHints.enumerated() {
            events.append(event(.hintUsed, sequence: 2 + index, hintId: hint.id))
        }
        events.append(event(.missionCompleted, sequence: 10))

        let state = StateProjection.fold(events, pack: pack)
        #expect(state.points(forMission: mission.id) == 88)
        #expect(state.usedHintIds[mission.id]?.count == 3)
    }

    @Test("Pointopdelingen forklarer hver bevægelse")
    func everyTransactionIsExplained() {
        let events = [
            event(.hintUsed, sequence: 1, hintId: "hint.boelgen.1"),
            event(.missionCompleted, sequence: 2),
        ]
        let state = StateProjection.fold(events, pack: pack)
        let transactions = state.transactions(forMission: mission.id)

        #expect(transactions.count == 2)
        #expect(transactions.allSatisfy { !$0.explanation.isEmpty })
        #expect(state.points(forMission: mission.id) == 97)
    }

    // MARK: - Idempotens

    /// FR-033, FR-023. Den vigtigste egenskab i hele foldet: en hændelse, der
    /// leveres to gange, må aldrig give point to gange.
    @Test("Samme hændelses-id foldet to gange giver ikke dobbeltpoint")
    func duplicateEventIdIsIdempotent() {
        let completionId = UUID()
        let events = [
            event(.missionCompleted, sequence: 1, id: completionId),
            event(.missionCompleted, sequence: 2, id: completionId),
        ]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.points(forMission: mission.id) == 100)
    }

    @Test("To forskellige gennemførelseshændelser tæller stadig kun én gang")
    func repeatedCompletionCountsOnce() {
        let events = [
            event(.missionCompleted, sequence: 1),
            event(.missionCompleted, sequence: 2),
        ]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.points(forMission: mission.id) == 100)
        #expect(state.completedMissionIds.count == 1)
    }

    /// FR-019. Genåbning af et hint er gratis.
    @Test("Samme hint åbnet flere gange trækker kun fra én gang")
    func reopeningAHintIsFree() {
        let events = [
            event(.hintUsed, sequence: 1, hintId: "hint.boelgen.1"),
            event(.hintUsed, sequence: 2, hintId: "hint.boelgen.1"),
            event(.hintUsed, sequence: 3, hintId: "hint.boelgen.1"),
            event(.missionCompleted, sequence: 4),
        ]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.points(forMission: mission.id) == 97)
    }

    @Test("Foldet er en ren funktion — samme log giver samme tilstand")
    func foldIsPure() {
        let events = [
            event(.hintUsed, sequence: 1, hintId: "hint.boelgen.2"),
            event(.missionCompleted, sequence: 2),
        ]
        #expect(StateProjection.fold(events, pack: pack) == StateProjection.fold(events, pack: pack))
    }

    @Test("Rækkefølgen på disken er ligegyldig — sequence bestemmer")
    func orderIsDeterminedBySequence() {
        let events = [
            event(.hintUsed, sequence: 3, hintId: "hint.boelgen.3"),
            event(.missionCompleted, sequence: 4),
            event(.hintUsed, sequence: 1, hintId: "hint.boelgen.1"),
            event(.hintUsed, sequence: 2, hintId: "hint.boelgen.2"),
        ]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.points(forMission: mission.id) == 88)
    }

    // MARK: - Genoptagelse og tilstedeværelse

    /// FR-036. Genoptagelse hviler på, at foldet husker trinnet.
    @Test("Seneste viste trin huskes")
    func currentStepIsRemembered() {
        let events = [
            event(.stepViewed, sequence: 1, stepId: "step.boelgen.intro"),
            event(.stepViewed, sequence: 2, stepId: "step.boelgen.oejet"),
        ]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.currentStepId[mission.id] == "step.boelgen.oejet")
    }

    /// Første verifikation vinder. En senere må ikke kunne omskrive, hvordan
    /// opgaven blev åbnet (FR-028).
    @Test("Den første tilstedeværelse er den, der står ved magt")
    func firstPresenceWins() {
        let first = PresenceEvidence(
            method: .known(.gps), accuracyMetres: 9, dwellSeconds: 21, verifiedAt: Self.epoch
        )
        let second = PresenceEvidence(
            method: .known(.softOverride), accuracyMetres: nil, dwellSeconds: 0, verifiedAt: Self.epoch
        )
        let events = [
            event(.presenceVerified, sequence: 1, presence: first),
            event(.presenceVerified, sequence: 2, presence: second),
        ]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.presence[mission.id]?.method == .known(.gps))
    }

    // MARK: - Robusthed

    @Test("Hints brugt i en uafsluttet mission vises, men koster endnu ikke")
    func hintsInUnfinishedMissionCostNothingYet() {
        let events = [event(.hintUsed, sequence: 1, hintId: "hint.boelgen.1")]
        let state = StateProjection.fold(events, pack: pack)

        #expect(state.usedHintIds[mission.id] == ["hint.boelgen.1"])
        #expect(state.transactions.isEmpty)
        #expect(state.totalPoints == 0)
    }

    /// FR-003. En log skrevet af en nyere app skal kunne læses af en ældre.
    @Test("En ukendt hændelsestype ignoreres frem for at vælte foldet")
    func unknownEventKindIsIgnored() {
        let unknown = GameEvent(
            sequence: 1,
            occurredAt: Self.epoch,
            contentVersion: pack.contentVersion,
            kind: .unknown("photoCaptured"),
            payload: GameEventPayload(missionId: mission.id)
        )
        let events = [unknown, event(.missionCompleted, sequence: 2)]
        let state = StateProjection.fold(events, pack: pack)
        #expect(state.points(forMission: mission.id) == 100)
    }

    @Test("En hændelse for en ukendt mission ignoreres")
    func unknownMissionIsIgnored() {
        let stray = GameEvent(
            sequence: 1,
            occurredAt: Self.epoch,
            contentVersion: pack.contentVersion,
            kind: .known(.missionCompleted),
            payload: GameEventPayload(missionId: "mission.findes.ikke")
        )
        let state = StateProjection.fold([stray], pack: pack)
        #expect(state.transactions.isEmpty)
    }

    @Test("To missioner holdes adskilt")
    func missionsAreScopedSeparately() throws {
        let other = try #require(pack.mission(id: "mission.fjordenhus.vandets-tromler"))
        let events = [
            event(.missionCompleted, sequence: 1),
            GameEvent(
                sequence: 2,
                occurredAt: Self.epoch,
                contentVersion: pack.contentVersion,
                kind: .known(.missionCompleted),
                payload: GameEventPayload(missionId: other.id)
            ),
        ]
        let state = StateProjection.fold(events, pack: pack)

        #expect(state.points(forMission: mission.id) == 100)
        #expect(state.points(forMission: other.id) == 100)
        #expect(state.totalPoints == 200)
    }
}
