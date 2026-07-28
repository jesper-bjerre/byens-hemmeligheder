import XCTest

/// User Story 1 fra kort til belønningsskærm.
///
/// Følger quickstart.md lag 2 skridt for skridt, så en grøn test og en manuel
/// gennemgang beviser det samme.
final class BoelgenFlowTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    /// Hele rejsen, inklusive de to fejlsvar quickstart beder om.
    func testFullFlowFromMapToReward() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        tapMission(missionId, in: app)
        waitForPresence(in: app)

        // Fiktionsmarkeringen står på den narrative intro (FR-007).
        XCTAssertTrue(
            app.descendants(matching: .any)
                .containing(NSPredicate(format: "label CONTAINS[c] %@", "Fiktiv mission")).firstMatch
                .waitForExistence(timeout: Self.uiTimeout),
            "Fiktionsmarkeringen mangler på introen"
        )

        continueNarrative(in: app)

        // De tre spor.
        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)

        // Registreret fejlsvar: vejledningen skal handle om rækkefølgen.
        enterCode("529", in: app)
        submitCode(in: app)
        XCTAssertTrue(
            app.descendants(matching: .any)
                .containing(NSPredicate(format: "label CONTAINS[c] %@", "rækkefølgen")).firstMatch
                .waitForExistence(timeout: Self.uiTimeout),
            "529 skulle give sin egen vejledning om rækkefølgen"
        )

        // Ufærdigt svar: må ikke tælle som fejlforsøg (FR-014).
        clearCode(in: app)
        enterCode("59", in: app)
        submitCode(in: app)
        XCTAssertTrue(
            app.descendants(matching: .any)
                .containing(NSPredicate(format: "label CONTAINS[c] %@", "cifre")).firstMatch
                .waitForExistence(timeout: Self.uiTimeout),
            "59 skulle behandles som ufærdigt, ikke som forkert"
        )

        // Accepteret alternativ form.
        clearCode(in: app)
        enterCode("592", in: app)
        submitCode(in: app)

        assertReward(points: 100, in: app)

        // Uden inventory (FR-050).
        XCTAssertFalse(
            app.staticTexts["Det femte signal"].exists,
            "Belønningsskærmen overrækker stadig en genstand"
        )
    }

    /// SC-005: alle tre hints giver præcis 88 point, og skærmen forklarer det.
    func testAllThreeHintsLeaveEightyEightPoints() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)

        // Åbn alle tre hints på kodetrinnet.
        app.buttons["hints.open"].tap()
        for order in 1...3 {
            let reveal = app.buttons["hint.reveal.\(order)"]
            XCTAssertTrue(reveal.waitForExistence(timeout: Self.uiTimeout), "Hint \(order) mangler")
            reveal.tap()
        }
        app.buttons["Luk"].tap()

        enterCode("592", in: app)
        submitCode(in: app)

        assertReward(points: 88, in: app)
    }
}
