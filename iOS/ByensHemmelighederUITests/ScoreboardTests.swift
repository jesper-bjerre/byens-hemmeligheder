import XCTest

/// Egne point og highscore er to forskellige skærme.
final class ScoreboardTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    func testTotalStartsAtZeroAndCountsUpAfterAMission() {
        let app = launchAtHome()

        app.buttons["home.points"].tap()
        let total = app.descendants(matching: .any)["scoreboard.total"]
        XCTAssertTrue(total.waitForExistence(timeout: Self.uiTimeout), "Pointskærmen kom ikke frem")
        XCTAssertTrue(
            total.label.contains("0 point"),
            "Der stod ikke nul point ved start: '\(total.label)'"
        )

        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["map.open"].tap()

        // Løs Bølgen og se tallet følge med.
        tapMission(missionId, in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)
        enterCode("592", in: app)
        submitCode(in: app)
        assertReward(points: 100, in: app)
        app.buttons["reward.done"].tap()

        app.buttons["home.points"].tap()
        XCTAssertTrue(total.waitForExistence(timeout: Self.uiTimeout))
        XCTAssertTrue(
            total.label.contains("100 point"),
            "Pointene fulgte ikke med efter en løst gåde: '\(total.label)'"
        )
    }

    private func launchAtHome() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-BHResetProgress",
            "-BHSimulatedLocation", "\(Vantage.boelgen.latitude),\(Vantage.boelgen.longitude)",
        ]
        app.launch()
        return app
    }

    /// FR-055. Det vigtigste på skærmen.
    func testTheLeaderboardIsMarkedAsAnExample() {
        let app = launchAtHome()

        app.buttons["scoreboard.open"].tap()
        let board = app.descendants(matching: .any)["scoreboard.leaderboard"]
        XCTAssertTrue(board.waitForExistence(timeout: Self.uiTimeout), "Ranglisten mangler")

        // Mærkatet.
        XCTAssertTrue(
            app.descendants(matching: .any)
                .containing(NSPredicate(format: "label CONTAINS[c] %@", "Eksempel")).firstMatch
                .waitForExistence(timeout: Self.uiTimeout),
            "Ranglisten er ikke mærket som eksempel"
        )

        // Og sætningen. Et mærkat kan overses; en sætning kan ikke misforstås.
        XCTAssertTrue(
            app.descendants(matching: .any)
                .containing(NSPredicate(format: "label CONTAINS[c] %@", "opdigtet")).firstMatch
                .exists,
            "Der står ingen forklaring på, at ranglisten ikke er ægte"
        )
    }
}
