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

    init() {
        let repository = ContentRepository(source: BundledContentPackSource(bundle: .main))
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

    /// I simulatoren styres positionen af udviklerpanelet; på en telefon kommer
    /// den fra CoreLocation.
    ///
    /// Skellet går ved simulatoren og ikke ved Debug, netop så en Debug-bygning
    /// på en rigtig telefon stadig tester den rigtige GPS-vej. Koden findes
    /// under ingen omstændigheder i en udgivelse (FR-051).
    @MainActor
    private static func makeLocationProvider() -> any LocationProviding {
        #if BH_DEV_TOOLS
        if let scripted = ScriptedLocationProvider.fromLaunchArguments() {
            return scripted
        }
        #if targetEnvironment(simulator)
        // Start ved Frydenlund 98, hvor testopgaverne ligger, så et gennemløb
        // kan afprøves med det samme uden at gå først. Opgaven **startes** ikke
        // af sig selv — kun opgavekortet popper op, og trykket er stadig
        // spillerens eget.
        //
        // Værdien spejler `loc.vejle-oest.frydenlund98` i indholdspakken. Den er
        // dev-kode og læses derfor ikke fra pakken; flyttes standpunktet, må den
        // rettes her.
        return ScriptedLocationProvider(
            start: GeoPoint(latitude: 55.734897, longitude: 9.620270)
        )
        #endif
        #endif
        return CoreLocationProvider()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(engine)
                .environment(router)
                .environment(ambience)
                .tint(BHColor.accent)
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
            ExploreMapView()
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
        .task {
            ambience.start()
            await engine.load()
            // Genoptag på samme trin efter fuld terminering (FR-036).
            router.restore(validatingAgainst: Set(engine.playableMissions.map(\.id)))
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
        if let mission = engine.pack?.mission(id: route.missionId) {
            switch route {
            case .missionDetail:
                MissionSheet(mission: mission)
            case .approach:
                ApproachView(mission: mission)
            case .step(_, let stepId):
                stepDestination(mission: mission, stepId: stepId)
            case .reward:
                RewardView(mission: mission)
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
