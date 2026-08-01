import BHContracts
import Foundation

/// Ét positionsfix, renset for CoreLocation.
public struct LocationSnapshot: Hashable, Sendable {
    public let point: GeoPoint
    public let horizontalAccuracyMetres: Double
    public let timestamp: Date
    /// Fra `CLLocation.sourceInformation`. Blokerer aldrig — stempler kun (FR-028).
    public let isSimulatedBySoftware: Bool

    public init(
        point: GeoPoint,
        horizontalAccuracyMetres: Double,
        timestamp: Date,
        isSimulatedBySoftware: Bool = false
    ) {
        self.point = point
        self.horizontalAccuracyMetres = horizontalAccuracyMetres
        self.timestamp = timestamp
        self.isSimulatedBySoftware = isSimulatedBySoftware
    }
}

/// Hvorfor positionen ikke er tilgængelig. Hver værdi skal have en dansk
/// besked og mindst én handling — ingen af dem må være en blindgyde (US3).
public enum AuthorizationProblem: Hashable, Sendable {
    case notDetermined
    case denied
    /// Skærmtid kan blokere Location Services på et barns telefon. Den oftest
    /// glemte af de fem udfald (FR-030).
    case restricted
    case reducedAccuracy
    case servicesDisabled
}

/// Tilstandsmaskinens udfald.
public enum PresenceState: Hashable, Sendable {
    case idle
    case authorizationNeeded(AuthorizationProblem)
    case acquiring
    case tooFar(distanceMetres: Double, bearingDegrees: Double?)
    case approaching(distanceMetres: Double, bearingDegrees: Double?)
    case accuracyInsufficient(accuracyMetres: Double, requiredMetres: Double)
    case dwelling(creditSeconds: Double, requiredSeconds: Double)
    /// Tilbudt efter for lang tid uden bekræftelse (FR-027).
    case softOverrideOffered(waitedSeconds: Double)
    case verified(PresenceEvidence)

    public var isVerified: Bool {
        if case .verified = self { return true }
        return false
    }
}

/// Afgør, om spilleren står på stedet.
///
/// ## Detektér, stempl, blokér aldrig
///
/// Gaten er en **ren struct**. Tid kommer udelukkende fra fixenes egne
/// tidsstempler og et injiceret `now` — aldrig fra `Date()` internt. Det gør
/// den deterministisk i test, og det holder appen ude af
/// `SystemBootTime`-kategorien i privacy-manifestet (R-007).
///
/// ## De fem mitigeringer mod GPS-drift
///
/// Bølgen og Fjordenhus er begge høje konstruktioner ved vand, hvor multipath
/// er en reel risiko. Modtrækkene, i rækkefølge efter hvor meget de er værd:
///
/// 1. **Standpunktet er gate-centrum, ikke bygningen.** Ligger 30–80 m fra
///    facaden, hvor gåden kan løses og himlen er fri. Dette er værd mere end
///    al filtrering tilsammen — og det er indholdets ansvar, ikke kodens.
/// 2. **Usikkerhedsbevidst afstand.** Dårlig præcision giver et *bredere*
///    accept-vindue frem for en afvisning (FR-026).
/// 3. **Robust konsensus-centrum.** Median over de seneste fixes. Multipath-
///    jitter er højfrekvent, og en median dræber den.
/// 4. **Dwell som henfaldende kredit.** Et dårligt fix trækker fra, men
///    nulstiller aldrig. "Næsten verificeret, ét dårligt fix, start forfra" er
///    den mest demoraliserende fejltilstand, der findes.
/// 5. **`accuracyProfile` pr. lokation**, felttunet i indhold.
public struct PresenceGate: Sendable {

    // MARK: - Konfiguration

    public struct Configuration: Hashable, Sendable {
        /// Gate-centrum. Standpunktet, ikke bygningen.
        public let centre: GeoPoint
        public let activationRadiusMetres: Double
        public let maxAcceptableAccuracyMetres: Double
        public let dwellSeconds: Double
        public let accuracyProfile: AccuracyProfile

