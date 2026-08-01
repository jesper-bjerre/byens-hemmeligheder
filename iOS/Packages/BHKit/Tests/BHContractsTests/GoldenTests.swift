import BHContracts
import BHTestSupport
import Foundation
import Testing

/// Kontraktvagten.
///
/// ## Hvad testen faktisk beskytter
///
/// `BHContracts`-typerne *er* API-DTO'erne (research.md R-003). Der findes ingen
/// mapping til at absorbere en omdøbning, så `shortTitle → subtitle` er ikke en
/// refaktorering — det er et brud på wire-formatet, der vil ramme enhver
/// klient, der allerede er shippet, og enhver indholdspakke, der allerede er
/// skrevet.
///
/// Swifts omdøbningsværktøj gør netop den ændring til ét tastetryk uden en
/// eneste advarsel. Denne test er advarslen.
///
/// ## Sådan opdaterer du en golden-fil
///
/// Kun når ændringen er tilsigtet og additiv:
///
/// ```sh
/// BH_REGENERATE_GOLDEN=1 swift test --filter Golden
/// ```
///
/// Læs derefter diffen. Er der forsvundet eller skiftet navn på et felt, er det
/// **ikke** en additiv ændring, og den hører til i en ny skemaversion.
@Suite("Golden-serialisering")
struct GoldenTests {

    /// Sat via miljøvariabel, aldrig via en konstant i koden. En genskabelse,
    /// der kan slås til ved et uheld, gør testen værdiløs.
    static var isRegenerating: Bool {
        ProcessInfo.processInfo.environment["BH_REGENERATE_GOLDEN"] == "1"
    }

    // MARK: - Selve sammenligningen

