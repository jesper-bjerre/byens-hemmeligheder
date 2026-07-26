import BHContracts
import BHDesignSystem
import BHGameCore
import MapKit
import SwiftUI

/// Forsiden. Kortet er skærmen.
///
/// ## Kortet er det primære element
///
/// Spilleren er i centrum og zoomer selv ud for at finde den næste opgave.
/// Der findes bevidst **ingen liste** — den ville dublere kortet og gøre
/// opdagelsen til en opremsning frem for en udforskning.
///
/// ## Kortet er stadig ikke en afhængighed
///
/// Fliser caches eller persisteres ikke; Apples vilkår forbyder det (R-008).
/// Men nu hvor listen er væk, bærer markørerne selv informationen: de er
/// selvstændige tilgængelighedselementer med fuld etiket, så en VoiceOver-bruger
/// kan swipe gennem opgaverne uden at kunne se kortet. Uden det ville SC-009
/// være brudt i det øjeblik, listen forsvandt.
///
/// ## Spillerens position tegnes af os, ikke af MapKit
///
/// `UserAnnotation` læser CoreLocation direkte og ville derfor ignorere den
/// simulerede position, udviklerpanelet sætter. Ét mærke, tegnet ud fra
/// ``MissionEngine/currentLocation``, opfører sig ens i simulator og i felten.
struct ExploreMapView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    @State private var camera: MapCameraPosition = .region(Self.vejleHarbour)
    /// Følger kortet spilleren? Slås fra, når brugeren selv panorerer.
    @State private var followsPlayer = true
    /// MapKits egen markering. Annotationens indhold kan ikke selv håndtere
    /// trykket — MapKit lægger sin egen wrapper om det og sluger det.
    @State private var hasCentredOnce = false
    @State private var selectedMission: Mission?
    /// Hvilken opgave der allerede er poppet op ved ankomst. Nulstilles, når
    /// spilleren går væk igen, så et gensyn giver et nyt pop.
    @State private var announcedMissionId: String?
    @State private var showsDevPanel = false

    /// Vejle Havn. Kun et startudsnit, indtil spillerens position kendes.
    static let vejleHarbour = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.708, longitude: 9.551),
        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    )

    var body: some View {
        content
    }

    private var content: some View {
        VStack(spacing: 0) {
            BHBrandHeader { headerTrailing }
            map
                .overlay(alignment: .topTrailing) { mapActions }
                .overlay(alignment: .bottom) { preview }
        }
        .background(BHColor.brand)
        .ignoresSafeArea(edges: .bottom)
        // Egen header frem for navigationslinjens titel. SwiftUI giver
        // værktøjslinje- og titelelementer faste fontstørrelser, der ikke
        // følger Dynamic Type — det fandt tilgængelighedsauditten allerede
        // én gang i HintSheet.
        .toolbar(.hidden, for: .navigationBar)
            .task {
                // Kun hvis spilleren allerede har sagt ja. En prompt ved opstart
                // er netop dét, FR-030 forbyder.
                if engine.hasLocationAuthorization {
                    engine.startLocationUpdates()
                }
            }
            .onChange(of: engine.currentLocation) { _, location in
                if followsPlayer, let location { centre(on: location) }
                announceArrivalIfNeeded()
            }
            .sheet(isPresented: $showsDevPanel) {
                #if BH_DEV_TOOLS
                DevLocationPanel()
                #endif
            }
    }

    /// Udviklerknappen findes **kun** i Debug.
    ///
    /// `#if` skal omslutte hele grenen og ikke kun dens indhold: en tom
    /// `ViewBuilder`-gren er gyldig, men en tom `ToolbarContentBuilder` er ikke
    /// — og dét viste sig først i en Release-bygning, dengang knappen sad i
    /// værktøjslinjen.
    @ViewBuilder
    private var headerTrailing: some View {
        #if BH_DEV_TOOLS
        Button {
            showsDevPanel = true
        } label: {
            Image(systemName: "hammer")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.onBrand)
                .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                .overlay(Circle().strokeBorder(BHColor.onBrand, lineWidth: 1.5))
        }
        .accessibilityLabel("Simuler position")
        #else
        EmptyView()
        #endif
    }

    // MARK: - Kort

    /// Kortet.
    ///
    /// ## Hvorfor trykket håndteres her og ikke på markøren
    ///
    /// `Annotation` lægger MapKits egen wrapper om sit indhold, og den opfanger
    /// alle tryk. Hverken en `Button`, en `.onTapGesture` eller
    /// `Map(selection:)` med `.tag` når frem til indholdet — verificeret med
    /// både element- og koordinattryk.
    ///
    /// Løsningen er at tage imod trykket på kortet og selv finde ud af, hvad der
    /// blev ramt: `MapReader` oversætter skærmpunktet til et koordinat, og
    /// nærmeste markør inden for en trykflade vinder. Det virker ens for en
    /// finger og for XCUITest, og hit-testen er vores egen at fejlsøge.
    private var map: some View {
        MapReader { proxy in
            Map(position: $camera) {
                if let location = engine.currentLocation {
                    Annotation("Dig", coordinate: location.coordinate) {
                        playerDot
                    }
                    .annotationTitles(.hidden)
                }

                ForEach(mappableMissions) { mission in
                    if let point = engine.vantagePoint(for: mission) {
                        Annotation(mission.shortTitle, coordinate: point.coordinate) {
                            missionPin(mission)
                        }
                        .annotationTitles(.hidden)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .bottom)
            .coordinateSpace(.named(Self.mapSpace))
            // `simultaneousGesture`, ikke `onTapGesture`.
            //
            // MapKit har sine egne genkendere til panorering og zoom. En
            // almindelig `.onTapGesture` konkurrerer med dem, og et klik med et
            // pegefelt indeholder næsten altid et par pixels bevægelse — nok
            // til at panoreringen vinder, så trykket aldrig når frem. Et
            // syntetisk touch fra XCUITest er derimod helt roligt og slipper
            // igennem, hvilket er grunden til, at testene bestod, mens en
            // finger ikke fik noget til at ske.
            //
            // En simultan gestus konkurrerer ikke — den kører ved siden af.
            .simultaneousGesture(
                SpatialTapGesture(coordinateSpace: .named(Self.mapSpace))
                    .onEnded { event in
                        handleTap(at: event.location, proxy: proxy)
                    }
            )
            .onMapCameraChange(frequency: .onEnd) { context in
                // Har brugeren flyttet kortet væk fra sig selv, skal det blive
                // liggende. Et kort, der hopper tilbage, er ubrugeligt til at
                // kigge efter den næste opgave.
                if let location = engine.currentLocation,
                   distanceMetres(from: context.region.center, to: location.coordinate) > 60 {
                    followsPlayer = false
                }
            }
        }
    }

    /// Kortets eget koordinatrum.
    ///
    /// Både gestussen og `MapProxy` måler i **samme** navngivne rum. Med
    /// `.local` begge steder virker det også — det blev efterprøvet — men
    /// `.local` betyder to forskellige ting de to steder, og at det falder
    /// sammen, er en tilfældighed ved det nuværende layout. Et navngivet rum
    /// siger hvad der menes.
    private static let mapSpace = "bh.map"

    /// Finder den markør, spilleren ramte — hvis nogen.
    ///
    /// Hit-testen sker i **skærmpunkter**, ikke i meter. Trykfladen er dermed
    /// lige stor uanset zoomniveau, og der er ingen omregning at tage fejl af.
    private func handleTap(at screenPoint: CGPoint, proxy: MapProxy) {
        // Rundhåndet trykflade. Markørerne ligger hundredvis af meter fra
        // hinanden, så et bredt vindue kan ikke ramme den forkerte — og en
        // finger på en telefon i blæsevejr rammer ikke præcist.
        let radius = BHMetrics.minimumTapTarget * 1.5

        let hit = mappableMissions
            .compactMap { mission -> (Mission, CGFloat)? in
                guard let point = engine.vantagePoint(for: mission),
                      let pinPoint = proxy.convert(point.coordinate, to: .named(Self.mapSpace))
                else { return nil }
                let dx = pinPoint.x - screenPoint.x
                let dy = pinPoint.y - screenPoint.y
                return (mission, sqrt(dx * dx + dy * dy))
            }
            .filter { $0.1 <= radius }
            .min { $0.1 < $1.1 }

        withAnimation(.snappy(duration: 0.25)) {
            selectedMission = hit?.0
        }
    }

    /// Markørens udseende.
    ///
    /// Bevidst **ikke** en `Button`. `Annotation` pakker sit indhold ind i
    /// MapKits egen markeringswrapper, som opfanger trykket — en knap indeni
    /// bliver aldrig aktiveret, hverken af en finger eller af XCUITest. Trykket
    /// håndteres derfor gennem `Map(selection:)` og `.tag(mission.id)`.
    private func missionPin(_ mission: Mission) -> some View {
        let solved = engine.isCompleted(mission)

        return VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(solved ? BHColor.success : BHColor.accent)
                    .frame(width: 36, height: 36)
                    .shadow(radius: 2, y: 1)
                Image(systemName: solved ? "checkmark" : "questionmark")
                    .font(.headline)
                    .foregroundStyle(BHColor.onAccent)
            }
            Text(mission.shortTitle)
                .font(BHFont.eyebrow)
                .foregroundStyle(BHColor.ink)
                .padding(.horizontal, BHSpacing.tight)
                .padding(.vertical, 2)
                .background(Capsule().fill(BHColor.surface.opacity(0.9)))
                .fixedSize()
        }
        .frame(minWidth: BHMetrics.minimumTapTarget, minHeight: BHMetrics.minimumTapTarget)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityAction { selectedMission = mission }
        .accessibilityLabel(MissionSummary.accessibilityLabel(for: mission, engine: engine))
        .accessibilityHint("Viser en kort beskrivelse af opgaven")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("mission.\(mission.id)")
    }

    /// Åbner opgavekortet af sig selv, når spilleren når frem.
    ///
    /// Samme kort som ved et tryk på markøren — spilleren skal ikke lede efter
    /// den prik, hen står oven på. Opgaven **startes** ikke automatisk; det
    /// blivende tryk på "Start opgave" er stadig spillerens eget.
    private func announceArrivalIfNeeded() {
        let arrived = mappableMissions.first {
            !engine.isCompleted($0) && engine.startability(for: $0) == .ready
        }

        guard let arrived else {
            // Gået væk igen. Næste ankomst må gerne melde sig på ny.
            announcedMissionId = nil
            return
        }
        guard announcedMissionId != arrived.id else { return }

        announcedMissionId = arrived.id
        guard selectedMission == nil else { return }
        withAnimation(.snappy(duration: 0.25)) { selectedMission = arrived }
    }

    /// Kortet, der lægger sig over kortet, når en markør er valgt.
    ///
    /// Bevidst **ikke** et ark. Et ark med fast højde komprimerer sit nederste
    /// element, så knapteksten ikke kan vokse med Dynamic Type — og et ark i
    /// fuld højde er ikke en popup. Et overlay bestemmer selv sin højde ud fra
    /// indholdet og har ingen af delene som problem.
    @ViewBuilder
    private var preview: some View {
        if let mission = selectedMission {
            MissionPreviewCard(
                mission: mission,
                onOpen: { start(mission) },
                onClose: {
                    withAnimation(.snappy(duration: 0.2)) { selectedMission = nil }
                }
            )
            .padding(BHSpacing.snug)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    /// Går direkte i gang. Spilleren står allerede ved stedet — knappen er
    /// lukket alle andre steder — så der er ingen vej at vise først.
    private func start(_ mission: Mission) {
        selectedMission = nil
        Task {
            await engine.startSession(for: mission)
            if engine.hasSeenSafetyInterstitial {
                router.push(.approach(missionId: mission.id))
            } else {
                // Sikkerhedsskærmen vises én gang pr. session (FR-008) og
                // fører selv videre til stedet.
                router.presentedSheet = .safety(missionId: mission.id)
            }
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
        .accessibilityLabel("Din position")
    }

    /// Uløste først, så en løst opgave aldrig dækker en, spilleren mangler.
    private var mappableMissions: [Mission] {
        engine.playableMissions.sorted { first, second in
            engine.isCompleted(first) && !engine.isCompleted(second)
        }
    }

    // MARK: - Handlinger oven på kortet

    @ViewBuilder
    private var mapActions: some View {
        if engine.currentLocation == nil {
            mapActionButton("Vis hvor jeg er", systemImage: "location") {
                router.presentedSheet = .permissionPrimer(missionId: "")
            }
        } else if !followsPlayer {
            mapActionButton("Centrér på mig", systemImage: "location.fill") {
                followsPlayer = true
                if let location = engine.currentLocation { centre(on: location) }
            }
        }
    }

    private func mapActionButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(BHFont.caption)
                .foregroundStyle(BHColor.accent)
                .padding(.horizontal, BHSpacing.snug)
                .frame(minHeight: BHMetrics.minimumTapTarget)
                .background(Capsule().fill(BHColor.surface))
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
        .padding(BHSpacing.snug)
    }

    /// Bevarer brugerens zoomniveau, når kortet følger med.
    ///
    /// **Den første centrering animerer ikke.** Under animationen er markørerne
    /// allerede tegnet på deres nye plads, mens kortets omregning fra koordinat
    /// til skærmpunkt stadig følger den gamle — og så rammer et tryk ved siden
    /// af det, fingeren ser. Et spring fjerner vinduet helt.
    private func centre(on location: GeoPoint) {
        let span = camera.region?.span
            ?? MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)

        if hasCentredOnce {
            withAnimation(.easeInOut(duration: 0.35)) { camera = .region(region) }
        } else {
            camera = .region(region)
            hasCentredOnce = true
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
}

// MARK: - Popup

/// Den korte beskrivelse, der vises ved tryk på en markør.
///
/// Indholdet er med vilje det samme som det gamle listekort: titel, status,
/// teaser, sværhedsgrad, varighed og afstand. Spilleren skal kunne afgøre
/// "gider jeg gå derhen?" uden at forlade kortet.
struct MissionPreviewCard: View {
    let mission: Mission
    let onOpen: () -> Void
    let onClose: () -> Void

    @Environment(MissionEngine.self) private var engine

    private var startability: MissionStartability { engine.startability(for: mission) }

    var body: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            HStack(alignment: .top) {
                MissionSummary(mission: mission)
                closeButton
            }

            safetyNote

            // Princip I: stedet er spillet. Knappen er lukket hjemmefra.
            Button("Start opgave", action: onOpen)
                .buttonStyle(.bhPrimary)
                .disabled(!startability.canStart)
                .opacity(startability.canStart ? 1 : 0.45)
                .accessibilityIdentifier("preview.open")
                .accessibilityHint(startability.canStart ? "" : startabilityNote ?? "")

            if let note = startabilityNote {
                Text(note)
                    .font(BHFont.caption)
                    .foregroundStyle(BHColor.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("preview.note")
            }
        }
        .padding(BHSpacing.regular)
        .background(
            RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                .fill(BHColor.canvas)
                .shadow(color: .black.opacity(0.18), radius: 16, y: -2)
        )
    }

    /// Sikkerhedsnoten står her, ikke bag en knap.
    ///
    /// Opgavekortet er nu det eneste, spilleren ser før turen, og forfatningens
    /// princip IV kræver, at risikoen er kendt inden da. Begge lokationer ligger
    /// ved åbent vand med cykeltrafik tæt på (FR-006).
    @ViewBuilder
    private var safetyNote: some View {
        if let notes = engine.location(for: mission)?.safety.notes {
            Label(notes, systemImage: "exclamationmark.triangle.fill")
                .font(BHFont.caption)
                .foregroundStyle(BHColor.caution)
                .labelStyle(.bhLeadingIcon)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Sikkerhed. \(notes)")
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(BHFont.body)
                .foregroundStyle(BHColor.inkMuted)
                .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
        }
        .accessibilityLabel("Luk")
        .accessibilityIdentifier("preview.close")
    }

    /// Den lille tekst under knappen. `nil`, når opgaven kan startes.
    private var startabilityNote: String? {
        let place = engine.location(for: mission)?.name ?? "stedet"

        switch startability {
        case .ready, .notGated:
            return nil
        case .locationUnknown:
            return "(Finder din position — du kan først starte, når du står ved \(place))"
        case .tooFar(let remaining):
            return "(Du kan først starte, når du står ved \(place) — der er \(Self.distance(remaining)) endnu)"
        }
    }

    private static func distance(_ metres: Double) -> String {
        metres < 950
            ? "cirka \(Int((metres / 10).rounded() * 10)) meter"
            : String(format: "cirka %.1f km", metres / 1000)
    }
}

/// Opgavekortet, som det så ud i listen. Delt, så popup og en fremtidig
/// oversigt ikke kan nå at drive fra hinanden.
struct MissionSummary: View {
    let mission: Mission

    @Environment(MissionEngine.self) private var engine

    var body: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                // Titlen får hele bredden. Stod status ved siden af, ville
                // titlen blive klemt og klippet ved de store
                // tilgængelighedsstørrelser — auditten fandt netop dét.
                Text(mission.title)
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(mission.teaser)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

                // Én chip pr. linje — som i designforslaget.
                //
                // Et ombrydende layout blev prøvet og forkastet: det giver hver
                // chip en fast størrelse, og så kan teksten ikke vokse med
                // Dynamic Type. Tilgængelighedsauditten afviste det med rette.
                VStack(alignment: .leading, spacing: BHSpacing.tight) { metadata }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Self.accessibilityLabel(for: mission, engine: engine))
    }

    @ViewBuilder
    private var metadata: some View {
        if engine.isCompleted(mission) {
            BHChip("Løst", systemImage: "checkmark.seal.fill", tint: BHColor.success)
        } else {
            BHChip("Ikke løst", systemImage: "circle.dashed", tint: BHColor.inkMuted)
        }
        BHChip("Sværhedsgrad \(mission.difficulty)", systemImage: "chart.bar.fill")
        BHChip("ca. \(mission.estimatedMinutes) min.", systemImage: "clock.fill")
        if let distance = engine.distanceMetres(to: mission) {
            BHChip(Self.distanceText(distance), systemImage: "figure.walk")
        }
    }

    /// Aldrig større præcision, end afstanden bærer.
    static func distanceText(_ metres: Double) -> String {
        metres < 950
            ? "\(Int((metres / 10).rounded() * 10)) m herfra"
            : String(format: "%.1f km herfra", metres / 1000)
    }

    static func accessibilityLabel(for mission: Mission, engine: MissionEngine) -> String {
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
