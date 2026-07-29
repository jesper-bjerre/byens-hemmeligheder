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
    private let transmission = "mission.frydenlund98.den-groenne-transmission"

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

    func testTwoMissionsInARowWithoutRestarting() {
        let app = launchApp(atLatitude: frydenlund.latitude, longitude: frydenlund.longitude)

        // MARK: Første opgave — multiple choice
        openMission(vera, in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        // Vera var en fritekstgåde om en gulerod. Den er skrevet om til en
        // logisk gåde med fire huller, og svaret vælges nu blandt fire
        // muligheder.
        chooseOption("Hul 3", in: app)
        assertReward(points: 50, in: app)

        app.buttons["reward.done"].tap()

        // MARK: Anden opgave — talkode, samme appkørsel
        //
        // Dét, der fejlede før: positionen kom aldrig igen, så `waitForPresence`
        // løb tør for tid.
        openMission(transmission, in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        enterCode("2026", in: app)
        submitCode(in: app)
        assertReward(points: 75, in: app)
    }

    /// Kortet skal stadig kende spillerens position efter en gennemført opgave.
    ///
    /// Samme rod som ovenfor, men et andet symptom: afstanden på opgavekortet
    /// blev beregnet ud fra den sidst kendte position og frøs fast.
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
        tapMissionPin(transmission, in: app)

        let start = app.buttons["preview.open"]
        XCTAssertTrue(start.waitForExistence(timeout: Self.uiTimeout))
        XCTAssertTrue(
            start.isEnabled,
            "Opgaven kunne ikke startes — kortet har mistet spillerens position"
        )
    }
}
