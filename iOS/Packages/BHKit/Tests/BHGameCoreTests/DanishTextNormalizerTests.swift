import BHContracts
import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

/// Tabeldrevet fra `contracts/spec/answer-testvectors.json`.
///
/// Vektorerne ligger i JSON og ikke i Swift, fordi de samme vektorer senere
/// skal køre i xUnit mod ASP.NET Core-implementeringen (research.md R-010). En
/// vektor tilføjet i JSON dækker dermed begge sider på én gang.
@Suite("Dansk svarnormalisering")
struct DanishTextNormalizerTests {

    struct Vector: Sendable, CustomStringConvertible {
        let name: String
        let input: String
        let profile: String
        let expected: String

        var description: String { name }

        var options: DanishTextNormalizer.Options {
            profile == "digitsOnly" ? .numericCode : .text
        }
    }

    static let vectors: [Vector] = {
        guard let json = try? ContractFixtures.specJSON("answer-testvectors.json"),
              let raw = json["normalization"] as? [[String: Any]]
        else { return [] }

        return raw.compactMap { entry in
            guard let name = entry["name"] as? String,
                  let input = entry["input"] as? String,
                  let profile = entry["profile"] as? String,
                  let expected = entry["expected"] as? String
            else { return nil }
            return Vector(name: name, input: input, profile: profile, expected: expected)
        }
    }()

    @Test("Vektorfilen er fundet og ikke tom")
    func vectorsAreLoaded() {
        #expect(!Self.vectors.isEmpty, "Fandt ingen normaliseringsvektorer — er stien til contracts/ korrekt?")
    }

    @Test("Normalisering følger vektoren", arguments: vectors)
    func normalizes(_ vector: Vector) {
        let actual = DanishTextNormalizer.normalize(vector.input, options: vector.options)
        #expect(
            actual == vector.expected,
            "\(vector.name): '\(vector.input)' gav '\(actual)', forventede '\(vector.expected)'"
        )
    }

    // MARK: - De regler, der er dyrest at få galt i halsen

    @Test("Foranstillede nuller er betydende")
    func leadingZeroesSurvive() {
        // Går denne i stykker, er en talkonvertering sneget sig ind.
        #expect(DanishTextNormalizer.normalize("007", options: .numericCode) == "007")
        #expect(
            DanishTextNormalizer.normalize("007", options: .numericCode)
                != DanishTextNormalizer.normalize("7", options: .numericCode)
        )
    }

    @Test("å folder til aa og ikke til a")
    func danishFoldingIsExplicit() {
        // Netop dét, `folding(options: .diacriticInsensitive)` ville få galt.
        #expect(DanishTextNormalizer.normalize("å", options: .text) == "aa")
        #expect(DanishTextNormalizer.normalize("ø", options: .text) == "oe")
        #expect(DanishTextNormalizer.normalize("æ", options: .text) == "ae")
    }

    @Test("Dekomponeret og sammensat å giver samme resultat")
    func nfcRunsFirst() {
        let composed = "\u{00E5}"           // å
        let decomposed = "a\u{030A}"        // a + kombinerende ring
        #expect(
            DanishTextNormalizer.normalize(composed, options: .text)
                == DanishTextNormalizer.normalize(decomposed, options: .text)
        )
    }

    @Test("Normalisering er idempotent")
    func isIdempotent() {
        for vector in Self.vectors {
            let once = DanishTextNormalizer.normalize(vector.input, options: vector.options)
            let twice = DanishTextNormalizer.normalize(once, options: vector.options)
            #expect(once == twice, "\(vector.name) ændrer sig ved anden normalisering")
        }
    }
}
