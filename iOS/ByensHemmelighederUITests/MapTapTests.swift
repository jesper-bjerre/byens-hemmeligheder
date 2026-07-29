import XCTest

/// Trykket på en markør — ad den vej en finger faktisk går.
///
/// ## Hvorfor denne fil findes
///
/// De øvrige tests bruger `element.tap()`. Er elementet ikke hit-testbart,
/// falder XCUITest tilbage til at aktivere tilgængeligheds-handlingen — og så
/// består testen, mens en rigtig finger ikke får noget til at ske. Præcis dét
/// skete: gestussen og `MapProxy` målte i hvert sit koordinatrum, forskudt af
/// safe area, og trykket landede ved siden af markøren.
///
/// Testene her trykker på **skærmkoordinater** i vinduets rum. Der findes ingen
/// tilgængelighedsgenvej at falde tilbage på, så de kan kun bestå, hvis
/// hit-testen i `handleTap` rent faktisk virker.
final class MapTapTests: FlowTestCase {

    private let boelgen = "mission.mission.boelgen.den-femte-besked"
    private let fjordenhus = "mission.mission.fjordenhus.vandets-tromler"

    /// Trykker på et punkt i vinduet, uafhængigt af elementhierarkiet.
    private func tapWindow(at point: CGPoint, in app: XCUIApplication) {
        let frame = app.frame
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: point.x - frame.minX, dy: point.y - frame.minY))
            .tap()
    }

    func testTappingPinWithRealTouchOpensPreview() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        let pin = app.buttons[boelgen]
        XCTAssertTrue(pin.waitForExistence(timeout: Self.uiTimeout), "Markøren mangler")

        // Midt på markørens cirkel — øverste tredjedel af rammen.
        let frame = pin.frame
        tapWindow(at: CGPoint(x: frame.midX, y: frame.minY + frame.height * 0.3), in: app)

        XCTAssertTrue(
            app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout),
            "Et rigtigt tryk på markøren åbnede ikke opgavekortet"
        )
        XCTAssertTrue(app.staticTexts["Bølgen – Den femte besked"].exists)
    }

    func testTappingTheOtherPinOpensTheOtherMission() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        // Spilleren står ved Bølgen, så dens kort popper op af sig selv og
        // dækker en del af kortet. Luk det først.
        if app.buttons["preview.dismiss"].waitForExistence(timeout: Self.uiTimeout) {
            app.buttons["preview.dismiss"].tap()
        }

        let pin = app.buttons[fjordenhus]
        XCTAssertTrue(pin.waitForExistence(timeout: Self.uiTimeout), "Fjordenhus' markør mangler")

        let frame = pin.frame
        tapWindow(at: CGPoint(x: frame.midX, y: frame.minY + frame.height * 0.3), in: app)

        XCTAssertTrue(app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout))
        XCTAssertTrue(
            app.staticTexts["Fjordenhus – Vandets tromler"].exists,
            "Trykket ramte den forkerte opgave"
        )
    }

    /// Et tryk på tomt kort må ikke åbne noget.
    func testTappingEmptyMapOpensNothing() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        XCTAssertTrue(app.buttons[boelgen].waitForExistence(timeout: Self.uiTimeout))

        // Øverste venstre hjørne af kortet, langt fra begge markører.
        let frame = app.frame
        tapWindow(at: CGPoint(x: frame.minX + 30, y: frame.minY + 220), in: app)

        XCTAssertFalse(
            app.buttons["preview.open"].waitForExistence(timeout: 3),
            "Et tryk på tomt kort åbnede et opgavekort"
        )
    }

    /// Kortet skal kunne lukkes igen og markøren trykkes på ny.
    func testPreviewCanBeClosedAndReopened() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        let pin = app.buttons[boelgen]
        XCTAssertTrue(pin.waitForExistence(timeout: Self.uiTimeout))
        let frame = pin.frame
        let target = CGPoint(x: frame.midX, y: frame.minY + frame.height * 0.3)

        tapWindow(at: target, in: app)
        XCTAssertTrue(app.buttons["preview.dismiss"].waitForExistence(timeout: Self.uiTimeout))
        app.buttons["preview.dismiss"].tap()

        XCTAssertFalse(app.buttons["preview.open"].waitForExistence(timeout: 3), "Kortet lukkede ikke")

        tapWindow(at: target, in: app)
        XCTAssertTrue(
            app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout),
            "Markøren kunne ikke trykkes igen efter lukning"
        )
    }

    // MARK: - Princip I: stedet er spillet

    /// Står man ved opgaven, kan den startes.
    func testStartIsEnabledAtTheLocation() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMissionPin("mission.boelgen.den-femte-besked", in: app)

        let start = app.buttons["preview.open"]
        XCTAssertTrue(start.waitForExistence(timeout: Self.uiTimeout))
        XCTAssertTrue(start.isEnabled, "Knappen var lukket, selvom spilleren står ved stedet")
        XCTAssertFalse(
            app.staticTexts["preview.note"].exists,
            "Der stod en advarsel, selvom spilleren er fremme"
        )
    }

    /// Hjemmefra kan den ikke — og det står der hvorfor.
    ///
    /// Flaget kører release-reglen. I Debug må en quizmaster åbne enhver
    /// opgave uden at simulere turen derhen; uden flaget ville denne test
    /// derfor bevise det modsatte af, hvad den hedder. Flaget findes ikke i
    /// Release — dér er værdien en konstant — så det kan ikke bruges til at
    /// åbne gaten hos en spiller.
    func testStartIsDisabledAwayFromTheLocation() {
        // Vejle Banegård, ~1 km fra begge opgaver.
        let app = launchApp(
            atLatitude: 55.7050,
            longitude: 9.5350,
            extraArguments: ["-BHEnforcePresenceGate"]
        )

        // Zoom ud, indtil markøren er synlig.
        let map = app.maps.firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: Self.uiTimeout))
        let pin = app.buttons["mission.mission.boelgen.den-femte-besked"]
        for _ in 0..<4 where !pin.exists {
            map.pinch(withScale: 0.4, velocity: -3)
            Thread.sleep(forTimeInterval: 1.5)
        }
        XCTAssertTrue(pin.exists, "Markøren kom aldrig frem")

        let frame = pin.frame
        tapWindow(at: CGPoint(x: frame.midX, y: frame.midY), in: app)

        let start = app.buttons["preview.open"]
        XCTAssertTrue(start.waitForExistence(timeout: Self.uiTimeout))
        XCTAssertFalse(start.isEnabled, "Opgaven kunne startes hjemmefra — princip I er brudt")

        let note = app.staticTexts["preview.note"]
        XCTAssertTrue(note.waitForExistence(timeout: Self.uiTimeout), "Der manglede en forklaring")
        XCTAssertTrue(note.label.contains("Bølgen"), "Forklaringen nævner ikke stedet: '\(note.label)'")
    }

    /// Ingen advarsler i opgaveflowet.
    ///
    /// Sikkerhedsteksterne er taget ud efter redaktionel beslutning: de passer
    /// ikke til dansk friluftsnorm, og ansvaret er spillerens eget. Data bliver
    /// i indholdspakken til en senere generel side — men de må ikke snige sig
    /// tilbage i turen.
    func testNoSafetyWarningsInTheMissionFlow() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMissionPin("mission.boelgen.den-femte-besked", in: app)
        XCTAssertTrue(app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout))

        XCTAssertFalse(
            app.descendants(matching: .any)
                .containing(NSPredicate(format: "label CONTAINS[c] %@", "vandkant")).firstMatch.exists,
            "Sikkerhedsadvarslen er tilbage på opgavekortet"
        )

        app.buttons["preview.open"].tap()
        XCTAssertFalse(
            app.buttons["safety.continue"].waitForExistence(timeout: 3),
            "\"Inden I går\"-skærmen bliver stadig vist"
        )
    }

    /// Ankomst skal selv åbne opgavekortet.
    func testArrivingOpensThePreviewByItself() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        // Ingen tryk på markøren — kortet skal komme af sig selv.
        XCTAssertTrue(
            app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout),
            "Opgavekortet kom ikke frem, da spilleren stod ved stedet"
        )
        XCTAssertTrue(app.staticTexts["Bølgen – Den femte besked"].exists)
    }

    /// Men opgaven må ikke starte af sig selv.
    func testArrivingDoesNotStartTheMission() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        XCTAssertTrue(app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout))

        // Havde opgaven startet sig selv, ville sikkerhedsskærmen eller det
        // første trin være fremme i stedet for kortet.
        XCTAssertFalse(app.buttons["safety.continue"].exists, "Opgaven startede af sig selv")
        XCTAssertFalse(app.buttons["narrative.continue"].exists, "Opgaven startede af sig selv")
    }
}
