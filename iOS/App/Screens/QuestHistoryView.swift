import BHContracts
import BHDesignSystem
import SwiftUI

/// Spillerens udførte opgaver og lokale statistik.
struct QuestHistoryView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    private var completed: [Mission] {
        engine.playableMissions
            .filter { engine.isCompleted($0) }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    private var available: [Mission] {
        engine.playableMissions.filter { !engine.isCompleted($0) }
    }

    private var points: Int {
        completed.reduce(0) { $0 + engine.points(for: $1) }
    }

    private var completionFraction: Double {
        guard !engine.playableMissions.isEmpty else { return 0 }
        return Double(completed.count) / Double(engine.playableMissions.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            PlayerTopBar()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: BHSpacing.section) {
                    VStack(alignment: .leading, spacing: BHSpacing.tight) {
                        Text("Mine opgaver")
                            .font(BHFont.title)
                            .foregroundStyle(BHColor.ink)
                            .accessibilityAddTraits(.isHeader)
                        Text("Se, hvad du allerede har opdaget, og hvor meget af Vejle der stadig venter.")
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                    }

                    statistics
                    completedSection
                    nextQuest
                }
                .padding(BHSpacing.regular)
                .padding(.bottom, BHSpacing.section)
            }
        }
        .background(BHColor.canvas)
        .accessibilityIdentifier("quests.screen")
    }

    private var statistics: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(title: "Din fremgang")

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 96), spacing: BHSpacing.tight)],
                spacing: BHSpacing.tight
            ) {
                statistic("Løst", value: "\(completed.count)", symbol: "checkmark.seal.fill")
                statistic("Point", value: "\(points)", symbol: "diamond.fill")
                statistic("Tilbage", value: "\(available.count)", symbol: "map.fill")
            }

            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                HStack {
                    Text("\(Int((completionFraction * 100).rounded())) % af opgaverne")
                    Spacer()
                    Text("\(completed.count) af \(engine.playableMissions.count)")
                }
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)

                ProgressView(value: completionFraction)
                    .tint(BHColor.accent)
                    .accessibilityLabel("Fremgang")
                    .accessibilityValue("\(Int((completionFraction * 100).rounded())) procent")
            }
            .padding(BHSpacing.regular)
            .background(
                RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                    .fill(BHColor.surface)
            )
        }
    }

    private func statistic(_ title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Image(systemName: symbol)
                .foregroundStyle(BHColor.accent)
                .accessibilityHidden(true)
            Text(value)
                .font(BHFont.title)
                .foregroundStyle(BHColor.ink)
                .monospacedDigit()
            Text(title)
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(BHSpacing.snug)
        .background(
            RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                .fill(BHColor.surface)
        )
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var completedSection: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(
                title: "Udførte opgaver",
                subtitle: "Pointene er beregnet fra din lokale spilhistorik."
            )

            if completed.isEmpty {
                BHCard {
                    VStack(alignment: .leading, spacing: BHSpacing.tight) {
                        Label("Dit første mysterium venter", systemImage: "shoeprints.fill")
                            .font(BHFont.heading)
                            .foregroundStyle(BHColor.ink)
                        Text("Find en opgave på kortet, gå hen til stedet, og løs gåden sammen.")
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                ForEach(completed) { mission in
                    MissionDiscoveryRow(
                        mission: mission,
                        badge: "Løst · \(engine.points(for: mission)) point"
                    )
                }
            }
        }
    }

    private var nextQuest: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                Label("Klar til den næste?", systemImage: "map.fill")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                Text("Kortet viser alle de frigivne opgaver og din aktuelle position.")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                Button("Åbn kortet") {
                    router.push(.map)
                }
                .buttonStyle(.bhPrimary)
                .accessibilityIdentifier("quests.map.open")
            }
        }
    }
}
