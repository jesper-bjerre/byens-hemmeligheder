import BHContentKit
import BHContracts
import BHDesignSystem
import BHGameCore
import BHLocationKit
import BHPersistence
import SwiftUI

@main
struct ByensHemmelighederApp: App {
    @State private var engine: MissionEngine
    @State private var router = Router()
    @State private var ambience = AmbiencePlayer()
    @State private var narration = NarrationPlayer()
    @State private var authentication = PlayerAuthentication.shared
    @State private var favorites = MissionFavoritesStore()
    @State private var scores = PlayerScoresStore()

    init() {
        let repository = ContentRepository(source: ContentEndpoint.makeContentPackSource())
        let eventStoreURL = (try? EventStore.defaultFileURL())
            ?? URL.temporaryDirectory.appending(path: "events-v1.jsonl")

        LaunchArguments.resetProgressIfRequested(eventStoreURL: eventStoreURL)
        LaunchArguments.installNetworkGuardIfRequested()

        let eventStore = EventStore(fileURL: eventStoreURL)
        _engine = State(
            initialValue: MissionEngine(
                repository: repository,
                eventStore: eventStore,
                locationProvider: Self.makeLocationProvider()
            )
        )
    }

    /// Positionskilden.
    ///
    /// I Debug en ``SwitchableLocationProvider``, så en tester kan slå
    /// simuleret position til hvor som helst — også på en telefon i felten.
    /// Det var før kun muligt i simulatoren, og en quizmaster måtte derfor gå
    /// hen til opgaven for at afprøve en rettelse.
    ///
    /// I simulatoren er simulering som udgangspunkt slået **til**, fordi der
    /// ikke er nogen rigtig GPS at falde tilbage på. På en telefon er den slået
    /// **fra**: den, der står ude ved en opgave, skal se den rigtige adfærd,
    /// med mindre hen selv vælger andet.
    ///
    /// Launch-argumenter kan stadig kun styre den i Debug (FR-051) — dét er
    /// input udefra og noget helt andet end en knap i appen.
    @MainActor
    private static func makeLocationProvider() -> any LocationProviding {
        #if DEBUG
        // Launch-argumentet er kun et test-fixture. En Release-bygning må
        // kun skifte til simulering gennem det synlige, rollebegrænsede UI.
        if let scripted = ScriptedLocationProvider.fromLaunchArguments() {
            return scripted
        }
        #endif

        #if targetEnvironment(simulator)
        let simulatorDefault = true
        #else
        let simulatorDefault = false
        #endif

        return SwitchableLocationProvider(
            real: CoreLocationProvider(),
            // Startpunktet gælder kun, indtil en rigtig position er set —
            // derefter flyttes manuskriptet dertil, når simuleringen slås til.
            // Værdien spejler Frydenlund 98 i indholdspakken.
            scripted: ScriptedLocationProvider(
                start: GeoPoint(latitude: 55.734897, longitude: 9.620270)
            ),
            defaultsToSimulation: simulatorDefault
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(engine)
                .environment(router)
                .environment(ambience)
                .environment(narration)
                .environment(authentication)
                .environment(favorites)
                .environment(scores)
                .tint(BHColor.accent)
                .task {
                    await authentication.restore()
                    await favorites.refresh(using: authentication)
                }
        }
    }
}

