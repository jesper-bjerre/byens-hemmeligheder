import XCTest

/// To opgaver i træk — uden at starte appen forfra.
///
/// ## Hvorfor filen findes
///
/// Alle øvrige gennemløbstests starter appen og kører **én** opgave. Det hul
/// skjulte en reel fejl: positionsstrømmen blev lukket, når approach-skærmen
/// forsvandt, og `AsyncStream` kan kun forbruges én gang. Anden opgave fandt
/// derfor aldrig satellitterne, og kortets blå prik frøs fast — uden at nogen
/// test blinkede rødt.
///
/// En fejl, der kun opstår ved gentagelse, kan kun fanges ved at gentage.
final class MultipleMissionsTests: FlowTestCase {

    private let vera = "mission.frydenlund98.veras-hemmelige-snack"

    /// Begge testopgaver ligger på Frydenlund 98.
    private let frydenlund = (latitude: 55.734897, longitude: 9.620270)

    /// Lukker det kort, der åbner sig selv ved ankomst.
    private func dismissArrivalCard(in app: XCUIApplication) {
        let close = app.buttons["preview.dismiss"]
        if close.waitForExistence(timeout: 5) {
            close.tap()
        }
    }

    /// Åbner en bestemt opgave, uanset om ankomstkortet allerede er fremme.
    private func openMission(_ missionId: String, in app: XCUIApplication) {
        dismissArrivalCard(in: app)
        tapMission(missionId, in: app)
    }

    // `testTwoMissionsInARowWithoutRestarting` stod her.
    //
    // Den løste to opgaver i samme appkørsel og krævede derfor to opgaver med
    // samme standpunkt. Frydenlund 98 havde to — Vera og Mads P — og da Mads
    // P blev fjernet, deler ingen to opgaver længere en lokation.
    //
    // Testen kan komme igen, når udviklerpanelets flytteknapper får id'er, en
    // test kan trykke på: så kan spilleren flyttes fra den ene opgave til den
    // næste uden at starte appen forfra.

    func testMapStillKnowsThePlayerAfterAMission() {
        let app = launchApp(atLatitude: frydenlund.latitude, longitude: frydenlund.longitude)

        openMission(vera, in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)
        // Vera var en fritekstgåde om en gulerod. Den er skrevet om til en
        // logisk gåde med fire huller, og svaret vælges nu blandt fire
        // muligheder.
        chooseOption("Hul 3", in: app)
        assertReward(points: 50, in: app)
        app.buttons["reward.done"].tap()

        // Tilbage på kortet skal den anden opgave stadig kunne startes — og det
        // kan den kun, hvis positionen stadig kommer ind.
        dismissArrivalCard(in: app)
        // Kortet skal stadig kende spilleren efter en løst opgave.
        tapMissionPin(vera, in: app)
        XCTAssertTrue(
            app.buttons["preview.dismiss"].waitForExistence(timeout: Self.uiTimeout),
            "Opgavekortet kom ikke frem efter en løst opgave"
        )
    }
}
