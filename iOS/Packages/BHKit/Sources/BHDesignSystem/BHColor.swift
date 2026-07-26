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

    /// Baggrunden bag alt.
    public static let canvas = dynamic(
        light: (0.98, 0.98, 0.97), dark: (0.06, 0.07, 0.09),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (0.00, 0.00, 0.00)
    )

    /// Kort og ark, der løfter sig fra baggrunden.
    public static let surface = dynamic(
        light: (1.00, 1.00, 1.00), dark: (0.12, 0.13, 0.16),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (0.08, 0.09, 0.11)
    )

    /// Brødtekst.
    public static let ink = dynamic(
        light: (0.09, 0.10, 0.12), dark: (0.95, 0.96, 0.97),
        lightContrast: (0.00, 0.00, 0.00), darkContrast: (1.00, 1.00, 1.00)
    )

    /// Sekundær tekst. Aldrig eneste bærer af information.
    public static let inkMuted = dynamic(
        light: (0.36, 0.38, 0.42), dark: (0.68, 0.71, 0.75),
        lightContrast: (0.20, 0.21, 0.24), darkContrast: (0.86, 0.88, 0.90)
    )

    /// Den primære handling. Fjordblå.
    public static let accent = dynamic(
        light: (0.05, 0.35, 0.55), dark: (0.42, 0.72, 0.92),
        lightContrast: (0.02, 0.24, 0.42), darkContrast: (0.60, 0.84, 1.00)
    )

    /// Tekst oven på ``accent``.
    public static let onAccent = dynamic(
        light: (1.00, 1.00, 1.00), dark: (0.04, 0.09, 0.14),
        lightContrast: (1.00, 1.00, 1.00), darkContrast: (0.00, 0.00, 0.00)
    )

    /// Bekræftelse — korrekt svar, verificeret position.
    public static let success = dynamic(
        light: (0.05, 0.42, 0.28), dark: (0.40, 0.82, 0.60),
        lightContrast: (0.02, 0.30, 0.19), darkContrast: (0.56, 0.92, 0.72)
    )

    /// Sikkerhedsnoter. Advarer uden at skræmme.
    public static let caution = dynamic(
        light: (0.55, 0.35, 0.02), dark: (0.96, 0.76, 0.35),
        lightContrast: (0.40, 0.25, 0.00), darkContrast: (1.00, 0.85, 0.50)
    )

    /// Fejl og blokerede tilstande.
    public static let danger = dynamic(
        light: (0.60, 0.13, 0.13), dark: (0.95, 0.52, 0.50),
        lightContrast: (0.45, 0.05, 0.05), darkContrast: (1.00, 0.66, 0.64)
    )

    /// Fiktionsmarkeringens baggrund (FR-007).
    public static let fiction = dynamic(
        light: (0.35, 0.22, 0.52), dark: (0.72, 0.60, 0.92),
        lightContrast: (0.25, 0.13, 0.40), darkContrast: (0.84, 0.74, 1.00)
    )

    public static let separator = dynamic(
        light: (0.85, 0.85, 0.84), dark: (0.24, 0.25, 0.28),
        lightContrast: (0.45, 0.45, 0.45), darkContrast: (0.65, 0.66, 0.68)
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
