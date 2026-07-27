import BHContracts
import BHDesignSystem
import SwiftUI

/// Et billede fra indholdspakken.
///
/// ## Rettigheder og mærkning følger med billedet
///
/// Alt-teksten kommer fra kontraktens `altText` — forfattet af mennesket, der
/// valgte billedet, ikke genereret (FR-038). Er mediet `aiGenerated`, vises det
/// **på skærmen**: forfatningens princip III forbyder at præsentere et
/// AI-billede som et autentisk fotografi, og en mærkning i en JSON-fil er ikke
/// en mærkning over for spilleren.
///
/// Filerne ligger i bundlens `media`-mappe, som er en mappereference i
/// projektet. Et nyt billede kræver derfor kun en indholdsændring — ikke en
/// ændring af `project.pbxproj`.
struct MissionHeroImage: View {
    let mediaId: String

    @Environment(MissionEngine.self) private var engine

    private var asset: MediaAsset? { engine.pack?.media(id: mediaId) }

    var body: some View {
        if let asset, let image = Self.load(asset.filename) {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
                    .accessibilityLabel(asset.altText)
                    .accessibilityAddTraits(.isImage)

                if asset.kind == .known(.aiGenerated) {
                    Label("AI-genereret billede", systemImage: "sparkles")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                        .labelStyle(.bhLeadingIcon)
                }
            }
        }
    }

    /// Slår filen op i bundlens `media`-mappe.
    private static func load(_ filename: String) -> Image? {
        guard let url = Bundle.main.url(
            forResource: (filename as NSString).deletingPathExtension,
            withExtension: (filename as NSString).pathExtension,
            subdirectory: "media"
        ),
        let data = try? Data(contentsOf: url),
        let uiImage = UIImage(data: data)
        else { return nil }
        return Image(uiImage: uiImage)
    }
}
