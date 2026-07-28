import XCTest

/// User Story 4: turen overlever afbrydelse og manglende netværk.
final class ResumeAndOfflineTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    /// SC-006. Dræb appen midt i opgaven og bekræft, at den genoptager samme sted.
    func testProgressSurvivesTermination() {
        var app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        // Vi står nu på spørgsmålet — bag tilstedeværelsesgaten, som tog tid at
        // komme igennem. Dræb appen.
        app.terminate()

        // Start igen **uden** at nulstille progressionen.
        app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude,
            resettingProgress: false
        )

        // Spørgsmålet skal komme frem igen — ikke kortet, og ikke gaten forfra.
        //
        // Opgaven har kun ét spørgsmål nu, så testen kan ikke længere vise, at
        // man lander på spor 3 af 3. Det, der stadig kan gå tabt, er hele
        // vejen dertil: kortet, tilstedeværelsen og fortællingen.
        let field = app.textFields["code.field"]
        XCTAssertTrue(
            field.waitForExistence(timeout: Self.presenceTimeout),
            "Appen genoptog ikke på det trin, spilleren stod på"
        )

        enterCode("592", in: app)
        submitCode(in: app)
        assertReward(points: 100, in: app)
    }

    /// SC-006, anden halvdel: et brugt hint skal stadig være brugt efter genstart.
    func testHintStatusSurvivesTermination() {
        var app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        // Åbn hint 1 på observationstrinnet.
        app.buttons["hints.open"].tap()
        app.buttons["hint.reveal.1"].tap()
        app.buttons["Luk"].tap()

        app.terminate()
        app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude,
            resettingProgress: false
        )

        // Hintet skal stå som åbnet — og genåbning må ikke koste igen (FR-019).
        let hints = app.buttons["hints.open"]
        XCTAssertTrue(hints.waitForExistence(timeout: Self.presenceTimeout))
        hints.tap()
        XCTAssertTrue(
            app.staticTexts["Åbnet"].waitForExistence(timeout: Self.uiTimeout),
            "Hintstatus overlevede ikke genstarten"
        )
    }

    /// SC-003. Hele missionen skal kunne gennemføres uden netværk.
    ///
    /// Simulatoren deler værtens netværk og kan ikke sættes i flytilstand
    /// programmatisk. Testen beviser derfor det, den kan bevise maskinelt:
    /// gennemløbet foretager ingen netværkskald. Indholdet er bundlet, loggen er
    /// lokal, og kortet er ikke-kritisk (R-008). Den fysiske flytilstandstest
    /// står i quickstart.md lag 2.
    func testFullFlowMakesNoNetworkRequests() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude,
            extraArguments: ["-BHFailOnNetworkAccess"]
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)
        enterCode("592", in: app)
        submitCode(in: app)

        assertReward(points: 100, in: app)

        // Flaget får appen til at afbryde ved ethvert URLSession-kald.
        // Når vi når hertil uden nedbrud, har intet i gennemløbet rørt netværket.
        XCTAssertEqual(app.state, .runningForeground, "Appen døde undervejs — noget kaldte netværket")
    }
}
