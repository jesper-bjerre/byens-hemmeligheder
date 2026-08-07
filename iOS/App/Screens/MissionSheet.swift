import BHContracts
import BHDesignSystem
import SwiftUI

/// Missionsdetaljen — det ark, spilleren beslutter sig ud fra.
///
/// **Sikkerhedsnoterne står her, ikke i en fodnote.** Forfatningens princip IV
/// kræver, at spilleren kender risikoen, før turen begynder, og begge
/// lokationer i feature 001 ligger ved åbent vand (FR-006).
struct MissionSheet: View {
    let mission: Mission

    @Environment(MissionEngine.self) private var engine
    @Environment(PlayerAuthentication.self) private var authentication
    @Environment(MissionFavoritesStore.self) private var favorites
    @Environment(Router.self) private var router
    @State private var expandsSafety = false
    @State private var expandsAccessibility = false
    @State private var favoriteMessage: String?

    private var location: Location? { engine.location(for: mission) }

    private var galleryMediaIds: [String] {
        [
            mission.resolvedThumbnailMediaId,
            mission.placeMediaId,
            mission.resolvedMoodMediaId,
        ]
        .compactMap { $0 }
        .reduce(into: [String]()) { result, id in
            if !result.contains(id) { result.append(id) }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                gallery
                header
                fictionLabel
                facts
                if let location { safety(location) }
                if let location { accessibility(location) }
                startButton
                sources
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle(mission.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Favoritter", isPresented: Binding(
            get: { favoriteMessage != nil },
            set: { if !$0 { favoriteMessage = nil } }
        )) {
            Button("OK") { favoriteMessage = nil }
        } message: {
            Text(favoriteMessage ?? "")
        }
    }

