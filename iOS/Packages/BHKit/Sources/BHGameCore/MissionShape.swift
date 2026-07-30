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
/// 1. en bunke kort — hvert et billede med lidt tekst, det første med
///    introduktionen
/// 2. ét spørgsmål med ét svar
///
/// Intet andet. Det fortællende trin er væk: fortællingen er kort 1, og hele
/// opgaven ligger nu på én side. Det, der skiller opgaverne, er **data** — teksten, billederne,
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

    /// Hvor lang et korts tekst må være.
    ///
    /// Teksten ligger som overlay hen over billedets nederste kant. Overlayet
    /// kan kun bære det, der er plads til — en længere tekst blev klippet,
    /// først usynligt og siden afvist af tilgængelighedsauditten ved de store
    /// skriftstørrelser.
    ///
    /// Grænsen er fundet ved måling, ikke ved skøn: 173 tegn klippede, og et
    /// kort på under 110 bestod. Er en tekst for lang, er svaret at dele den
    /// over flere kort — ikke at stryge ord.
    /// Hvor lang en tekst må være for at kunne bæres som overlay.
    ///
    /// Målt: 110 tegn bestod tilgængelighedsauditten, 135 blev klippet. Over
    /// grænsen lægger kortet teksten i en bjælke under billedet i stedet — den
    /// kan vokse frit. Grænsen afviser derfor intet indhold; den afgør kun,
    /// hvordan kortet ser ud.
    public static let maximumOverlayTextLength = 110

    /// Ingen øvre grænse for et korts tekst.
    ///
    /// Der stod før 110 her, fordi overlayet klippede alt derover. Nu skifter
    /// kortet selv til en bjælke, og et langt kort er et layoutvalg frem for
    /// en fejl. Grænsen er sat højt for stadig at fange en tekst, der er så
    /// lang, at kortet er blevet til en artikel.
    public static let maximumCardTextLength = 600

    /// Markerer et facit, der endnu ikke er fastlagt.
    ///
    /// Et opgavedokument kan være færdigt på alt andet end svaret: "Den
    /// forsvundne landevej" venter på, at broens retning bliver målt i felten.
    /// Opgaven skal kunne ligge i pakken med sin fortælling, sine hints og sin
    /// stemme — men den må aldrig nå en spiller.
    ///
    /// Sentinellen er selv et gyldigt svar, så alle de øvrige invarianter
    /// holder: kontrakten kræver mindst ét accepteret svar, og V-02 kræver, at
    /// det kanoniske svar bedømmes korrekt af sin egen regel. Prisen er, at
    /// "uløselig" ikke længere kan aflæses af en tom liste — derfor denne
    /// konstant og reglen nedenfor.
    public static let unsetFacit = "FACIT-IKKE-FASTLAGT"

    public enum Violation: Hashable, Sendable, CustomStringConvertible {
        case noCards
        /// Teksten er for lang til overlayet og vil blive klippet.
        case cardTextTooLong(cardId: String, length: Int)
        case wrongStepCount(Int)
        case noChallengeStep
        case multipleChallengeSteps(Int)
        case unknownStepKind(String)
        case wrongChoiceCount(stepId: String, count: Int)
        case wrongHintCount(Int)
        /// Opgaven kan spilles, men facit er ikke fastlagt. Så står spilleren
        /// ved stedet uden nogen vej videre.
        case playableWithoutAnswer
        /// Stemningsbilledet skal være mærket som AI-genereret, og
        /// stedbilledet må ikke være det.
        case misclassifiedMedia(mediaId: String, expected: String)

        public var description: String {
            switch self {
            case .noCards:
                "har ingen kort — der skal mindst være ét med introduktionen"
            case .cardTextTooLong(let cardId, let length):
                "kortet '\(cardId)' har \(length) tegn — grænsen er \(maximumCardTextLength). Del teksten over flere kort."
            case .wrongStepCount(let count):
                "har \(count) trin — formen er præcis 1: spørgsmålet"
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
            case .playableWithoutAnswer:
                "kan spilles, men facit er ikke fastlagt — den er uløselig"
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
        if steps.count != 1 {
            found.append(.wrongStepCount(steps.count))
        }

        if mission.orderedCards.isEmpty {
            found.append(.noCards)
        }

        for card in mission.orderedCards where card.text.count > maximumCardTextLength {
            found.append(.cardTextTooLong(cardId: card.id, length: card.text.count))
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

        // En opgave uden facit må ikke kunne nå spilleren.
        //
        // "Den forsvundne landevej" er skrevet færdig på alt andet end svaret:
        // opgavedokumentet siger, at den rigtige retning først kan fastlægges
        // efter opmåling i felten. Den ligger derfor i pakken som
        // ``MissionStatus/researchReady`` og vises ikke. Denne regel er det,
        // der gør, at et uskyldigt statusskift ikke sender en uløselig opgave
        // ud til en familie, der står ved en bro i regnvejr.
        let isPlayable = mission.status.known == .fieldTestReady || mission.status.known == .publishReady
        let accepted = mission.challengeStep?.answerRule?.acceptedAnswers ?? []
        if isPlayable, accepted.isEmpty || accepted.contains(unsetFacit) {
            found.append(.playableWithoutAnswer)
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
