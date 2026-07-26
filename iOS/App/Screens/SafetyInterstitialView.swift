import BHContracts
import BHDesignSystem
import SwiftUI

/// Vises før sessionens første mission (FR-008).
///
/// Ikke en formalitet. Begge lokationer i feature 001 ligger ved åbent vand med
/// cykeltrafik tæt på, og målgruppen er 10–15-årige med en telefon i hånden.
/// Skærmen skal læses, ikke klikkes væk — derfor står lokationens egne
/// sikkerhedsnoter her, ikke en generisk ansvarsfraskrivelse.
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
