import BHGameCore
import CoreLocation
import Foundation

/// Det eneste sted i projektet, der importerer CoreLocation.
///
/// ## Kun `whenInUse`
///
/// Intet `NSLocationAlwaysAndWhenInUse`, intet `UIBackgroundModes: location`.
/// Appen har ingen grund til at kende spillerens position, når den ikke er
/// åben, og forfatningens princip VI gør det til et krav frem for en
/// præference.
///
/// ## Alle fem autorisationsudfald
///
/// Inklusive `.restricted`, som Skærmtid kan sætte på et barns telefon. Det er
/// målgruppens telefon, så det er ikke et hjørnetilfælde (FR-030).
@MainActor
public final class CoreLocationProvider: NSObject, LocationProviding {

    private let manager: CLLocationManager

    private var snapshotContinuation: AsyncStream<LocationSnapshot>.Continuation?
    private var authorizationContinuation: AsyncStream<AuthorizationProblem?>.Continuation?

    public let snapshots: AsyncStream<LocationSnapshot>
    public let authorizationProblems: AsyncStream<AuthorizationProblem?>

    public init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager

        var snapshotContinuation: AsyncStream<LocationSnapshot>.Continuation!
        snapshots = AsyncStream { snapshotContinuation = $0 }
        var authorizationContinuation: AsyncStream<AuthorizationProblem?>.Continuation!
        authorizationProblems = AsyncStream { authorizationContinuation = $0 }

        super.init()

        self.snapshotContinuation = snapshotContinuation
        self.authorizationContinuation = authorizationContinuation

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // Vi vil have hvert fix. Filtreringen hører hjemme i PresenceGate, hvor
        // den er testbar, ikke i CoreLocations udistancerede heuristik.
        manager.distanceFilter = kCLDistanceFilterNone
    }

    // MARK: - LocationProviding

    public func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func requestTemporaryFullAccuracy(purposeKey: String) {
        #if os(iOS)
        guard manager.accuracyAuthorization == .reducedAccuracy else { return }
        manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey) { [weak self] _ in
            guard let self else { return }
            MainActor.assumeIsolated { self.emitAuthorizationState() }
        }
        #endif
    }

    public func start() {
        emitAuthorizationState()
        manager.startUpdatingLocation()
    }

    public func stop() {
        manager.stopUpdatingLocation()
    }

    // MARK: - Autorisation

    private func emitAuthorizationState() {
        authorizationContinuation?.yield(Self.problem(for: manager))
    }

    /// Afbildningen fra CoreLocation til noget, US3 kan vise en handling for.
    static func problem(for manager: CLLocationManager) -> AuthorizationProblem? {
        switch manager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            // `denied` dækker både "brugeren sagde nej" og "Location Services
            // er slået fra på hele enheden". De kræver hver sin vejledning.
            return CLLocationManager.locationServicesEnabled() ? .denied : .servicesDisabled
        case .authorizedWhenInUse, .authorizedAlways:
            #if os(iOS)
            if manager.accuracyAuthorization == .reducedAccuracy { return .reducedAccuracy }
            #endif
            return nil
        @unknown default:
            // En fremtidig værdi må ikke give en blindgyde. `notDetermined`
            // fører til en primer og en prompt — den mindst skadelige antagelse.
            return .notDetermined
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CoreLocationProvider: CLLocationManagerDelegate {

    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated { emitAuthorizationState() }
    }

    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let snapshots = locations.map(Self.snapshot(from:))
        MainActor.assumeIsolated {
            for snapshot in snapshots {
                snapshotContinuation?.yield(snapshot)
            }
        }
    }

    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        // Et enkelt fejlet fix er normalt og skal ikke ændre tilstanden.
        // PresenceGate viser `acquiring`, indtil noget brugbart kommer ind.
        guard (error as? CLError)?.code == .denied else { return }
        MainActor.assumeIsolated { emitAuthorizationState() }
    }

    /// Oversætter ét `CLLocation` til gate-lagets ``LocationSnapshot``.
    ///
    /// `isSimulatedBySoftware` fanger Xcode, Simulator, GPX og
    /// desktopværktøjer. Den fanger **ikke** jailbreak-tweaks eller
    /// RF-spoofere — og det er den ærlige begrænsning, politikken hviler på
    /// (R-007). Verifikationen lykkes stadig; flaget registreres kun (FR-028).
    nonisolated static func snapshot(from location: CLLocation) -> LocationSnapshot {
        var simulated = false
        if let source = location.sourceInformation {
            simulated = source.isSimulatedBySoftware
        }
        return LocationSnapshot(
            point: GeoPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ),
            horizontalAccuracyMetres: location.horizontalAccuracy,
            timestamp: location.timestamp,
            isSimulatedBySoftware: simulated
        )
    }
}
