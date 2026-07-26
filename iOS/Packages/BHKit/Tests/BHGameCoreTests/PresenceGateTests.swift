import BHContracts
import Foundation
import Testing

@testable import BHGameCore

/// Alle scenarier køres med **injiceret ur og nul GPS**. Gaten kalder aldrig
/// `Date()` internt, og det er dét, der gør disse tests deterministiske frem
/// for flaky (research.md R-007).
@Suite("Tilstedeværelse")
struct PresenceGateTests {

    /// Standpunktet. Alle afstande i testene måles herfra.
    static let centre = GeoPoint(latitude: 55.7089, longitude: 9.5481)
    static let epoch = Date(timeIntervalSince1970: 1_800_000_000)

    static func configuration(
        dwellSeconds: Double = 20,
        profile: AccuracyProfile = .urbanCanyon,
        radius: Double = 45,
        maxAccuracy: Double = 40
    ) -> PresenceGate.Configuration {
        PresenceGate.Configuration(
            centre: centre,
            activationRadiusMetres: radius,
            maxAcceptableAccuracyMetres: maxAccuracy,
            dwellSeconds: dwellSeconds,
            accuracyProfile: profile,
            bearingDegrees: 118
        )
    }

    /// Flytter et punkt et antal meter mod nord. 1 breddegrad ≈ 111 320 m.
    static func offset(_ point: GeoPoint, northMetres: Double) -> GeoPoint {
        GeoPoint(
            latitude: point.latitude + northMetres / 111_320,
            longitude: point.longitude
        )
    }

    static func snapshot(
        at point: GeoPoint,
        accuracy: Double = 8,
        secondsAfterEpoch: Double,
        simulated: Bool = false
    ) -> LocationSnapshot {
        LocationSnapshot(
            point: point,
            horizontalAccuracyMetres: accuracy,
            timestamp: epoch.addingTimeInterval(secondsAfterEpoch),
            isSimulatedBySoftware: simulated
        )
    }

    // MARK: - Grundtilstande

    @Test("Uden fixes er gaten i tomgang")
    func startsIdle() {
        let gate = PresenceGate(configuration: Self.configuration())
        #expect(gate.state == .idle)
    }

    @Test("Manglende tilladelse vises frem for at blive stiltiende ignoreret")
    func authorizationProblemSurfaces() {
        var gate = PresenceGate(configuration: Self.configuration())
        let state = gate.update(authorization: .restricted)
        #expect(state == .authorizationNeeded(.restricted))
    }

    @Test("Langt væk giver tooFar med retning")
    func farAwayReportsDistanceAndBearing() {
        var gate = PresenceGate(configuration: Self.configuration())
        let far = Self.offset(Self.centre, northMetres: 800)
        let state = gate.ingest(Self.snapshot(at: far, secondsAfterEpoch: 0), now: Self.epoch)

        guard case .tooFar(let distance, let bearing) = state else {
            Issue.record("Forventede tooFar, fik \(state)")
            return
        }
        #expect(distance > 700)
        #expect(bearing != nil)
    }

    @Test("Tæt på, men uden for radius, giver approaching")
    func nearbyReportsApproaching() {
        var gate = PresenceGate(configuration: Self.configuration())
        let nearby = Self.offset(Self.centre, northMetres: 90)
        let state = gate.ingest(Self.snapshot(at: nearby, secondsAfterEpoch: 0), now: Self.epoch)

        guard case .approaching = state else {
            Issue.record("Forventede approaching, fik \(state)")
            return
        }
    }

    @Test("At stå stille på stedet verificerer")
    func standingStillVerifies() {
        var gate = PresenceGate(configuration: Self.configuration(dwellSeconds: 10))
        var state: PresenceState = .idle

        for second in stride(from: 0.0, through: 30.0, by: 1.0) {
            state = gate.ingest(
                Self.snapshot(at: Self.centre, secondsAfterEpoch: second),
                now: Self.epoch.addingTimeInterval(second)
            )
            if state.isVerified { break }
        }

        guard case .verified(let evidence) = state else {
            Issue.record("Forventede verified, fik \(state)")
            return
        }
        #expect(evidence.method == .known(.gps))
        #expect(evidence.dwellSeconds >= 10)
    }

