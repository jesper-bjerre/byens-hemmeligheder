import BHContentKit
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
    /// Fylder hele bredden uden højdeloft. Bruges af opgavekortene, hvor
    /// billedet **er** indholdet og ikke en illustration ved siden af tekst.
    var fillsWidth = false
    /// Uden mærkat og uden hjørneafrunding — den fuldskærmsvisning, hvor
    /// spilleren kan zoome. Mærkaten står på kortet, man kom fra.
    var isZoomable = false
    /// Uden egen hjørneafrunding. Kortet runder hele stakken — billede og
    /// tekstbjælke — så billedet må ikke runde sin nederste kant selv.
    var isSquared = false

    @Environment(MissionEngine.self) private var engine
    @State private var image: Image?

    private var asset: MediaAsset? { engine.pack?.media(id: mediaId) }

    var body: some View {
        Group {
            if let asset, asset.resolvedMediaType == .image {
                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    imageOrPlaceholder(asset)

                    if !isZoomable {
                        if asset.kind == .known(.aiGenerated) {
                            Label("AI-genereret billede", systemImage: "sparkles")
                                .font(BHFont.caption)
                                .foregroundStyle(BHColor.inkMuted)
                                .labelStyle(.bhLeadingIcon)
                        }
                        // Kreditlinjen ved eksternt materiale. Står som den er
                        // skrevet i indholdet — appen tilføjer intet, fordi
                        // formen ofte er et vilkår i den aftale, billedet er
                        // hentet under.
                        if let credit = asset.creditLine, !credit.isEmpty {
                            Text(credit)
                                .font(BHFont.caption)
                                .foregroundStyle(BHColor.inkMuted)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("media.credit")
                        }
                    }
                }
            }
        }
        .task(id: mediaId) {
            guard let asset, asset.resolvedMediaType == .image, image == nil else { return }
            image = await ImageCache.shared.image(for: asset)
        }
    }

    @ViewBuilder
    private func imageOrPlaceholder(_ asset: MediaAsset) -> some View {
        if let image {
            // Loftet er der, fordi billederne er stående 3:4. I fuld bredde
            // ville et af dem fylde over 500 punkter og skubbe spørgsmålet ned
            // under skærmkanten — og så skal spilleren rulle for at finde ud
            // af, hvad hen skal.
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: fillsWidth ? nil : 340)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: (isZoomable || isSquared) ? 0 : BHRadius.card,
                        style: .continuous
                    )
                )
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

/// Det samme billede, men lille — som i designforslagets opgavekort.
///
/// Deler ``ImageCache`` med ``MissionHeroImage``, så billedet kun afkodes én
/// gang, selvom kortet, introen og spørgsmålet alle viser det.
///
/// Højden er fast og bredden følger med i 3:4. Det er samme forhold, som
/// filerne er beskåret til, så der hverken strækkes eller klippes.
struct MissionThumbnail: View {
    let mediaId: String

    @Environment(MissionEngine.self) private var engine
    @State private var image: Image?

    private static let height: CGFloat = 132

    private var asset: MediaAsset? { engine.pack?.media(id: mediaId) }

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.height * 3 / 4, height: Self.height)
                    .clipShape(RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .fill(BHColor.surface)
                    .frame(width: Self.height * 3 / 4, height: Self.height)
            }
        }
        // Alt-teksten hører til det store billede. Her ville den blive læst op
        // midt i opgavekortets sammensatte etiket og gøre den uoverskuelig.
        .accessibilityHidden(true)
        .task(id: mediaId) {
            guard let asset, asset.resolvedMediaType == .image, image == nil else { return }
            image = await ImageCache.shared.image(for: asset)
        }
    }
}

/// Afkodede billeder, holdt i hukommelsen.
///
/// En `actor`, fordi afkodningen sker uden for hovedtråden, og flere skærme kan
/// bede om det samme billede samtidig — introen og opgavetrinnet viser det
/// samme fotografi. Uden den ville de afkode hver sin kopi.
/// ## Bytes hentes gennem ``MediaSource``, ikke fra `Bundle.main`
///
/// Cachen kaldte tidligere `Bundle.main` direkte. Det virkede, men det låste
/// billederne til appen: skiftet til en server ville betyde, at netop denne fil
/// skulle laves om — og den er en visnings-hjælper, ikke et sted, nogen leder
/// efter indhentningslogik.
///
/// Nu er kilden injiceret. Serveren kommer først, når quizmasterne har prøvet
/// en TestFlight-version, og til den tid er ændringen at sætte en anden
/// ``MediaSource`` ind i ``shared``.
actor ImageCache {
    static let shared = ImageCache(source: ContentEndpoint.makeMediaSource())

    private let source: any MediaSource
    private var cached: [String: Image] = [:]

    init(source: any MediaSource) {
        self.source = source
    }

    func image(for asset: MediaAsset) async -> Image? {
        if let existing = cached[asset.id] { return existing }

        guard case .data(let data, _) = try? await source.fetch(asset, ifNoneMatch: nil),
              let uiImage = UIImage(data: data)
        else { return nil }

        let image = Image(uiImage: uiImage)
        cached[asset.id] = image
        return image
    }
}
