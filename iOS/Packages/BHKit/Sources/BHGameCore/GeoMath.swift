import Foundation

/// Et punkt på jorden. Bevidst ikke `CLLocationCoordinate2D` — `BHGameCore` må
/// ikke importere Apple-frameworks, så logikken kan testes uden simulator og
/// senere genimplementeres server-side (research.md R-002).
public struct GeoPoint: Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Afstand og pejling.
///
/// Haversine er rigeligt her. Afstandene er tiere af meter, og
/// aktiveringsradius er i forvejen et felttunet skøn — forskellen på Haversine
/// og Vincenty er langt under GPS-usikkerheden.
public enum GeoMath {

    /// Jordens middelradius i meter.
    static let earthRadiusMetres = 6_371_008.8

    public static func distanceMetres(from origin: GeoPoint, to destination: GeoPoint) -> Double {
        let φ1 = origin.latitude.degreesToRadians
        let φ2 = destination.latitude.degreesToRadians
        let Δφ = (destination.latitude - origin.latitude).degreesToRadians
        let Δλ = (destination.longitude - origin.longitude).degreesToRadians

        let a = sin(Δφ / 2) * sin(Δφ / 2)
            + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
        let c = 2 * atan2(sqrt(a), sqrt(max(0, 1 - a)))
        return earthRadiusMetres * c
    }

    /// Indledende pejling i grader, 0 = nord, med uret. Altid i `0..<360`.
    ///
    /// Bruges til retningspilen. **Aldrig som gate** — og aldrig fra kompasset,
    /// som kræver kalibrering og er upålideligt nær stål og store
    /// konstruktioner (R-007).
    public static func bearingDegrees(from origin: GeoPoint, to destination: GeoPoint) -> Double {
        let φ1 = origin.latitude.degreesToRadians
        let φ2 = destination.latitude.degreesToRadians
        let Δλ = (destination.longitude - origin.longitude).degreesToRadians

        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
        let degrees = atan2(y, x).radiansToDegrees
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }

    /// Komponentvis median. Grundlaget for det robuste konsensus-centrum:
    /// multipath-jitter er højfrekvent, og en median dræber den, hvor et
    /// gennemsnit blot flytter sig med udfaldet (R-007, mitigering 3).
    public static func componentwiseMedian(of points: [GeoPoint]) -> GeoPoint? {
        guard !points.isEmpty else { return nil }
        return GeoPoint(
            latitude: median(of: points.map(\.latitude)),
            longitude: median(of: points.map(\.longitude))
        )
    }

    static func median(of values: [Double]) -> Double {
        precondition(!values.isEmpty)
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
