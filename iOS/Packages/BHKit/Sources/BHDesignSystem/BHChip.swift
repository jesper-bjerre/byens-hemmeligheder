import SwiftUI

/// Et nøgletal i en tonet pille — sværhedsgrad, varighed, afstand.
///
/// Chippen erstatter den tætpakkede række af etiketter, designforslaget
/// afløser. Formen er ikke kun pynt: chips i et ombrydende layout kan **falde
/// ned på næste linje**, hvor en fast `HStack` klipper det sidste nøgletal væk
/// ved de store tilgængelighedsstørrelser. Tilgængelighedsauditten fandt netop
/// den fejl (FR-037).
public struct BHChip: View {
    private let title: String
    private let systemImage: String
    private let tint: Color

    public init(_ title: String, systemImage: String, tint: Color? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint ?? BHColor.accent
    }

    public var body: some View {
        Label(title, systemImage: systemImage)
            .font(BHFont.caption)
            .foregroundStyle(tint)
            .labelStyle(.titleAndIcon)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, BHSpacing.snug)
            .padding(.vertical, BHSpacing.tight)
            .background(
                Capsule().fill(tint.opacity(0.12))
            )
            .accessibilityElement(children: .combine)
    }
}
