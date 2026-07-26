import XCTest

/// Automatiseret tilgængelighedsaudit på hver nøgleskærm.
///
/// `performAccessibilityAudit` fanger manglende etiketter, for små trykflader,
/// afskåret tekst ved store skriftstørrelser og utilstrækkelig kontrast. Den
/// erstatter **ikke** den manuelle VoiceOver-gennemgang i quickstart lag 3 —
/// en skærm kan bestå auditten og stadig være ubrugelig at navigere i blinde.
/// Den fanger til gengæld de fejl, et menneske holder op med at opdage efter
/// tyvende gennemløb.
final class AccessibilityAuditTests: FlowTestCase {

    private let missionId = "mission.boelgen.den-femte-besked"

    /// Kontrasten på fiktions- og sikkerhedsmærkaterne er bevidst dæmpet mod
    /// deres egen tonede baggrund. Auditten måler mod sidens baggrund og melder
    /// derfor falsk — kontrasten er kontrolleret i BHDesignSystem.
    private let ignored: XCUIAccessibilityAuditType = [.contrast]

    /// Kortskærmen og opgavekortet fravælger desuden `.hitRegion`.
    ///
    /// Apples egen "Juridiske oplysninger"-attribution er 10 pt høj, og den er
    /// MapKits — ikke vores. R-008 forbyder udtrykkeligt at dække den, så den
    /// kan hverken forstørres eller flyttes. Alle vores egne trykflader på
    /// skærmen er mindst 44 pt.
    private let ignoredOnMap: XCUIAccessibilityAuditType = [.contrast, .hitRegion]

    private func audit(
        _ app: XCUIApplication,
        screen: String,
        excluding: XCUIAccessibilityAuditType? = nil
    ) throws {
        try app.performAccessibilityAudit(for: .all.subtracting(excluding ?? ignored)) { issue in
            // Uden elementets identitet er en auditfejl umulig at rette —
            // beskeden alene siger kun *hvad*, ikke *hvor*. Værdierne trækkes
            // ud som strenge her, fordi `issue` ikke er `Sendable`.
            let summary = issue.compactDescription
            let element = issue.element?.debugDescription ?? "(ukendt element)"
            print("AUDIT [\(screen)] \(summary)\n\(element)\n---")
            return false  // ingen fejl accepteres
        }
    }

    func testMapScreenIsAccessible() throws {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        XCTAssertTrue(app.buttons["mission.\(missionId)"].waitForExistence(timeout: Self.uiTimeout))
        try audit(app, screen: "Kort", excluding: ignoredOnMap)
    }

    func testMissionPreviewPopupIsAccessible() throws {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMissionPin(missionId, in: app)
        XCTAssertTrue(app.buttons["preview.open"].waitForExistence(timeout: Self.uiTimeout))
        // Kortet ligger synligt bag overlayet, så Apples attribution tælles med.
        try audit(app, screen: "Opgavepopup", excluding: ignoredOnMap)
    }

    /// Sikkerhedsskærmen ligger nu direkte mellem kortet og opgaven.
    func testSafetyInterstitialIsAccessible() throws {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMission(missionId, in: app)
        XCTAssertTrue(app.buttons["safety.continue"].waitForExistence(timeout: Self.uiTimeout))
        try audit(app, screen: "Sikkerhed")
    }

    func testChallengeScreensAreAccessible() throws {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)

        try audit(app, screen: "Narrativ intro")
        continueNarrative(in: app)

        try audit(app, screen: "Valgspørgsmål")
        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)

        try audit(app, screen: "Talkode")
    }

    func testHintSheetIsAccessible() throws {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        app.buttons["hints.open"].tap()
        XCTAssertTrue(app.buttons["hint.reveal.1"].waitForExistence(timeout: Self.uiTimeout))
        try audit(app, screen: "Hints")
    }

    func testRewardScreenIsAccessible() throws {
        let app = launchApp(
            atLatitude: Vantage.boelgen.latitude,
            longitude: Vantage.boelgen.longitude
        )
        tapMission(missionId, in: app)
        startMission(in: app)
        waitForPresence(in: app)
        continueNarrative(in: app)

        chooseOption("5", in: app)
        chooseOption("9", in: app)
        chooseOption("2", in: app)
        enterCode("592", in: app)
        submitCode(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["reward.points"].waitForExistence(timeout: Self.uiTimeout))
        try audit(app, screen: "Belønning")
    }
}
