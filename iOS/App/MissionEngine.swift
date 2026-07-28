import BHContentKit
import BHContracts
import BHGameCore
import BHLocationKit
import BHPersistence
import Foundation
import Observation

/// Bindeleddet mellem indhold, position, svar og hændelseslog.
///
/// Motoren kender ingen opgaver. Den kender kontrakten. Bølgen og Fjordenhus
/// kører gennem præcis den samme kode, og hvis en tredje opgave kræver en linje
/// her, er kontrakten utilstrækkelig — ikke motoren (US2).
@Observable
@MainActor
final class MissionEngine {

    // MARK: - Offentlig tilstand

    private(set) var pack: ContentPack?
    private(set) var playerState = PlayerState()
    private(set) var session: GameSession?
    private(set) var presence: PresenceState = .idle
    private(set) var loadFailure: String?

    /// Hints spilleren har åbnet i den igangværende mission. Genåbning er gratis.
    private(set) var revealedHintIds: Set<String> = []
    /// Seneste bedømmelse, så skærmen kan vise vejledningen.
    private(set) var lastOutcome: AnswerOutcome?

    /// Sat, når sikkerhedsskærmen er vist én gang i denne session (FR-008).
    private(set) var hasSeenSafetyInterstitial = false

    /// Spillerens seneste position. Kortet centrerer på den.
    ///
    /// Bevidst kun i hukommelsen. Der skrives ingen rutehistorik nogen steder —
    /// hverken til hændelsesloggen eller til disk (forfatningens princip VI).
    private(set) var currentLocation: GeoPoint?
    private(set) var authorizationProblem: AuthorizationProblem?

    var hasLocationAuthorization: Bool {
        switch authorizationProblem {
        case nil, .reducedAccuracy: true
        default: false
        }
    }

    // MARK: - Afhængigheder

    private let repository: ContentRepository
    private let eventStore: EventStore
    private let locationProvider: any LocationProviding
    private let ledger = ScoreLedger()
    private let evaluator = AnswerEvaluator()

    private var gate: PresenceGate?
    private var locationTask: Task<Void, Never>?
    private var authorizationTask: Task<Void, Never>?

    init(
        repository: ContentRepository,
        eventStore: EventStore,
        locationProvider: any LocationProviding
    ) {
        self.repository = repository
        self.eventStore = eventStore
        self.locationProvider = locationProvider
    }

    // MARK: - Indlæsning

    func load() async {
        do {
            let pack = try await repository.pack()
            self.pack = pack
            let events = try await eventStore.allEvents()
            playerState = StateProjection.fold(events, pack: pack)
        } catch {
            loadFailure = "Indholdet kunne ikke indlæses. Prøv at starte appen igen."
        }
    }

    var playableMissions: [Mission] {
        guard let pack else { return [] }
        return pack.missions.filter { mission in
            switch mission.status.known {
            case .fieldTestReady, .publishReady: true
            default: false
            }
        }
    }

    func location(for mission: Mission) -> Location? {
        pack?.location(id: mission.locationId)
    }

    func isCompleted(_ mission: Mission) -> Bool {
        playerState.completedMissionIds.contains(mission.id)
    }

    /// Om opgaven er lukket for genspilning.
    ///
    /// Adskilt fra ``isCompleted(_:)`` med vilje. "Løst" er en kendsgerning om
    /// spillerens historik og styrer flueben på kortet og "Løst"-mærket;
    /// "spærret" er en beslutning om, hvad man må. I Debug er en opgave løst
    /// uden at være spærret, og de to må ikke smelte sammen.
    var blocksReplay: Bool { !LaunchArguments.allowsMissionReplay }

    // MARK: - Session