/// Navigationsstakken og de ark, der kan lægge sig oven på den.
struct RootView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router
    @Environment(AmbiencePlayer.self) private var ambience
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            PlayerHomeShell()
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
        .task {
            ambience.start()
            await engine.load()
            // Genoptag på samme trin efter fuld terminering (FR-036).
            router.restore(
                validatingAgainst: Set(engine.playableMissions.map(\.id)),
                stepIds: Set(engine.playableMissions.flatMap { $0.orderedSteps.map(\.id) })
            )
            await resumeSessionIfNeeded()
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetContent(for: sheet)
        }
        // Appen har ingen baggrundslyd-tilstand, så lyden stopper, når den
        // lægges væk. Uden dette kom musikken aldrig igen — og det så ud, som
        // om løkken var holdt op.
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                ambience.start()
                engine.startLocationUpdates()
            case .background:
                ambience.stop()
                // Kilden hviler, mens appen er væk. Strømmen lever videre.
                engine.pauseLocationUpdates()
            default: break
            }
        }
        .overlay {
            if let failure = engine.loadFailure {
                ContentUnavailableView(
                    "Indholdet kunne ikke indlæses",
                    systemImage: "exclamationmark.triangle",
                    description: Text(failure)
                )
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        if case .map = route {
            ExploreMapView()
        } else if case .leaderboards = route {
            LeaderboardView()
        } else if case .scoreboard = route {
            ScoreboardView()
        } else if let mission = engine.pack?.mission(id: route.missionId) {
            switch route {
            case .map:
                ExploreMapView()
            case .leaderboards:
                LeaderboardView()
            case .missionDetail:
                MissionSheet(mission: mission)
            case .approach:
                ApproachView(mission: mission)
            case .step(_, let stepId):
                stepDestination(mission: mission, stepId: stepId)
            case .reward:
                RewardView(mission: mission)
            case .scoreboard:
                // Fanget ovenfor. Grenen findes kun, fordi `switch` skal
                // dække alle tilfælde.
                ScoreboardView()
            }
        } else {
            // En rute, der peger på indhold, som ikke længere findes, må ikke
            // give en tom skærm.
            ContentUnavailableView(
                "Opgaven findes ikke længere",
                systemImage: "questionmark.folder",
                description: Text("Gå tilbage til kortet og vælg en anden opgave.")
            )
        }
    }

    @ViewBuilder
    private func stepDestination(mission: Mission, stepId: String) -> some View {
        if let step = mission.orderedSteps.first(where: { $0.id == stepId }) {
            switch step {
            case .narrative(let narrative):
                NarrativeStepView(mission: mission, step: narrative)
            case .singleChoice, .numericCode, .freeText:
                ChallengeView(mission: mission, step: step)
            case .unknown:
                // Et trin fra en nyere kontrakt. Spring det over frem for at
                // vise en tom skærm (FR-003).
                UnknownStepView(mission: mission, step: step)
            }
        } else {
            ContentUnavailableView(
                "Trinnet findes ikke",
                systemImage: "questionmark.square.dashed",
                description: Text("Gå tilbage og start opgaven forfra.")
            )
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: Router.Sheet) -> some View {
        switch sheet {
        case .hints(let missionId, let stepId):
            if let mission = engine.pack?.mission(id: missionId),
               let step = mission.orderedSteps.first(where: { $0.id == stepId }) {
                HintSheet(mission: mission, step: step)
            }
        case .presenceProblem:
            if let content = PresenceProblemContent.forState(engine.presence) {
                PresenceProblemSheet(content: content)
            }
        case .safety(let missionId):
            if let mission = engine.pack?.mission(id: missionId) {
                SafetyInterstitialView(mission: mission)
            }
        case .permissionPrimer:
            PermissionPrimerView()
        }
    }

    /// Efter genstart skal motoren kende den mission, stien peger på.
    ///
    /// Om opgaven må genåbnes, afgør `startSession` alene — reglen skal have ét
    /// hjem. Afvises den, fordi opgaven er løst, peger stien på
    /// belønningsskærmen, og den klarer sig uden en session: point og opdeling
    /// hentes fra spillertilstanden, ikke fra sessionen.
    private func resumeSessionIfNeeded() async {
        guard let route = router.path.last,
              let mission = engine.pack?.mission(id: route.missionId),
              engine.session == nil
        else { return }
        await engine.startSession(for: mission)
    }
}

/// Fallback for et trin, appen ikke kender.
struct UnknownStepView: View {
    let mission: Mission
    let step: Step

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    var body: some View {
        ContentUnavailableView {
            Label("Dette trin kræver en nyere version", systemImage: "arrow.up.circle")
        } description: {
            Text("Opdatér appen for at se trinnet. Du kan fortsætte til det næste imens.")
        } actions: {
            Button("Fortsæt") {
                if let next = engine.nextStep(after: step, in: mission) {
                    router.replaceTop(with: .step(missionId: mission.id, stepId: next.id))
                } else {
                    router.replaceTop(with: .reward(missionId: mission.id))
                }
            }
            .buttonStyle(.bhPrimary)
        }
    }
}
