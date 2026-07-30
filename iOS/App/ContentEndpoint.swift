import BHContentKit
import Foundation

/// Hvor appen henter opgaver og medier.
///
/// ## Ét sted at beslutte det
///
/// Kilden vælges tre steder i appen — indholdspakken, billedcachen og
/// fortællerstemmen. Uden dette ville de kunne komme til at pege forskellige
/// steder hen, og fejlen ville se ud som "billederne mangler" frem for
/// "halvdelen af appen taler med den forkerte server".
///
/// ## Der er ikke længere bundlet indhold
///
/// ADR 0004 og forfatningens princip V: indholdet er serverbårent. Pakken og
/// medierne er taget ud af appens bundle — 14 af 24 MB — og hentes nu over
/// netværket.
///
/// Der er med vilje **ingen fallback**. En app, der stille falder tilbage til
/// gammelt indhold ved en forkert konfiguration, ser fuldstændig normal ud og
/// spiller opgaver, der måske er trukket tilbage. Mangler URL'en, skal det
/// mærkes med det samme.
///
/// Baggrundsmusikken ligger stadig i bundlen. Den er appens egen præsentation
/// på linje med farvepaletten — ikke indhold.
enum ContentEndpoint {

    /// Basis-URL'en, sat i `Info.plist` via `BH_CONTENT_BASE_URL` i xcconfig.
    ///
    /// Tom betyder bundlet indhold.
    static var baseURL: URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "BHContentBaseURL") as? String,
              !raw.trimmingCharacters(in: .whitespaces).isEmpty,
              let url = URL(string: raw)
        else { return nil }
        return url
    }

    static var isServerBacked: Bool { baseURL != nil }

    /// - Precondition: `BH_CONTENT_BASE_URL` skal være sat.
    static func makeContentPackSource() -> any ContentPackSource {
        NetworkContentPackSource(baseURL: requiredBaseURL)
    }

    static func makeMediaSource() -> any MediaSource {
        NetworkMediaSource(baseURL: requiredBaseURL)
    }

    /// Stopper opstarten frem for at lade appen køre videre halvt konfigureret.
    ///
    /// Et nedbrud ved opstart er hårdt, men det er ærligt: en app uden
    /// indholdskilde kan ikke gøre nogen af de ting, den er til for. Alternativet
    /// er en tom skærm, ingen ved hvorfor viser sig.
    private static var requiredBaseURL: URL {
        guard let baseURL else {
            fatalError(
                "BH_CONTENT_BASE_URL mangler. Sæt den i Config/Local.xcconfig, "
                + "fx: BH_CONTENT_BASE_URL = http:/$()/localhost:5199"
            )
        }
        return baseURL
    }
}
