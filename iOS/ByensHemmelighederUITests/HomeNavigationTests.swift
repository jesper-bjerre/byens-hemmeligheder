import XCTest

/// Det nye app-shell: de vigtigste veje skal kunne findes uden at kende appen.
final class HomeNavigationTests: XCTestCase {
    private let timeout: TimeInterval = 10

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testExploreOpensWithMapPointsAndLeaderboard() {
        let app = launchHome()

        XCTAssertTrue(app.descendants(matching: .any)["home.explore"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["map.open"].exists)
        XCTAssertTrue(app.buttons["home.map.preview"].exists)
        XCTAssertTrue(app.buttons["home.points"].exists)
        XCTAssertTrue(app.buttons["scoreboard.open"].exists)
        XCTAssertFalse(app.staticTexts["Udvalgt i Vejle"].exists)
    }

    func testBottomNavigationOpensSearchQuestsAndProfile() {
        let app = launchHome()

        app.buttons["tab.search"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["search.screen"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.textFields["search.field"].exists)

        app.buttons["tab.quests"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["quests.screen"].waitForExistence(timeout: timeout))
        XCTAssertEqual(app.buttons["tab.quests"].label, "Mine")

        app.buttons["tab.profile"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["profile.screen"].waitForExistence(timeout: timeout))
        XCTAssertFalse(app.buttons["profile.location-tools"].exists)
    }

    func testMapButtonOpensTheExistingMap() {
        let app = launchHome()

        let preview = app.buttons["home.map.preview"]
        XCTAssertTrue(preview.waitForExistence(timeout: timeout))
        // Tryk midt på selve kortfladen, ikke på "Åbn kortet"-kapslen. Det
        // svarer til den naturlige handling, som den visuelle regression
        // tidligere slugte i MapKit-fladen.
        preview.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'mission.'"))
                .firstMatch.waitForExistence(timeout: timeout),
            "Kortet viste ingen opgavemarkør"
        )
        XCTAssertTrue(app.descendants(matching: .any)["map.screen"].exists)
        XCTAssertFalse(app.buttons["ambience.toggle"].exists)
        XCTAssertFalse(app.buttons["scoreboard.open"].exists)

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["home.explore"].waitForExistence(timeout: timeout),
            "Kortet havde ingen vej tilbage til Explore"
        )

        app.buttons["map.open"].tap()
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'mission.'"))
                .firstMatch.waitForExistence(timeout: timeout),
            "Opgavemarkørerne forsvandt, da kortet blev åbnet igen"
        )
    }

    func testTrophyOpensLeaderboardInsteadOfPersonalPoints() {
        let app = launchHome()

        app.buttons["scoreboard.open"].tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["leaderboard.screen"].waitForExistence(timeout: timeout)
        )
        XCTAssertFalse(app.descendants(matching: .any)["scoreboard.total"].exists)
        XCTAssertFalse(app.staticTexts["Detektiv Lupin"].exists)
        XCTAssertFalse(app.staticTexts["Familien Nord"].exists)
    }

    func testSearchFiltersByMissionTitle() {
        let app = launchHome()

        app.buttons["tab.search"].tap()
        let field = app.textFields["search.field"]
        XCTAssertTrue(field.waitForExistence(timeout: timeout))
        field.tap()
        field.typeText("Bølgen")

        XCTAssertTrue(
            app.descendants(matching: .any)[
                "discovery.mission.mission.boelgen.den-femte-besked"
            ].waitForExistence(timeout: timeout),
            "Søgning på opgavens titel fandt ikke Bølgen"
        )
    }

    func testMissionDescriptionHasGalleryFavoriteAndCollapsedPracticalInformation() {
        let app = launchHome()

        app.buttons["tab.search"].tap()
        let field = app.textFields["search.field"]
        XCTAssertTrue(field.waitForExistence(timeout: timeout))
        field.tap()
        field.typeText("Bølgen")

        let mission = app.descendants(matching: .any)[
            "discovery.mission.mission.boelgen.den-femte-besked"
        ]
        XCTAssertTrue(mission.waitForExistence(timeout: timeout))
        mission.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["mission.gallery"].waitForExistence(timeout: timeout),
            "Opgavebeskrivelsen mangler billedgalleriet"
        )
        XCTAssertTrue(app.buttons["mission.favorite"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["mission.safety"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["mission.accessibility"].exists)

        app.buttons["mission.favorite"].tap()
        XCTAssertTrue(
            app.alerts["Favoritter"].waitForExistence(timeout: timeout),
            "En gæst fik ingen forklaring på, at favoritter kræver login"
        )
    }

    private func launchHome() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-BHResetProgress",
            "-BHSimulatedLocation", "55.710503,9.557547",
        ]
        app.launch()
        return app
    }
}
