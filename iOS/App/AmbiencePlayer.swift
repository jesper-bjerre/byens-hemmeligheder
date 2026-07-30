import AVFoundation
import Foundation
import Observation

/// Baggrundsstemning — en lav drone, der går i ring under hele spillet.
///
/// ## Hvorfor den ikke er indhold
///
/// Stemningen hører til appen, ikke til opgaven. Den ligger derfor i bundlen og
/// ikke i indholdspakken, selvom ADR 0004 flytter alt *indhold* til serveren.
/// Musikken er præsentation på linje med farvepaletten.
///
/// Filen lå indtil videre i `contracts/content/da-DK/media/` sammen med
/// opgavernes medier. Det var forkert placeret: da indholdet flyttede til
/// serveren, ville musikken være fulgt med og skulle hentes over netværket for
/// at appen kunne spille sin egen baggrundslyd. Den ligger nu i `App/Resources/`.
///
/// ## Hvorfor den er dæmpet og kan slukkes
///
/// Spilleren står udendørs, ofte nær trafik og vand, med GPS'en tændt. Tre ting
/// følger af det:
///
/// - Lydsessionen er `.ambient` med `.mixWithOthers`, så lydkontakten og
///   spillerens egen musik altid vinder.
/// - Musikken dæmpes automatisk, når fortællerstemmen taler. To stemmer oven på
///   hinanden er ingen af dem.
/// - Den kan slukkes med ét tryk, og valget huskes.
@Observable
@MainActor
final class AmbiencePlayer {

    /// Filen i bundlens `media`-mappe.
    private static let filename = "ambience-by.m4a"
    private static let preferenceKey = "bh.ambience.enabled"

    /// Normalt niveau.
    ///
    /// Var 0,18 og reelt uhørligt. Den tidligere attrap var en drone på 55–165 Hz,
    /// og det område gengiver hverken en bærbars højttalere eller en telefon i
    /// en lomme. Lærdommen er, at "lavt nok til at overhøres" ikke må forveksles
    /// med "for lavt til at høres".
    private static let normalVolume: Float = 0.35
    /// Niveau, mens fortællerstemmen taler.
    private static let duckedVolume: Float = 0.10

    private var player: AVAudioPlayer?
    private let defaults: UserDefaults

    private(set) var isEnabled: Bool

    /// Om lyden faktisk spiller. Skelner "slået til" fra "kører".
    var isPlaying: Bool { player?.isPlaying ?? false }

    /// Hvorfor afspilningen ikke kom i gang. `nil` når alt er som det skal være.
    ///
    /// Uden den fejler musikken tavst, og så er der intet at fejlsøge på —
    /// præcis den situation, der kostede en runde her.
    private(set) var lastFailure: String?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // Slået til, med mindre spilleren har sagt fra.
        self.isEnabled = defaults.object(forKey: Self.preferenceKey) as? Bool ?? true
        observeInterruptions()
    }

    /// Et telefonopkald standser afspilningen. Uden dette ville musikken være
    /// væk resten af turen — og det ville ligne, at den var gået i stykker.
    private func observeInterruptions() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw)
            else { return }
            let options = (notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt)
                .map(AVAudioSession.InterruptionOptions.init(rawValue:)) ?? []

            MainActor.assumeIsolated {
                guard let self else { return }
                switch type {
                case .began:
                    self.player?.pause()
                case .ended where options.contains(.shouldResume) && self.isEnabled:
                    AudioSession.configure()
                    self.player?.play()
                default:
                    break
                }
            }
        }
        #endif
    }

    // MARK: - Styring

    func start() {
        guard isEnabled else { return }

        // Lytter spilleren allerede til noget, lægger vi os ikke oven på.
        // To stykker musik samtidig er ingen af dem, og valget er spillerens.
        guard !AudioSession.isOtherAudioPlaying else {
            lastFailure = "Spilleren lytter til anden lyd. Stemningen starter ikke."
            return
        }

        guard player == nil else {
            player?.play()
            return
        }
        guard let url = Bundle.main.url(
            forResource: (Self.filename as NSString).deletingPathExtension,
            withExtension: (Self.filename as NSString).pathExtension,
            subdirectory: nil
        ) else {
            lastFailure = "Filen '\(Self.filename)' findes ikke i bundlens media-mappe."
            return
        }
        guard let player = try? AVAudioPlayer(contentsOf: url) else {
            lastFailure = "Filen kunne ikke afkodes som lyd."
            return
        }

        AudioSession.configure()

        player.numberOfLoops = -1
        player.volume = Self.normalVolume
        player.prepareToPlay()
        self.player = player

        if player.play() {
            lastFailure = nil
        } else {
            lastFailure = "AVAudioPlayer afviste at starte. Er lydsessionen aktiv?"
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        defaults.set(enabled, forKey: Self.preferenceKey)
        enabled ? start() : stop()
    }

    func toggle() {
        setEnabled(!isEnabled)
    }

    /// Skruer ned, mens fortællerstemmen taler, og op igen bagefter.
    func duck(_ ducked: Bool) {
        guard let player else { return }
        player.setVolume(ducked ? Self.duckedVolume : Self.normalVolume, fadeDuration: 0.4)
    }
}
