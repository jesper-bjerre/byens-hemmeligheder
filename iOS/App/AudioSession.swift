import AVFoundation
import Foundation

/// Appens lydsession — sat ét sted, én gang.
///
/// ## `.playback`, ikke `.ambient`
///
/// Forskellen er lydkontakten på siden af telefonen. `.ambient` respekterer den
/// og går i stå, når telefonen er sat på lydløs; `.playback` gør ikke.
///
/// Det var oprindeligt et bevidst valg: appen bruges udendørs, og lyd fra en
/// lomme på lydløs er påtrængende. Men det er ikke, hvad spillere forventer —
/// spil og musikapps spiller videre på lydløs, og en fortællerstemme, der tier
/// uden forklaring, ligner en fejl frem for et hensyn.
///
/// Lydkontakten er derfor ikke længere vores afbryder. Højttalerknappen i
/// headeren er.
///
/// ## `.mixWithOthers`
///
/// Uden den ville appen **afbryde** spillerens egen musik eller podcast i det
/// øjeblik, den åbnes. Med den lægger vi os ved siden af.
///
/// Baggrundsmusikken går et skridt videre og starter slet ikke, hvis spilleren
/// allerede lytter til noget — to stykker musik oven på hinanden er ingen af
/// dem, og valget er spillerens, ikke vores.
///
/// ## Ingen baggrundsafspilning
///
/// `UIBackgroundModes: audio` er bevidst **ikke** sat. Lyden stopper, når appen
/// lukkes ned i baggrunden. Appen har intet ærinde at spille videre i en lomme,
/// og baggrundslyd ville holde processen — og GPS'en — i live længere end nødvendigt.
/// Kun fra hovedtråden. Begge afspillere er `@MainActor`, så isolationen
/// koster ingenting og gør `isConfigured` sikker uden en lås.
@MainActor
enum AudioSession {

    private static var isConfigured = false

    static func configure() {
        #if os(iOS)
        guard !isConfigured else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        isConfigured = true
        #endif
    }

    /// Om spilleren allerede lytter til noget andet.
    static var isOtherAudioPlaying: Bool {
        #if os(iOS)
        AVAudioSession.sharedInstance().isOtherAudioPlaying
        #else
        false
        #endif
    }
}