    private func assertGolden(_ value: some Encodable & Decodable, named name: String) throws {
        let encoded = try BHJSON.goldenEncoder.encode(value)
        let url = ContractFixtures.goldenDirectory.appending(path: "\(name).json")

        if Self.isRegenerating {
            try FileManager.default.createDirectory(
                at: ContractFixtures.goldenDirectory,
                withIntermediateDirectories: true
            )
            try encoded.write(to: url, options: [.atomic])
            return
        }

        guard let expected = try? Data(contentsOf: url) else {
            Issue.record("""
                Golden-filen '\(name).json' findes ikke.
                Er typen ny, så kør: BH_REGENERATE_GOLDEN=1 swift test --filter Golden
                """)
            return
        }

        let actualText = String(decoding: encoded, as: UTF8.self)
        let expectedText = String(decoding: expected, as: UTF8.self)

        #expect(actualText == expectedText, """
            \(name) serialiserer ikke længere som golden-filen.

            DETTE ER EN API-ÆNDRING, ikke en refaktorering.

            Kontrakten tillader kun additive ændringer. Er et felt omdøbt eller
            fjernet, skal ændringen rulles tilbage eller lægges i en ny
            skemaversion. Er feltet nyt og optional, kan filen genskabes med:
              BH_REGENERATE_GOLDEN=1 swift test --filter Golden

            \(Self.firstDifference(expected: expectedText, actual: actualText))
            """)
    }

    /// Peger på den første linje, der afviger. En 200-linjers diff i en
    /// fejlbesked bliver ikke læst.
    static func firstDifference(expected: String, actual: String) -> String {
        let expectedLines = expected.split(separator: "\n", omittingEmptySubsequences: false)
        let actualLines = actual.split(separator: "\n", omittingEmptySubsequences: false)

        for index in 0..<max(expectedLines.count, actualLines.count) {
            let expectedLine = index < expectedLines.count ? String(expectedLines[index]) : "(filen slutter)"
            let actualLine = index < actualLines.count ? String(actualLines[index]) : "(filen slutter)"
            if expectedLine != actualLine {
                return """
                    Første forskel på linje \(index + 1):
                      golden: \(expectedLine.trimmingCharacters(in: .whitespaces))
                      nu:     \(actualLine.trimmingCharacters(in: .whitespaces))
                    """
            }
        }
        return "Filerne har samme linjer, men afviger i bytes."
    }

    // MARK: - Indholdsmodellen


    @Test("Location") func location() throws {
        try assertGolden(GoldenSamples.location, named: "Location")
    }

    @Test("Mission") func mission() throws {
        try assertGolden(GoldenSamples.mission, named: "Mission")
    }

    @Test("AnswerRule") func answerRule() throws {
        try assertGolden(GoldenSamples.answerRule, named: "AnswerRule")
    }

    @Test("Hint") func hint() throws {
        try assertGolden(GoldenSamples.hint, named: "Hint")
    }

    @Test("Completion") func completion() throws {
        try assertGolden(GoldenSamples.completion, named: "Completion")
    }

    @Test("EvidenceCard") func evidenceCard() throws {
        try assertGolden(GoldenSamples.evidenceCard, named: "EvidenceCard")
    }

    @Test("MediaAsset") func mediaAsset() throws {
        try assertGolden(GoldenSamples.mediaAsset, named: "MediaAsset")
    }

    @Test("Source") func source() throws {
        try assertGolden(GoldenSamples.source, named: "Source")
    }

    @Test("ContentPack") func contentPack() throws {
        try assertGolden(GoldenSamples.contentPack, named: "ContentPack")
    }

    // MARK: - Trintyperne hver for sig

    @Test("Step: narrative") func narrativeStep() throws {
        try assertGolden(Step.narrative(GoldenSamples.narrativeStep), named: "Step.narrative")
    }

    @Test("Step: singleChoice") func singleChoiceStep() throws {
        try assertGolden(Step.singleChoice(GoldenSamples.singleChoiceStep), named: "Step.singleChoice")
    }

    @Test("Step: numericCode") func numericCodeStep() throws {
        try assertGolden(Step.numericCode(GoldenSamples.numericCodeStep), named: "Step.numericCode")
    }

    @Test("Step: freeText") func freeTextStep() throws {
        try assertGolden(Step.freeText(GoldenSamples.freeTextStep), named: "Step.freeText")
    }

    // MARK: - Kørselsmodellen

    @Test("GameEvent") func gameEvent() throws {
        try assertGolden(GoldenSamples.gameEvent, named: "GameEvent")
    }

    @Test("PresenceEvidence") func presenceEvidence() throws {
        try assertGolden(GoldenSamples.presenceEvidence, named: "PresenceEvidence")
    }

    @Test("GameSession") func gameSession() throws {
        try assertGolden(GoldenSamples.gameSession, named: "GameSession")
    }

    // MARK: - Egenskaber, golden-filerne ikke i sig selv fanger

    @Test("Hver golden-fil kan afkodes tilbage til sin type")
    func goldenFilesDecodeBack() throws {
        // Beskytter mod, at en encoder-ændring gør filerne pæne, men ulæselige.
        let pack = try decodeGolden(ContentPack.self, named: "ContentPack")
        #expect(pack.missions.count == 1)
        #expect(pack.missions[0].steps.count == 3)

        let event = try decodeGolden(GameEvent.self, named: "GameEvent")
        #expect(event.id == GoldenSamples.uuid)
        #expect(event.occurredAt == GoldenSamples.date)
    }

    @Test("Serialisering er stabil ved gentagen kodning")
    func encodingIsIdempotent() throws {
        let once = try BHJSON.goldenEncoder.encode(GoldenSamples.contentPack)
        let decoded = try BHJSON.decoder.decode(ContentPack.self, from: once)
        let twice = try BHJSON.goldenEncoder.encode(decoded)
        #expect(once == twice, "En round-trip ændrer wire-formatet")
    }

    /// FR-003. Ukendte enum-værdier skal overleve en round-trip uændret —
    /// ellers ville en gammel klient stiltiende omskrive nyere data.
    @Test("En ukendt enum-værdi bevares gennem kodning")
    func unknownEnumValueSurvivesRoundTrip() throws {
        let encoded = try BHJSON.goldenEncoder.encode(GoldenSamples.unknownKindEvent)
        let decoded = try BHJSON.decoder.decode(GameEvent.self, from: encoded)

        #expect(decoded.kind == .unknown("photoCaptured"))
        #expect(decoded.kind.rawValue == "photoCaptured")
        #expect(decoded.kind.known == nil)
    }

    /// Wire-navnene er Swift-navnene. Uden dette ville en nøglestrategi kunne
    /// skjule en omdøbning for golden-testen.
    @Test("Der bruges ingen key-konverteringsstrategi")
    func noKeyConversionStrategy() throws {
        let encoded = try BHJSON.goldenEncoder.encode(GoldenSamples.location)
        let text = String(decoding: encoded, as: UTF8.self)

        #expect(text.contains("\"activationRadiusMetres\""), "camelCase skal stå urørt")
        #expect(!text.contains("activation_radius_metres"), "snake_case ville bryde kontrakten")
    }

    @Test("Datoer skrives som ISO 8601 med fraktionelle sekunder")
    func datesUseISO8601() throws {
        let encoded = try BHJSON.goldenEncoder.encode(GoldenSamples.presenceEvidence)
        let text = String(decoding: encoded, as: UTF8.self)
        #expect(text.contains("2027-01-15T"), "Datoen skal være ISO 8601, ikke et sekundtal")
        #expect(text.contains("."), "Fraktionelle sekunder mangler — ASP.NET Core sender dem")
    }

    // MARK: - Hjælpere

    private func decodeGolden<T: Decodable>(_ type: T.Type, named name: String) throws -> T {
        let url = ContractFixtures.goldenDirectory.appending(path: "\(name).json")
        return try BHJSON.decoder.decode(type, from: try Data(contentsOf: url))
    }
}