    // MARK: - Hygiejne

    /// CoreLocations første callback er ofte timer gammelt.
    @Test("Et forældet første fix afvises")
    func staleFirstFixIsRejected() {
        var gate = PresenceGate(configuration: Self.configuration())
        // Fixet er tidsstemplet en time før `now`.
        let stale = Self.snapshot(at: Self.centre, secondsAfterEpoch: -3600)
        let state = gate.ingest(stale, now: Self.epoch)

        #expect(state == .acquiring, "Et timer gammelt fix må ikke tælle som ankomst")
        #expect(state.isVerified == false)
    }

    @Test("Negativ nøjagtighed afvises")
    func negativeAccuracyIsRejected() {
        var gate = PresenceGate(configuration: Self.configuration())
        let broken = Self.snapshot(at: Self.centre, accuracy: -1, secondsAfterEpoch: 0)
        #expect(gate.ingest(broken, now: Self.epoch).isVerified == false)
    }

    @Test("Et teleporterende fix afvises")
    func teleportIsRejected() {
        var gate = PresenceGate(configuration: Self.configuration(dwellSeconds: 5))
        gate.ingest(Self.snapshot(at: Self.centre, secondsAfterEpoch: 0), now: Self.epoch)

        // 5 km på ét sekund er ikke en person.
        let teleported = Self.snapshot(
            at: Self.offset(Self.centre, northMetres: 5000),
            secondsAfterEpoch: 1
        )
        let state = gate.ingest(teleported, now: Self.epoch.addingTimeInterval(1))
        #expect(state.isVerified == false)
    }

    /// FR-026: dårlig præcision giver et bredere vindue, ikke en afvisning.
    @Test("60 m præcision 10 m fra centrum akkumulerer stadig")
    func poorAccuracyWidensTheWindowInsteadOfRejecting() {
        var gate = PresenceGate(configuration: Self.configuration(dwellSeconds: 20))
        let nearCentre = Self.offset(Self.centre, northMetres: 10)

        var state: PresenceState = .idle
        for second in stride(from: 0.0, through: 6.0, by: 1.0) {
            state = gate.ingest(
                Self.snapshot(at: nearCentre, accuracy: 60, secondsAfterEpoch: second),
                now: Self.epoch.addingTimeInterval(second)
            )
        }

        guard case .dwelling = state else {
            Issue.record("Forventede dwelling trods 60 m præcision, fik \(state)")
            return
        }
    }

    /// Den mest demoraliserende fejltilstand der findes, må ikke kunne opstå.
    @Test("Ét dårligt fix trækker fra, men nulstiller aldrig")
    func oneBadFixDecaysButNeverResets() {
        var gate = PresenceGate(configuration: Self.configuration(dwellSeconds: 30))

        // Byg kredit op.
        for second in stride(from: 0.0, through: 10.0, by: 1.0) {
            gate.ingest(
                Self.snapshot(at: Self.centre, secondsAfterEpoch: second),
                now: Self.epoch.addingTimeInterval(second)
            )
        }
        guard case .dwelling(let before, _) = gate.state else {
            Issue.record("Forventede dwelling, fik \(gate.state)")
            return
        }
        #expect(before > 5)

        // Ét ubrugeligt fix.
        let bad = Self.snapshot(at: Self.centre, accuracy: 500, secondsAfterEpoch: 11)
        gate.ingest(bad, now: Self.epoch.addingTimeInterval(11))

        // Næste gode fix skal vise en kredit, der er lidt lavere — ikke nul.
        let state = gate.ingest(
            Self.snapshot(at: Self.centre, secondsAfterEpoch: 12),
            now: Self.epoch.addingTimeInterval(12)
        )
        guard case .dwelling(let after, _) = state else {
            Issue.record("Forventede dwelling, fik \(state)")
            return
        }
        #expect(after > 0, "Krediten må aldrig nulstilles af ét dårligt fix")
        #expect(after < before + 2, "Krediten skal være trukket fra")
    }

