import BHGameCore
import Foundation

/// Kilden til positionsfixes.
///
/// Protokollen findes, så ``PresenceGate`` kan fodres af CoreLocation i drift
/// og af et manuskript under test, uden at gaten kender forskel.
@MainActor
public protocol LocationProviding: AnyObject {
    /// Positionsfixes, renset for CoreLocation.
    var snapshots: AsyncStream<LocationSnapshot> { get }
    /// `nil` betyder "i orden". Alt andet skal vises med en handling (US3).
    var authorizationProblems: AsyncStream<AuthorizationProblem?> { get }

    /// Beder om tilladelse. Kaldes umiddelbart efter spillets egen primer,
    /// aldrig ved opstart (FR-030).
    func requestAuthorization()
    /// Kun relevant ved `.reducedAccuracy`.
    func requestTemporaryFullAccuracy(purposeKey: String)
    func start()
    func stop()
}
