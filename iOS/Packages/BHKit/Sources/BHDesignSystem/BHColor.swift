import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Semantiske farver.
///
/// Navnene beskriver **rollen**, ikke kuløren. `BHColor.danger` kan skifte
/// nuance i increment 005 uden at et eneste kaldsted skal røres — og et
/// kaldsted, der hedder `.orange`, ville have låst den beslutning fast.
///
/// Hver farve har tre varianter: normal, mørk og forøget kontrast. Den sidste
/// er ikke pynt: forfatningens princip VII kræver, at oplevelsen holder for en
/// familie, og Forøget Kontrast er den indstilling, der oftest er slået til hos
/// dem, der har brug for den.
///
/// Farve bærer aldrig betydning alene (FR-039). Alt, der markeres med farve,
/// har også tekst eller et symbol.
public enum BHColor {

    /// Brandets mørke — headerens bund. Fjorden om aftenen.
    public static let brand = dynamic(
        light: (0.055, 0.117, 0.216), dark: (0.031, 0.071, 0.137),
        lightContrast: (0.020, 0.055, 0.118), darkContrast: (0.000, 0.020, 0.055)
    )

    /// Wordmarkets første linje. Hvid på navy.
    public static let onBrandPrimary = dynamic(
        light: (1.00, 1.00, 1.00), dark: (1.00, 1.00, 1.00),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (1.00, 1.00, 1.00)
    )

    /// Wordmarkets anden linje og accenter oven på ``brand``.
    public static let onBrand = dynamic(
        light: (0.42, 0.78, 0.79), dark: (0.48, 0.82, 0.83),
        lightContrast: (0.62, 0.90, 0.91), darkContrast: (0.68, 0.93, 0.94)
    )

    /// Baggrunden bag alt. Varm off-white, ikke klinisk hvid.
    public static let canvas = dynamic(
        light: (0.969, 0.969, 0.961), dark: (0.055, 0.078, 0.110),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (0.00, 0.00, 0.00)
    )

    /// Kort og ark, der løfter sig fra baggrunden.
    public static let surface = dynamic(
        light: (1.00, 1.00, 1.00), dark: (0.106, 0.129, 0.169),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (0.071, 0.094, 0.129)
    )

    /// Brødtekst.
    public static let ink = dynamic(
        light: (0.055, 0.117, 0.216), dark: (0.949, 0.961, 0.969),
        lightContrast: (0.00, 0.00, 0.00), darkContrast: (1.00, 1.00, 1.00)
    )

    /// Sekundær tekst. Aldrig eneste bærer af information.
    public static let inkMuted = dynamic(
        light: (0.318, 0.365, 0.427), dark: (0.675, 0.714, 0.757),
        lightContrast: (0.180, 0.216, 0.267), darkContrast: (0.855, 0.878, 0.902)
    )

    /// Den primære handling. Petrolgrøn.
    public static let accent = dynamic(
        light: (0.055, 0.478, 0.478), dark: (0.298, 0.714, 0.706),
        lightContrast: (0.020, 0.353, 0.353), darkContrast: (0.451, 0.831, 0.824)
    )

    /// Tekst oven på ``accent``.
    public static let onAccent = dynamic(
        light: (1.00, 1.00, 1.00), dark: (0.020, 0.078, 0.086),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (0.00, 0.00, 0.00)
    )

    /// Chippens tonede baggrund.
    public static let accentSoft = dynamic(
        light: (0.890, 0.945, 0.945), dark: (0.086, 0.180, 0.192),
        lightContrast: (0.831, 0.918, 0.918), darkContrast: (0.110, 0.220, 0.235)
    )

    /// Bekræftelse — korrekt svar, verificeret position.
    public static let success = dynamic(
        light: (0.043, 0.400, 0.302), dark: (0.376, 0.804, 0.643),
        lightContrast: (0.016, 0.286, 0.216), darkContrast: (0.529, 0.902, 0.749)
    )

    /// Sikkerhedsnoter. Advarer uden at skræmme.
    public static let caution = dynamic(
        light: (0.545, 0.345, 0.020), dark: (0.957, 0.757, 0.349),
        lightContrast: (0.396, 0.247, 0.00), darkContrast: (1.00, 0.851, 0.498)
    )

    /// Fejl og blokerede tilstande.
    public static let danger = dynamic(
        light: (0.600, 0.129, 0.129), dark: (0.949, 0.518, 0.498),
        lightContrast: (0.451, 0.051, 0.051), darkContrast: (1.00, 0.659, 0.639)
    )

    /// Fiktionsmarkeringens farve (FR-007).
    public static let fiction = dynamic(
        light: (0.353, 0.220, 0.522), dark: (0.718, 0.600, 0.918),
        lightContrast: (0.251, 0.129, 0.400), darkContrast: (0.839, 0.741, 1.00)
    )

    public static let separator = dynamic(
        light: (0.878, 0.878, 0.867), dark: (0.239, 0.251, 0.278),
        lightContrast: (0.451, 0.451, 0.451), darkContrast: (0.651, 0.659, 0.678)
    )

    // MARK: - Opbygning

    private typealias RGB = (Double, Double, Double)

    private static func dynamic(
        light: RGB, dark: RGB, lightContrast: RGB, darkContrast: RGB
    ) -> Color {
        #if canImport(UIKit)
        Color(
            UIColor { traits in
                let increased = traits.accessibilityContrast == .high
                switch (traits.userInterfaceStyle, increased) {
                case (.dark, true): return UIColor(rgb: darkContrast)
                case (.dark, false): return UIColor(rgb: dark)
                case (_, true): return UIColor(rgb: lightContrast)
                case (_, false): return UIColor(rgb: light)
                }
            }
        )
        #else
        // macOS bygges kun for at kunne køre `swift test` uden simulator.
        Color(red: light.0, green: light.1, blue: light.2)
        #endif
    }
}

#if canImport(UIKit)
extension UIColor {
    fileprivate convenience init(rgb: (Double, Double, Double)) {
        self.init(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
    }
}
#endif