    // MARK: - SC-010

    /// Den forbipasserende. Går forbi standpunktet i normalt gangtempo og
    /// standser aldrig.
    @Test("En spiller, der går forbi uden at standse, låser aldrig op")
    func walkingPastNeverVerifies() {
        var gate = PresenceGate(configuration: Self.configuration(dwellSeconds: 20))
        var state: PresenceState = .idle

        // 1,4 m/s fra 120 m syd for standpunktet til 120 m nord for det.
        for second in stride(from: 0.0, through: 170.0, by: 1.0) {
            let metresNorth = -120 + 1.4 * second
            state = gate.ingest(
                Self.snapshot(
                    at: Self.offset(Self.centre, northMetres: metresNorth),
                    secondsAfterEpoch: second
                ),
                now: Self.epoch.addingTimeInterval(second)
            )
            #expect(state.isVerified == false, "Låste op efter \(second) s — SC-010 er brudt")
        }
        #expect(state.isVerified == false)
    }

    // MARK: - Soft override og simulering

    @Test("Soft override tilbydes efter for lang tid uden bekræftelse")
    func softOverrideIsOfferedEventually() {
        var gate = PresenceGate(configuration: Self.configuration())
        let far = Self.offset(Self.centre, northMetres: 400)

        var state: PresenceState = .idle
        for second in stride(from: 0.0, through: 200.0, by: 10.0) {
            state = gate.ingest(
                Self.snapshot(at: far, secondsAfterEpoch: second),
                now: Self.epoch.addingTimeInterval(second)
            )
            if case .softOverrideOffered = state { break }
        }

        guard case .softOverrideOffered = state else {
            Issue.record("Forventede softOverrideOffered, fik \(state)")
            return
        }
    }

    @Test("Soft override verificerer og stempler metoden")
    func acceptingSoftOverrideStamps() {
        var gate = PresenceGate(configuration: Self.configuration())
        let state = gate.acceptSoftOverride(now: Self.epoch)

        guard case .verified(let evidence) = state else {
            Issue.record("Forventede verified, fik \(state)")
            return
        }
        #expect(evidence.method == .known(.softOverride))
    }

    /// FR-028: simuleret position blokerer ikke — den stempler.
    @Test("Simuleret position verificerer stadig, men stemples")
    func simulatedLocationStillVerifies() {
        var gate = PresenceGate(configuration: Self.configuration(dwellSeconds: 5))
        var state: PresenceState = .idle

        for second in stride(from: 0.0, through: 20.0, by: 1.0) {
            state = gate.ingest(
                Self.snapshot(at: Self.centre, secondsAfterEpoch: second, simulated: true),
                now: Self.epoch.addingTimeInterval(second)
            )
            if state.isVerified { break }
        }

        guard case .verified(let evidence) = state else {
            Issue.record("Forventede verified, fik \(state)")
            return
        }
        #expect(evidence.method == .known(.simulated), "Simuleret position skal registreres")
    }

    // MARK: - Konfiguration fra indhold

    @Test("En lokation uden koordinater kan ikke konfigurere en gate")
    func locationWithoutCoordinatesYieldsNoConfiguration() {
        let location = Location(
            id: "loc.test",
            areaId: "area.test",
            name: "Uden koordinat",
            address: "—",
            latitude: nil,
            longitude: nil,
            activationRadiusMetres: nil,
            maxAcceptableAccuracyMetres: nil,
            dwellSeconds: 20,
            accuracyProfile: .known(.standard),
            vantagePoint: nil,
            publicAccess: true,
            safety: Safety(flags: [], notes: "—"),
            accessibility: Accessibility(
                surface: "—", incline: "—", steps: false,
                wheelchair: .known(.unknown), stroller: .known(.unknown),
                distanceFromAccessMetres: nil, notes: "—"
            ),
            fieldVerified: false,
            lastPhysicallyVerified: nil
        )
        #expect(PresenceGate.Configuration(location: location) == nil)
    }
}