    @ViewBuilder
    private var gallery: some View {
        if galleryMediaIds.isEmpty {
            RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                .fill(LinearGradient(
                    colors: [BHColor.brand, BHColor.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 260)
                .overlay {
                    Image(systemName: "map.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(BHColor.onBrandPrimary.opacity(0.85))
                }
        } else {
            TabView {
                ForEach(galleryMediaIds, id: \.self) { mediaId in
                    MissionDetailGalleryImage(mediaId: mediaId)
                }
            }
            .frame(height: 290)
            .tabViewStyle(.page(indexDisplayMode: galleryMediaIds.count > 1 ? .always : .never))
            .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                    .strokeBorder(BHColor.separator.opacity(0.7))
            }
            .shadow(color: .black.opacity(0.12), radius: 18, y: 6)
            .accessibilityIdentifier("mission.gallery")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            HStack(alignment: .top, spacing: BHSpacing.snug) {
                Text(mission.title)
                    .font(BHFont.title)
                    .foregroundStyle(BHColor.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)

                favoriteButton
            }
            Text(mission.description)
                .font(BHFont.body)
                .foregroundStyle(BHColor.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var favoriteButton: some View {
        let isFavorite = favorites.isFavorite(mission.id)
        let count = favorites.metrics(for: mission.id)?.favoriteCount ?? 0
        return Button {
            guard authentication.state == .signedIn else {
                favoriteMessage = "Log ind under Profil for at gemme opgaven som favorit."
                return
            }
            Task {
                await favorites.toggle(mission.id, using: authentication)
                if let error = favorites.errorMessage {
                    favoriteMessage = error
                    favorites.clearMessage()
                }
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title2.weight(.semibold))
                Text("\(count)")
                    .font(BHFont.caption)
                    .monospacedDigit()
            }
            .foregroundStyle(BHColor.accent)
            .frame(minWidth: BHMetrics.minimumTapTarget, minHeight: BHMetrics.minimumTapTarget)
            .background(Circle().fill(BHColor.accentSoft))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Fjern fra favoritter" : "Gem som favorit")
        .accessibilityValue("\(count) favoritter")
        .accessibilityIdentifier("mission.favorite")
    }

    /// FR-007. Skal være synlig, ikke skjult bag en informationsknap.
    private var fictionLabel: some View {
        Label(mission.fictionLabel, systemImage: "theatermasks.fill")
            .font(BHFont.caption)
            .foregroundStyle(BHColor.fiction)
            .labelStyle(.titleAndIcon)
            .padding(BHSpacing.snug)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .fill(BHColor.fiction.opacity(0.12))
            )
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Fiktion. \(mission.fictionLabel)")
    }

    private var facts: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                factRow("Sværhedsgrad", "\(mission.difficulty) af 5", "brain.head.profile")
                factRow("Varighed", "ca. \(mission.estimatedMinutes) minutter", "clock")
                factRow("Point", "\(mission.basePoints) at hente", "star")
                if let location {
                    factRow("Sted", location.name, "mappin.and.ellipse")
                }
            }
        }
    }

    private func factRow(_ label: String, _ value: String, _ symbol: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BHSpacing.tight) {
            Image(systemName: symbol)
                .foregroundStyle(BHColor.accent)
                .accessibilityHidden(true)
            Text(label)
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
            Spacer(minLength: BHSpacing.tight)
            Text(value)
                .font(BHFont.body)
                .foregroundStyle(BHColor.ink)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private func safety(_ location: Location) -> some View {
        BHCard {
            DisclosureGroup(isExpanded: $expandsSafety) {
                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    Text(location.safety.notes)
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, BHSpacing.tight)
            } label: {
                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    Label("Sikkerhed", systemImage: "exclamationmark.triangle.fill")
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.caution)
                        .labelStyle(.titleAndIcon)

                    Text(location.safety.flags.isEmpty
                         ? "Tryk for at læse sikkerhedsinformationen."
                         : location.safety.flags.map(\.danishName).joined(separator: " · "))
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                }
            }
            .tint(BHColor.accent)
        }
        .accessibilityIdentifier("mission.safety")
    }

    private func accessibility(_ location: Location) -> some View {
        BHCard {
            DisclosureGroup(isExpanded: $expandsAccessibility) {
                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    Text("Underlag: \(location.accessibility.surface)")
                    Text("Hældning: \(location.accessibility.incline)")
                    Text("Kørestol: \(location.accessibility.wheelchair.danishName)")
                    Text("Barnevogn: \(location.accessibility.stroller.danishName)")
                    Text(location.accessibility.notes)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, BHSpacing.tight)
            } label: {
                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    Label("Adgang", systemImage: "figure.roll")
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                        .labelStyle(.titleAndIcon)
                    Text("Kørestol: \(location.accessibility.wheelchair.danishName) · Barnevogn: \(location.accessibility.stroller.danishName)")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                }
            }
            .font(BHFont.body)
            .foregroundStyle(BHColor.ink)
            .tint(BHColor.accent)
        }
        .accessibilityIdentifier("mission.accessibility")
    }

    private var startButton: some View {
        Button("Tag afsted") {
            Task {
                guard await engine.startSession(for: mission) else { return }
                if engine.hasSeenSafetyInterstitial {
                    router.push(.approach(missionId: mission.id))
                } else {
                    router.presentedSheet = .safety(missionId: mission.id)
                }
            }
        }
        .buttonStyle(.bhPrimary)
        .accessibilityHint("Starter opgaven og viser vej til stedet")
    }

    private var sources: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Text("Kilder")
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
            ForEach(mission.sourceIds, id: \.self) { sourceId in
                if let source = engine.pack?.source(id: sourceId) {
                    Text("\(source.title) — \(source.publisher)")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Billedgalleriets kant-til-kant-format. Kredit og AI-mærkning ligger som
/// overlay, så billederne kan fylde toppen uden at miste rettighedsoplysninger.
private struct MissionDetailGalleryImage: View {
    let mediaId: String

    @Environment(MissionEngine.self) private var engine
    @State private var image: Image?

    private var asset: MediaAsset? { engine.pack?.media(id: mediaId) }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(BHColor.surface)
                        .overlay { ProgressView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            if let asset {
                VStack(alignment: .leading, spacing: 3) {
                    if asset.kind == .known(.aiGenerated) {
                        Label("AI-genereret", systemImage: "sparkles")
                    }
                    if let credit = asset.creditLine, !credit.isEmpty {
                        Text(credit).lineLimit(2)
                    }
                }
                .font(BHFont.caption)
                .foregroundStyle(.white)
                .padding(BHSpacing.tight)
                .background(.black.opacity(0.68), in: RoundedRectangle(cornerRadius: BHRadius.control))
                .padding(BHSpacing.tight)
            }
        }
        .accessibilityLabel(asset?.altText ?? "Billede til opgaven")
        .task(id: mediaId) {
            guard let asset, asset.resolvedMediaType == .image else { return }
            image = await ImageCache.shared.image(for: asset)
        }
    }
}

// MARK: - Danske navne til kontraktens enums

extension Tolerant where Known == SafetyFlag {
    var danishName: String {
        switch known {
        case .traffic: "Trafik"
        case .water: "Vand"
        case .steepSlope: "Stigning"
        case .darkness: "Mørke"
        case .privateProperty: "Privat område"
        case .cyclePath: "Cykelsti"
        case .construction: "Byggeri"
        case .crowding: "Mange mennesker"
        case nil: rawValue
        }
    }
}

extension Tolerant where Known == AccessLevel {
    var danishName: String {
        switch known {
        case .yes: "Ja"
        case .partial: "Delvist"
        case .no: "Nej"
        case .unknown: "Ikke registreret endnu"
        case nil: rawValue
        }
    }
}
