import BHContracts
import Foundation

/// Den ene form, **alle** opgaver har.
///
/// ## Hvorfor formen er en type og ikke en aftale
///
/// Opgaverne divergerede stille og roligt. Bølgen og Fjordenhus fik fem trin
/// med en kæde af delspørgsmål; Frydenlund-opgaverne fik to. Hvert nyt mønster
/// trak sit eget layout med sig, og resultatet var, at en opgave med
/// svarmuligheder slet ikke viste noget billede, mens en med kode viste tre
/// bevis-kort. Ingen havde besluttet det — det opstod.
///
/// Formen er derfor skrevet ned og efterprøves maskinelt. En opgave er:
///
/// 1. ét fortællende trin, der sætter stemningen
/// 2. ét spørgsmål med ét svar
///
/// Intet andet. Det, der skiller opgaverne, er **data** — teksten, billederne,
/// svaret — aldrig strukturen og aldrig skærmbilledet.
///
/// ## Hvorfor det betyder noget nu
///
/// Al logik og indhold ligger i appen, indtil quizmasterne har prøvet en
/// TestFlight-version. Først derefter flyttes det til en server. Netop derfor
/// skal formen ligge fast **inden** der er indhold nok til, at en ændring gør
/// ondt: en server, der skal levere fire forskellige opgaveformer, er et andet
/// og meget større stykke arbejde end en, der leverer én.
public enum MissionShape {

    /// Antallet af svarmuligheder i et multiple choice-spørgsmål.
    ///
    /// Fast, fordi layoutet er fast. Fire knapper fylder ens på enhver skærm og
    /// ved enhver tekststørrelse; fem eller tre ville kræve, at UI'et tilpassede
    /// sig indholdet — og så er vi tilbage ved, at opgaverne ser forskellige ud.
    public static let choiceCount = 4

    /// Antallet af hints. Uændret fra FR-017.
    public static let hintCount = 3

    public enum Violation: Hashable, Sendable, CustomStringConvertible {
        case noNarrativeStep
        case wrongStepCount(Int)
        case noChallengeStep
        case multipleChallengeSteps(Int)
        case unknownStepKind(String)
        case wrongChoiceCount(stepId: String, count: Int)
        case wrongHintCount(Int)
        /// Stemningsbilledet skal være mærket som AI-genereret, og
        /// stedbilledet må ikke være det.
        case misclassifiedMedia(mediaId: String, expected: String)

        public var description: String {
            switch self {
            case .noNarrativeStep:
                "mangler et fortællende trin"
            case .wrongStepCount(let count):
                "har \(count) trin — formen er præcis 2: fortælling og spørgsmål"
            case .noChallengeStep:
                "har intet spørgsmål at svare på"
            case .multipleChallengeSteps(let count):
                "har \(count) spørgsmål — formen er præcis 1"
            case .unknownStepKind(let kind):
                "har et trin af typen '\(kind)', som appen ikke kender"
            case .wrongChoiceCount(let stepId, let count):
                "trinnet '\(stepId)' har \(count) svarmuligheder — formen er \(choiceCount)"
            case .wrongHintCount(let count):
                "har \(count) hints — formen er \(hintCount)"
            case .misclassifiedMedia(let mediaId, let expected):
                "mediet '\(mediaId)' skulle være \(expected)"
            }
        }
    }

    /// Efterprøver én opgave. Tom liste betyder, at formen holder.
    ///
    /// - Parameter media: opslag fra medie-id til aktiv. Uden det kan
    ///   mærkningen af billederne ikke kontrolleres, og den del springes over.
    public static func violations(
        of mission: Mission,
        media: [String: MediaAsset] = [:]
    ) -> [Violation] {
        var found: [Violation] = []

        let steps = mission.orderedSteps
        if steps.count != 2 {
            found.append(.wrongStepCount(steps.count))
        }

        if !steps.contains(where: { if case .narrative = $0 { true } else { false } }) {
            found.append(.noNarrativeStep)
        }

        let challenges = steps.filter { $0.answerRule != nil }
        switch challenges.count {
        case 0: found.append(.noChallengeStep)
        case 1: break
        default: found.append(.multipleChallengeSteps(challenges.count))
        }

        for step in steps {
            if case .unknown(let unknown) = step {
                found.append(.unknownStepKind(unknown.kind))
            }
            if case .singleChoice(let choice) = step, choice.options.count != choiceCount {
                found.append(.wrongChoiceCount(stepId: choice.id, count: choice.options.count))
            }
        }

        if mission.hints.count != hintCount {
            found.append(.wrongHintCount(mission.hints.count))
        }

        // Stedbilledet er et orienteringsmiddel. Er det AI-genereret, kan det
        // vise noget, der ikke findes — og så leder spilleren efter et påhit.
        //
        // ``MediaKind/enhanced`` er tilladt: motivet er ægte og optaget på
        // stedet, kun stemningen er bearbejdet (ADR 0003). Der stod tidligere
        // også et krav om, at stemningsbilledet **skulle** være AI-genereret.
        // Det var forkert — de rigtige billeder er bearbejdede fotografier, og
        // reglen ville have afvist netop det, ADR'en beskriver.
        if let id = mission.placeMediaId, let asset = media[id], asset.kind == .known(.aiGenerated) {
            found.append(.misclassifiedMedia(mediaId: id, expected: "et rigtigt fotografi og ikke AI-genereret"))
        }

        return found
    }
}
