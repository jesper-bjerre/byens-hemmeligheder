import BHContentKit
import BHContracts
import BHDesignSystem
import BHLocationKit
import BHPersistence
import SwiftUI

@main
struct ByensHemmelighederApp: App {
    @State private var engine: MissionEngine
    @State private var router = Router()

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
        return ScriptedLocationProvider()
        #endif
        #endif
        return CoreLocationProvider()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(engine)
                .environment(router)
                .tint(BHColor.accent)
        }
    }
}

/// Navigationsstakken og de ark, der kan lægge sig oven på den.
struct RootView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            ExploreMapView()
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
        .task {
            await engine.load()
            // Genoptag på samme trin efter fuld terminering (FR-036).
            router.restore(validatingAgainst: Set(engine.playableMissions.map(\.id)))
            await resumeSessionIfNeeded()
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetContent(for: sheet)
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
            case .singleChoice, .numericCode:
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