    /// Starter en mission og **binder den til indholdsversionen** (FR-035).
    /// En indholdsopdatering midt i turen skifter ikke facit under spilleren.
    ///
    /// En løst opgave startes ikke igen — i Release. Spærringen står her og
    /// ikke kun i kortets knap; samme grund som ved ``reveal(_:in:now:)``: en
    /// regel, der kun findes i et view, holder kun så længe alle veje til
    /// handlingen går gennem netop dét view, og der er allerede to kaldesteder.
    ///
    /// I Debug må den samme opgave køres igen og igen. Hint- og pointhistorik
    /// nulstilles **ikke** af det: `revealedHintIds` genlæses nedenfor fra
    /// spillertilstanden, og ``complete(_:now:)`` skriver ikke en gennemførelse
    /// nummer to. En genspilning tilføjer altså ingen point og glemmer intet.
    ///
    /// - Returns: `false`, hvis opgaven ikke blev åbnet. Kaldere skal så **ikke**
    ///   navigere videre — ellers står spilleren på et opgavetrin uden session.
    @discardableResult
    func startSession(for mission: Mission, now: Date = Date()) async -> Bool {
        guard let pack, !(blocksReplay && isCompleted(mission)) else { return false }

        session = GameSession(
            missionId: mission.id,
            contentVersion: pack.contentVersion,
            startedAt: now,
            currentStepId: mission.orderedSteps.first?.id
        )
        revealedHintIds = Set(playerState.usedHintIds[mission.id] ?? [])
        lastOutcome = nil
        presence = .idle

        if let location = location(for: mission),
           let configuration = PresenceGate.Configuration(location: location) {
            gate = PresenceGate(configuration: configuration)
        } else {
            // Uden koordinater kan der ikke gates. Spilleren skal ikke straffes
            // for, at felten endnu ikke er besøgt — missionen kan spilles, og
            // tilstedeværelsen stemples som `demo` (FR-028).
            gate = nil
            presence = .verified(
                PresenceEvidence(
                    method: .known(.demo),
                    accuracyMetres: nil,
                    dwellSeconds: 0,
                    verifiedAt: now
                )
            )
        }

        await record(.missionOpened, missionId: mission.id, now: now)
        return true
    }

    func markSafetyInterstitialSeen() {
        hasSeenSafetyInterstitial = true
    }

    // MARK: - Position

    /// Åbner positionsstrømmen.
    ///
    /// ## Strømmen lukkes aldrig igen
    ///
    /// `AsyncStream` kan forbruges **én gang**. Annulleres den `Task`, der
    /// itererer den, afsluttes strømmen for altid, og en ny `for await` på den
    /// samme strøm returnerer med det samme. Det kostede en fejl, hvor kun den
    /// første opgave kunne gennemføres: approach-skærmen lukkede strømmen, når
    /// den forsvandt, og derefter kom der aldrig flere positioner — heller ikke
    /// til kortet.
    ///
    /// Forbrugeren oprettes derfor én gang og lever, så længe appen gør.
    /// ``pauseLocationUpdates()`` standser kun kilden, ikke strømmen.
    func startLocationUpdates() {
        locationProvider.start()
        guard locationTask == nil else { return }

        locationTask = Task { [weak self] in
            guard let self else { return }
            for await snapshot in locationProvider.snapshots {
                await self.ingest(snapshot)
            }
        }
        authorizationTask = Task { [weak self] in
            guard let self else { return }
            for await problem in locationProvider.authorizationProblems {
                await self.updateAuthorization(problem)
            }
        }
    }

    /// Beder kilden holde op med at måle. Strømmen forbliver åben.
    ///
    /// Bruges, når appen lægges i baggrunden — ikke når en skærm forsvinder.
    func pauseLocationUpdates() {
        locationProvider.stop()
    }

    func requestLocationAuthorization() {
        locationProvider.requestAuthorization()
    }

    func requestFullAccuracy() {
        locationProvider.requestTemporaryFullAccuracy(purposeKey: "MissionUnlock")
    }

    private func ingest(_ snapshot: LocationSnapshot, now: Date = Date()) async {
        // Kortet skal kunne vise spilleren, også når ingen mission er i gang.
        currentLocation = snapshot.point

        guard gate != nil else { return }
        let wasVerified = presence.isVerified
        presence = gate!.ingest(snapshot, now: now)
        await recordVerificationIfNeeded(wasVerified: wasVerified, now: now)
    }

