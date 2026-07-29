import XCTest

/// Hvordan opgavekortet på kortet lukkes.
///
/// Krydset i hjørnet er væk. Det optog hele højre side af overlayet uden at
/// bruge den, og et mål på 44×44 i et hjørne er det sværeste sted på skærmen
/// at ramme med en tommelfinger. I stedet er der to store mål: knappen
/// "Tilbage til kortet" og hele fladen ved siden af kortet.
///
/// ## Hvorfor det kræver en test og ikke bare et øjekast
///
/// Kortet ligger som et `overlay` oven på MapKit, og kortet har sin egen
/// tryklytter, der rydder markeringen, når trykket ikke rammer en markør.
/// Om et tryk **inde i** overlayet også når ned til den lytter, er ikke til at
/// læse sig til — det afhænger af, hvordan SwiftUI leverer trykket gennem
/// lagene. Gør det, lukker kortet sig selv, så snart spilleren rører teasteksten.
final class PreviewDismissTests: FlowTestCase {

    private let missionId = "mission.frydenlund98.veras-hemmelige-snack"

    /// Det, der er nemmest at komme til at ødelægge.
    func testTappingInsideTheCardKeepsItOpen() {
        let app = launchApp(
            atLatitude: Vantage.frydenlund98.latitude,
            longitude: Vantage.frydenlund98.longitude
        )

        tapMissionPin(missionId, in: app)
        let dismiss = app.buttons["preview.dismiss"]
        XCTAssertTrue(dismiss.waitForExistence(timeout: Self.uiTimeout))

        // Tryk midt på beskrivelsen — et sted i kortet uden knap.
        let summary = app.descendants(matching: .any)["preview.summary"]
        XCTAssertTrue(summary.waitForExistence(timeout: Self.uiTimeout), "Beskrivelsen stod ikke på kortet")
        summary.tap()

        XCTAssertTrue(
            dismiss.exists,
            "Opgavekortet lukkede sig selv, da spilleren rørte ved det"
        )
    }

    func testTheDismissButtonClosesTheCard() {
        let app = launchApp(
            atLatitude: Vantage.frydenlund98.latitude,
            longitude: Vantage.frydenlund98.longitude
        )

        tapMissionPin(missionId, in: app)
        let dismiss = app.buttons["preview.dismiss"]
        XCTAssertTrue(dismiss.waitForExistence(timeout: Self.uiTimeout))
        dismiss.tap()

        XCTAssertTrue(
            waitForDisappearance(of: dismiss),
            "Kortet blev stående efter 'Tilbage til kortet'"
        )
    }

    /// Tryk ved siden af — på selve kortet, langt fra enhver markør.
    func testTappingBesideTheCardClosesIt() {
        let app = launchApp(
            atLatitude: Vantage.frydenlund98.latitude,
            longitude: Vantage.frydenlund98.longitude
        )

        tapMissionPin(missionId, in: app)
        let dismiss = app.buttons["preview.dismiss"]
        XCTAssertTrue(dismiss.waitForExistence(timeout: Self.uiTimeout))

        // Øverste venstre hjørne af kortfladen: over overlayet, som ligger
        // nederst, og langt fra begge markører ved Frydenlund 98.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.28))
            .withOffset(CGVector(dx: 0, dy: 0))
            .tap()

        XCTAssertTrue(
            waitForDisappearance(of: dismiss),
            "Kortet blev stående, da spilleren trykkede ved siden af det"
        )
    }

    private func waitForDisappearance(of element: XCUIElement) -> Bool {
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element)
        return XCTWaiter().wait(for: [gone], timeout: Self.uiTimeout) == .completed
    }
}
