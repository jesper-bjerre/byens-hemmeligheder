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
    @Environment(AmbiencePlayer.self) private var ambience

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
            BHBrandHeader {
                HStack(spacing: BHSpacing.tight) {
                    ambienceButton
                    scoreboardButton
                    headerTrailing
                }
            }
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

    /// Slår baggrundsstemningen fra. Ét tryk, og valget huskes.
    ///
    /// Knappen er ikke gemt i en indstillingsskærm. Spilleren står udendørs,
    /// måske ved siden af andre — lyden skal kunne slukkes dér, hvor den
    /// generer, ikke tre menuer nede.
    private var ambienceButton: some View {
        Button {
            ambience.toggle()
        } label: {
            Image(systemName: ambience.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.onBrand)
                .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                .overlay(Circle().strokeBorder(BHColor.onBrand, lineWidth: 1.5))
        }
        .accessibilityLabel(ambience.isEnabled ? "Slå baggrundslyd fra" : "Slå baggrundslyd til")
        .accessibilityIdentifier("ambience.toggle")
    }

    /// Udviklerknappen findes **kun** i Debug.
    ///
    /// `#if` skal omslutte hele grenen og ikke kun dens indhold: en tom
    /// `ViewBuilder`-gren er gyldig, men en tom `ToolbarContentBuilder` er ikke
    /// — og dét viste sig først i en Release-bygning, dengang knappen sad i
    /// værktøjslinjen.
    @ViewBuilder
    /// Vejen til point og rangliste.
    ///
    /// I headeren og ikke i en fanebjælke: appen har én skærm, kortet, og en
    /// fanebjælke ville tage plads fra det uden at føre nogen steder hen, man
    /// ikke kan komme med ét tryk.
    private var scoreboardButton: some View {
        Button {
            router.push(.scoreboard)
        } label: {
            Image(systemName: "rosette")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.onBrand)
                .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                .overlay(Circle().strokeBorder(BHColor.onBrand, lineWidth: 1.5))
        }
        .accessibilityLabel("Dine point")
        .accessibilityIdentifier("scoreboard.open")
    }

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
                    if let point = displayPoint(for: mission) {
                        Annotation(mission.shortTitle, coordinate: point.coordinate) {
                            missionPin(mission)
                        }
                        // MapKit tegner titlen selv.
                        //
                        // Den lå tidligere i vores eget indhold, og så indgik
                        // den i markørens udstrækning: elementet blev op mod
                        // 167 pt bredt, mens hit-testen ledte inden for 66 pt
                        // af ankeret — et tryk på etikettens kant ramte
                        // ingenting. Låste vi bredden, kunne teksten ikke vokse
                        // med Dynamic Type.
                        //
                        // MapKits egen titel ligger uden for vores indhold og
                        // dermed uden for hit-testen. Så kan titlen være der,
                        // uden at de to krav strides om den samme etiket.
                        .annotationTitles(.automatic)
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

    /// Markørens halve udstrækning, som den tegnes — plus lidt slør.
    ///
    /// ## Hvorfor markøren ikke har en etiket
    ///
    /// Den havde det. Titlen gjorde elementet op mod 167 pt bredt, mens
    /// hit-testen ledte inden for 66 pt af ankeret — et tryk på etikettens kant
    /// ramte ingenting. Låste man så bredden fast, kunne teksten ikke længere
    /// vokse med Dynamic Type, og tilgængelighedsauditten afviste den med rette.
    ///
    /// De to krav kan ikke opfyldes samtidig af den samme etiket. Titlen står i
    /// stedet i kortet, der åbnes ved tryk, og VoiceOver læser den fulde
    /// beskrivelse direkte fra markøren. Tilbage er en cirkel, hvis udstrækning
    /// er kendt — og så kan tegning og hit-test ikke være uenige.
    private static let pinHalfWidth: CGFloat = 34
    private static let pinHalfHeight: CGFloat = 34

    /// Finder den markør, spilleren ramte — hvis nogen.
    ///
    /// Hit-testen sker i **skærmpunkter** mod et rektangel, der svarer til det,
    /// der er tegnet — ikke mod en cirkel. En markør er bred og lav, ikke rund.
    /// Rammer flere, vinder den nærmeste.
    private func handleTap(at screenPoint: CGPoint, proxy: MapProxy) {
        let hit = mappableMissions
            .compactMap { mission -> (Mission, CGFloat)? in
                guard let point = displayPoint(for: mission),
                      let pinPoint = proxy.convert(point.coordinate, to: .named(Self.mapSpace))
                else { return nil }

                let dx = pinPoint.x - screenPoint.x
                let dy = pinPoint.y - screenPoint.y
                guard abs(dx) <= Self.pinHalfWidth, abs(dy) <= Self.pinHalfHeight else { return nil }

                // Lodret vægtes tungere: markører, der deler adresse, spredes
                // netop lodret, og dér skal de kunne skelnes.
                return (mission, sqrt(dx * dx + (dy * 2) * (dy * 2)))
            }
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

        return ZStack {
            // Uløst er brandets petrol; løst er neutralt grå.
            //
            // To grønne nuancer var for tæt på hinanden. Forskellen ligger nu i
            // mætning og lyshed, ikke kun i kulør — det virker også for den,
            // der ikke skelner farverne, og en løst opgave skal i forvejen ikke
            // konkurrere om opmærksomheden med dem, der mangler.
            Circle()
                .fill(solved ? BHColor.inkMuted : BHColor.accent)
                .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                .shadow(radius: 2, y: 1)
            Image(systemName: solved ? "checkmark" : "questionmark")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.onAccent)
        }
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
        // `.ready` udelukker allerede en spærret opgave, så der spørges ikke
        // særskilt til `isCompleted`. I Debug betyder det, at en løst opgave
        // melder sig igen, når man kommer tilbage til stedet — hvilket er hele
        // pointen med at kunne køre det samme gennemløb flere gange.
        let arrived = mappableMissions.first { engine.startability(for: $0) == .ready }

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
            guard await engine.startSession(for: mission) else { return }
            router.push(.approach(missionId: mission.id))
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

    /// Hvor markøren **tegnes**.
    ///
    /// Flere opgaver kan dele samme adresse — Frydenlund 98 har allerede to —
    /// og så lander de oven på hinanden, hvor kun den øverste kan trykkes.
    /// Deler flere opgaver koordinat, spredes de derfor på en lille cirkel
    /// omkring det.
    ///
    /// Hit-testen bruger **samme** funktion, så det, fingeren rammer, er det,
    /// øjet ser. Bruges der to forskellige punkter, opstår præcis den slags
    /// fejl, der er umulig at få øje på i koden.
    private func displayPoint(for mission: Mission) -> GeoPoint? {
        guard let anchor = engine.vantagePoint(for: mission) else { return nil }

        let sharing = mappableMissions.filter { other in
            guard let point = engine.vantagePoint(for: other) else { return false }
            return Self.isSameSpot(point, anchor)
        }
        guard sharing.count > 1,
              let index = sharing.firstIndex(where: { $0.id == mission.id })
        else { return anchor }

        let angle = 2 * Double.pi * Double(index) / Double(sharing.count)
        let metresNorth = Self.fanRadiusMetres * cos(angle)
        let metresEast = Self.fanRadiusMetres * sin(angle)

        // 1 breddegrad ≈ 111 320 m. Længdegrader smalner mod polerne.
        let latitude = anchor.latitude + metresNorth / 111_320
        let longitude = anchor.longitude
            + metresEast / (111_320 * cos(anchor.latitude * .pi / 180))
        return GeoPoint(latitude: latitude, longitude: longitude)
    }

    /// Hvor langt markører spredes, når de deler adresse.
    ///
    /// 25 m blev prøvet og var for lidt: ved almindeligt zoom svarer det til
    /// under 30 punkter, og to markører på 44 punkter overlapper hinanden. Både
    /// en finger og en test rammer da den forkerte.
    ///
    /// 55 m adskiller dem tydeligt. Markøren peger derved et stykke fra det
    /// nøjagtige standpunkt, men det er kun et visuelt spredningspunkt —
    /// positionsgaten måler stadig mod lokationens rigtige koordinat.
    private static let fanRadiusMetres = 55.0

    /// To standpunkter regnes som samme sted inden for cirka en meter.
    private static func isSameSpot(_ first: GeoPoint, _ second: GeoPoint) -> Bool {
        abs(first.latitude - second.latitude) < 0.00001
            && abs(first.longitude - second.longitude) < 0.00001
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
    /// Hvad spilleren **må** — ikke hvad der er sandt om afstanden.
    private var canStart: Bool { engine.canStart(mission) }

    var body: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            // Ingen luk-knap i hjørnet. Den optog hele højre side af overlayet
            // uden at bruge den til noget, og et kryds på 44×44 er i forvejen
            // det sværeste mål på skærmen at ramme med en tommelfinger.
            //
            // Der lukkes i stedet med knappen nedenfor eller ved at trykke ved
            // siden af kortet — to store mål frem for ét lille.
            MissionSummary(mission: mission)

            // Princip I: stedet er spillet. Knappen er lukket hjemmefra.
            //
            // På en løst opgave vises den slet ikke. En grå knap, der aldrig
            // kan trykkes, er et element mere at undre sig over — og "Løst"
            // står allerede på kortet.
            if !startability.isPermanent {
                Button("Start opgave", action: onOpen)
                    .buttonStyle(.bhPrimary)
                    .disabled(!canStart)
                    .opacity(canStart ? 1 : 0.45)
                    .accessibilityIdentifier("preview.open")
                    .accessibilityHint(canStart ? "" : startabilityNote ?? "")
            }

            if let note = startabilityNote {
                Text(note)
                    .font(BHFont.caption)
                    .foregroundStyle(BHColor.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("preview.note")
            }

            dismissButton
        }
        .padding(BHSpacing.regular)
        .background(
            RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous)
                .fill(BHColor.canvas)
                .shadow(color: .black.opacity(0.18), radius: 16, y: -2)
        )
        // Gør hele kortet til ét trykmål, så et tryk på en tom flade **i**
        // kortet ikke falder igennem til kortets egen tryklytter og lukker det
        // overlay, spilleren lige har åbnet.
        .contentShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
        .onTapGesture {}
    }

    /// Vejen tilbage. Ordene siger, hvor man havner — ikke hvad knappen gør
    /// ved vinduet.
    private var dismissButton: some View {
        Button("Tilbage til kortet", action: onClose)
            .buttonStyle(.bhSecondary)
            .accessibilityIdentifier("preview.dismiss")
    }

    /// Den lille tekst under knappen. `nil`, når opgaven kan startes.
    private var startabilityNote: String? {
        let place = engine.location(for: mission)?.name ?? "stedet"

        // Må opgaven startes, er der intet at forklare — heller ikke når
        // afstanden i sig selv ville have lukket knappen.
        if canStart, !startability.isPermanent { return nil }

        switch startability {
        case .ready, .notGated:
            return nil
        case .alreadySolved:
            return "Gåden er løst. Den kan kun løses én gang."
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Ved de store tilgængelighedsstørrelser lægges billedet over teksten.
    ///
    /// Side om side er det ønskede layout og bruger overlayets fulde bredde.
    /// Men et billede med fast bredde efterlader stadig lige så lidt til
    /// titlen, og ved AX-størrelserne brækker "Veras hemmelige snack" så i ét
    /// ord pr. linje. Auditten har fanget netop dét på dette kort før.
    ///
    /// Derfor: side om side, indtil teksten bliver så stor, at det ikke længere
    /// er til at læse — og så under hinanden.
    private var stacksVertically: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        BHCard {
            if stacksVertically {
                VStack(alignment: .leading, spacing: BHSpacing.snug) {
                    thumbnail
                    details
                }
            } else {
                HStack(alignment: .top, spacing: BHSpacing.regular) {
                    thumbnail
                    details
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Self.accessibilityLabel(for: mission, engine: engine))
        .accessibilityIdentifier("preview.summary")
    }

    @ViewBuilder
    private var thumbnail: some View {
        // `resolvedThumbnailMediaId` og ikke `placeMediaId`.
        //
        // Miniaturen blev skrevet, før `thumbnailMediaId` fandtes, og læste
        // derfor stedbilledet. To opgaver har intet stedbillede — Mads
        // P-opgaven og Broen — og stod som tomme kort på kortet, selvom begge
        // havde en miniature valgt. Faldbagsvejen, feltet blev bygget med, blev
        // aldrig taget i brug.
        if let thumbnailMediaId = mission.resolvedThumbnailMediaId {
            MissionThumbnail(mediaId: thumbnailMediaId)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
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
