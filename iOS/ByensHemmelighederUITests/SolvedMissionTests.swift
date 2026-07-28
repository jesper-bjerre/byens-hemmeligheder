import XCTest

/// En gåde løses kun én gang — for spilleren.
///
/// Anden gang kender hen facit, og så måler pointene ikke længere det, de skal
/// måle. Regnskabet har hele tiden været sikret — hverken motoren eller folden
/// tæller den samme gennemførelse to gange — men spillet kunne spilles om.
/// Disse tests dækker indgangen, ikke kassen.
///
/// ## Hvorfor der sendes et flag ind
///
/// Under udvikling skal det samme gennemløb kunne køres igen og igen, så
/// spærringen er slået fra i Debug. Men det er netop i Debug, testene kører, og
/// en regel, der kun findes i Release, er en regel, ingen test nogensinde ser.
///
/// `-BHEnforceReplayBlock` kører derfor release-reglen i en debugbygning.
/// Flaget findes ikke i Release — dér er værdien en konstant — så det kan ikke
/// bruges til at slå spærringen *fra* hos en spiller.
final class SolvedMissionTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    /// Kører appen med release-reglen for genspilning.
    private func launchAsRelease(resettingProgress: Bool = true) -> XCUIApplication {
        launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude,
            resettingProgress: resettingProgress,
            extraArguments: ["-BHEnforceReplayBlock"]
        )
    }

    // MARK: - Release: spærret

    /// Løs opgaven, gå tilbage til kortet, tryk på markøren igen.
    func testASolvedMissionCannotBeStartedAgain() {
        let app = launchAsRelease()

        solveBoelgen(in: app)

        app.buttons["reward.done"].tap()

        // Tilbage på kortet. Markøren står der stadig — den er en del af byen,
        // også når den er løst — men popuppen tilbyder ikke at starte igen.
        tapMissionPin(missionId, in: app)

        XCTAssertFalse(
            app.buttons["preview.open"].exists,
            "Knappen 'Start opgave' stod på en løst opgave"
        )

        let note = app.staticTexts["preview.note"]
        XCTAssertTrue(
            note.waitForExistence(timeout: Self.uiTimeout),
            "Der stod intet om, hvorfor opgaven ikke kan startes"
        )
        XCTAssertEqual(note.label, "Gåden er løst. Den kan kun løses én gang.")
    }

    /// Spærringen må ikke kunne gå tabt ved en genstart.
    ///
    /// Den er udledt af hændelsesloggen og ikke af noget, der kun findes i
    /// hukommelsen — men det er præcis den slags, der først viser sig næste
    /// gang appen åbnes.
    func testTheBlockSurvivesTermination() {
        var app = launchAsRelease()

        solveBoelgen(in: app)
        app.terminate()

        app = launchAsRelease(resettingProgress: false)

        // Navigationsstien genskabes, så appen åbner på belønningsskærmen.
        // Den skal kunne tegnes **uden** en session: `startSession` afviser den
        // løste opgave, og skærmen henter derfor point fra spillertilstanden.
        let done = app.buttons["reward.done"]
        XCTAssertTrue(
            done.waitForExistence(timeout: Self.presenceTimeout),
            "Belønningsskærmen overlevede ikke genstarten uden en session"
        )
        XCTAssertEqual(app.staticTexts["reward.points"].label, "Du fik 100 point")
        done.tap()

        tapMissionPin(missionId, in: app)
        XCTAssertFalse(
            app.buttons["preview.open"].exists,
            "Opgaven kunne startes igen efter en genstart"
        )
    }

    /// Positiv kontrol.
    ///
    /// Uden den ville begge tests ovenfor også bestå, hvis "Start opgave"
    /// forsvandt fra *alle* opgaver — og så beviste de ingenting.
    func testAnUnsolvedMissionStillOffersToStart() {
        let app = launchAsRelease()

        tapMissionPin(missionId, in: app)
        XCTAssertTrue(
            app.buttons["preview.open"].exists,
            "En uløst opgave tilbød ikke at blive startet"
        )
    }

    // MARK: - Debug: fri genspilning

    /// Uden flaget er det en almindelig debugbygning, og så skal det samme
    /// gennemløb kunne køres forfra.
    func testDebugCanReplayASolvedMission() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        solveBoelgen(in: app)
        app.buttons["reward.done"].tap()

        // Hele vejen igennem igen — ikke bare knappen, men gennemløbet.
        solveBoelgen(in: app)
    }

    /// Genspilning må ikke koste eller give noget.
    ///
    /// Belønningsskærmen viser stadig 100 efter anden runde: `complete` skriver
    /// ikke en gennemførelse nummer to, og hintet står som åbnet, fordi
    /// `revealedHintIds` læses fra spillertilstanden og ikke fra sessionen.
    /// Det er dét, `solveBoelgen` ovenfor allerede hævder med `assertReward`,
    /// men her siges det om den tilstand, der overlever runden.
    func testReplayKeepsHintAndPointHistory() {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )

        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        // Brug ét hint, så der er en historik at miste.
        app.buttons["hints.open"].tap()
        app.buttons["hint.reveal.1"].tap()
        app.buttons["Luk"].tap()

        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)
        enterCode("592", in: app)
        submitCode(in: app)
        assertReward(points: 97, in: app)
        app.buttons["reward.done"].tap()

        // Anden runde: hintet er stadig åbnet, og fradraget står stadig.
        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        app.buttons["hints.open"].tap()
        XCTAssertTrue(
            app.staticTexts["Åbnet"].waitForExistence(timeout: Self.uiTimeout),
            "Hinthistorikken blev nulstillet af en genspilning"
        )
        app.buttons["Luk"].tap()

        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)
        enterCode("592", in: app)
        submitCode(in: app)

        assertReward(points: 97, in: app)
    }

    // MARK: - Hjælper

    private func solveBoelgen(in app: XCUIApplication) {
        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)
        enterCode("592", in: app)
        submitCode(in: app)

        assertReward(points: 100, in: app)
    }
}
