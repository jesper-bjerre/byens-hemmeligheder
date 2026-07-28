import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Vejen frem til standpunktet.
///
/// Retningspilen kommer fra indholdets `bearingDegrees`, ikke fra kompasset.
/// `CLHeading` kræver kalibrering og er upålideligt nær stål og store
/// konstruktioner — og begge lokationer i feature 001 er netop dét (R-007).
/// Pilen er derfor et blødt hint, aldrig en gate.
struct ApproachView: View {
    let mission: Mission

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router
    @Environment(\.openURL) private var openURL

    private var location: Location? { engine.location(for: mission) }
    private var problem: PresenceProblemContent? { PresenceProblemContent.forState(engine.presence) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                statusCard
                if let vantage = location?.vantagePoint {
                    vantageCard(vantage)
                }
                actions
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle("Find stedet")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            engine.startLocationUpdates()
        }
        // Bevidst ingen `onDisappear`-stop. Positionen skal blive ved med at
        // komme: kortet bruger den, og strømmen kan ikke åbnes igen, når den
        // først er lukket.
        .onChange(of: engine.presence.isVerified) { _, verified in
            guard verified, let first = mission.orderedSteps.first else { return }
            router.replaceTop(with: .step(missionId: mission.id, stepId: first.id))
        }
    }

    // MARK: - Status

    private var statusCard: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                HStack(spacing: BHSpacing.regular) {
                    directionArrow
                    VStack(alignment: .leading, spacing: BHSpacing.hairline) {
                        Text(problem?.title ?? "Du er fremme")
                            .font(BHFont.heading)
                            .foregroundStyle(BHColor.ink)
                        Text(distanceText)
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                    }
                }
                if let message = problem?.message {
                    Text(message)
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(problem?.title ?? "Du er fremme"). \(distanceText). \(problem?.message ?? "")")
    }

    private var directionArrow: some View {
        Image(systemName: "location.north.fill")
            .font(.title)
            .imageScale(.large)
            .foregroundStyle(BHColor.accent)
            .rotationEffect(.degrees(bearing ?? 0))
            .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
            // Retningen står allerede i tekstform i standpunktsinstruktionen.
            // En roteret pil siger ingenting til VoiceOver.
            .accessibilityHidden(true)
    }

    private var bearing: Double? {
        switch engine.presence {
        case .tooFar(_, let bearing), .approaching(_, let bearing): bearing
        default: location?.vantagePoint?.bearingDegrees
        }
    }

    private var distanceText: String {
        switch engine.presence {
        case .tooFar(let distance, _), .approaching(let distance, _):
            "Cirka \(max(1, Int(distance.rounded()))) meter tilbage"
        case .dwelling:
            "Bliv stående et øjeblik"
        case .verified:
            "Du står på stedet"
        default:
            "Afstanden er ikke kendt endnu"
        }
    }

    // MARK: - Standpunkt og sikkerhed

    private func vantageCard(_ vantage: VantagePoint) -> some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Label("Sådan står du", systemImage: "figure.stand")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                    .labelStyle(.titleAndIcon)
                Text(vantage.instruction)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// Udfører tilstandens egen handling.
    private func perform(_ action: PresenceProblemContent.Action) {
        switch action {
        case .requestAuthorization:
            engine.requestLocationAuthorization()
        case .requestFullAccuracy:
            engine.requestFullAccuracy()
        case .openSettings:
            #if os(iOS)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
            #endif
        case .confirmManually:
            Task { await engine.acceptSoftOverride() }
        case .dismiss:
            break
        }
    }

    // MARK: - Handlinger

    @ViewBuilder
    private var actions: some View {
        if engine.presence.isVerified {
            Button("Start opgaven") {
                if let first = mission.orderedSteps.first {
                    router.replaceTop(with: .step(missionId: mission.id, stepId: first.id))
                }
            }
            .buttonStyle(.bhPrimary)
            .accessibilityIdentifier("approach.start")
        } else if let problem, problem.primaryAction != .dismiss {
            // Kun når der faktisk er noget at gøre.
            //
            // Her stod før en knap, der altid hed "Hvad sker der?". Den dukkede
            // op i de sekunder, hvor positionen bare var på vej, og stillede et
            // spørgsmål frem for at tilbyde en handling. Forklaringen står i
            // forvejen i statuskortet ovenfor.
            //
            // Tilbage er den handling, tilstanden faktisk peger på — "Jeg står
            // her nu", "Giv adgang til position" — og kun når der er en.
            // Uden den ville en spiller med dårligt signal stå uden vej videre,
            // og forfatningens krav om nul blindgyder ville være brudt (SC-004).
            Button(problem.primaryAction.label) {
                perform(problem.primaryAction)
            }
            .buttonStyle(.bhSecondary)
            .accessibilityIdentifier("approach.action")
            .accessibilityHint(problem.message)
        }
    }
}
