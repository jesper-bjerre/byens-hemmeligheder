import BHContracts
import BHDesignSystem
import SwiftUI

/// Hints med fradraget skrevet på knappen.
///
/// Spilleren får **prisen at vide før købet** (FR-018): den står på selve
/// knappen. Der var tidligere en bekræftelsesdialog oven i, men den gentog blot
/// tallet fra knappen, spilleren netop havde læst — to tryk for én beslutning.
///
/// Hintet kan derefter genåbnes gratis så mange gange, det skal være (FR-019).
/// Fradragene kommer fra indholdet, ikke fra koden (FR-021).
struct HintSheet: View {
    let mission: Mission
    let step: Step

    @Environment(MissionEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BHSpacing.snug) {
                    Text("Hints åbnes i rækkefølge. Hvert koster point, men du kan altid læse et igen uden at betale mere.")
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(engine.missionHints(in: mission)) { hint in
                        hintCard(hint)
                    }

                    Button("Luk") { dismiss() }
                        .buttonStyle(.bhSecondary)
                        .padding(.top, BHSpacing.tight)
                }
                .padding(BHSpacing.regular)
            }
            .background(BHColor.canvas)
            .navigationTitle("Hints")
            .navigationBarTitleDisplayMode(.inline)
            // Bevidst ingen "Luk" i værktøjslinjen. SwiftUI giver
            // værktøjslinjeknapper en fast fontstørrelse, som ikke følger
            // Dynamic Type, og tilgængelighedsauditten afviser den med rette
            // (FR-037). Knappen ligger i stedet nederst i indholdet, hvor
            // fonten er vores egen — og hvor den er lettere at nå med tommelen.
        }
        // Kun fuld højde. Ved `.medium` komprimeres indholdet, og knappernes
        // etiketter klippes ved de store tilgængelighedsstørrelser —
        // tilgængelighedsauditten fanger det. Tre hintkort med brødtekst vil
        // i forvejen have hele skærmen.
        .presentationDetents([.large])
    }

    private func hintCard(_ hint: Hint) -> some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                HStack {
                    Text("Hint \(hint.order) · \(hint.title)")
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: BHSpacing.tight)
                    if engine.isRevealed(hint) {
                        Label("Åbnet", systemImage: "lock.open.fill")
                            .font(BHFont.eyebrow)
                            .foregroundStyle(BHColor.inkMuted)
                            .labelStyle(.titleAndIcon)
                    } else if !engine.isUnlocked(hint, in: mission) {
                        // Status bæres af både tekst og symbol (FR-039).
                        Label("Låst", systemImage: "lock.fill")
                            .font(BHFont.eyebrow)
                            .foregroundStyle(BHColor.inkMuted)
                            .labelStyle(.titleAndIcon)
                    }
                }

                if engine.isRevealed(hint) {
                    Text(hint.text)
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } else if let blocking = engine.blockingHint(for: hint, in: mission) {
                    // Låst. Stigen går hvor → hvordan → næsten løsningen, og
                    // fradragene stiger med den. Kunne spilleren springe til
                    // det sidste, ville hen betale 5 % for noget, et vink på
                    // 3 % måske havde klaret.
                    Text("Åbn hint \(blocking.order) først")
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                        .frame(maxWidth: .infinity, minHeight: BHMetrics.minimumTapTarget, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("hint.locked.\(hint.order)")
                } else {
                    // Fradraget står på selve knappen — ikke i en note nedenunder.
                    Button("Vis hint — \(engine.penalty(for: hint, in: mission)) point") {
                        Task { await engine.reveal(hint, in: mission) }
                    }
                    .buttonStyle(.bhSecondary)
                    .accessibilityHint("Åbner hint \(hint.order) og trækker \(engine.penalty(for: hint, in: mission)) point fra")
                    .accessibilityIdentifier("hint.reveal.\(hint.order)")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
