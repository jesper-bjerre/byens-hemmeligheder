import BHTestSupport
import Foundation
import Testing

/// V-06, FR-047, SC-008.
///
/// En tidligere AI-genereret illustration viste koden `541` for Bølgen. Den er
/// ugyldig og må ikke forekomme noget sted — hverken i opgavetekster, mockups,
/// tests eller dokumentation. Den eneste korrekte kode er `592`, og den kan
/// bevises: fem bølger → ni etager → to bølger før pausen.
///
/// Testen scanner den shippende pakke som **rå tekst** frem for gennem de
/// afkodede typer. En forkert kode gemt i et hint, en alt-tekst eller en
/// completion-besked ville slippe gennem en strukturel kontrol.
@Suite("Forbudte koder")
struct ForbiddenCodeTests {

    /// Koder, der er registreret som ugyldige i opgavedokumenterne.
    static let forbiddenCodes = ["541"]

    @Test("Den ugyldige kode forekommer ingen steder i indholdspakken")
    func forbiddenCodeIsAbsentFromContentPack() throws {
        let raw = try String(contentsOf: ContractFixtures.contentPackURL, encoding: .utf8)

        for code in Self.forbiddenCodes {
            let hits = Self.occurrences(of: code, in: raw)
            #expect(
                hits.isEmpty,
                "Den ugyldige kode '\(code)' står i indholdspakken: \(hits.joined(separator: " | "))"
            )
        }
    }

    @Test("Den ugyldige kode forekommer ingen steder i kontraktmapperne")
    func forbiddenCodeIsAbsentFromContracts() throws {
        let fileManager = FileManager.default
        let root = ContractFixtures.contractsDirectory

        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey]
        ) else {
            Issue.record("Kunne ikke gennemløbe \(root.path())")
            return
        }

        for case let url as URL in enumerator {
            guard ["json", "md"].contains(url.pathExtension) else { continue }
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { continue }

            for code in Self.forbiddenCodes {
                let hits = Self.occurrences(of: code, in: text)
                #expect(
                    hits.isEmpty,
                    "'\(code)' står i \(url.lastPathComponent): \(hits.joined(separator: " | "))"
                )
            }
        }
    }

    /// Den vigtigste test i filen.
    ///
    /// En scanner, der leder efter noget, der ikke findes, ser altid grøn ud —
    /// også når den er holdt op med at lede. Uden denne positive kontrol var
    /// hele suiten teater.
    @Test("Detektoren finder faktisk koden, når den er der")
    func detectorActuallyDetects() {
        #expect(!Self.occurrences(of: "541", in: "Koden er 541.").isEmpty)
        #expect(!Self.occurrences(of: "541", in: #""text": "541""#).isEmpty)
        #expect(!Self.occurrences(of: "541", in: "541").isEmpty)
    }

    @Test("Detektoren giver ikke falske udslag på længere tal")
    func detectorIgnoresLongerNumbers() {
        #expect(Self.occurrences(of: "541", in: "Nummer 15410 er fint").isEmpty)
        #expect(Self.occurrences(of: "541", in: "koordinat 9.5411").isEmpty)
        #expect(Self.occurrences(of: "541", in: "1541").isEmpty)
    }

    @Test("Det gyldige facit står i pakken")
    func theValidCodeIsPresent() throws {
        let raw = try String(contentsOf: ContractFixtures.contentPackURL, encoding: .utf8)
        // Sanity: finder scanneren overhovedet cifre, den leder efter?
        #expect(raw.contains("592"), "Bølgens facit mangler")
        #expect(raw.contains("428"), "Fjordenhus' facit mangler")
    }

    /// Finder koden som selvstændigt tal, så `1541` eller `5410` ikke giver
    /// falske udslag — men `"541"` og ` 541 ` gør.
    ///
    /// Bruger `NSRegularExpression` og **ikke** Swifts `Regex`. Sidstnævnte
    /// understøtter ikke lookbehind på runtime-byggede mønstre: `try? Regex(...)`
    /// giver `nil`, og en detektor, der lydløst holder op med at lede, er værre
    /// end ingen detektor. Derfor kaster opbygningen her, og
    /// ``detectorActuallyDetects`` holder øje med, at den stadig virker.
    static func occurrences(of code: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "(?<![0-9])\(code)(?![0-9])") else {
            // Kan mønsteret ikke bygges, er testen defekt — ikke indholdet.
            return ["Mønsteret for '\(code)' kunne ikke bygges — detektoren er i stykker"]
        }

        var results: [String] = []
        for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            let subject = String(line)
            let range = NSRange(subject.startIndex..<subject.endIndex, in: subject)
            guard regex.firstMatch(in: subject, range: range) != nil else { continue }
            results.append("linje \(index + 1): \(subject.trimmingCharacters(in: .whitespaces).prefix(160))")
        }
        return results
    }
}
