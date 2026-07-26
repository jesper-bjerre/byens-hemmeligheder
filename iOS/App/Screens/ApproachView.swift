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

    private var location: Location? { engine.location(for: mission) }
    private var problem: PresenceProblemContent? { PresenceProblemContent.forState(engine.presence) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                statusCard
                if let vantage = location?.vantagePoint {
                    vantageCard(vantage)
                }
                if let location {
                    safetyReminder(location)
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
        .onDisappear {
            engine.stopLocationUpdates()
        }
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

    private func safetyReminder(_ location: Location) -> some View {
        Label(location.safety.notes, systemImage: "exclamationmark.triangle.fill")
            .font(BHFont.caption)
            .foregroundStyle(BHColor.caution)
            .labelStyle(.titleAndIcon)
            .padding(BHSpacing.snug)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .fill(BHColor.caution.opacity(0.12))
            )
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Sikkerhed. \(location.safety.notes)")
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
        } else if problem != nil {
            Button("Hvad sker der?") {
                router.presentedSheet = .presenceProblem(missionId: mission.id)
            }
            .buttonStyle(.bhSecondary)
        }
    }
}
