import BHContracts
import BHDesignSystem
import SwiftUI

/// **Uden for flowet.** Vises ikke i dag.
///
/// Skærmen lå tidligere før sessionens første mission (FR-008). Den er taget
/// ud efter redaktionel beslutning: en advarsel foran hver tur passer ikke til
/// dansk friluftsnorm, og ansvaret for ikke at gå i vandet er spillerens eget.
///
/// Filen står tilbage som grundlag for den generelle sikkerhedsside, appen
/// senere får et menupunkt til — og for den godkendelse, spilleren eventuelt
/// skal give ved første start. `MissionEngine.hasSeenSafetyInterstitial` er
/// bevaret til netop det.
///
/// Bemærk, at forfatningens princip IV er upåvirket: den kræver
/// sikkerhedsreview ved feltbesøg og at opgaverne ikke *kræver* farlig færdsel
/// — ikke at advarslen står i brugerfladen. Sikkerhedsdata bliver derfor i
/// indholdspakken.
struct SafetyInterstitialView: View {
    let mission: Mission

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss

    private var location: Location? { engine.location(for: mission) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BHSpacing.loose) {
                    Image(systemName: "figure.and.child.holdinghands")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundStyle(BHColor.caution)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: BHSpacing.snug) {
                        Text("Inden I går")
                            .font(BHFont.title)
                            .foregroundStyle(BHColor.ink)
                        Text("Opgaven løses udendørs i et havneområde. Den vigtigste regel er enkel: se op fra telefonen, når I bevæger jer.")
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)

                    rules

                    if let location {
                        BHCard {
                            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                                Text("Om \(location.name)")
                                    .font(BHFont.heading)
                                    .foregroundStyle(BHColor.ink)
                                Text(location.safety.notes)
                                    .font(BHFont.body)
                                    .foregroundStyle(BHColor.inkMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }

                    Button("Det er forstået") {
                        engine.markSafetyInterstitialSeen()
                        dismiss()
                        router.push(.approach(missionId: mission.id))
                    }
                    .buttonStyle(.bhPrimary)
                    .accessibilityIdentifier("safety.continue")
                }
                .padding(BHSpacing.regular)
            }
            .background(BHColor.canvas)
            .navigationTitle("Sikkerhed")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled()
    }

    private var rules: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            rule("Hold afstand til vandkanten.", "water.waves")
            rule("Stå aldrig på cykelstien eller kørebanen.", "bicycle")
            rule("Kig op, når I krydser eller flytter jer.", "eye")
            rule("Gå ikke ind på privat område.", "hand.raised")
            rule("I skal aldrig klatre eller læne jer over afspærringer.", "figure.stand")
        }
    }

    private func rule(_ text: String, _ symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(BHFont.body)
            .foregroundStyle(BHColor.ink)
            .labelStyle(.titleAndIcon)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
