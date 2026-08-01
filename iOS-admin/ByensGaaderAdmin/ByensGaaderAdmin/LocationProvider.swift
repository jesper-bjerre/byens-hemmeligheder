import CoreLocation
import Foundation

/// Quizmasterens nuværende position — én aflæsning ad gangen (FR-107).
///
/// Der lyttes ikke løbende. Knappen trykkes, mens hen står på stedet, og et
/// abonnement, der bliver ved, ville tømme batteriet på en dag i felten uden
/// at gøre koordinatet en meter bedre.
@Observable
final class LocationProvider: NSObject, CLLocationManagerDelegate {

    private(set) var coordinate: CLLocationCoordinate2D?
    /// Vandret usikkerhed i meter. Vises, fordi et koordinat med 65 meters
    /// usikkerhed ikke må skrives ind i en opgave med 45 meters aktiveringsradius.
    private(set) var accuracyMetres: CLLocationAccuracy?
    private(set) var isLocating = false
    private(set) var failure: String?

    /// Tælles op ved hver færdig aflæsning. Kaldstedet lytter på den og ikke på
    /// koordinatet: to aflæsninger på det samme sted giver den samme værdi, og
    /// så ville anden gang se ud som ingen ændring.
    private(set) var fixCount = 0

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestOnce() {
        failure = nil
        coordinate = nil
        accuracyMetres = nil
        isLocating = true

        switch manager.authorizationStatus {
        case .notDetermined:
            // Aflæsningen fortsætter i `locationManagerDidChangeAuthorization`.
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isLocating = false
            failure = "Appen har ikke adgang til din position. Slå den til under Indstillinger."
        default:
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isLocating else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isLocating = false
            failure = "Appen har ikke adgang til din position. Slå den til under Indstillinger."
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinate = location.coordinate
        accuracyMetres = location.horizontalAccuracy
        isLocating = false
        fixCount += 1
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        isLocating = false
        failure = error.localizedDescription
    }
}
