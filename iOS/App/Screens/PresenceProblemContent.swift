import BHGameCore
import Foundation

/// Afbildningen fra hver ``PresenceState`` til dansk besked og konkret handling.
///
/// ## Nul blindgyder
///
/// SC-004 kræver, at **ingen** tilstand efterlader spilleren uden en forklaring
/// og noget at gøre. Derfor er afbildningen totalfunktion og ikke en `switch`
/// spredt ud over skærmene: en ny tilstand kan ikke tilføjes uden at
/// oversættelsen følger med, og testen tæller dem.
///
/// Sproget er almindeligt dansk. "Positionsnøjagtigheden er utilstrækkelig" er
/// ikke en besked til en familie ved en havnekant.
struct PresenceProblemContent: Equatable {
    let title: String
    let message: String
    /// Hvad spilleren kan gøre lige nu. Aldrig tom.
    let primaryAction: Action
    let secondaryAction: Action?
    let symbol: String

    enum Action: Equatable {
        /// Bed om tilladelse gennem OS-prompten.
        case requestAuthorization
        /// Bed om fuld nøjagtighed.
        case requestFullAccuracy
        /// Åbn Indstillinger.
        case openSettings
        /// Bekræft selv, at du står på stedet.
        case confirmManually
        /// Luk arket og bliv stående.
        case dismiss

        var label: String {
            switch self {
            case .requestAuthorization: "Giv adgang til position"
            case .requestFullAccuracy: "Slå præcis position til"
            case .openSettings: "Åbn Indstillinger"
            case .confirmManually: "Jeg står her nu"
            case .dismiss: "Jeg venter lidt"
            }
        }
    }

    // MARK: - Afbildningen

    static func forState(_ state: PresenceState) -> PresenceProblemContent? {
        switch state {
        case .idle, .acquiring:
            PresenceProblemContent(
                title: "Finder din position",
                message: "Telefonen leder efter satellitterne. Det tager som regel et halvt minut under åben himmel.",
                primaryAction: .dismiss,
                secondaryAction: nil,
                symbol: "location.magnifyingglass"
            )

        case .authorizationNeeded(let problem):
            forAuthorization(problem)

        case .tooFar(let distance, _):
            PresenceProblemContent(
                title: "Du er ikke fremme endnu",
                message: "Der er cirka \(Self.round(distance)) meter tilbage. Følg pilen, og hold øje med trafikken undervejs.",
                primaryAction: .dismiss,
                secondaryAction: nil,
                symbol: "figure.walk"
            )

        case .approaching(let distance, _):
            PresenceProblemContent(
                title: "Du er tæt på",
                message: "Der er cirka \(Self.round(distance)) meter tilbage. Gå det sidste stykke frem til standpunktet, og bliv stående et øjeblik.",
                primaryAction: .dismiss,
                secondaryAction: nil,
                symbol: "figure.walk.motion"
            )

        case .accuracyInsufficient(let accuracy, _):
            PresenceProblemContent(
                title: "Signalet er usikkert lige nu",
                message: "Telefonen er i tvivl om, hvor du står — den kan tage fejl med op til \(Self.round(accuracy)) meter. Høje bygninger og vand kaster signalet rundt. Prøv at gå et par skridt væk fra facaden, så du har mere fri himmel over dig.",
                primaryAction: .dismiss,
                secondaryAction: .confirmManually,
                symbol: "antenna.radiowaves.left.and.right.slash"
            )

        case .dwelling(let credit, let required):
            PresenceProblemContent(
                title: "Bliv stående et øjeblik",
                message: "Du er fremme. Vent \(max(1, Int((required - credit).rounded(.up)))) sekunder mere, så låser opgaven op.",
                primaryAction: .dismiss,
                secondaryAction: nil,
                symbol: "hourglass"
            )

        case .softOverrideOffered:
            PresenceProblemContent(
                title: "Signalet vil ikke samarbejde",
                message: "Vi kan ikke få et sikkert fix på din position. Står du ved stedet, kan du selv bekræfte det og gå i gang. Opgaven bliver registreret som selvbekræftet.",
                primaryAction: .confirmManually,
                secondaryAction: .dismiss,
                symbol: "hand.raised.fill"
            )

        case .verified:
            nil
        }
    }

    private static func forAuthorization(_ problem: AuthorizationProblem) -> PresenceProblemContent {
        switch problem {
        case .notDetermined:
            PresenceProblemContent(
                title: "Appen skal kende din position",
                message: "Opgaven låser op, når du står på stedet. Det er derfor, appen har brug for din position — og den forlader aldrig telefonen.",
                primaryAction: .requestAuthorization,
                secondaryAction: nil,
                symbol: "location.circle"
            )

        case .denied:
            PresenceProblemContent(
                title: "Adgang til position er slået fra",
                message: "Uden position kan appen ikke se, at du står på stedet. Du kan slå den til igen under Indstillinger → Anonymitet og sikkerhed → Stedtjenester.",
                primaryAction: .openSettings,
                secondaryAction: .confirmManually,
                symbol: "location.slash"
            )

        case .restricted:
            // Skærmtid på et barns telefon. Barnet kan ikke selv ændre det.
            PresenceProblemContent(
                title: "Position er spærret på denne telefon",
                message: "Stedtjenester er begrænset — det sker typisk med Skærmtid. Spørg den, der har sat telefonen op. Indtil da kan du bekræfte selv, at du står på stedet.",
                primaryAction: .confirmManually,
                secondaryAction: .openSettings,
                symbol: "lock.circle"
            )

        case .reducedAccuracy:
            PresenceProblemContent(
                title: "Positionen er upræcis",
                message: "Appen får kun din omtrentlige position, og det er ikke nøjagtigt nok til at se, at du står ved netop dette sted.",
                primaryAction: .requestFullAccuracy,
                secondaryAction: .confirmManually,
                symbol: "scope"
            )

        case .servicesDisabled:
            PresenceProblemContent(
                title: "Stedtjenester er slået fra",
                message: "Stedtjenester er slået fra for hele telefonen. Du kan slå dem til i Indstillinger — eller bekræfte selv, at du står på stedet.",
                primaryAction: .openSettings,
                secondaryAction: .confirmManually,
                symbol: "location.slash.circle"
            )
        }
    }

    private static func round(_ value: Double) -> Int {
        max(1, Int(value.rounded()))
    }
}
