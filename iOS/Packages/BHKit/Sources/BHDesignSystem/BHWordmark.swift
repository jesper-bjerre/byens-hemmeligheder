import SwiftUI

/// Appens navnetræk på den mørke brandflade.
///
/// To linjer, serif, hvor anden linje bærer accentfarven — som i
/// designforslaget. Skrives med Dynamic Type, ikke faste punktstørrelser, så
/// den vokser med spillerens indstilling (FR-037).
public struct BHWordmark: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: -2) {
            Text("Vejles")
                .foregroundStyle(BHColor.onBrandPrimary)
            Text("Gåder")
                .foregroundStyle(BHColor.onBrand)
        }
        .font(.system(.title, design: .serif, weight: .regular))
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Vejles Gåder")
        .accessibilityAddTraits(.isHeader)
    }
}

/// Den mørke header, kortet ligger under.
public struct BHBrandHeader<Trailing: View>: View {
    private let trailing: Trailing

    public init(@ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(alignment: .center) {
            BHWordmark()
            Spacer(minLength: BHSpacing.regular)
            trailing
        }
        .padding(.horizontal, BHSpacing.regular)
        .padding(.bottom, BHSpacing.snug)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BHColor.brand)
    }
}
