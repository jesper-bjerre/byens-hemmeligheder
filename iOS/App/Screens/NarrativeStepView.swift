import BHContracts
import BHDesignSystem
import SwiftUI

/// Den fortællende intro.
///
/// Fiktionsmarkeringen står **over** teksten og er en del af sideindholdet, ikke
/// en fodnote. En fiktiv besked må aldrig kunne forveksles med et ægte
/// historisk dokument (FR-007, forfatningens princip III).
struct NarrativeStepView: View {
    let mission: Mission
    let step: NarrativeStep

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                fictionLabel

                Text(step.title)
                    .font(BHFont.display)
                    .foregroundStyle(BHColor.ink)
                    .fixedSize(horizontal: false, vertical: true)

                // Stemningsbilledet hører til her og kun her. Det er
                // AI-genereret og bærer aldrig noget, opgaven skal løses med;
                // stedbilledet, spilleren skal orientere sig efter, vises på
                // selve spørgsmålet.
                if let moodMediaId = mission.resolvedMoodMediaId {
                    MissionHeroImage(mediaId: moodMediaId)
                }

                Text(step.body)
                    .font(BHFont.narrative)
                    .foregroundStyle(BHColor.ink)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Button(step.continueLabel) {
                    advance()
                }
                .buttonStyle(.bhPrimary)
                .accessibilityIdentifier("narrative.continue")
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle(mission.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await engine.viewStep(.narrative(step), in: mission)
        }
    }

    private var fictionLabel: some View {
        Label(mission.fictionLabel, systemImage: "theatermasks.fill")
            .font(BHFont.caption)
            .foregroundStyle(BHColor.fiction)
            .labelStyle(.titleAndIcon)
            .padding(BHSpacing.snug)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .fill(BHColor.fiction.opacity(0.12))
            )
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Fiktion. \(mission.fictionLabel)")
    }

    private func advance() {
        guard let next = engine.nextStep(after: .narrative(step), in: mission) else {
            router.replaceTop(with: .reward(missionId: mission.id))
            return
        }
        router.replaceTop(with: .step(missionId: mission.id, stepId: next.id))
    }
}
