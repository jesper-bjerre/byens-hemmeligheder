import XCTest

/// Fælles fundament for gennemløbstestene.
///
/// ## Hvorfor testene tager tid
///
/// Positionsgaten kræver, at spilleren står stille i den dwell-tid, indholdet
/// angiver — 20 sekunder for begge lokationer. Testene komprimerer ikke uret,
/// fordi ``PresenceGate`` kasserer fixes, der er mere end 15 sekunder gamle: et
/// falsk ur ville få gaten til at afvise sine egne testdata. Ventetiden er
/// derfor ægte, og til gengæld tester den den rigtige adfærd.
class FlowTestCase: XCTestCase {

    /// Rigelig margin til dwell plus animationer.
    static let presenceTimeout: TimeInterval = 60
    static let uiTimeout: TimeInterval = 10

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    /// Starter appen med spilleren placeret præcis på en missions standpunkt.
    func launchApp(
        atLatitude latitude: Double,
        longitude: Double,
        resettingProgress: Bool = true,
        extraArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-BHSimulatedLocation", "\(latitude),\(longitude)",
        ] + extraArguments
        if resettingProgress {
            app.launchArguments.append("-BHResetProgress")
        }
        app.launch()
        return app
    }

    // MARK: - Standpunkter fra indholdspakken

    enum Vantage {
        static let boelgen = (latitude: 55.7089, longitude: 9.5481)
        static let fjordenhus = (latitude: 55.7069, longitude: 9.5518)
    }

    // MARK: - Skridt i gennemløbet

    func tapMission(_ missionId: String, in app: XCUIApplication) {
        let row = app.buttons["mission.\(missionId)"]
        XCTAssertTrue(row.waitForExistence(timeout: Self.uiTimeout), "Opgaven '\(missionId)' står ikke på forsiden")
        row.tap()
    }

    func startMission(in app: XCUIApplication) {
        let start = app.buttons["Tag afsted"]
        XCTAssertTrue(start.waitForExistence(timeout: Self.uiTimeout), "Knappen 'Tag afsted' mangler")
        start.tap()

        // Sikkerhedsskærmen vises før sessionens første mission (FR-008).
        let safety = app.buttons["safety.continue"]
        if safety.waitForExistence(timeout: 3) {
            safety.tap()
        }
    }

    /// Venter på, at gaten verificerer og det første trin åbner.
    func waitForPresence(in app: XCUIApplication) {
        let narrative = app.buttons["narrative.continue"]
        let start = app.buttons["approach.start"]

        let deadline = Date().addingTimeInterval(Self.presenceTimeout)
        while Date() < deadline {
            if narrative.exists { return }
            if start.exists {
                start.tap()
                return
            }
            _ = narrative.waitForExistence(timeout: 2)
        }
        XCTFail("Positionen blev ikke bekræftet inden for \(Int(Self.presenceTimeout)) sekunder")
    }

    func continueNarrative(in app: XCUIApplication) {
        let button = app.buttons["narrative.continue"]
        XCTAssertTrue(button.waitForExistence(timeout: Self.uiTimeout), "Den narrative intro mangler")
        button.tap()
    }

    func chooseOption(_ label: String, in app: XCUIApplication) {
        let option = app.buttons["option.\(label)"]
        XCTAssertTrue(option.waitForExistence(timeout: Self.uiTimeout), "Svarmuligheden '\(label)' mangler")
        option.tap()
    }

    func enterCode(_ code: String, in app: XCUIApplication) {
        let field = app.textFields["code.field"]
        XCTAssertTrue(field.waitForExistence(timeout: Self.uiTimeout), "Kodefeltet mangler")
        field.tap()
        XCTAssertTrue(
            app.keyboards.element.waitForExistence(timeout: Self.uiTimeout),
            "Tastaturet kom ikke op til kodefeltet"
        )
        field.typeText(code)
    }

    /// Tømmer kodefeltet og **bekræfter**, at det blev tomt.
    ///
    /// Feltets `accessibilityValue` er læsevenlig ("5 9 2", ikke "592"), fordi
    /// VoiceOver skal læse cifrene enkeltvis. Den værdi kan derfor ikke bruges
    /// til at tælle sletninger med — feltet tømmes i stedet, indtil det melder
    /// sig tomt.
    func clearCode(in app: XCUIApplication) {
        let field = app.textFields["code.field"]
        guard field.exists else { return }

        // Tastaturet skal være oppe, før sletninger lander. Uden ventetiden
        // sender testen tasteanslag ud i ingenting, og fejlen viser sig først
        // som et mystisk restindhold i feltet flere skridt senere.
        field.tap()
        XCTAssertTrue(
            app.keyboards.element.waitForExistence(timeout: Self.uiTimeout),
            "Tastaturet kom ikke op til kodefeltet"
        )

        for _ in 0..<12 {
            if (field.value as? String) == "Tomt" { return }
            field.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        XCTAssertEqual(field.value as? String, "Tomt", "Kodefeltet kunne ikke tømmes")
    }

    func submitCode(in app: XCUIApplication) {
        let submit = app.buttons["code.submit"]
        XCTAssertTrue(submit.waitForExistence(timeout: Self.uiTimeout), "Send-knappen mangler")
        submit.tap()
    }

    func assertReward(points: Int, in app: XCUIApplication) {
        // Elementtypen for et sammensat tilgængelighedselement er ikke stabil
        // på tværs af iOS-versioner. Slå op på id frem for på type.
        let reward = app.descendants(matching: .any)["reward.points"]
        XCTAssertTrue(
            reward.waitForExistence(timeout: Self.uiTimeout),
            "Belønningsskærmen kom ikke frem"
        )
        XCTAssertTrue(
            reward.label.contains("\(points)"),
            "Forventede \(points) point, skærmen sagde '\(reward.label)'"
        )
    }
}
