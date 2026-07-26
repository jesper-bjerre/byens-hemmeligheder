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

    /// Trykker på opgavens markør på kortet og åbner den fra popuppen.
    ///
    /// Forsiden er kortet — der findes ingen liste. Markøren er en knap med sit
    /// eget id, netop så den kan findes her uden at gå gennem MapKits
    /// markeringsbinding.
    func tapMission(_ missionId: String, in app: XCUIApplication) {
        tapMissionPin(missionId, in: app)

        let open = app.buttons["preview.open"]
        XCTAssertTrue(
            open.waitForExistence(timeout: Self.uiTimeout),
            "Popuppen med opgavebeskrivelsen kom ikke frem"
        )
        open.tap()
    }

    /// Åbner kun popuppen, uden at gå videre til detaljen.
    func tapMissionPin(_ missionId: String, in app: XCUIApplication) {
        let pin = app.buttons["mission.\(missionId)"]
        XCTAssertTrue(
            pin.waitForExistence(timeout: Self.uiTimeout),
            "Opgavens markør '\(missionId)' står ikke på kortet"
        )

        // Vent på, at markøren står stille. Dukker den op, mens kortet stadig
        // centrerer, flytter den sig under fingeren.
        var previous = pin.frame
        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 0.2)
            let current = pin.frame
            if current == previous { break }
            previous = current
        }

        pin.tap()
        if !app.buttons["preview.open"].waitForExistence(timeout: 3) {
            pin.tap()
        }
    }

    /// Kvitterer for sikkerhedsskærmen, hvis den vises.
    ///
    /// "Start opgave" på opgavekortet går nu direkte i gang — der er ikke
    /// længere et missionsark imellem. Tilbage er kun sikkerhedsskærmen, som
    /// vises én gang pr. session (FR-008).
    func startMission(in app: XCUIApplication) {
        let safety = app.buttons["safety.continue"]
        if safety.waitForExistence(timeout: 5) {
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

    /// Tømmer kodefeltet via appens egen ryd-knap.
    ///
    /// Tidligere sendte testen sletteanslag ind i feltet. Det var upålideligt:
    /// feltets rapporterede værdi nåede at være forældet mellem anslagene, og
    /// testen efterlod rester, der først viste sig som et forkert svar flere
    /// skridt senere. En knap i appen er både mere robust at teste og bedre for
    /// en spiller med handsker på.
    func clearCode(in app: XCUIApplication) {
        let clear = app.buttons["code.clear"]
        guard clear.waitForExistence(timeout: Self.uiTimeout) else { return }
        clear.tap()

        let field = app.textFields["code.field"]
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
