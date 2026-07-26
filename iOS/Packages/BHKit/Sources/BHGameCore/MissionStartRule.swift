import BHContracts
import Foundation

/// Om en opgave kan startes fra dér, hvor spilleren står.
public enum MissionStartability: Hashable, Sendable {
    /// Spilleren er ved stedet. Opgaven kan begynde.
    case ready
    /// Spilleren er for langt væk.
    case tooFar(metresRemaining: Double)
    /// Positionen kendes endnu ikke.
    case locationUnknown
    /// Lokationen har ingen koordinater, så der er intet at måle mod.
    ///
    /// Gælder hele feature 001, indtil felten er besøgt (V-10). Opgaven kan
    /// startes — spilleren skal ikke straffes for, at opmålingen mangler, og
    /// tilstedeværelsen stemples som ``PresenceMethod/demo``.
    case notGated

    public var canStart: Bool {
        switch self {
        case .ready, .notGated: true
        case .tooFar, .locationUnknown: false
        }
    }
}

/// Afgør, om "Start opgave" må trykkes.
///
/// ## Hvorfor reglen er sin egen type
///
/// Forfatningens princip I siger, at stedet *er* spillet. Knappen skal derfor
/// være lukket hjemmefra — men reglen må ikke bo i en `View`, hvor den kun kan
/// efterprøves ved at køre appen. Her er den en ren funktion med testvektorer.
///
/// ## Forholdet til `PresenceGate`
///
/// Denne regel er **grovere** end gaten og har et andet formål. Den svarer på
/// "er spilleren i nærheden nok til at gå i gang?", mens ``PresenceGate``
/// bagefter afgør "står spilleren faktisk stille på standpunktet?" med dwell,
/// nøjagtighed og medianfiltrering. Reglen her må derfor aldrig være strengere
/// end gaten: ellers ville knappen være lukket et sted, hvor gaten ville have
/// åbnet, og spilleren ville stå og undre sig.
public enum MissionStartRule {

    /// Hvor meget længere ude end aktiveringsradius knappen stadig åbner.
    ///
    /// Gaten arbejder usikkerhedsbevidst: står spilleren på standpunktet med
    /// 40 m nøjagtighed, kan den målte afstand sagtens være 30 m. Uden en
    /// margen her ville knappen være lukket i præcis den situation, gaten er
    /// bygget til at acceptere (FR-026).
    public static let slack = 1.5

    public static func evaluate(
        distanceMetres: Double?,
        activationRadiusMetres: Double?
    ) -> MissionStartability {
        guard let activationRadiusMetres else { return .notGated }
        guard let distanceMetres else { return .locationUnknown }

        let limit = activationRadiusMetres * slack
        if distanceMetres <= limit { return .ready }
        return .tooFar(metresRemaining: distanceMetres - limit)
    }
}
