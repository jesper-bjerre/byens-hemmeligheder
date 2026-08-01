import Foundation

/// Appens konfiguration (FR-102).
///
/// ## Serveradressen er ikke et felt i UI'et
///
/// Den står i `Info.plist` og kommer derfra fra bygningens `BH_BACKEND_URL`.
/// En adresse, quizmasteren kan skrive i appen, er et felt, hen kan skrive
/// forkert — og fejlen viser sig først som "kunne ikke hente", langt fra det
/// sted, den blev lavet. Fem quizmastere skal pege på den samme server.
///
/// ## Undtagen i Debug
///
/// Under udvikling skal appen kunne pege på maskinen ved siden af. Den
/// overstyres derfor af `UserDefaults`-nøglen `BHBackendURL`, som iOS også
/// læser fra procesargumenter. I skemaets *Arguments Passed On Launch*:
///
/// ```
/// -BHBackendURL "http://192.168.0.12:5199"
/// ```
///
/// Det er stadig en konfiguration og ikke et skærmbillede, og linjen findes
/// ikke i Release.
///
/// > Vigtigt: `BH_BACKEND_URL` peger i dag på `localhost` i **begge**
/// > konfigurationer, fordi backenden endnu ikke er udrullet. Den skal rettes i
/// > Release, før appen lægges på TestFlight — ellers står den og henter fra en
/// > server, der ikke findes på telefonen.
enum AdminConfiguration {

    private static let backendKey = "BHBackendURL"

    /// Bruges kun, hvis `Info.plist` mangler nøglen — altså aldrig i en
    /// bygning, der er sat rigtigt op.
    private static let fallback = URL(string: "http://localhost:5199")!

    static var backendURL: URL {
        #if DEBUG
        if let raw = UserDefaults.standard.string(forKey: backendKey),
           let url = URL(string: raw.trimmingCharacters(in: .whitespaces)),
           url.scheme != nil {
            return url
        }
        #endif

        guard let raw = Bundle.main.object(forInfoDictionaryKey: backendKey) as? String,
              let url = URL(string: raw.trimmingCharacters(in: .whitespaces)),
              url.scheme != nil
        else { return fallback }

        return url
    }

    // MARK: - Hvilken server

    /// De servere, der findes. Ikke et skrivefelt.
    ///
    /// FR-102 siger, at adressen er en app-konfiguration og ikke et felt i
    /// UI'et. Pointen var, at en adresse, man kan taste, er en, man kan taste
    /// forkert — og fejlen viser sig som "kunne ikke hente", langt fra det
    /// sted, den blev lavet.
    ///
    /// En vælger mellem to navngivne servere bryder ikke det: der er ikke noget
    /// at stave forkert, og der er stadig kun ét sted, adresserne står.
    enum Backend: String, CaseIterable, Identifiable {
        case drift
        case lokal

        var id: String { rawValue }

        var name: String {
            switch self {
            case .drift: "Drift"
            case .lokal: "Lokal maskine"
            }
        }

        var url: URL {
            switch self {
            case .drift: URL(string: "https://byensgaader-api-p.azurewebsites.net")!
            case .lokal: URL(string: "http://localhost:5199")!
            }
        }

        /// Hvad valget betyder i praksis. Står under vælgeren, fordi "Lokal
        /// maskine" på en telefon peger på telefonen selv og ikke på noget,
        /// der svarer.
        var note: String {
            switch self {
            case .drift: "Det indhold, quizmasterne arbejder i."
            case .lokal: "Kræver ./backend/run.sh. Virker kun i simulatoren."
            }
        }
    }

    /// Serveren, appen taler med lige nu.
    static var backend: Backend {
        Backend.allCases.first { $0.url == backendURL } ?? .drift
    }

    /// Skifter server. Kun i Debug — en udsendt bygning peger på drift og
    /// bliver der.
    static func select(_ backend: Backend) {
        #if DEBUG
        UserDefaults.standard.set(backend.url.absoluteString, forKey: backendKey)
        #endif
    }

    /// Sandt, når serveren kan vælges. Falsk i Release.
    static var canChooseBackend: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    // MARK: - Hvem der retter

    private static let quizmasterKey = "bh.admin.quizmaster"

    /// Navnet, der følger med hver gemning i `X-Quizmaster` (FR-111).
    ///
    /// Dette **er** et felt i UI'et, og det er ikke en modsigelse af FR-102:
    /// serveradressen er den samme for alle fem, mens navnet pr. definition er
    /// forskelligt. Uden det kan sporet ikke svare på hvem, og serveren afviser
    /// gemningen.
    static var quizmaster: String {
        get { UserDefaults.standard.string(forKey: quizmasterKey) ?? "" }
        set {
            UserDefaults.standard.set(
                newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: quizmasterKey)
        }
    }

    static var isReady: Bool { !quizmaster.isEmpty }

    /// Sproget, der redigeres. Der findes én pakke endnu, og et faneblad til at
    /// vælge mellem én ting er kun i vejen.
    static let locale = "da-DK"
}
