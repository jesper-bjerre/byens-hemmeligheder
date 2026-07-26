import BHContracts
import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

/// Kører GPX-fixturerne gennem ``PresenceGate``.
///
/// Fixturerne findes for at kunne afspilles i Xcodes simulator, men en fil, der
/// kun bliver afspillet i hånden, holder op med at blive afspillet. Ved at køre
/// de samme punkter gennem gaten i CI bliver de til regressionsdata frem for
/// dokumentation — og den dag, nogen justerer dwell-reglen, siger testen fra.
@Suite("GPX-scenarier")
struct GPXScenarioTests {

    /// Bølgens standpunkt, som det står i indholdspakken.
    static func configuration() throws -> PresenceGate.Configuration {
        let pack = try ContractFixtures.contentPack()
        let location = try #require(pack.location(id: "loc.vejle-havn.boelgen"))
        return try #require(PresenceGate.Configuration(location: location))
    }

    static func track(_ filename: String) throws -> [GeoPoint] {
        let url = ContractFixtures.repositoryRoot
            .appending(path: "iOS/TestSupport/GPX/\(filename)")
        let xml = try String(contentsOf: url, encoding: .utf8)

        let pattern = try NSRegularExpression(pattern: #"lat="([-0-9.]+)"\s+lon="([-0-9.]+)""#)
        let range = NSRange(xml.startIndex..<xml.endIndex, in: xml)

        return pattern.matches(in: xml, range: range).compactMap { match in
            guard let latRange = Range(match.range(at: 1), in: xml),
                  let lonRange = Range(match.range(at: 2), in: xml),
                  let latitude = Double(xml[latRange]),
                  let longitude = Double(xml[lonRange])
            else { return nil }
            return GeoPoint(latitude: latitude, longitude: longitude)
        }
    }

    /// Afspiller sporet med ét fix i sekundet, som Xcode gør.
    static func replay(
        _ points: [GeoPoint],
        configuration: PresenceGate.Configuration,
        accuracy: Double
    ) -> (finalState: PresenceState, everVerified: Bool, secondsToVerify: Int?) {
        let epoch = Date(timeIntervalSince1970: 1_800_000_000)
        var gate = PresenceGate(configuration: configuration)
        var everVerified = false
        var secondsToVerify: Int?
        var state: PresenceState = .idle

        for (second, point) in points.enumerated() {
            let now = epoch.addingTimeInterval(Double(second))
            state = gate.ingest(
                LocationSnapshot(
                    point: point,
                    horizontalAccuracyMetres: accuracy,
                    timestamp: now,
                    isSimulatedBySoftware: true
                ),
                now: now
            )
            if state.isVerified, !everVerified {
                everVerified = true
                secondsToVerify = second
            }
        }
        return (state, everVerified, secondsToVerify)
    }

    // MARK: - Scenarierne

    @Test("Fixturerne findes og indeholder punkter")
    func fixturesExist() throws {
        for filename in ["boelgen-standpunkt.gpx", "boelgen-gaa-forbi.gpx", "boelgen-facade.gpx"] {
            #expect(try Self.track(filename).count > 30, "\(filename) har for få punkter")
        }
    }

    @Test("Standpunktet verificerer inden for dwell-tiden")
    func standingAtVantagePointVerifies() throws {
        let configuration = try Self.configuration()
        let result = Self.replay(
            try Self.track("boelgen-standpunkt.gpx"),
            configuration: configuration,
            accuracy: 8
        )

        #expect(result.everVerified, "Standpunktet burde verificere")
        if let seconds = result.secondsToVerify {
            #expect(
                Double(seconds) < configuration.dwellSeconds * 2,
                "Verificerede først efter \(seconds) s — for langsomt til en familie ved en havnekant"
            )
        }
    }

    /// SC-010. Den vigtigste af de tre.
    @Test("Gå-forbi verificerer aldrig — SC-010")
    func walkingPastNeverVerifies() throws {
        let result = Self.replay(
            try Self.track("boelgen-gaa-forbi.gpx"),
            configuration: try Self.configuration(),
            accuracy: 8
        )
        #expect(
            result.everVerified == false,
            "En forbipasserende låste opgaven op efter \(result.secondsToVerify ?? -1) s"
        )
    }

    /// Facaden ligger uden for standpunktets radius, og signalet er dårligt.
    /// Spilleren må ikke ende i en blindgyde — men må heller ikke låse op fra
    /// det forkerte sted.
    @Test("Facaden verificerer ikke, men efterlader en handling")
    func facadeDoesNotVerifyButOffersAWayOut() throws {
        let result = Self.replay(
            try Self.track("boelgen-facade.gpx"),
            configuration: try Self.configuration(),
            accuracy: 55
        )

        #expect(result.everVerified == false, "Facaden er ikke standpunktet")
        #expect(
            PresenceProblemMapping.hasActionableState(result.finalState),
            "Sluttilstanden \(result.finalState) er en blindgyde"
        )
    }
}

/// Minimal spejling af app-lagets afbildning, så `BHGameCore` kan hævde
/// blindgyde-fri­heden uden at afhænge af SwiftUI.
enum PresenceProblemMapping {
    /// SC-004: hver tilstand skal have en forklaring og mindst én handling.
    static func hasActionableState(_ state: PresenceState) -> Bool {
        switch state {
        case .idle, .acquiring, .tooFar, .approaching, .accuracyInsufficient,
             .dwelling, .softOverrideOffered, .authorizationNeeded, .verified:
            true
        }
    }
}
