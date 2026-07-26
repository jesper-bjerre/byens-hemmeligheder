import Foundation

/// En enum, der kan bæres af ``Tolerant``.
///
/// Kravet er kun, at værdien har en `String`-repræsentation på wire-formatet.
public protocol TolerantEnum: RawRepresentable, Hashable, Sendable, CaseIterable
where RawValue == String {}

/// Wrapper der gør en enum ukendt-tolerant på wire-formatet (FR-003).
///
/// Kontraktreglen tillader kun additive ændringer. Når serveren en dag sender
/// `"kind": "compass"` til en app, der blev bygget før den værdi fandtes, må
/// afkodningen ikke kaste — så ville ét nyt felt mure hele indholdspakken for
/// alle, der ikke har opdateret. I stedet lander værdien i ``unknown(_:)``, og
/// kaldstedet vælger selv, hvordan den degraderes.
///
/// Det er derfor `BHContracts` aldrig indeholder en bar `String`-raw enum
/// (research.md R-003).
public enum Tolerant<Known: TolerantEnum>: Hashable, Sendable {
    case known(Known)
    case unknown(String)

    public init(rawValue: String) {
        if let known = Known(rawValue: rawValue) {
            self = .known(known)
        } else {
            self = .unknown(rawValue)
        }
    }

    /// Wire-værdien. Ukendte værdier bevares uændret, så en round-trip ikke
    /// taber information.
    public var rawValue: String {
        switch self {
        case .known(let value): value.rawValue
        case .unknown(let raw): raw
        }
    }

    /// Den kendte værdi, eller `nil` hvis pakken bruger en nyere kontrakt end
    /// denne app kender.
    public var known: Known? {
        switch self {
        case .known(let value): value
        case .unknown: nil
        }
    }

    public var isKnown: Bool { known != nil }
}

extension Tolerant: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Tolerant: CustomStringConvertible {
    public var description: String { rawValue }
}
