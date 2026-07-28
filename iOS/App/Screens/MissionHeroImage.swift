import BHContracts
import BHDesignSystem
import SwiftUI

/// Et billede fra indholdspakken.
///
/// ## Afkodningen sker én gang, uden for `body`
///
/// Filerne er fotografier på flere megabyte. Blev de afkodet inde i `body` —
/// som de var — skete det forfra ved hver eneste gentegning, og `body` kaldes
/// ofte. Det var målbart: opgavetrinnet med et fotografi var så længe om at
/// komme frem, at en UI-test løb tør for tid, og i appen ville skærmen hakke.
///
/// Derfor: afkod i en `Task`, gem i ``ImageCache``, og hold pladsen imens.
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
    @State private var image: Image?

    private var asset: MediaAsset? { engine.pack?.media(id: mediaId) }

    var body: some View {
        Group {
            if let asset, asset.resolvedMediaType == .image {
                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    imageOrPlaceholder(asset)

                    if asset.kind == .known(.aiGenerated) {
                        Label("AI-genereret billede", systemImage: "sparkles")
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.inkMuted)
                            .labelStyle(.bhLeadingIcon)
                    }
                }
            }
        }
        .task(id: mediaId) {
            guard let asset, asset.resolvedMediaType == .image, image == nil else { return }
            image = await ImageCache.shared.image(named: asset.filename)
        }
    }

    @ViewBuilder
    private func imageOrPlaceholder(_ asset: MediaAsset) -> some View {
        if let image {
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
                .accessibilityLabel(asset.altText)
                .accessibilityAddTraits(.isImage)
        } else {
            // Holder pladsen, så resten af skærmen ikke hopper, når billedet
            // lander.
            RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                .fill(BHColor.surface)
                .aspectRatio(4 / 3, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay(ProgressView())
                .accessibilityLabel("Billedet hentes frem")
        }
    }
}

/// Afkodede billeder, holdt i hukommelsen.
///
/// En `actor`, fordi afkodningen sker uden for hovedtråden, og flere skærme kan
/// bede om det samme billede samtidig — introen og opgavetrinnet viser det
/// samme fotografi. Uden den ville de afkode hver sin kopi.
actor ImageCache {
    static let shared = ImageCache()

    private var cached: [String: Image] = [:]

    func image(named filename: String) -> Image? {
        if let existing = cached[filename] { return existing }

        guard let url = Bundle.main.url(
            forResource: (filename as NSString).deletingPathExtension,
            withExtension: (filename as NSString).pathExtension,
            subdirectory: "media"
        ),
        let data = try? Data(contentsOf: url),
        let uiImage = UIImage(data: data)
        else { return nil }

        let image = Image(uiImage: uiImage)
        cached[filename] = image
        return image
    }
}
