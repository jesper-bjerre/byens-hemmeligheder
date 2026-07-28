import XCTest

/// User Story 2: den anden opgave skal virke uden ny kode.
///
/// Testen er bevidst en næsten ordret kopi af Bølgen-gennemløbet med andre tal.
/// Det er selve pointen: kunne den ikke skrives sådan, ville motoren ikke være
/// indholdsdrevet (SC-002).
final class FjordenhusFlowTests: FlowTestCase {

    private let missionId = "mission.fjordenhus.vandets-tromler"

    func testFullFlowFromMapToReward() {
        let app = launchApp(
            atLatitude: Vantage.fjordenhus.latitude,
            longitude: Vantage.fjordenhus.longitude
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        // Form → vand → højde.

        enterCode("428", in: app)
        submitCode(in: app)

        assertReward(points: 100, in: app)

        XCTAssertFalse(
            app.staticTexts["Fjordseglet"].exists,
            "Belønningsskærmen overrækker stadig en genstand"
        )
    }

    /// Opgaverne er fritstående og kan spilles i vilkårlig rækkefølge (SC-002).
    func testFjordenhusPlayableWithoutBoelgen() {
        let app = launchApp(
            atLatitude: Vantage.fjordenhus.latitude,
            longitude: Vantage.fjordenhus.longitude
        )

        // Bølgen er urørt og skal stadig stå som uløst på kortet.
        XCTAssertTrue(
            app.buttons["mission.mission.boelgen.den-femte-besked"].waitForExistence(timeout: Self.uiTimeout),
            "Bølgen forsvandt fra kortet"
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)
        enterCode("4 2 8", in: app)
        submitCode(in: app)

        assertReward(points: 100, in: app)
    }
}
