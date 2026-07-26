import Foundation

// Indholdsmodellen — den udgivne kontrakt (data-model.md, del 1).
//
// Typerne her *er* API-DTO'erne (research.md R-003). Der findes ingen separat
// domænemodel at mappe til, og feltnavnene er derfor wire-navne: en omdøbning
// er en API-ændring, ikke en refaktorering. GoldenTests håndhæver det.
//
// Alt er immutable. Adfærd bor i BHGameCore.

/// Rodobjektet. Én pakke pr. sprog.
public struct ContentPack: Codable, Hashable, Sendable {
    public let schemaVersion: String
    /// Den version en ``GameSession`` bindes til ved start (FR-035).
    public let contentVersion: String
    public let locale: String
    public let areas: [Area]
    public let locations: [Location]
    public let missions: [Mission]
    public let media: [MediaAsset]
    public let sources: [Source]

    public init(
        schemaVersion: String,
        contentVersion: String,
        locale: String,
        areas: [Area],
        locations: [Location],
        missions: [Mission],
        media: [MediaAsset],
        sources: [Source]
    ) {
        self.schemaVersion = schemaVersion
        self.contentVersion = contentVersion
        self.locale = locale
        self.areas = areas
        self.locations = locations
        self.missions = missions
        self.media = media
        self.sources = sources
    }
}

public struct Area: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    /// Spejler mappestrukturen i `docs/design af opgaver/opgaver/`.
    public let postalCode: String

    public init(id: String, name: String, postalCode: String) {
        self.id = id
        self.name = name
        self.postalCode = postalCode
    }
}

/// Stedet. Bærer alt, der gør forfatningens princip I og IV håndhævelige.
public struct Location: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let areaId: String
    public let name: String
    public let address: String
    /// Foreløbig i feature 001. `nil` er tilladt, men blokerer `publishReady` (V-10).
    public let latitude: Double?
    public let longitude: Double?
    public let activationRadiusMetres: Double?
    /// Skal være `<= activationRadiusMetres` (V-08).
    public let maxAcceptableAccuracyMetres: Double?
    /// Hvor længe spilleren skal opholde sig. Forhindrer at en forbipasserende
    /// låser op (FR-025, SC-010).
    public let dwellSeconds: Double
    public let accuracyProfile: Tolerant<AccuracyProfile>
    /// Spillerens standpunkt — ikke bygningen. Dette er gate-centrum (R-007).
    public let vantagePoint: VantagePoint?
    public let publicAccess: Bool
    public let safety: Safety
    public let accessibility: Accessibility
    public let fieldVerified: Bool
    public let lastPhysicallyVerified: String?

    public init(
        id: String,
        areaId: String,
        name: String,
        address: String,
        latitude: Double?,
        longitude: Double?,
        activationRadiusMetres: Double?,
        maxAcceptableAccuracyMetres: Double?,
        dwellSeconds: Double,
        accuracyProfile: Tolerant<AccuracyProfile>,
        vantagePoint: VantagePoint?,
        publicAccess: Bool,
        safety: Safety,
        accessibility: Accessibility,
        fieldVerified: Bool,
        lastPhysicallyVerified: String?
    ) {
        self.id = id
        self.areaId = areaId
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.activationRadiusMetres = activationRadiusMetres
        self.maxAcceptableAccuracyMetres = maxAcceptableAccuracyMetres
        self.dwellSeconds = dwellSeconds
        self.accuracyProfile = accuracyProfile
        self.vantagePoint = vantagePoint
        self.publicAccess = publicAccess
        self.safety = safety
        self.accessibility = accessibility
        self.fieldVerified = fieldVerified
        self.lastPhysicallyVerified = lastPhysicallyVerified
    }
}

/// Begge lokationer i feature 001 er `urbanCanyon` — høje konstruktioner ved vand.
public enum AccuracyProfile: String, TolerantEnum {
    case standard
    case urbanCanyon
}

/// Spillerens standpunkt.
public struct VantagePoint: Codable, Hashable, Sendable {
    public let latitude: Double?
    public let longitude: Double?
    /// Kigretning. Blødt hint til retningspilen — aldrig en gate (R-007).
    public let bearingDegrees: Double?
    public let instruction: String

    public init(latitude: Double?, longitude: Double?, bearingDegrees: Double?, instruction: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.bearingDegrees = bearingDegrees
        self.instruction = instruction
    }
}

public struct Safety: Codable, Hashable, Sendable {
    public let flags: [Tolerant<SafetyFlag>]
    /// Dansk tekst vist på missionsark og approach-skærm (FR-006).
    public let notes: String

    public init(flags: [Tolerant<SafetyFlag>], notes: String) {
        self.flags = flags
        self.notes = notes
    }
}

public enum SafetyFlag: String, TolerantEnum {
    case traffic
    case water
    case steepSlope
    case darkness
    case privateProperty
    case cyclePath
    case construction
    case crowding
}

public struct Accessibility: Codable, Hashable, Sendable {
    public let surface: String
    public let incline: String
    public let steps: Bool
    public let wheelchair: Tolerant<AccessLevel>
    public let stroller: Tolerant<AccessLevel>
    public let distanceFromAccessMetres: Double?
    public let notes: String

    public init(
        surface: String,
        incline: String,
        steps: Bool,
        wheelchair: Tolerant<AccessLevel>,
        stroller: Tolerant<AccessLevel>,
        distanceFromAccessMetres: Double?,
        notes: String
    ) {
        self.surface = surface
        self.incline = incline
        self.steps = steps
        self.wheelchair = wheelchair
        self.stroller = stroller
        self.distanceFromAccessMetres = distanceFromAccessMetres
        self.notes = notes
    }
}

public enum AccessLevel: String, TolerantEnum {
    case yes
    case partial
    case no
    case unknown
}

// MARK: - Opslag

extension ContentPack {
    public func area(id: String) -> Area? { areas.first { $0.id == id } }
    public func location(id: String) -> Location? { locations.first { $0.id == id } }
    public func mission(id: String) -> Mission? { missions.first { $0.id == id } }
    public func media(id: String) -> MediaAsset? { media.first { $0.id == id } }
    public func source(id: String) -> Source? { sources.first { $0.id == id } }
}