        public init(
            centre: GeoPoint,
            activationRadiusMetres: Double,
            maxAcceptableAccuracyMetres: Double,
            dwellSeconds: Double,
            accuracyProfile: AccuracyProfile
        ) {
            self.centre = centre
            self.activationRadiusMetres = activationRadiusMetres
            self.maxAcceptableAccuracyMetres = maxAcceptableAccuracyMetres
            self.dwellSeconds = dwellSeconds
            self.accuracyProfile = accuracyProfile
        }

        /// Bygger konfigurationen ud fra indholdet. Returnerer `nil`, hvis
        /// lokationen mangler koordinater — hvilket den gør i hele feature 001,
        /// indtil felten er besøgt (V-10).
        public init?(location: Location) {
            guard let latitude = location.latitude, let longitude = location.longitude else {
                return nil
            }
            let centre = GeoPoint(latitude: latitude, longitude: longitude)

            guard let radius = location.activationRadiusMetres,
                  let maxAccuracy = location.maxAcceptableAccuracyMetres
            else { return nil }

            self.init(
                centre: centre,
                activationRadiusMetres: radius,
                maxAcceptableAccuracyMetres: maxAccuracy,
                dwellSeconds: location.dwellSeconds,
                accuracyProfile: location.accuracyProfile.known ?? .standard
            )
        }
    }

    /// Tal, der skal kunne justeres mod optagne feltspor i increment 003 uden
    /// at røre logikken.
    public struct Tuning: Hashable, Sendable {
        /// Ældre fixes kasseres. CoreLocations første callback er ofte timer
        /// gammelt — den klassiske stale-cached-first-fix-bug.
        public var maxFixAgeSeconds: Double = 15
        public var maxUsableAccuracyMetres: Double = 100
        public var consensusWindowSeconds: Double = 30
        public var consensusSampleCount: Int = 10
        /// Loft pr. fix, så en enkelt lang pause mellem fixes ikke giver gratis dwell.
        public var dwellCreditCapPerFixSeconds: Double = 2
        public var dwellDebitPerRejectedFixSeconds: Double = 1
        /// Over denne hastighed er spilleren på vej forbi, ikke på stedet.
        /// Dette er dét, der gør SC-010 sandt: en forbipasserende låser ikke op,
        /// uanset hvor stor aktiveringsradius indholdet vælger.
        public var maxDwellSpeedMetresPerSecond: Double = 1.0
        /// Hurtigere end dette er ikke en person. Fixet kasseres.
        public var teleportSpeedMetresPerSecond: Double = 60
        public var softOverrideAfterSeconds: Double = 90

        public init() {}

        public static func forProfile(_ profile: AccuracyProfile) -> Tuning {
            var tuning = Tuning()
            if profile == .urbanCanyon {
                // Høje konstruktioner ved vand. Tål mere jitter, vent lidt
                // længere før soft override, og accepter et bredere vindue.
                tuning.maxUsableAccuracyMetres = 120
                tuning.consensusSampleCount = 12
                tuning.softOverrideAfterSeconds = 120
            }
            return tuning
        }
    }

    // MARK: - Tilstand

    public let configuration: Configuration
    public let tuning: Tuning

    private var window: [LocationSnapshot] = []
    private var dwellCredit: Double = 0
    private var lastAcceptedTimestamp: Date?
    private var lastAcceptedPoint: GeoPoint?
    private var firstIngestAt: Date?
    private var sawSimulatedFix = false
    private var verifiedWithLowConfidence = false
    private var authorizationProblem: AuthorizationProblem?

    public private(set) var state: PresenceState = .idle

    public init(configuration: Configuration, tuning: Tuning? = nil) {
        self.configuration = configuration
        self.tuning = tuning ?? .forProfile(configuration.accuracyProfile)
    }

    // MARK: - Input

    /// Autorisationstilstanden fra CoreLocation. `nil` betyder "i orden".
    public mutating func update(authorization problem: AuthorizationProblem?) -> PresenceState {
        authorizationProblem = problem
        if let problem, !state.isVerified {
            state = .authorizationNeeded(problem)
        }
        return state
    }

