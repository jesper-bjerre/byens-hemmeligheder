import BHGameCore
import Foundation
import Observation

/// Én positionskilde, der kan skifte mellem rigtig GPS og et manuskript.
///
/// ## Hvorfor der er brug for den
///
/// Simuleret position lå før i simulatoren alene. En quizmaster, der skal
/// prøve en opgave igennem, måtte derfor enten gå derhen fysisk eller undvære.
/// Begge dele gør det dyrt at afprøve en rettelse.
///
/// ## Hvorfor begge kilder forbruges hele tiden
///
/// `AsyncStream` kan forbruges **én gang**. Begge underliggende kilder opretter
/// deres strøm i `init` og holder på sin continuation — annulleres forbrugeren,
/// er strømmen død for altid. Det kostede allerede én fejl i dette projekt:
/// positionen holdt op med at virke, anden gang en opgave blev åbnet.
///
/// Derfor lytter denne type på **begge** kilder fra begyndelsen og videresender
/// kun fra den aktive. Der skiftes ikke forbruger; der skiftes filter. Prisen er,
/// at CoreLocation kører videre, mens der simuleres — og den er lille, fordi
/// ``stop()`` kaldes på den inaktive kilde.
///
/// ## Hvorfor valget ikke er et launch-argument
///
/// Launch-argumenter er input udefra og bliver i Debug (FR-051). Dette er en
/// knap, quizmasteren selv trykker på, og valget huskes mellem opstarter.
@MainActor
@Observable
public final class SwitchableLocationProvider: LocationProviding {

    public let snapshots: AsyncStream<LocationSnapshot>
    public let authorizationProblems: AsyncStream<AuthorizationProblem?>

    private let real: any LocationProviding
    /// Manuskriptet. Altid til stede, så panelet kan styre det uden at vente på
    /// et skift.
    public let scripted: ScriptedLocationProvider

    private var snapshotContinuation: AsyncStream<LocationSnapshot>.Continuation!
    private var authorizationContinuation: AsyncStream<AuthorizationProblem?>.Continuation!
    private var forwarding: [Task<Void, Never>] = []

    private static let preferenceKey = "bh.location.simulated"
    private let defaults: UserDefaults

    /// Den senest sete rigtige position. Bruges til at sætte manuskriptet dér,
    /// hvor quizmasteren faktisk står, når simuleringen slås til.
    private var lastRealPoint: GeoPoint?

    public private(set) var isSimulating: Bool

    public init(
        real: any LocationProviding,
        scripted: ScriptedLocationProvider,
        defaults: UserDefaults = .standard,
        defaultsToSimulation: Bool
    ) {
        self.real = real
        self.scripted = scripted
        self.defaults = defaults
        self.isSimulating = defaults.object(forKey: Self.preferenceKey) as? Bool ?? defaultsToSimulation

        var snapshotContinuation: AsyncStream<LocationSnapshot>.Continuation!
        snapshots = AsyncStream { snapshotContinuation = $0 }
        var authorizationContinuation: AsyncStream<AuthorizationProblem?>.Continuation!
        authorizationProblems = AsyncStream { authorizationContinuation = $0 }
        self.snapshotContinuation = snapshotContinuation
        self.authorizationContinuation = authorizationContinuation

        forward()
    }

    /// Lytter på begge kilder resten af appens levetid.
    private func forward() {
        forwarding.append(Task { [weak self] in
            guard let self else { return }
            for await snapshot in real.snapshots {
                lastRealPoint = snapshot.point
                if !isSimulating { snapshotContinuation.yield(snapshot) }
            }
        })
        forwarding.append(Task { [weak self] in
            guard let self else { return }
            for await snapshot in scripted.snapshots where isSimulating {
                snapshotContinuation.yield(snapshot)
            }
        })
        forwarding.append(Task { [weak self] in
            guard let self else { return }
            for await problem in real.authorizationProblems {
                // Tilladelsesproblemer kommer altid fra den rigtige kilde. Et
                // manuskript har ingen tilladelse at mangle, og at skjule
                // problemet under simulering ville gøre det usynligt, indtil
                // quizmasteren slog simuleringen fra igen.
                authorizationContinuation.yield(problem)
            }
        })
    }

    // MARK: - Skiftet

    public func setSimulating(_ simulating: Bool) {
        guard simulating != isSimulating else { return }
        isSimulating = simulating
        defaults.set(simulating, forKey: Self.preferenceKey)

        if simulating {
            // Begynd dér, hvor quizmasteren står. Uden det springer kortet til
            // et fast punkt i Vejle, og man har mistet sin egen position.
            if let lastRealPoint { scripted.teleport(to: lastRealPoint) }
            real.stop()
            scripted.start()
        } else {
            scripted.stop()
            real.start()
        }
    }

    // MARK: - LocationProviding

    public func requestAuthorization() { real.requestAuthorization() }

    public func requestTemporaryFullAccuracy(purposeKey: String) {
        real.requestTemporaryFullAccuracy(purposeKey: purposeKey)
    }

    public func start() {
        isSimulating ? scripted.start() : real.start()
    }

    public func stop() {
        isSimulating ? scripted.stop() : real.stop()
    }
}