    private func updateAuthorization(_ problem: AuthorizationProblem?) async {
        authorizationProblem = problem
        guard gate != nil else { return }
        presence = gate!.update(authorization: problem)
    }

    /// Afstanden fra spilleren til en missions standpunkt, når begge er kendt.
    func distanceMetres(to mission: Mission) -> Double? {
        guard let here = currentLocation,
              let location = location(for: mission),
              let configuration = PresenceGate.Configuration(location: location)
        else { return nil }
        return GeoMath.distanceMetres(from: here, to: configuration.centre)
    }

    /// Om "Start opgave" må trykkes fra dér, hvor spilleren står (princip I).
    func startability(for mission: Mission) -> MissionStartability {
        MissionStartRule.evaluate(
            isCompleted: blocksReplay && isCompleted(mission),
            distanceMetres: distanceMetres(to: mission),
            activationRadiusMetres: location(for: mission)?.activationRadiusMetres
        )
    }

    /// Standpunktet for en mission, hvis indholdet kender det.
    func vantagePoint(for mission: Mission) -> GeoPoint? {
        guard let location = location(for: mission),
              let configuration = PresenceGate.Configuration(location: location)
        else { return nil }
        return configuration.centre
    }

    #if BH_DEV_TOOLS
    /// Den simulerede kilde, hvis appen kører på den. `nil` betyder rigtig GPS.
    var simulatedLocationProvider: ScriptedLocationProvider? {
        locationProvider as? ScriptedLocationProvider
    }
    #endif

    /// Spilleren bekræfter selv efter for lang tid uden fix (FR-027).
    func acceptSoftOverride(now: Date = Date()) async {
        guard gate != nil else { return }
        let wasVerified = presence.isVerified
        presence = gate!.acceptSoftOverride(now: now)
        await recordVerificationIfNeeded(wasVerified: wasVerified, now: now)
    }

    private func recordVerificationIfNeeded(wasVerified: Bool, now: Date) async {
        guard !wasVerified, case .verified(let evidence) = presence,
              let missionId = session?.missionId
        else { return }
        session?.presenceEvidence = evidence
        await record(.presenceVerified, missionId: missionId, presence: evidence, now: now)
    }

    // MARK: - Trin

    func step(withId id: String, in mission: Mission) -> Step? {
        mission.orderedSteps.first { $0.id == id }
    }

    func nextStep(after step: Step, in mission: Mission) -> Step? {
        let ordered = mission.orderedSteps
        guard let index = ordered.firstIndex(where: { $0.id == step.id }) else { return nil }
        // Ukendte trin springes over frem for at vise en tom skærm (FR-003).
        return ordered[(index + 1)...].first { $0.kind != "unknown" && !isUnknown($0) }
    }

    private func isUnknown(_ step: Step) -> Bool {
        if case .unknown = step { return true }
        return false
    }

    func viewStep(_ step: Step, in mission: Mission, now: Date = Date()) async {
        session?.currentStepId = step.id
        lastOutcome = nil
        await record(.stepViewed, missionId: mission.id, stepId: step.id, now: now)
    }

    // MARK: - Svar

    @discardableResult
    func submit(_ input: String, for step: Step, in mission: Mission, now: Date = Date()) async -> AnswerOutcome {
        let outcome = evaluator.evaluate(input, step: step)
        lastOutcome = outcome

        // Et ufærdigt svar er ikke et forsøg og logges ikke (FR-014).
        guard outcome.countsAsAttempt else { return outcome }

        var payload = GameEventPayload(
            missionId: mission.id,
            stepId: step.id,
            answer: input,
            outcome: outcome.logLabel
        )
        if case .nearMiss(let id, _) = outcome { payload.nearMissId = id }
        await record(.answerSubmitted, payload: payload, now: now)

        return outcome
    }

    // MARK: - Hints

    /// De hints, **trinnet** tilbyder. Afgør, om hint-knappen overhovedet vises.
    func hints(for step: Step, in mission: Mission) -> [Hint] {
        step.hintIds.compactMap { mission.hint(id: $0) }.sorted { $0.order < $1.order }
    }

