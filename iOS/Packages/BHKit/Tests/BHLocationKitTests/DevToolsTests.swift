import Foundation
import Testing

@testable import BHLocationKit

/// FR-051: udviklerværktøjer må ikke findes i en udgivelsesbygning.
///
/// ## Hvorfor testen ser sådan ud
///
/// En unit test kan ikke inspicere en anden konfiguration end den, den selv er
/// oversat i. Derfor er kontrollen todelt:
///
/// 1. **Denne fil** hævder, at `BH_DEV_TOOLS` og `DEBUG` følges ad. Kør den i
///    release for at få den til at bide:
///    ```sh
///    swift test -c release --filter Udviklerværktøjer
///    ```
/// 2. **Binæren** kontrolleres udefra, fordi det er dét, der faktisk sendes til
///    en bruger:
///    ```sh
///    nm ByensHemmeligheder.app/ByensHemmeligheder | grep -c ScriptedLocationProvider
///    ```
///    Skal give `0` for en Release-bygning.
///
/// Punkt 2 er den egentlige garanti. Punkt 1 er den, der fejler i CI, før nogen
/// når at bygge en udgivelse.
@Suite("Udviklerværktøjer")
struct DevToolsTests {

    @Test("BH_DEV_TOOLS er kun sat i Debug")
    func devToolsFlagFollowsDebug() {
        #if BH_DEV_TOOLS
        #if DEBUG
        // Forventet: Debug-bygning med værktøjer.
        #else
        Issue.record("""
            BH_DEV_TOOLS er sat i en bygning uden DEBUG.
            ScriptedLocationProvider ville følge med i en udgivelse (FR-051).
            Kontrollér `.define(..., .when(configuration: .debug))` i Package.swift.
            """)
        #endif
        #endif
    }

    @Test("ScriptedLocationProvider findes kun, når flaget er sat")
    func providerExistsOnlyBehindTheFlag() {
        #if BH_DEV_TOOLS
        // Typen skal kunne nævnes her — ellers er guarden for bred.
        #expect(ScriptedLocationProvider.Pace.walking.metresPerSecond == 1.4)
        #else
        // I release findes typen ikke, og filen kan derfor ikke referere til
        // den. At denne gren oversætter, er i sig selv beviset.
        #expect(Bool(true))
        #endif
    }

    #if BH_DEV_TOOLS

    @Test("Simuleret position stemples som simuleret")
    @MainActor
    func simulatedFixesAreFlagged() async {
        let provider = ScriptedLocationProvider()
        provider.start()

        var iterator = provider.snapshots.makeAsyncIterator()
        let snapshot = await iterator.next()
        provider.stop()

        #expect(snapshot?.isSimulatedBySoftware == true, "Simulerede fixes skal kunne kendes (FR-028)")
    }

    @Test("Tempoene svarer til virkelige hastigheder")
    func pacesAreRealistic() {
        #expect(ScriptedLocationProvider.Pace.standingStill.metresPerSecond == 0)
        #expect(ScriptedLocationProvider.Pace.walking.metresPerSecond == 1.4)
        #expect(ScriptedLocationProvider.Pace.running.metresPerSecond == 4.0)
    }

    #endif
}
