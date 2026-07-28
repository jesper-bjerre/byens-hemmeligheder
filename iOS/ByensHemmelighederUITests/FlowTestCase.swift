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
        // Der ventes på lukkeknappen og ikke på "Start opgave": den sidste
        // findes ikke på en løst opgave, og så ville hvert eneste tryk her
        // koste tre sekunder og et overflødigt gentryk.
        if !app.buttons["preview.close"].waitForExistence(timeout: 3) {
            pin.tap()
        }
    }

    /// Ikke længere noget skridt mellem opgavekortet og stedet.
    ///
    /// "Start opgave" går direkte til approach-skærmen. Sikkerhedsskærmen er
    /// taget ud af flowet efter redaktionel beslutning. Metoden bevares, så
    /// gennemløbstestene læser som rejsen gør.
    func startMission(in app: XCUIApplication) {}

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

    /// Går videre fra den narrative intro.
    ///
    /// **Ét tryk, aldrig to.** Et gentagelsesforsøg blev prøvet og forkastet:
    /// når skærmen allerede var skiftet, landede andet tryk på det næste trin
    /// og ramte en anden knap. Kuren var værre end sygdommen.
    ///
    /// Ventetiden på `isHittable` er den rigtige beskyttelse — knappen kan
    /// findes, mens visningen stadig glider ind, og et tryk midt i en overgang
    /// lander ingen steder.
    func continueNarrative(in app: XCUIApplication) {
        let button = app.buttons["narrative.continue"]
        XCTAssertTrue(button.waitForExistence(timeout: Self.uiTimeout), "Den narrative intro mangler")

        let deadline = Date().addingTimeInterval(5)
        while !button.isHittable, Date() < deadline {
            Thread.sleep(forTimeInterval: 0.2)
        }
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

    /// Tømmer kodefeltet med tastaturet.
    ///
    /// Appen havde kortvarigt en "Ryd"-knap, som denne hjælper brugte. Den er
    /// fjernet igen: spilleren kan selv slette, og hvert ekstra element er et
    /// spørgsmål mere om, hvad man skal.
    ///
    /// Der trykkes på feltet **før hver** omgang sletninger. Efter et tryk på
    /// "Svar" har feltet ikke nødvendigvis fokus længere, og tasteanslag uden
    /// fokus falder på gulvet — feltet så uændret ud, uden at noget fejlede.
    func clearCode(in app: XCUIApplication) {
        let field = app.textFields["code.field"]
        guard field.exists else { return }

        for _ in 0..<3 {
            if (field.value as? String) == "Tomt" { return }

            field.tap()
            guard app.keyboards.element.waitForExistence(timeout: Self.uiTimeout) else { continue }
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 10))
        }

        XCTAssertEqual(field.value as? String, "Tomt", "Kodefeltet kunne ikke tømmes")
    }

    /// Skriver et fritekstsvar (`freeText`-trin).
    func enterText(_ text: String, in app: XCUIApplication) {
        let field = app.textFields["text.field"]
        XCTAssertTrue(field.waitForExistence(timeout: Self.uiTimeout), "Tekstfeltet mangler")
        field.tap()
        XCTAssertTrue(
            app.keyboards.element.waitForExistence(timeout: Self.uiTimeout),
            "Tastaturet kom ikke op til tekstfeltet"
        )
        field.typeText(text)
    }

    func submitText(in app: XCUIApplication) {
        let submit = app.buttons["text.submit"]
        XCTAssertTrue(submit.waitForExistence(timeout: Self.uiTimeout), "Svar-knappen mangler")
        submit.tap()
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
