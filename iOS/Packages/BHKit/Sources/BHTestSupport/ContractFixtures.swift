import BHContracts
import Foundation

/// Adgang til `contracts/` fra testene.
///
/// Testene læser den pakke og de vektorer, der **faktisk shipper** — ikke en
/// kopi. En kopi ville kunne drive fra originalen, og så ville den grønne test
/// bevise noget om den forkerte fil.
///
/// Stien findes ud fra `#filePath` frem for `Bundle.module`, fordi
/// `contracts/` bevidst ligger uden for pakken: kontrakten ejes ikke af
/// iOS-appen, den bruges bare af den først (plan.md, Structure Decision).
public enum ContractFixtures {

    /// Repo-roden, fundet fra denne fils placering på disken.
    ///
    /// `iOS/Packages/BHKit/Sources/BHTestSupport/ContractFixtures.swift` → roden.
    public static var repositoryRoot: URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()   // …/Sources/BHTestSupport
            .deletingLastPathComponent()   // …/Sources
            .deletingLastPathComponent()   // …/BHKit
            .deletingLastPathComponent()   // …/Packages
            .deletingLastPathComponent()   // …/iOS
            .deletingLastPathComponent()   // repo-roden
    }

    public static var contractsDirectory: URL {
        repositoryRoot.appending(path: "contracts", directoryHint: .isDirectory)
    }

    public static var contentPackURL: URL {
        contractsDirectory.appending(path: "content/da-DK/content-pack.json")
    }

    public static var schemaURL: URL {
        contractsDirectory.appending(path: "bh-content-v1.schema.json")
    }

    public static var goldenDirectory: URL {
        contractsDirectory.appending(path: "golden", directoryHint: .isDirectory)
    }

    public static func specURL(_ filename: String) -> URL {
        contractsDirectory.appending(path: "spec/\(filename)")
    }

    // MARK: - Indlæsning

    public static func contentPackData() throws -> Data {
        try Data(contentsOf: contentPackURL)
    }

    /// Den shippende indholdspakke, afkodet med projektets egen decoder.
    public static func contentPack() throws -> ContentPack {
        try BHJSON.decoder.decode(ContentPack.self, from: contentPackData())
    }

    public static func specData(_ filename: String) throws -> Data {
        try Data(contentsOf: specURL(filename))
    }

    /// Læser en testvektorfil som løst JSON, så vektorerne kan tilføjes uden at
    /// en Swift-type skal følge med.
    public static func specJSON(_ filename: String) throws -> [String: Any] {
        let data = try specData(filename)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FixtureError.notAnObject(filename)
        }
        return object
    }

    public enum FixtureError: Error, CustomStringConvertible {
        case notAnObject(String)
        case missingKey(String, in: String)

        public var description: String {
            switch self {
            case .notAnObject(let file):
                "\(file) er ikke et JSON-objekt."
            case .missingKey(let key, let file):
                "Nøglen '\(key)' mangler i \(file)."
            }
        }
    }
}
