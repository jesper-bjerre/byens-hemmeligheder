import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Belønningsskærmen.
///
/// ## Uden inventory
///
/// Belønningen er beskeden, pointene og den historiske forklaring — der
/// overrækkes ingen genstand (FR-050). Opgavedokumenternes afsluttende linjer om
/// Det femte signal og Fjordseglet er omskrevet til ren fortælling i indholdet,
/// og genstandene er bevaret i dokumenterne til senere brug.
///
/// ## Pointopdelingen er ledgeren
///
/// Der findes ingen parallel forklaringsmodel. Opdelingen nedenfor *er*
/// hændelsesloggen foldet og filtreret på missionen (FR-020) — derfor kan et
/// tal på denne skærm aldrig komme til at modsige det, spilleren faktisk gjorde.
struct RewardView: View {
    let mission: Mission

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    private var transactions: [ScoreTransaction] { engine.transactions(for: mission) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                headline
                message
                scoreBreakdown
                historyFact
                presenceNote
                doneButton
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle("Løst")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Label(mission.completion.headline, systemImage: "checkmark.seal.fill")
                .font(BHFont.display)
                .foregroundStyle(BHColor.success)
                .labelStyle(.titleAndIcon)
            Text(mission.completion.subheadline)
                .font(BHFont.heading)
                .foregroundStyle(BHColor.inkMuted)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    private var message: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Text(mission.completion.messageLabel)
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.accent)
                Text(mission.completion.message)
                    .font(BHFont.narrative)
                    .foregroundStyle(BHColor.ink)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var scoreBreakdown: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                HStack {
                    Text("Point")
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                    Spacer()
                    Text("\(engine.points(for: mission))")
                        .font(BHFont.code)
                        .foregroundStyle(BHColor.success)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Du fik \(engine.points(for: mission)) point")
                .accessibilityIdentifier("reward.points")

                Divider().overlay(BHColor.separator)

                ForEach(transactions) { transaction in
                    HStack(alignment: .firstTextBaseline) {
                        Text(transaction.explanation)
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: BHSpacing.tight)
                        Text(signed(transaction.points))
                            .font(BHFont.body)
                            .foregroundStyle(transaction.points < 0 ? BHColor.caution : BHColor.ink)
                            .monospacedDigit()
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(transaction.explanation): \(spokenPoints(transaction.points))")
                }
            }
        }
    }

    private var historyFact: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Label("Sådan hænger det sammen", systemImage: "book.closed.fill")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                    .labelStyle(.titleAndIcon)
                Text(mission.completion.historyFact)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// Neutralt badge, aldrig en anklage. Simuleret position giver point som
    /// alt andet — flaget registreres kun (FR-028).
    @ViewBuilder
    private var presenceNote: some View {
        if let evidence = engine.session?.presenceEvidence,
           let note = evidence.method.playerFacingNote {
            Label(note, systemImage: "info.circle")
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
                .labelStyle(.titleAndIcon)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var doneButton: some View {
        Button("Tilbage til kortet") {
            router.popToRoot()
        }
        .buttonStyle(.bhPrimary)
        .accessibilityIdentifier("reward.done")
    }

    private func signed(_ points: Int) -> String {
        points < 0 ? "\(points)" : "+\(points)"
    }

    private func spokenPoints(_ points: Int) -> String {
        points < 0 ? "minus \(abs(points)) point" : "plus \(points) point"
    }
}

extension Tolerant where Known == PresenceMethod {
    /// Hvad spilleren får at vide om, hvordan opgaven blev åbnet.
    var playerFacingNote: String? {
        switch known {
        case .gps, nil:
            nil
        case .gpsLowConfidence:
            "Positionen var usikker, da opgaven blev åbnet."
        case .softOverride:
            "Du bekræftede selv, at du stod på stedet."
        case .demo:
            "Stedet er endnu ikke opmålt, så opgaven blev åbnet uden positionskontrol."
        case .simulated:
            "Positionen var simuleret."
        }
    }
}
