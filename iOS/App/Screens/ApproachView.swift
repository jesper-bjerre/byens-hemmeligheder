import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Vejen frem til stedet.
///
/// Retningspilen regnes ud af spillerens position og opgavens koordinat, ikke
/// af kompasset. `CLHeading` kræver kalibrering og er upålideligt nær stål og
/// store konstruktioner — og begge lokationer i feature 001 er netop dét
/// (R-007). Pilen er derfor et blødt hint, aldrig en gate.
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

                dwellCountdown
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

    /// Nedtællingen, mens gaten venter på, at spilleren står stille.
    ///
    /// Tallene fandtes hele tiden i ``PresenceState/dwelling(creditSeconds:requiredSeconds:)``
    /// — der stod bare "Bliv stående et øjeblik". Et øjeblik er ikke en enhed,
    /// og uden at kunne se, at der sker noget, ligner ventetiden en app, der har
    /// hængt sig.
    @ViewBuilder
    private var dwellCountdown: some View {
        if case .dwelling(let credit, let required) = engine.presence, required > 0 {
            let remaining = max(0, Int((required - credit).rounded(.up)))
            ZStack {
                Circle()
                    .stroke(BHColor.separator, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: min(1, credit / required))
                    .stroke(BHColor.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: credit)
                Text("\(remaining)")
                    .font(BHFont.display)
                    .foregroundStyle(BHColor.ink)
                    .monospacedDigit()
            }
            .frame(width: 96, height: 96)
            .frame(maxWidth: .infinity)
            // Ringen er dekoration; tallet står allerede i statusteksten.
            .accessibilityHidden(true)
            .accessibilityIdentifier("approach.countdown")
        }
    }

    private var bearing: Double? {
        switch engine.presence {
        case .tooFar(_, let bearing), .approaching(_, let bearing): bearing
        // Uden en position er der ingen retning at pege i.
        default: nil
        }
    }

    private var distanceText: String {
        switch engine.presence {
        case .tooFar(let distance, _), .approaching(let distance, _):
            "Cirka \(max(1, Int(distance.rounded()))) meter tilbage"
        case .dwelling(let credit, let required):
            "Bliv stående — \(max(0, Int((required - credit).rounded(.up)))) sekunder tilbage"
        case .verified:
            "Du står på stedet"
        default:
            "Afstanden er ikke kendt endnu"
        }
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
