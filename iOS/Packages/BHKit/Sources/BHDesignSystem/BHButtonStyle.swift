import SwiftUI

/// Den primære handling på skærmen.
///
/// Højden er mindst ``BHMetrics/primaryButtonHeight``, men bunden er et
/// *minimum*, ikke en fast værdi — knappen vokser med teksten, når Dynamic Type
/// skrues op. En fast højde ville klippe etiketten netop hos dem, der har brug
/// for den store skrift (FR-037, FR-041).
public struct BHPrimaryButtonStyle: ButtonStyle {
    private let isDestructive: Bool

    public init(isDestructive: Bool = false) {
        self.isDestructive = isDestructive
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BHFont.heading)
            .foregroundStyle(BHColor.onAccent)
            // Etiketten skal kunne bryde over flere linjer. Uden dette klippes
            // "Vis hint — 3 point" ved de store tilgængelighedsstørrelser, og
            // knappen bliver ulæselig netop for den, der har skruet op (FR-037).
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, BHSpacing.snug)
            .frame(maxWidth: .infinity)
            .frame(minHeight: BHMetrics.primaryButtonHeight)
            .padding(.horizontal, BHSpacing.regular)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .fill(isDestructive ? BHColor.danger : BHColor.accent)
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
            .contentShape(RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous))
    }
}

/// Sekundær handling. Samme trykflade, mindre vægt.
public struct BHSecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BHFont.heading)
            .foregroundStyle(BHColor.accent)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, BHSpacing.snug)
            .frame(maxWidth: .infinity)
            .frame(minHeight: BHMetrics.primaryButtonHeight)
            .padding(.horizontal, BHSpacing.regular)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .strokeBorder(BHColor.accent, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous))
    }
}

extension ButtonStyle where Self == BHPrimaryButtonStyle {
    public static var bhPrimary: BHPrimaryButtonStyle { BHPrimaryButtonStyle() }
    public static var bhDestructive: BHPrimaryButtonStyle { BHPrimaryButtonStyle(isDestructive: true) }
}

extension ButtonStyle where Self == BHSecondaryButtonStyle {
    public static var bhSecondary: BHSecondaryButtonStyle { BHSecondaryButtonStyle() }
}

/// Kortbaggrunden, alle ark og paneler deler.
public struct BHCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(BHSpacing.regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                    .fill(BHColor.surface)
            )
    }
}
