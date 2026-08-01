import SwiftUI
import Testing
import UIKit

@testable import ByensGaaderAdmin

/// `Image("Icon-Task")` fejler **tavst**, hvis navnet er stavet forkert: der
/// tegnes ingenting, og der kommer ingen advarsel hverken ved oversættelse eller
/// i konsollen. Testen her er den eneste, der fanger en tastefejl i et
/// billednavn, før en quizmaster ser et hul i skærmen.
@Suite("Grafikken")
struct AssetTests {

    /// Hvert navn, appen slår op. Tilføjes et `Image(...)` i koden, hører navnet
    /// hjemme her — ellers beviser testen ikke det, den påstår.
    static let referenced = [
        "Icon-Task", "Icon-Map", "Icon-Photo", "Icon-Hint",
        "Icon-GPS", "Icon-Route", "Icon-Publish", "Icon-Audio",
        "EmptyState-NoTasks", "EmptyState-ChooseLocation", "EmptyState-ReadyForTest",
    ]

    @Test("Alle billeder, appen beder om, findes i kataloget", arguments: referenced)
    func everyReferencedImageExists(_ name: String) {
        #expect(UIImage(named: name) != nil, "'\(name)' findes ikke i Assets.xcassets")
    }

    @Test("Appikonet ligger i bygningen")
    func theAppIconIsBundled() {
        let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any]
        let primary = icons?["CFBundlePrimaryIcon"] as? [String: Any]
        let files = primary?["CFBundleIconFiles"] as? [String]
        #expect(files?.isEmpty == false, "Appen har intet ikon i sin Info.plist")
    }

    /// Illustrationerne skal kunne bære en tab-bar på 3× uden at blive grødede.
    @Test("Ikonerne er store nok til at skaleres ned", arguments: [
        "Icon-Task", "Icon-Map", "Icon-Photo", "Icon-Hint",
        "Icon-GPS", "Icon-Route", "Icon-Publish", "Icon-Audio",
    ])
    func iconsAreBigEnough(_ name: String) throws {
        let image = try #require(UIImage(named: name))
        #expect(image.size.width >= 128, "\(name) er kun \(Int(image.size.width)) px bred")
        #expect(image.size.width == image.size.height, "\(name) er ikke kvadratisk")
    }
}