    /// Optager ét fix og returnerer den nye tilstand.
    ///
    /// - Parameter now: injiceret ur. Bruges udelukkende til at afgøre, om
    ///   fixet er forældet, og hvornår soft override skal tilbydes.
    @discardableResult
    public mutating func ingest(_ snapshot: LocationSnapshot, now: Date) -> PresenceState {
        // En verificeret gate åbner ikke igen. Spilleren må gerne gå væk fra
        // stedet, mens opgaven løses.
        guard !state.isVerified else { return state }

        if firstIngestAt == nil { firstIngestAt = now }
        if snapshot.isSimulatedBySoftware { sawSimulatedFix = true }

        guard authorizationProblem == nil else {
            state = .authorizationNeeded(authorizationProblem!)
            return state
        }

        switch hygiene(of: snapshot, now: now) {
        case .reject(let reason):
            // Henfald, ikke nulstilling. Gulv ved 0.
            dwellCredit = max(0, dwellCredit - tuning.dwellDebitPerRejectedFixSeconds)
            state = stateAfterRejection(reason, now: now)
            return state

        case .accept:
            break
        }

        record(snapshot)
        state = evaluate(snapshot, now: now)
        return state
    }

    /// Spilleren bekræftede selv. Verificerer med ``PresenceMethod/softOverride``.
    @discardableResult
    public mutating func acceptSoftOverride(now: Date) -> PresenceState {
        state = .verified(
            PresenceEvidence(
                method: .known(sawSimulatedFix ? .simulated : .softOverride),
                accuracyMetres: window.last?.horizontalAccuracyMetres,
                dwellSeconds: dwellCredit,
                verifiedAt: now
            )
        )
        return state
    }

    // MARK: - Hygiejne

    private enum Hygiene {
        case accept
        case reject(RejectionReason)
    }

    enum RejectionReason: Hashable {
        case negativeAccuracy
        case accuracyTooPoor(Double)
        case stale(ageSeconds: Double)
        case teleport(speedMetresPerSecond: Double)
    }

    private func hygiene(of snapshot: LocationSnapshot, now: Date) -> Hygiene {
        let accuracy = snapshot.horizontalAccuracyMetres
        if accuracy < 0 { return .reject(.negativeAccuracy) }
        if accuracy > tuning.maxUsableAccuracyMetres { return .reject(.accuracyTooPoor(accuracy)) }

        let age = abs(snapshot.timestamp.timeIntervalSince(now))
        if age > tuning.maxFixAgeSeconds { return .reject(.stale(ageSeconds: age)) }

        if let lastPoint = lastAcceptedPoint, let lastTime = lastAcceptedTimestamp {
            let interval = snapshot.timestamp.timeIntervalSince(lastTime)
            if interval > 0 {
                let speed = GeoMath.distanceMetres(from: lastPoint, to: snapshot.point) / interval
                if speed > tuning.teleportSpeedMetresPerSecond {
                    return .reject(.teleport(speedMetresPerSecond: speed))
                }
            }
        }
        return .accept
    }

    private func stateAfterRejection(_ reason: RejectionReason, now: Date) -> PresenceState {
        if let offer = softOverrideStateIfDue(now: now) { return offer }
        switch reason {
        case .accuracyTooPoor(let accuracy):
            return .accuracyInsufficient(
                accuracyMetres: accuracy,
                requiredMetres: configuration.maxAcceptableAccuracyMetres
            )
        case .negativeAccuracy, .stale, .teleport:
            // Der er endnu ikke noget troværdigt at vise. `acquiring` er
            // sandheden, ikke en undskyldning.
            return window.isEmpty ? .acquiring : state
        }
    }

    // MARK: - Vindue og konsensus

    private mutating func record(_ snapshot: LocationSnapshot) {
        window.append(snapshot)
        let cutoff = snapshot.timestamp.addingTimeInterval(-tuning.consensusWindowSeconds)
        window.removeAll { $0.timestamp < cutoff }
        if window.count > tuning.consensusSampleCount {
            window.removeFirst(window.count - tuning.consensusSampleCount)
        }
    }

    /// Konsensus-centrum: komponentvis median over vinduet.
    var consensusCentre: GeoPoint? {
        GeoMath.componentwiseMedian(of: window.map(\.point))
    }

    /// Repræsentativ præcision: medianen, ikke det bedste fix. Vis aldrig
    /// større præcision, end målingerne bærer.
    var consensusAccuracyMetres: Double? {
        guard !window.isEmpty else { return nil }
        return GeoMath.median(of: window.map(\.horizontalAccuracyMetres))
    }

