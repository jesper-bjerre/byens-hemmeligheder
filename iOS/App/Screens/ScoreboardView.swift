import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Spillerens point og en rangliste.
///
/// ## Halvdelen er ægte, halvdelen er en attrap — og det skal kunne ses
///
/// Spillerens egne point er **rigtige**. De udledes af hændelsesloggen på
/// samme måde som på belønningsskærmen, og de holder på tværs af genstart.
///
/// Ranglisten er **opdigtet**. Der findes ingen server, ingen konti og ingen
/// andre spillere — FR-050 holdt bevidst highscore ude af feature 001. Den er
/// her for at vise testerne, hvad version 1 skal kunne.
///
/// Derfor står der "Eksempel" på ranglisten, og navnene er tydeligt fiktive.
/// Forfatningens princip III forbyder at præsentere noget opdigtet som ægte, og
/// en tester, der tror, hen er nummer fire i Vejle, har fået en forkert idé om
/// både spillet og sin egen indsats.
struct ScoreboardView: View {
    @Environment(MissionEngine.self) private var engine

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                totalCard
                solvedMissions
                leaderboard
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

    // MARK: - Attrappen

    /// Opdigtede spillere. Navnene er hverken rigtige personer eller testere.
    private static let example: [(name: String, points: Int)] = [
        ("Detektiv Lupin", 512),
        ("Familien Nord", 448),
        ("Kaninen Vera", 390),
        ("Havnens Skygge", 275),
    ]

    private var leaderboard: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            HStack(spacing: BHSpacing.tight) {
                Text("Bedste i Vejle")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                BHChip("Eksempel", systemImage: "wrench.and.screwdriver.fill", tint: BHColor.caution)
            }

            // Sagt med ord og ikke kun med et mærkat. Et mærkat kan overses;
            // en sætning kan ikke misforstås.
            Text("Ranglisten er opdigtet og viser, hvordan den kommer til at se ud. "
                 + "Der er endnu ingen server og ingen andre spillere.")
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(Array(Self.example.enumerated()), id: \.offset) { index, entry in
                BHCard {
                    HStack(spacing: BHSpacing.regular) {
                        Text("\(index + 1)")
                            .font(BHFont.heading)
                            .foregroundStyle(BHColor.inkMuted)
                            .monospacedDigit()
                            .frame(minWidth: 28, alignment: .leading)
                        Text(entry.name)
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: BHSpacing.snug)
                        Text("\(entry.points)")
                            .font(BHFont.heading)
                            .foregroundStyle(BHColor.inkMuted)
                            .monospacedDigit()
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Eksempel, nummer \(index + 1): \(entry.name), \(entry.points) point")
            }
        }
        .accessibilityIdentifier("scoreboard.leaderboard")
    }
}
