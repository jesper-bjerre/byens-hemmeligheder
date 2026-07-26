import BHContracts
import BHDesignSystem
import BHGameCore
import MapKit
import SwiftUI

/// Kortet med spilleren i centrum.
///
/// ## Kortet er en bekvemmelighed, ikke en afhængighed
///
/// Fliser caches eller persisteres **ikke** — Apples vilkår forbyder det, og
/// konflikten med løftet om offline løses ved at gøre kortet undværligt frem
/// for at bryde vilkårene (research.md R-008). Listen nedenunder bærer al den
/// information, kortet viser. Med nul fliser er skærmen stadig fuldt brugbar.
///
/// ## Spillerens position tegnes af os, ikke af MapKit
///
/// `UserAnnotation` læser CoreLocation direkte og ville derfor ignorere den
/// simulerede position, udviklerpanelet sætter. Ét mærke, tegnet ud fra
/// ``MissionEngine/currentLocation``, opfører sig ens i simulator og i felten —
/// og så er der kun ét sted at fejlsøge.
struct ExploreMapView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    @State private var camera: MapCameraPosition = .region(Self.vejleHarbour)
    /// Følger kortet spilleren? Slås fra, når brugeren selv panorerer.
    @State private var followsPlayer = true
    @State private var visibleCentre: CLLocationCoordinate2D?
    @State private var showsAllMissions = false
    @State private var showsDevPanel = false

    /// Hvor mange uløste opgaver listen viser, før den folder ud.
    private static let previewCount = 3

    /// Vejle Havn. Kun et startudsnit, indtil spillerens position kendes.
    static let vejleHarbour = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.708, longitude: 9.551),
        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    )

    var body: some View {
        withDevTools(content)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                map
                missionList
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle("Byens Hemmeligheder")
        .navigationBarTitleDisplayMode(.large)
        .task {
            // Kun hvis spilleren allerede har sagt ja. En prompt ved opstart er
            // netop dét, FR-030 forbyder.
            if engine.hasLocationAuthorization {
                engine.startLocationUpdates()
            }
        }
        .onChange(of: engine.currentLocation) { _, location in
            guard followsPlayer, let location else { return }
            centre(on: location)
        }
        .sheet(isPresented: $showsDevPanel) {
            #if BH_DEV_TOOLS
            DevLocationPanel()
            #endif
        }
    }

    /// Værktøjslinjen findes **kun** i Debug.
    ///
    /// `#if` skal ligge om hele `.toolbar`-modifikatoren og ikke om dens
    /// indhold: en tom `ToolbarContentBuilder` er ikke gyldig, og fejlen viser
    /// sig først i en Release-bygning, hvor flaget er slået fra.
    @ViewBuilder
    private func withDevTools(_ content: some View) -> some View {
        #if BH_DEV_TOOLS
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showsDevPanel = true
                } label: {
                    Label("Simuler position", systemImage: "hammer")
                }
            }
        }
        #else
        content
        #endif
    }

    // MARK: - Kort

    private var map: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Map(position: $camera) {
                if let location = engine.currentLocation {
                    Annotation("Dig", coordinate: location.coordinate) {
                        playerDot
                    }
                    .annotationTitles(.hidden)
                }

                ForEach(unsolvedMissions) { mission in
                    if let point = engine.vantagePoint(for: mission) {
                        Marker(mission.shortTitle, systemImage: "mappin", coordinate: point.coordinate)
                            .tint(BHColor.accent)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .frame(height: 340)
            .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
            .onMapCameraChange(frequency: .onEnd) { context in
                visibleCentre = context.region.center
                // Har brugeren flyttet kortet væk fra sig selv, skal det blive
                // liggende. Et kort, der hopper tilbage, er ubrugeligt til at
                // kigge efter den næste opgave.
                if let location = engine.currentLocation,
                   distanceMetres(from: context.region.center, to: location.coordinate) > 60 {
                    followsPlayer = false
                }
            }
            // Kortet gentager kun, hvad listen allerede siger.
            .accessibilityHidden(true)

            mapFooter
        }
    }

    private var playerDot: some View {
        ZStack {
            Circle()
                .fill(BHColor.accent.opacity(0.25))
                .frame(width: 34, height: 34)
            Circle()
                .fill(BHColor.accent)
                .frame(width: 16, height: 16)
                .overlay(Circle().strokeBorder(.white, lineWidth: 3))
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var mapFooter: some View {
        if engine.currentLocation == nil {
            Button {
                router.presentedSheet = .permissionPrimer(missionId: "")
            } label: {
                Label("Vis hvor jeg er", systemImage: "location")
                    .font(BHFont.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(BHColor.accent)
            .frame(minHeight: BHMetrics.minimumTapTarget)
        } else if !followsPlayer {
            Button {
                followsPlayer = true
                if let location = engine.currentLocation { centre(on: location) }
            } label: {
                Label("Centrér på mig", systemImage: "location.fill")
                    .font(BHFont.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(BHColor.accent)
            .frame(minHeight: BHMetrics.minimumTapTarget)
        }
    }

    /// Bevarer brugerens zoomniveau, når kortet følger med.
    private func centre(on location: GeoPoint) {
        let span = camera.region?.span
            ?? MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        withAnimation(.easeInOut(duration: 0.35)) {
            camera = .region(MKCoordinateRegion(center: location.coordinate, span: span))
        }
    }

    private func distanceMetres(
        from first: CLLocationCoordinate2D,
        to second: CLLocationCoordinate2D
    ) -> Double {
        GeoMath.distanceMetres(
            from: GeoPoint(latitude: first.latitude, longitude: first.longitude),
            to: GeoPoint(latitude: second.latitude, longitude: second.longitude)
        )
    }

    // MARK: - Liste

    /// Uløste opgaver, nærmeste først når positionen kendes.
    private var unsolvedMissions: [Mission] {
        engine.playableMissions
            .filter { !engine.isCompleted($0) }
            .sorted { first, second in
                switch (engine.distanceMetres(to: first), engine.distanceMetres(to: second)) {
                case let (a?, b?): a < b
                case (_?, nil): true
                case (nil, _?): false
                case (nil, nil): first.shortTitle < second.shortTitle
                }
            }
    }

    private var solvedMissions: [Mission] {
        engine.playableMissions.filter { engine.isCompleted($0) }
    }

    private var listedMissions: [Mission] {
        showsAllMissions ? unsolvedMissions : Array(unsolvedMissions.prefix(Self.previewCount))
    }

    private var missionList: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            Text(unsolvedMissions.isEmpty ? "Alle opgaver er løst" : "Næste opgaver")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.ink)

            if unsolvedMissions.isEmpty {
                Text("Du har løst alle opgaverne ved Vejle Havn. Flere kommer til.")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(listedMissions) { mission in
                Button {
                    router.push(.missionDetail(missionId: mission.id))
                } label: {
                    missionRow(mission)
                }
                .buttonStyle(.plain)
            }

            if unsolvedMissions.count > Self.previewCount {
                Button(showsAllMissions ? "Vis færre" : "Vis alle \(unsolvedMissions.count)") {
                    withAnimation { showsAllMissions.toggle() }
                }
                .buttonStyle(.plain)
                .font(BHFont.caption)
                .foregroundStyle(BHColor.accent)
                .frame(minHeight: BHMetrics.minimumTapTarget)
            }

            if !solvedMissions.isEmpty {
                solvedSection
            }
        }
    }

    private var solvedSection: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            Text("Løst")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.inkMuted)
                .padding(.top, BHSpacing.tight)

            ForEach(solvedMissions) { mission in
                Button {
                    router.push(.missionDetail(missionId: mission.id))
                } label: {
                    missionRow(mission)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func missionRow(_ mission: Mission) -> some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                HStack(alignment: .firstTextBaseline) {
                    Text(mission.title)
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: BHSpacing.tight)
                    statusBadge(for: mission)
                }
                Text(mission.teaser)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: BHSpacing.regular) {
                    Label(
                        "Sværhedsgrad \(mission.difficulty) af 5",
                        systemImage: "brain.head.profile"
                    )
                    Label("ca. \(mission.estimatedMinutes) min.", systemImage: "clock")
                    if let distance = engine.distanceMetres(to: mission) {
                        Label(distanceText(distance), systemImage: "figure.walk")
                    }
                }
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
                .labelStyle(.titleAndIcon)
            }
        }
        .frame(minHeight: BHMetrics.minimumTapTarget)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: mission))
        .accessibilityHint("Åbner opgavens detaljer")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("mission.\(mission.id)")
    }

    /// Aldrig større præcision, end afstanden bærer.
    private func distanceText(_ metres: Double) -> String {
        metres < 950
            ? "\(Int((metres / 10).rounded() * 10)) m herfra"
            : String(format: "%.1f km herfra", metres / 1000)
    }

    /// Status bæres af **både** tekst og symbol. Farve alene ville udelukke
    /// den, der ikke skelner farverne (FR-039).
    @ViewBuilder
    private func statusBadge(for mission: Mission) -> some View {
        if engine.isCompleted(mission) {
            Label("Løst", systemImage: "checkmark.seal.fill")
                .font(BHFont.eyebrow)
                .foregroundStyle(BHColor.success)
                .labelStyle(.titleAndIcon)
        } else {
            Label("Ikke løst", systemImage: "circle.dashed")
                .font(BHFont.eyebrow)
                .foregroundStyle(BHColor.inkMuted)
                .labelStyle(.titleAndIcon)
        }
    }

    private func accessibilityLabel(for mission: Mission) -> String {
        var parts = [
            mission.title,
            engine.isCompleted(mission) ? "Løst" : "Ikke løst",
            mission.teaser,
            "Sværhedsgrad \(mission.difficulty) af 5",
            "Cirka \(mission.estimatedMinutes) minutter",
        ]
        if let distance = engine.distanceMetres(to: mission) {
            parts.append(distanceText(distance))
        }
        return parts.joined(separator: ". ")
    }
}

extension GeoPoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
