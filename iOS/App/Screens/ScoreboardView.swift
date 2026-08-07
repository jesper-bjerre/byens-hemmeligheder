import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Spillerens egne point og løste opgaver.
///
/// Tallene er rigtige og udledes af hændelsesloggen på samme måde som på
/// belønningsskærmen. Highscorelisterne ligger på deres egen skærm; konto og
/// logout hører kun hjemme under Profil.
struct ScoreboardView: View {
    @Environment(MissionEngine.self) private var engine

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                totalCard
                solvedMissions
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle("Dine point")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Ægte tal

    private var solved: [Mission] {
        engine.playableMissions.filter { engine.isCompleted($0) }
    }

    private var totalPoints: Int {
        solved.reduce(0) { $0 + engine.points(for: $1) }
    }

    private var totalCard: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Text("Dine point i alt")
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.inkMuted)
                Text("\(totalPoints)")
                    .font(BHFont.display)
                    .foregroundStyle(BHColor.accent)
                    .monospacedDigit()
                Text("\(solved.count) af \(engine.playableMissions.count) gåder løst")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Du har \(totalPoints) point i alt. \(solved.count) af \(engine.playableMissions.count) gåder løst."
        )
        .accessibilityIdentifier("scoreboard.total")
    }

    @ViewBuilder
    private var solvedMissions: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            Text("Løste gåder")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.ink)

            if solved.isEmpty {
                Text("Du har ikke løst nogen gåder endnu. Find en på kortet og gå derhen.")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(solved) { mission in
                    BHCard {
                        HStack(alignment: .top, spacing: BHSpacing.regular) {
                            Text(mission.shortTitle)
                                .font(BHFont.body)
                                .foregroundStyle(BHColor.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: BHSpacing.snug)
                            Text("\(engine.points(for: mission))")
                                .font(BHFont.heading)
                                .foregroundStyle(BHColor.accent)
                                .monospacedDigit()
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(mission.title): \(engine.points(for: mission)) point")
                }
            }
        }
    }

}
