import BHContracts
import BHDesignSystem
import MapKit
import SwiftUI

/// Startsiden: inspiration før geografi.
///
/// Kortet er stadig den autoritative måde at se samtlige opgaver på. Forsiden
/// fremhæver et lille udvalg og gør det tydeligt, hvad man får ud af login,
/// inden spilleren begynder at lede.
struct PlayerExploreView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(PlayerAuthentication.self) private var authentication
    @Environment(MissionFavoritesStore.self) private var favorites
    @Environment(PlayerScoresStore.self) private var scores
    @Environment(Router.self) private var router

    private var missions: [Mission] { engine.playableMissions }

    /// Ny betyder nyligt frigivet — ikke nyligt oprettet. En kladde kan have
    /// ligget længe hos redaktionen og er først en ny oplevelse for spilleren,
    /// når den faktisk bliver offentlig.
    private var newMissions: [Mission] {
        missions
            .filter { releaseDate(for: $0) != nil }
            .sorted { first, second in
                let firstDate = releaseDate(for: first) ?? .distantPast
                let secondDate = releaseDate(for: second) ?? .distantPast
                return firstDate == secondDate
                    ? first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
                    : firstDate > secondDate
            }
            .prefix(6)
            .map { $0 }
    }

    private var favoriteMissions: [Mission] {
        missions
            .filter { (favorites.metrics(for: $0.id)?.favoriteCount ?? 0) > 0 }
            .sorted { first, second in
                let firstCount = favorites.metrics(for: first.id)?.favoriteCount ?? 0
                let secondCount = favorites.metrics(for: second.id)?.favoriteCount ?? 0
                return firstCount == secondCount
                    ? first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
                    : firstCount > secondCount
            }
            .prefix(6)
            .map { $0 }
    }

    private var trendingMissions: [Mission] {
        missions
            .filter { (favorites.metrics(for: $0.id)?.trendingCount ?? 0) > 0 }
            .sorted { first, second in
                let firstCount = favorites.metrics(for: first.id)?.trendingCount ?? 0
                let secondCount = favorites.metrics(for: second.id)?.trendingCount ?? 0
                return firstCount == secondCount
                    ? first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
                    : firstCount > secondCount
            }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: BHSpacing.section) {
                PlayerTopBar()
                    .padding(.horizontal, -BHSpacing.regular)

                if authentication.state != .signedIn {
                    PlayerAccountCard(purpose: .leaderboard)
                }

                mapPreview

                horizontalMissionSection(
                    title: "Favoritter lige nu",
                    subtitle: "De opgaver, som flest spillere har gemt som favorit.",
                    missions: favoriteMissions,
                    badge: "Favorit",
                    emptyText: "Ingen opgaver har fået et hjerte endnu."
                )
                horizontalMissionSection(
                    title: "Trender lige nu",
                    subtitle: "Flest nye favoritter inden for de seneste 30 dage.",
                    missions: trendingMissions,
                    badge: "Trender",
                    emptyText: "Der er endnu ingen nye favoritter fra de seneste 30 dage."
                )
                horizontalMissionSection(
                    title: "Nye oplevelser",
                    subtitle: "De senest frigivne gåder og hemmeligheder.",
                    missions: newMissions,
                    badge: "Ny",
                    emptyText: "Der er ingen nyligt frigivne opgaver at vise endnu."
                )
            }
            .padding(.horizontal, BHSpacing.regular)
            .padding(.bottom, BHSpacing.section)
        }
        .background(BHColor.canvas)
        .accessibilityIdentifier("home.explore")
        .task(id: authentication.state) {
            await favorites.refresh(using: authentication)
            await scores.syncAll(from: engine, using: authentication)
        }
    }

    /// Et orienterende udsnit, ikke et ekstra kort-UI.
    ///
    /// Hele kortet er én genvej. Selve MapKit-fladen tager ingen bevægelser,
    /// så spilleren ikke ender med at panorere eller zoome i et lille kort
    /// midt i forsidens scroll.
    private var mapPreview: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(
                title: "Opgaver omkring dig",
                subtitle: "Tryk på kortet for at udforske, zoome og åbne opgaver."
            )

            Button {
                router.push(.map)
            } label: {
                ExploreMapPreview()
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                            .strokeBorder(BHColor.separator)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Label("Åbn kortet", systemImage: "arrow.up.right")
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.onAccent)
                            .padding(.horizontal, BHSpacing.snug)
                            .frame(minHeight: BHMetrics.minimumTapTarget)
                            .background(Capsule().fill(BHColor.accent))
                            .padding(BHSpacing.snug)
                    }
                    // MapKit er en indlejret UIKit-flade. Den transparente del
                    // af kortet indgik ellers ikke altid i knappens hit-test,
                    // selv om Map'et selv havde interaktion slået fra.
                    .contentShape(
                        RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Åbn kortet med opgaver omkring din position")
            .accessibilityHint("Åbner det interaktive kort")
            .accessibilityIdentifier("home.map.preview")
        }
    }

    private func horizontalMissionSection(
        title: String,
        subtitle: String,
        missions: [Mission],
        badge: String,
        emptyText: String,
        showsExampleBadge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(
                title: title,
                subtitle: subtitle,
                showsExampleBadge: showsExampleBadge
            )

            if missions.isEmpty {
                Text(emptyText)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: BHSpacing.snug) {
                        ForEach(missions) { mission in
                            compactCard(mission, badge: badge)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }

    private func compactCard(_ mission: Mission, badge: String) -> some View {
        Button {
            router.push(.missionDetail(missionId: mission.id))
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                MissionCoverImage(mission: mission, height: 145)

                VStack(alignment: .leading, spacing: BHSpacing.tight) {
                    Text(badge.uppercased())
                        .font(BHFont.eyebrow)
                        .foregroundStyle(BHColor.accent)
                    Text(mission.title)
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    Label("ca. \(mission.estimatedMinutes) min.", systemImage: "clock")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                    if let engagement = engagementLabel(for: mission, badge: badge) {
                        Label(engagement, systemImage: "heart.fill")
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.accent)
                    }
                }
                .padding(BHSpacing.snug)
                .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
            }
            .frame(width: 250)
            .background(BHColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                    .strokeBorder(BHColor.separator.opacity(0.7))
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(badge): \(mission.title)")
        .accessibilityHint("Åbner opgaven")
    }

    private func engagementLabel(for mission: Mission, badge: String) -> String? {
        guard let metrics = favorites.metrics(for: mission.id) else { return nil }
        switch badge {
        case "Favorit": return "\(metrics.favoriteCount) favoritter"
        case "Trender": return "\(metrics.trendingCount) nye favoritter"
        default: return nil
        }
    }

    private func releaseDate(for mission: Mission) -> Date? {
        guard let value = mission.releasedAt else { return nil }
        return ISO8601DateFormatter().date(from: value)
    }
}

/// Det lille kort på Explore er bevidst uden interaktion.
private struct ExploreMapPreview: View {
    @Environment(MissionEngine.self) private var engine
    @State private var camera: MapCameraPosition = .region(Self.vejle)

    private static let vejle = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.708, longitude: 9.551),
        span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    )

    var body: some View {
        Map(position: $camera, interactionModes: []) {
            ForEach(engine.playableMissions) { mission in
                if let location = engine.location(for: mission),
                   let latitude = location.latitude,
                   let longitude = location.longitude {
                    Marker(
                        mission.title,
                        systemImage: engine.isCompleted(mission) ? "checkmark" : "questionmark",
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    )
                    .tint(engine.isCompleted(mission) ? BHColor.success : BHColor.accent)
                }
            }

            if let location = engine.currentLocation {
                Annotation("Din position", coordinate: location.coordinate) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                }
            }
        }
        .mapControlVisibility(.hidden)
        .allowsHitTesting(false)
        .task { centreOnCurrentLocation() }
        .onChange(of: engine.currentLocation) { _, _ in centreOnCurrentLocation() }
        .accessibilityHidden(true)
    }

    private func centreOnCurrentLocation() {
        guard let location = engine.currentLocation else { return }
        camera = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: Self.vejle.span
            )
        )
    }
}
