import XCTest

/// Pointskærmen: spillerens egne tal er ægte, ranglisten er en attrap.
///
/// Attrappen er det, der kan gå galt. Vises den uden mærkning, tror en tester,
/// at hen er nummer fire i Vejle — og har så fået en forkert idé om både
/// spillet og sin egen indsats (FR-055).
final class ScoreboardTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    func testTotalStartsAtZeroAndCountsUpAfterAMission() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        app.buttons["scoreboard.open"].tap()
        let total = app.descendants(matching: .any)["scoreboard.total"]
        XCTAssertTrue(total.waitForExistence(timeout: Self.uiTimeout), "Pointskærmen kom ikke frem")
        XCTAssertTrue(
            total.label.contains("0 point"),
            "Der stod ikke nul point ved start: '\(total.label)'"
        )

        app.navigationBars.buttons.firstMatch.tap()

        // Løs Bølgen og se tallet følge med.
        tapMission(missionId, in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)
        enterCode("592", in: app)
        submitCode(in: app)
        assertReward(points: 100, in: app)
        app.buttons["reward.done"].tap()

        app.buttons["scoreboard.open"].tap()
        XCTAssertTrue(total.waitForExistence(timeout: Self.uiTimeout))
        XCTAssertTrue(
            total.label.contains("100 point"),
            "Pointene fulgte ikke med efter en løst gåde: '\(total.label)'"
        )
    }

    /// FR-055. Det vigtigste på skærmen.
    func testTheLeaderboardIsMarkedAsAnExample() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

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
