import Foundation

/// Launch-argumenter, UI-testene styrer appen med.
///
/// Kun i Debug. En udgivelsesbygning må ikke kunne nulstille progression eller
/// ændre adfærd ud fra noget, der kan sendes ind udefra (FR-051).
enum LaunchArguments {

    #if BH_DEV_TOOLS

    static var shouldResetProgress: Bool {
        ProcessInfo.processInfo.arguments.contains("-BHResetProgress")
    }

    static var shouldFailOnNetworkAccess: Bool {
        ProcessInfo.processInfo.arguments.contains("-BHFailOnNetworkAccess")
    }

    /// Om en løst opgave må spilles om.
    ///
    /// **I Debug: ja.** Et gennemløb skal kunne afprøves igen og igen uden at
    /// nulstille alt. Derfor er `-BHResetProgress` ikke svaret her — den ville
    /// også slette hint- og pointhistorik, og så var det ikke længere den samme
    /// tilstand, man prøvede at fejlsøge.
    ///
    /// **I Release: nej, ubetinget.** Se `#else`-grenen nedenfor: værdien er en
    /// konstant, ikke et opslag i `arguments`. FR-051 kræver, at en
    /// udgivelsesbygning ikke kan skifte adfærd ud fra noget udefra, og en
    /// spærring mod snyd er netop den slags, der ikke må kunne slås fra.
    ///
    /// `-BHEnforceReplayBlock` lader en UI-test køre release-reglen i en
    /// debugbygning. Uden den kunne spærringen kun efterprøves i hånden på en
    /// udgivelsesbygning — altså i praksis aldrig.
    static var allowsMissionReplay: Bool {
        !ProcessInfo.processInfo.arguments.contains("-BHEnforceReplayBlock")
    }

    /// Rydder hændelseslog og navigationstilstand, så hver test starter blankt.
    static func resetProgressIfRequested(eventStoreURL: URL) {
        guard shouldResetProgress else { return }
        try? FileManager.default.removeItem(at: eventStoreURL)
        UserDefaults.standard.removeObject(forKey: "bh.router.path.v1")
    }

    /// Installerer en spærre, der får appen til at gå ned ved ethvert
    /// netværkskald.
    ///
    /// SC-003 lover, at hele missionen kan gennemføres uden netværk. Det er en
    /// egenskab, der er let at miste ved et uheld — én analytics-linje, ét
    /// billede hentet fra en URL. Spærren gør tabet højlydt i stedet for
    /// stiltiende.
    static func installNetworkGuardIfRequested() {
        guard shouldFailOnNetworkAccess else { return }
        URLProtocol.registerClass(NetworkGuard.self)
    }

    /// Fanger enhver forespørgsel, der når URL Loading System.
    private final class NetworkGuard: URLProtocol {
        override class func canInit(with request: URLRequest) -> Bool {
            // MapKit går uden om URLSession, så kortfliser rammer ikke her.
            // Alt andet gør.
            fatalError("""
                Netværkskald under et gennemløb: \(request.url?.absoluteString ?? "ukendt").
                SC-003 kræver, at missionen kan gennemføres uden netværk.
                """)
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        override func startLoading() {}
        override func stopLoading() {}
    }

    #else

    static func resetProgressIfRequested(eventStoreURL: URL) {}
    static func installNetworkGuardIfRequested() {}

    /// En løst gåde spilles aldrig om i en udgivelsesbygning.
    static let allowsMissionReplay = false

    #endif
}
