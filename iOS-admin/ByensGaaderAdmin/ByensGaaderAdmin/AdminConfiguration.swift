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
/// Debug peger som standard på DEV, mens Release altid peger på drift. Lokal
/// backend vælges bevidst i appen eller med argumentet ovenfor. `AssetTests`
/// holder værdien op mod ``Backend``, så en adresse, der kun står i bygningen,
/// får testene til at fejle.
enum AdminConfiguration {

    private static let backendKey = "BHBackendURL"

    /// Bruges kun, hvis `Info.plist` mangler nøglen. En manglende indstilling
    /// må ikke lydløst sende appen mod localhost, hvor fejlen ligner nedetid.
    private static var fallback: URL {
        #if DEBUG
        Backend.udvikling.url
        #else
        Backend.drift.url
        #endif
    }

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
        case udvikling
        case drift
        case lokal

        var id: String { rawValue }

        var name: String {
            switch self {
            case .udvikling: "Udvikling (DEV)"
            case .drift: "Drift"
            case .lokal: "Lokal maskine"
            }
        }

        var url: URL {
            switch self {
            case .udvikling: URL(string: "https://byensgaader-api-d.azurewebsites.net")!
            case .drift: URL(string: "https://byensgaader-api-p.azurewebsites.net")!
            case .lokal: URL(string: "http://localhost:5199")!
            }
        }

        /// Hvad valget betyder i praksis. Står under vælgeren, fordi "Lokal
        /// maskine" på en telefon peger på telefonen selv og ikke på noget,
        /// der svarer.
        var note: String {
            switch self {
            case .udvikling: "Testmiljøet med adskilte opgaver og brugere."
            case .drift: "Det indhold, quizmasterne arbejder i."
            case .lokal: "Kræver ./backend/run.sh. Virker kun i simulatoren."
            }
        }
    }

    /// Serveren, appen taler med lige nu.
    static var backend: Backend {
        Backend.allCases.first { $0.url == backendURL } ?? .udvikling
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

    /// Sproget, der redigeres. Der findes én pakke endnu, og et faneblad til at
    /// vælge mellem én ting er kun i vejen.
    static let locale = "da-DK"
}
