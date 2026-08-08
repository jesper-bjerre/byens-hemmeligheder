import BHContracts
import BHDesignSystem
import SwiftUI

/// De fire faste områder i spillerappen.
///
/// Fanerne er lokal UI-tilstand og ikke en del af den genskabte spilrute. En
/// spiller, der genstarter midt i en opgave, skal stadig lande i opgaven; et
/// skift fra Explore til Søg er derimod ikke progression og gemmes ikke.
private enum PlayerSection: String, CaseIterable, Identifiable {
    case explore
    case search
    case quests
    case profile

    var id: Self { self }

    var title: String {
        switch self {
        case .explore: "Udforsk"
        case .search: "Søg"
        case .quests: "Mine"
        case .profile: "Profil"
        }
    }

    var symbol: String {
        switch self {
        case .explore: "house.fill"
        case .search: "magnifyingglass"
        case .quests: "book.closed.fill"
        case .profile: "person.crop.circle"
        }
    }
}

/// Appens nye startpunkt og faste bundnavigation.
struct PlayerHomeShell: View {
    @State private var section: PlayerSection = .explore

    var body: some View {
        Group {
            switch section {
            case .explore:
                PlayerExploreView()
            case .search:
                MissionSearchView()
            case .quests:
                QuestHistoryView()
            case .profile:
                PlayerProfileView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PlayerTabBar(selection: $section)
        }
        .background(BHColor.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct PlayerTabBar: View {
    @Binding var selection: PlayerSection

    var body: some View {
        HStack(alignment: .bottom, spacing: BHSpacing.hairline) {
            ForEach(PlayerSection.allCases) { section in
                Button {
                    selection = section
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: section.symbol)
                            .font(section == .search ? .title2.bold() : .body.weight(.semibold))
                            .frame(height: 26)
                        Text(section.title)
                            .font(BHFont.caption)
                    }
                    .foregroundStyle(selection == section ? BHColor.onAccent : BHColor.inkMuted)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 58)
                    .padding(.vertical, section == .search ? BHSpacing.tight : BHSpacing.hairline)
                    .background {
                        if selection == section {
                            if section == .search {
                                Circle().fill(BHColor.accent)
                            } else {
                                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                                    .fill(BHColor.accent)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(section.title)
                .accessibilityAddTraits(selection == section ? .isSelected : [])
                .accessibilityIdentifier("tab.\(section.rawValue)")
            }
        }
        .padding(.horizontal, BHSpacing.tight)
        .padding(.vertical, BHSpacing.tight)
        .background(
            Capsule(style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.14), radius: 18, y: 5)
        )
        .overlay(Capsule(style: .continuous).strokeBorder(BHColor.separator.opacity(0.8)))
        .padding(.horizontal, BHSpacing.regular)
        .padding(.top, BHSpacing.tight)
        .padding(.bottom, BHSpacing.tight)
    }
}

/// Den fælles top, inspireret af referenceappens piller og runde genveje.
struct PlayerTopBar: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    private var totalPoints: Int {
        engine.playableMissions
            .filter { engine.isCompleted($0) }
            .reduce(0) { $0 + engine.points(for: $1) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Text("VEJLE")
                .font(BHFont.eyebrow)
                .tracking(2)
                .foregroundStyle(BHColor.accent)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: BHSpacing.tight) { title; actions }
                VStack(alignment: .leading, spacing: BHSpacing.tight) { title; actions }
            }
        }
        .padding(.horizontal, BHSpacing.regular)
        .padding(.top, BHSpacing.snug)
        .padding(.bottom, BHSpacing.tight)
        .background(BHColor.canvas)
    }

    private var title: some View {
        Text("Vejles Koder")
            .font(BHFont.title)
            .foregroundStyle(BHColor.ink)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private var actions: some View {
        HStack(spacing: BHSpacing.tight) {
            Button {
                router.push(.map)
            } label: {
                Image(systemName: "map.fill")
                    .font(BHFont.heading)
                    .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                    .background(Circle().fill(BHColor.surface))
                    .overlay(Circle().strokeBorder(BHColor.separator))
            }
            .accessibilityLabel("Åbn kortet")
            .accessibilityIdentifier("map.open")

            Button {
                router.push(.scoreboard)
            } label: {
                Label("\(totalPoints)", systemImage: "diamond.fill")
                    .font(BHFont.heading)
                    .monospacedDigit()
                    .padding(.horizontal, BHSpacing.snug)
                    .frame(minHeight: BHMetrics.minimumTapTarget)
                    .background(Capsule().fill(BHColor.accentSoft))
                    .overlay(Capsule().strokeBorder(BHColor.accent.opacity(0.35)))
            }
            .accessibilityLabel("\(totalPoints) point. Åbn dine point")
            .accessibilityIdentifier("home.points")

            Button {
                router.push(.leaderboards)
            } label: {
                Image(systemName: "trophy.fill")
                    .font(BHFont.heading)
                    .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                    .background(Circle().fill(BHColor.surface))
                    .overlay(Circle().strokeBorder(BHColor.separator))
            }
            .accessibilityLabel("Åbn highscorelisten")
            .accessibilityIdentifier("scoreboard.open")
        }
        .foregroundStyle(BHColor.accent)
    }
}

/// Tværgående sektionsoverskrift med valgfri forklaring.
struct DiscoverySectionHeader: View {
    let title: String
    var subtitle: String?
    var showsExampleBadge = false

    var body: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            HStack(alignment: .firstTextBaseline, spacing: BHSpacing.tight) {
                Text(title)
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                if showsExampleBadge {
                    BHChip("Eksempel", systemImage: "sparkles", tint: BHColor.caution)
                }
            }
            if let subtitle {
                Text(subtitle)
                    .font(BHFont.caption)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Et beskåret opgavefoto til forsidens kort.
///
/// Kortet viser både AI-mærkning og kredit på selve billedet. De oplysninger må
/// ikke forsvinde, blot fordi billedet bruges i en mere kompakt sammenhæng.
struct MissionCoverImage: View {
    let mission: Mission
    var height: CGFloat = 220

    @Environment(MissionEngine.self) private var engine
    @State private var image: Image?

    private var mediaId: String? { mission.resolvedThumbnailMediaId }
    private var asset: MediaAsset? {
        guard let mediaId else { return nil }
        return engine.pack?.media(id: mediaId)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [BHColor.brand, BHColor.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay {
                        Image(systemName: "map.fill")
                            .font(.largeTitle)
                            .foregroundStyle(BHColor.onBrand.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .clipped()

            if let asset {
                VStack(alignment: .leading, spacing: 4) {
                    if asset.kind == .known(.aiGenerated) {
                        Label("AI-genereret", systemImage: "sparkles")
                    }
                    if let credit = asset.creditLine, !credit.isEmpty {
                        Text(credit)
                            .lineLimit(2)
                    }
                }
                .font(BHFont.caption)
                .foregroundStyle(.white)
                .padding(BHSpacing.tight)
                .background(.black.opacity(0.62), in: RoundedRectangle(cornerRadius: BHRadius.control))
                .padding(BHSpacing.tight)
            }
        }
        .frame(height: height)
        .accessibilityLabel(asset?.altText ?? "Illustration til \(mission.title)")
        .accessibilityAddTraits(.isImage)
        .task(id: mediaId) {
            guard let asset, asset.resolvedMediaType == .image else { return }
            image = await ImageCache.shared.image(for: asset)
        }
    }
}

/// Kompakt opgaverække, delt af søgning og historik.
struct MissionDiscoveryRow: View {
    let mission: Mission
    var badge: String?

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    var body: some View {
        Button {
            router.push(.missionDetail(missionId: mission.id))
        } label: {
            HStack(alignment: .top, spacing: BHSpacing.snug) {
                if let mediaId = mission.resolvedThumbnailMediaId {
                    MissionThumbnail(mediaId: mediaId)
                }

                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    if let badge {
                        Text(badge.uppercased())
                            .font(BHFont.eyebrow)
                            .foregroundStyle(BHColor.accent)
                    }
                    Text(mission.title)
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                        .multilineTextAlignment(.leading)
                    if let location = engine.location(for: mission) {
                        Label(location.name, systemImage: "mappin.and.ellipse")
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.inkMuted)
                            .lineLimit(2)
                    }
                    Label("ca. \(mission.estimatedMinutes) min. · \(mission.basePoints) point", systemImage: "clock")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(BHColor.inkMuted)
            }
            .padding(BHSpacing.snug)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                    .fill(BHColor.surface)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mission.title), cirka \(mission.estimatedMinutes) minutter, \(mission.basePoints) point")
        .accessibilityHint("Åbner opgaven")
        .accessibilityIdentifier("discovery.mission.\(mission.id)")
    }
}