    /// Hastighed over vinduet. Grundlaget for at skelne "står her" fra "går forbi".
    var windowSpeedMetresPerSecond: Double? {
        guard let first = window.first, let last = window.last else { return nil }
        let interval = last.timestamp.timeIntervalSince(first.timestamp)
        guard interval > 0 else { return nil }
        return GeoMath.distanceMetres(from: first.point, to: last.point) / interval
    }

    // MARK: - Bedømmelse

    private mutating func evaluate(_ snapshot: LocationSnapshot, now: Date) -> PresenceState {
        defer {
            lastAcceptedTimestamp = snapshot.timestamp
            lastAcceptedPoint = snapshot.point
        }

        guard let centre = consensusCentre, let accuracy = consensusAccuracyMetres else {
            return .acquiring
        }

        let distance = GeoMath.distanceMetres(from: centre, to: configuration.centre)
        // Regnes altid ud af de to punkter. Indholdet bar tidligere en fast
        // kigretning, men den kunne stå og pege forkert, længe efter at
        // koordinatet var rettet.
        let bearing = GeoMath.bearingDegrees(from: centre, to: configuration.centre)

        // Usikkerhedsbevidst afstand (FR-026). Dårlig præcision gør vinduet
        // bredere, ikke smallere.
        let optimistic = max(0, distance - accuracy)
        let pessimistic = distance + accuracy
        let radius = configuration.activationRadiusMetres

        // Uden for selv i bedste fald: spilleren er ikke her.
        if optimistic > radius {
            if let offer = softOverrideStateIfDue(now: now) { return offer }
            let displayDistance = max(distance, accuracy)
            return optimistic > radius * 3
                ? .tooFar(distanceMetres: displayDistance, bearingDegrees: bearing)
                : .approaching(distanceMetres: displayDistance, bearingDegrees: bearing)
        }

        // Muligvis inde. Utvetydigt inde (`pessimistic <= radius`) tæller
        // altid; ellers kræves enten acceptabel præcision eller en
        // urbanCanyon-profil, hvor jitter er forventet.
        let unambiguouslyInside = pessimistic <= radius
        let accuracyAcceptable = accuracy <= configuration.maxAcceptableAccuracyMetres
        let lowConfidence = !unambiguouslyInside && !accuracyAcceptable

        if lowConfidence && configuration.accuracyProfile != .urbanCanyon {
            if let offer = softOverrideStateIfDue(now: now) { return offer }
            return .accuracyInsufficient(
                accuracyMetres: accuracy,
                requiredMetres: configuration.maxAcceptableAccuracyMetres
            )
        }
        if lowConfidence { verifiedWithLowConfidence = true }

        // Går spilleren forbi, akkumuleres der ikke. Krediten nulstilles dog
        // ikke — vender personen om og bliver stående, fortsætter den.
        let transiting = (windowSpeedMetresPerSecond ?? 0) > tuning.maxDwellSpeedMetresPerSecond
        if !transiting, let previous = lastAcceptedTimestamp {
            let delta = snapshot.timestamp.timeIntervalSince(previous)
            if delta > 0 {
                dwellCredit += min(delta, tuning.dwellCreditCapPerFixSeconds)
            }
        }

        if dwellCredit >= configuration.dwellSeconds {
            let method: PresenceMethod =
                sawSimulatedFix ? .simulated
                : verifiedWithLowConfidence ? .gpsLowConfidence
                : .gps
            return .verified(
                PresenceEvidence(
                    method: .known(method),
                    accuracyMetres: accuracy,
                    dwellSeconds: dwellCredit,
                    verifiedAt: now
                )
            )
        }

        return .dwelling(creditSeconds: dwellCredit, requiredSeconds: configuration.dwellSeconds)
    }

    /// Soft override tilbydes, når spilleren har prøvet længe nok uden at nå
    /// frem. Ingen tilstand må være en blindgyde (FR-027, US3).
    private func softOverrideStateIfDue(now: Date) -> PresenceState? {
        guard let start = firstIngestAt else { return nil }
        let waited = now.timeIntervalSince(start)
        guard waited >= tuning.softOverrideAfterSeconds else { return nil }
        return .softOverrideOffered(waitedSeconds: waited)
    }
}