    /// De hints, **arket** viser: hele missionens stige.
    ///
    /// Ikke kun trinnets egne. Rækkefølgen er en missionsregel — hint 2 kræver
    /// hint 1 — og et trin, der kun tilbyder hint 2, ville ellers være en
    /// blindgyde: spilleren kunne se det låste hint uden at kunne åbne det, der
    /// spærrer.
    func missionHints(in mission: Mission) -> [Hint] {
        mission.orderedHints
    }

    func isRevealed(_ hint: Hint) -> Bool {
        revealedHintIds.contains(hint.id)
    }

    /// Om hintet må åbnes nu (hint 2 kræver hint 1).
    func isUnlocked(_ hint: Hint, in mission: Mission) -> Bool {
        HintRule.isUnlocked(hint, in: mission.orderedHints, revealed: revealedHintIds)
    }

    /// Hvilket hint der spærrer — til beskeden på skærmen.
    func blockingHint(for hint: Hint, in mission: Mission) -> Hint? {
        HintRule.blocking(hint, in: mission.orderedHints, revealed: revealedHintIds)
    }

    /// Fradraget, spilleren får at vide **før** hintet åbnes (FR-018).
    func penalty(for hint: Hint, in mission: Mission) -> Int {
        ScoreLedger.penalty(base: mission.basePoints, percent: hint.penaltyPercent)
    }

    func reveal(_ hint: Hint, in mission: Mission, now: Date = Date()) async {
        // Rækkefølgen håndhæves her og ikke kun i knappens `disabled`.
        // En regel, der kun findes i et view, holder kun så længe alle veje
        // til handlingen går gennem netop dét view.
        guard isUnlocked(hint, in: mission) else { return }

        // Genåbning koster ikke igen (FR-019).
        guard revealedHintIds.insert(hint.id).inserted else { return }
        await record(.hintUsed, missionId: mission.id, hintId: hint.id, now: now)
    }

    // MARK: - Afslutning

    func complete(_ mission: Mission, now: Date = Date()) async {
        guard !playerState.completedMissionIds.contains(mission.id) else { return }
        await record(.missionCompleted, missionId: mission.id, now: now)
    }

    /// Pointopdelingen, belønningsskærmen viser (FR-020).
    func transactions(for mission: Mission) -> [ScoreTransaction] {
        playerState.transactions(forMission: mission.id)
    }

    func points(for mission: Mission) -> Int {
        playerState.points(forMission: mission.id)
    }

    // MARK: - Hændelseslog

    private func record(
        _ kind: GameEventKind,
        missionId: String,
        stepId: String? = nil,
        hintId: String? = nil,
        presence: PresenceEvidence? = nil,
        now: Date
    ) async {
        await record(
            kind,
            payload: GameEventPayload(
                missionId: missionId,
                stepId: stepId,
                hintId: hintId,
                presence: presence
            ),
            now: now
        )
    }

    private func record(_ kind: GameEventKind, payload: GameEventPayload, now: Date) async {
        guard let pack else { return }
        do {
            let event = GameEvent(
                sequence: try await eventStore.nextSequence(),
                occurredAt: now,
                contentVersion: session?.contentVersion ?? pack.contentVersion,
                kind: .known(kind),
                payload: payload
            )
            try await eventStore.append(event)
            playerState = StateProjection.fold(try await eventStore.allEvents(), pack: pack)
        } catch {
            // En fejlet skrivning må aldrig afbryde turen. Spilleren er ude ved
            // en havnekant — tilstanden i hukommelsen er stadig gyldig, og
            // loggen samles op ved næste hændelse.
        }
    }
}

extension AnswerOutcome {
    /// Kort etiket til hændelsesloggen.
    var logLabel: String {
        switch self {
        case .correct: "correct"
        case .nearMiss: "nearMiss"
        case .incorrect: "incorrect"
        case .malformed: "malformed"
        }
    }

    /// Vejledningen, spilleren skal se.
    var feedback: String? {
        switch self {
        case .correct: nil
        case .nearMiss(_, let feedback): feedback
        case .incorrect(let feedback): feedback
        case .malformed(let reason): reason.message
        }
    }
}
