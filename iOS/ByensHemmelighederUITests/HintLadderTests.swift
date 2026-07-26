import XCTest

/// Hintstigen: hint 2 kan ikke fås før hint 1.
///
/// Rækkefølgen beskytter spillerens point. Stigen går *hvor → hvordan → næsten
/// løsningen* med stigende fradrag (3 → 4 → 5 %). Kunne man springe direkte til
/// det sidste, ville man betale 5 % for noget, et vink på 3 % måske havde klaret.
final class HintLadderTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    /// Fører spilleren frem til kodetrinnet og åbner hint-arket.
    private func reachHintSheet() -> XCUIApplication {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        let hints = app.buttons["hints.open"]
        XCTAssertTrue(hints.waitForExistence(timeout: Self.uiTimeout), "Hint-knappen mangler")
        hints.tap()
        return app
    }

    func testOnlyTheFirstHintIsOpenAtTheStart() {
        let app = reachHintSheet()

        XCTAssertTrue(
            app.buttons["hint.reveal.1"].waitForExistence(timeout: Self.uiTimeout),
            "Hint 1 kunne ikke åbnes"
        )
        XCTAssertFalse(app.buttons["hint.reveal.2"].exists, "Hint 2 var åbent fra start")
        XCTAssertFalse(app.buttons["hint.reveal.3"].exists, "Hint 3 var åbent fra start")

        XCTAssertTrue(app.staticTexts["hint.locked.2"].exists, "Hint 2 manglede sin forklaring")
        XCTAssertTrue(
            app.staticTexts["hint.locked.2"].label.contains("1"),
            "Forklaringen siger ikke hvilket hint der spærrer: '\(app.staticTexts["hint.locked.2"].label)'"
        )
    }

    func testSecondHintUnlocksAfterTheFirst() {
        let app = reachHintSheet()

        app.buttons["hint.reveal.1"].tap()
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Vis hintet")).firstMatch.tap()

        XCTAssertTrue(
            app.buttons["hint.reveal.2"].waitForExistence(timeout: Self.uiTimeout),
            "Hint 2 åbnede ikke, efter hint 1 var brugt"
        )
        XCTAssertFalse(app.buttons["hint.reveal.3"].exists, "Hint 3 sprang køen over")
        XCTAssertTrue(app.staticTexts["hint.locked.3"].exists)
    }

    func testThirdHintNeedsBothOthers() {
        let app = reachHintSheet()

        for order in 1...2 {
            let reveal = app.buttons["hint.reveal.\(order)"]
            XCTAssertTrue(reveal.waitForExistence(timeout: Self.uiTimeout), "Hint \(order) mangler")
            reveal.tap()
            app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Vis hintet")).firstMatch.tap()
        }

        XCTAssertTrue(
            app.buttons["hint.reveal.3"].waitForExistence(timeout: Self.uiTimeout),
            "Hint 3 åbnede ikke, efter både 1 og 2 var brugt"
        )
        XCTAssertFalse(app.staticTexts["hint.locked.3"].exists)
    }

    /// Stigen må ikke gøre det dyrere at bruge alle tre.
    func testWalkingTheWholeLadderStillLeavesEightyEightPoints() {
        let app = reachHintSheet()

        for order in 1...3 {
            let reveal = app.buttons["hint.reveal.\(order)"]
            XCTAssertTrue(reveal.waitForExistence(timeout: Self.uiTimeout), "Hint \(order) var låst")
            reveal.tap()
            app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Vis hintet")).firstMatch.tap()
        }
        app.buttons["Luk"].tap()

        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)
        enterCode("592", in: app)
        submitCode(in: app)

        assertReward(points: 88, in: app)
    }
}
