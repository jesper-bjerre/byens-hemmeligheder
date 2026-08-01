import Foundation

@testable import ByensGaaderAdmin

/// Adgang til `contracts/` fra admin-appens tests.
///
/// Testene læser den pakke, der **faktisk shipper** — ikke en kopi. En kopi
/// ville kunne drive fra originalen, og så beviste den grønne test noget om den
/// forkerte fil.
///
/// Stien findes ud fra `#filePath`, ligesom i `BHKit`. `contracts/` ligger
/// bevidst uden for begge apps: kontrakten ejes ikke af nogen af dem.
enum ContractFixtures {

    /// `iOS-admin/ByensGaaderAdmin/ByensGaaderAdminTests/…` → repo-roden.
    static var repositoryRoot: URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()   // …/ByensGaaderAdminTests
            .deletingLastPathComponent()   // …/ByensGaaderAdmin
            .deletingLastPathComponent()   // …/iOS-admin
            .deletingLastPathComponent()   // repo-roden
    }

    static var contentPackURL: URL {
        repositoryRoot.appending(path: "contracts/content/da-DK/content-pack.json")
    }

    static func contentPackData() throws -> Data {
        try Data(contentsOf: contentPackURL)
    }

    /// Et friskt dokument pr. test. `PackDocument` er mutabelt, og to tests, der
    /// deler ét, ville afhænge af rækkefølgen.
    static func document() throws -> PackDocument {
        try PackDocument(data: try contentPackData(), etag: "\"prøve\"")
    }
}
