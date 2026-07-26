#if BH_DEV_TOOLS

import BHGameCore
import Foundation

/// Simuleret position, styrbar mens appen kører.
///
/// ## Findes ikke i en udgivelsesbygning
///
/// Hele filen ligger bag `BH_DEV_TOOLS`, som kun sættes i Debug — både på
/// app-targetet og på dette SPM-target. FR-051 kræver, at udviklerværktøjer
/// ikke kan nå en udgivelse, og den eneste garanti, der holder, er at koden
/// ikke bliver oversat.
///
/// ## Hvorfor tidsstemplerne er ægte
///
/// Fixene stemples med den rigtige `Date()`. `PresenceGate` kasserer fixes,
/// der er mere end 15 sekunder gamle, så et komprimeret ur ville få gaten til
/// at afvise sine egne simulerede fixes. Konsekvensen er, at dwell tager lige
/// så lang tid som i felten — hvilket også er dét, der gør simuleringen værd
/// at stole på.
@MainActor
public final class ScriptedLocationProvider: LocationProviding {

    /// Hvor hurtigt den simulerede spiller bevæger sig.
    public enum Pace: Sendable, CaseIterable {
        case standingStill
        case walking
        case running

        public var metresPerSecond: Double {
            switch self {
            case .standingStill: 0
            case .walking: 1.4
            case .running: 4.0
            }
        }

        public var danishName: String {
            switch self {
            case .standingStill: "Står stille"
            case .walking: "Går"
            case .running: "Løber"
            }
        }
    }

    private var snapshotContinuation: AsyncStream<LocationSnapshot>.Continuation?
    private var authorizationContinuation: AsyncStream<AuthorizationProblem?>.Continuation?
    private var playback: Task<Void, Never>?

    public let snapshots: AsyncStream<LocationSnapshot>
    public let authorizationProblems: AsyncStream<AuthorizationProblem?>

    /// Hvor den simulerede spiller står lige nu.
    public private(set) var currentPoint: GeoPoint
    public private(set) var accuracyMetres: Double
    public private(set) var isMoving = false

    public init(
        start: GeoPoint = GeoPoint(latitude: 55.7100, longitude: 9.5400),
        accuracyMetres: Double = 8
    ) {
        currentPoint = start
        self.accuracyMetres = accuracyMetres

        var snapshotContinuation: AsyncStream<LocationSnapshot>.Continuation!
        snapshots = AsyncStream { snapshotContinuation = $0 }
        var authorizationContinuation: AsyncStream<AuthorizationProblem?>.Continuation!
        authorizationProblems = AsyncStream { authorizationContinuation = $0 }

        self.snapshotContinuation = snapshotContinuation
        self.authorizationContinuation = authorizationContinuation
    }

    /// Bygger en provider ud fra launch-argumenter, hvis de er sat.
    ///
    /// `-BHSimulatedLocation <lat>,<lon>[,<accuracy>]`
    public static func fromLaunchArguments(
        _ arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> ScriptedLocationProvider? {
        guard let index = arguments.firstIndex(of: "-BHSimulatedLocation"),
              arguments.count > index + 1
        else { return nil }

        let parts = arguments[index + 1].split(separator: ",").map(String.init)
        guard parts.count >= 2,
              let latitude = Double(parts[0]),
              let longitude = Double(parts[1])
        else { return nil }

        return ScriptedLocationProvider(
            start: GeoPoint(latitude: latitude, longitude: longitude),
            accuracyMetres: parts.count > 2 ? (Double(parts[2]) ?? 8) : 8
        )
    }

    // MARK: - Styring

    /// Flytter spilleren øjeblikkeligt. Bruges til at komme hen i nærheden,
    /// ikke til at snyde gaten — dwell skal stadig optjenes.
    public func teleport(to point: GeoPoint) {
        playback?.cancel()
        playback = nil
        isMoving = false
        currentPoint = point
        emit()
        startStandingStill()
    }

    /// Går fra den nuværende position til `destination` og bliver stående.
    public func walk(to destination: GeoPoint, pace: Pace = .walking) {
        playback?.cancel()
        guard pace.metresPerSecond > 0 else {
            currentPoint = destination
            startStandingStill()
            return
        }

        let origin = currentPoint
        let distance = GeoMath.distanceMetres(from: origin, to: destination)
        let duration = distance / pace.metresPerSecond
        isMoving = true

        playback = Task { [weak self] in
            let tick = 1.0
            var elapsed = 0.0
            while elapsed < duration {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .seconds(tick))
                elapsed += tick
                guard let self else { return }
                let fraction = min(1, elapsed / duration)
                self.currentPoint = Self.interpolate(from: origin, to: destination, fraction: fraction)
                self.emit()
            }
            guard let self else { return }
            self.isMoving = false
            self.startStandingStill()
        }
    }

    /// Går **forbi** punktet uden at standse.
    ///
    /// Det er scenariet bag SC-010: en forbipasserende må aldrig låse en opgave
    /// op. Ruten går 120 m før punktet til 120 m efter det.
    public func walkPast(_ point: GeoPoint, pace: Pace = .walking) {
        let before = Self.offset(point, northMetres: -120)
        let after = Self.offset(point, northMetres: 120)
        teleport(to: before)
        walk(to: after, pace: pace)
    }

    /// Sætter den simulerede nøjagtighed, så dårligt signal kan afprøves.
    public func setAccuracy(_ metres: Double) {
        accuracyMetres = metres
        emit()
    }

    // MARK: - LocationProviding

    public func requestAuthorization() {
        authorizationContinuation?.yield(nil)
    }

    public func requestTemporaryFullAccuracy(purposeKey: String) {
        authorizationContinuation?.yield(nil)
    }

    public func start() {
        authorizationContinuation?.yield(nil)
        guard playback == nil else { return }
        emit()
        startStandingStill()
    }

    public func stop() {
        playback?.cancel()
        playback = nil
        isMoving = false
    }

    // MARK: - Udsendelse

    /// Et fix i sekundet, også når spilleren står stille. Uden dem optjener
    /// ``PresenceGate`` ingen dwell-kredit — præcis som en rigtig telefon, der
    /// holder op med at melde ind.
    private func startStandingStill() {
        playback?.cancel()
        playback = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                self.emit()
            }
        }
    }

    private func emit() {
        snapshotContinuation?.yield(
            LocationSnapshot(
                point: currentPoint,
                horizontalAccuracyMetres: accuracyMetres,
                timestamp: Date(),
                isSimulatedBySoftware: true
            )
        )
    }

    // MARK: - Geometri

    static func interpolate(from origin: GeoPoint, to destination: GeoPoint, fraction: Double) -> GeoPoint {
        GeoPoint(
            latitude: origin.latitude + (destination.latitude - origin.latitude) * fraction,
            longitude: origin.longitude + (destination.longitude - origin.longitude) * fraction
        )
    }

    /// Flytter et punkt nord/syd. Bruges af udviklerpanelet til at placere
    /// spilleren et stykke fra standpunktet.
    public static func offset(_ point: GeoPoint, northMetres: Double) -> GeoPoint {
        GeoPoint(latitude: point.latitude + northMetres / 111_320, longitude: point.longitude)
    }
}

#endif
