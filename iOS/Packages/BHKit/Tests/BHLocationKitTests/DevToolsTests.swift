import Foundation
import Observation
import Testing

@testable import BHLocationKit

/// Den rollebeskyttede GPS-simulering.
///
/// ## Hvorfor testen ser sådan ud
///
/// Providerne findes også i Release, fordi verificerede Designere og Admins
/// skal kunne feltteste. Appen eksponerer dem kun efter rollecheck og accepterer
/// aldrig launch-argumentet i Release.
@Suite("Udviklerværktøjer")
struct DevToolsTests {

    @Test("ScriptedLocationProvider er tilgængelig for rollebeskyttet UI")
    func providerIsAvailableForRoleProtectedUI() {
        #expect(ScriptedLocationProvider.Pace.walking.metresPerSecond == 1.4)
    }

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

    @Test("Skift til simuleret position opdaterer den åbne visning")
    @MainActor
    func simulationSwitchIsObservable() async {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let provider = SwitchableLocationProvider(
            real: ScriptedLocationProvider(),
            scripted: ScriptedLocationProvider(),
            defaults: defaults,
            defaultsToSimulation: false
        )

        await confirmation("Den observerede tilstand ændres") { didObserveChange in
            withObservationTracking {
                _ = provider.isSimulating
            } onChange: {
                didObserveChange()
            }

            provider.setSimulating(true)
        }

        #expect(provider.isSimulating)
        defaults.removePersistentDomain(forName: #function)
    }
}
