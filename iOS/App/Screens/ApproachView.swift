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

    @State private var visualDwellCredit = 0.0
    @State private var visualDwellUpdatedAt = Date()
    @State private var visualDwellIsActive = false

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
        .task {
            syncVisualDwell(with: engine.presence)
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                guard !Task.isCancelled else { break }
                advanceVisualDwell()
            }
        }
        .onChange(of: engine.presence) { _, state in
            syncVisualDwell(with: state)
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
                        Text(statusTitle)
                            .font(BHFont.heading)
                            .foregroundStyle(BHColor.ink)
                        Text(distanceText)
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                    }
                }
                if let statusMessage {
                    Text(statusMessage)
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                locationProgress
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusTitle). \(distanceText). \(statusMessage ?? "")")
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

    /// Synlig aktivitet fra første satellitsøgning og en jævn nedtælling, når
    /// spilleren er fremme.
    ///
    /// GPS-gaten kan stå på samme kredit i nogle sekunder, mens den samler nok
    /// målinger til en konsensus. Den kosmetiske kredit bevæger sig imens, men
    /// stopper ved ét sekund; den kan aldrig åbne opgaven før den rigtige gate.
    @ViewBuilder
    private var locationProgress: some View {
        switch engine.presence {
        case .idle, .acquiring:
            VStack(alignment: .leading, spacing: BHSpacing.hairline) {
                Label("Kalder på satellitterne…", systemImage: "satellite")
                    .font(BHFont.caption)
                    .foregroundStyle(BHColor.inkMuted)
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(BHColor.accent)
                    .accessibilityLabel("Leder efter satellitter")
            }

        case .dwelling(let credit, let required) where required > 0:
            let displayedCredit = min(required, max(credit, visualDwellCredit))
            VStack(alignment: .leading, spacing: BHSpacing.hairline) {
                HStack {
                    Label("Satellitkontakt", systemImage: "satellite.fill")
                    Spacer()
                    Text("\(visualDwellRemaining) sek.")
                        .monospacedDigit()
                }
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)

                ProgressView(value: displayedCredit, total: required)
                    .progressViewStyle(.linear)
                    .tint(BHColor.accent)
                    .animation(.linear(duration: 0.25), value: displayedCredit)
                    .accessibilityLabel("Bekræfter position")
                    .accessibilityValue("\(visualDwellRemaining) sekunder tilbage")
            }
            .accessibilityIdentifier("approach.countdown")

        default:
            EmptyView()
        }
    }

    private var statusTitle: String {
        switch engine.presence {
        case .idle, .acquiring: "Satellitterne leger gemmeleg"
        case .dwelling: "Vi har fået øje på jer"
        default: problem?.title ?? "Du er fremme"
        }
    }

    private var statusMessage: String? {
        switch engine.presence {
        case .idle, .acquiring:
            "Hold telefonen i ro med lidt fri himmel. Vi kalder på satellitterne."
        case .dwelling:
            "Bliv stående — vi dobbelttjekker positionen, så en forbipasserende ikke løber med gåden."
        default:
            problem?.message
        }
    }

    private var visualDwellRemaining: Int {
        guard case .dwelling(let credit, let required) = engine.presence else { return 0 }
        return max(1, Int((required - max(credit, visualDwellCredit)).rounded(.up)))
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
        case .dwelling:
            "Bliv stående — \(max(1, visualDwellRemaining)) sekunder tilbage"
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

    private func syncVisualDwell(with state: PresenceState) {
        guard case .dwelling(let credit, _) = state else {
            visualDwellCredit = 0
            visualDwellIsActive = false
            return
        }
        if !visualDwellIsActive {
            visualDwellCredit = credit
            visualDwellIsActive = true
        } else {
            visualDwellCredit = max(visualDwellCredit, credit)
        }
        visualDwellUpdatedAt = Date()
    }

    private func advanceVisualDwell() {
        guard case .dwelling(let credit, let required) = engine.presence else { return }
        let now = Date()
        let elapsed = max(0, now.timeIntervalSince(visualDwellUpdatedAt))
        visualDwellUpdatedAt = now
        // Det sidste sekund tilhører den faktiske GPS-gate. UI'et lover aldrig,
        // at opgaven er åben, før tilstedeværelsen er verificeret.
        let ceiling = max(0, required - 1)
        visualDwellCredit = min(ceiling, max(credit, visualDwellCredit + elapsed))
    }
}
