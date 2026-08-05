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
        static let boelgen = (latitude: 55.710503, longitude: 9.557547)
        static let fjordenhus = (latitude: 55.706393, longitude: 9.554360)
        /// To opgaver deler denne adresse — derfor spredes markørerne her.
        static let frydenlund98 = (latitude: 55.734897, longitude: 9.620270)
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
        // Der ventes på "Tilbage til kortet" og ikke på "Start opgave": den
        // sidste findes ikke på en løst opgave, og så ville hvert eneste tryk
        // her koste tre sekunder og et overflødigt gentryk.
        if !app.buttons["preview.dismiss"].waitForExistence(timeout: 3) {
            pin.tap()
        }
    }

    /// Ikke længere noget skridt mellem opgavekortet og stedet.
    ///
    /// "Start opgave" går direkte til approach-skærmen. Sikkerhedsskærmen er
    /// taget ud af flowet efter redaktionel beslutning. Metoden bevares, så
    /// gennemløbstestene læser som rejsen gør.
    func startMission(in app: XCUIApplication) {}

    /// Venter på, at gaten verificerer og opgavesiden åbner.
    ///
    /// Der ventes på hint-knappen. Den står på **hver** opgaveside, uanset om
    /// der svares med kode, fritekst eller fire valgmuligheder — modsat
    /// svarknappen, som ikke findes, når svaret er et valg. Ét kendemærke er
    /// nok, når siden er den samme for alle opgaver.
    func waitForPresence(in app: XCUIApplication) {
        let page = app.buttons["hints.open"]
        let start = app.buttons["approach.start"]

        let deadline = Date().addingTimeInterval(Self.presenceTimeout)
        while Date() < deadline {
            if page.exists { return }
            if start.exists {
                start.tap()
                return
            }
            _ = page.waitForExistence(timeout: 2)
        }
        XCTFail("Positionen blev ikke bekræftet inden for \(Int(Self.presenceTimeout)) sekunder")
    }

    /// Venter på, at opgavesiden er fremme.
    ///
    /// Der var før en "Jeg er klar"-knap mellem fortællingen og spørgsmålet.
    /// Den er væk: hele opgaven ligger på én side med kortene øverst og svaret
    /// nederst. Metoden er bevaret, så gennemløbstestene stadig læser som
    /// rejsen gør — men den trykker ikke længere på noget.
    func continueNarrative(in app: XCUIApplication) {
        let cards = app.scrollViews.firstMatch
        XCTAssertTrue(cards.waitForExistence(timeout: Self.uiTimeout), "Opgavesiden kom ikke frem")
    }

    /// Quizmasterens spørgsmål skal stå over svaret uanset svartype.
    func assertQuestion(_ text: String, in app: XCUIApplication) {
        let question = app.descendants(matching: .any)["challenge.question"]
        XCTAssertTrue(
            question.waitForExistence(timeout: Self.uiTimeout),
            "Quizmasterens spørgsmål mangler ved svarfeltet"
        )
        XCTAssertEqual(question.label, text)
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

    /// Hævder, at kodefeltet er tomt.
    ///
    /// Appen tømmer det selv efter et svar, der ikke var rigtigt. Hjælperen her
    /// hed før `clearCode` og slettede baglæns med tastaturet — indtil det gik
    /// op for os, at spilleren ikke *kunne* gøre andet: feltet holder præcis så
    /// mange cifre, som koden er lang, så et fyldt felt kasserer alt nyt
    /// tastetryk. Testen kæmpede med en blindgyde, appen havde, og ikke med
    /// XCUITest.
    func assertCodeFieldIsEmpty(in app: XCUIApplication) {
        let field = app.textFields["code.field"]
        XCTAssertTrue(
            field.waitForExistence(timeout: Self.uiTimeout),
            "Kodefeltet forsvandt"
        )
        XCTAssertEqual(
            field.value as? String,
            "Tomt",
            "Feltet blev ikke tømt efter et forkert svar — spilleren kan ikke taste videre"
        )
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
        let submit = app.buttons[ChallengeIdentifiers.submit]
        XCTAssertTrue(submit.waitForExistence(timeout: Self.uiTimeout), "Svar-knappen mangler")
        submit.tap()
    }

    func submitCode(in app: XCUIApplication) {
        let submit = app.buttons[ChallengeIdentifiers.submit]
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

/// Id'er, appen og testene deler.
///
/// Svarknappen hed før `code.submit` i én opgave og `text.submit` i en anden.
/// To navne på den samme handling betyder, at en test skal vide, hvilken slags
/// opgave den kigger på — og så er testene lige så uens, som skærmene var.
enum ChallengeIdentifiers {
    static let submit = "challenge.submit"
    static let header = "challenge.header"
}
