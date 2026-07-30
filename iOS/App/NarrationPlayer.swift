import AVFoundation
import BHContentKit
import BHContracts
import Foundation
import Observation

/// Fortællerstemmen, der sætter opgaven i gang.
///
/// ## Den spiller af sig selv
///
/// Der var tidligere en knap, "Afspil introen". Den blev fjernet, fordi den
/// syntetiske stemme lød dårligt, og en knap, ingen trykker på, er bare et
/// element mere at overse. Nu er stemmerne indtalt, og fortællingen hører til
/// oplevelsen — den starter derfor af sig selv, når opgaven åbner.
///
/// ## Alt nødvendigt står stadig på skærmen
///
/// Stemmen giver stemning og uddybning, aldrig indhold (ADR 0003). Forfatningen
/// kræver, at opgaven kan løses uden lyd, og opgavedokumenterne siger det
/// samme. Derfor må intet her være den eneste vej til en oplysning — hverken
/// for en spiller uden høretelefoner i en blæsende havn eller for en spiller,
/// der ikke kan høre.
///
/// ## Højttalerknappen gælder også her
///
/// Der kommer ikke en knap mere. Spilleren har allerede én lydkontakt i
/// headeren, og den slår **al** lyd fra: stemning og fortæller. To kontakter
/// ville betyde to steder at lede, når man vil have ro.
@Observable
@MainActor
final class NarrationPlayer: NSObject {

    private var player: AVAudioPlayer?
    private let source: any MediaSource

    /// Sat, mens der tales, så baggrundsmusikken kan dæmpes.
    private(set) var isSpeaking = false

    /// Hvorfor stemmen ikke kom i gang. `nil`, når alt er som det skal være.
    ///
    /// Samme grund som i ``AmbiencePlayer``: uden den fejler lyden tavst, og så
    /// er der intet at fejlsøge på.
    private(set) var lastFailure: String?

    /// Hvilken opgave der allerede er læst op, så et skift tilbage til samme
    /// skærm ikke starter forfra midt i en sætning.
    private var spokenMissionId: String?

    init(source: any MediaSource = ContentEndpoint.makeMediaSource()) {
        self.source = source
        super.init()
    }

    /// Læser opgavens introduktion op, hvis der er en og lyden er slået til.
    func speak(_ asset: MediaAsset?, forMission missionId: String, isEnabled: Bool) async {
        guard isEnabled else { return }
        guard let asset, asset.resolvedMediaType == .audio else { return }
        guard spokenMissionId != missionId else { return }

        guard case .data(let data, _) = try? await source.fetch(asset, ifNoneMatch: nil) else {
            lastFailure = "Lydfilen '\(asset.filename)' findes ikke i bundlens media-mappe."
            return
        }
        guard let player = try? AVAudioPlayer(data: data) else {
            lastFailure = "Filen '\(asset.filename)' kunne ikke afkodes som lyd."
            return
        }

        AudioSession.configure()
        player.delegate = self
        player.prepareToPlay()
        self.player = player

        if player.play() {
            spokenMissionId = missionId
            isSpeaking = true
            lastFailure = nil
        } else {
            lastFailure = "AVAudioPlayer afviste at starte. Er lydsessionen aktiv?"
        }
    }

    /// Stopper og glemmer, at opgaven er læst op.
    ///
    /// Kaldes, når spilleren forlader opgaven. Uden det ville stemmen tale
    /// videre ud i kortet, efter man er gået — og gentagelsesspærren ville
    /// forhindre, at den kunne høres igen næste gang.
    func stop() {
        player?.stop()
        player = nil
        isSpeaking = false
        spokenMissionId = nil
    }
}

extension NarrationPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        MainActor.assumeIsolated {
            isSpeaking = false
        }
    }
}
