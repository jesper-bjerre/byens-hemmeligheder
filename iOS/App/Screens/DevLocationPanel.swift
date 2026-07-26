#if BH_DEV_TOOLS

import BHContracts
import BHDesignSystem
import BHGameCore
import BHLocationKit
import SwiftUI

/// Udviklerpanel til at bevæge sig uden at gå udenfor.
///
/// Findes kun i Debug (FR-051). Panelet snyder **ikke** gaten: dwell skal
/// stadig optjenes, hygiejnefiltrene gælder, og "gå forbi" verificerer aldrig.
/// Det eneste, panelet gør, er at flytte de fixes, telefonen ellers ville få
/// fra satellitterne — så tilstandsmaskinen kan afprøves ærligt ved et
/// skrivebord.
struct DevLocationPanel: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    @State private var pace: ScriptedLocationProvider.Pace = .walking
    @State private var poorSignal = false

    private var provider: ScriptedLocationProvider? { engine.simulatedLocationProvider }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BHSpacing.loose) {
                    if provider == nil {
                        unavailable
                    } else {
                        status
                        pacePicker
                        signalToggle
                        missionControls
                    }
                }
                .padding(BHSpacing.regular)
            }
            .background(BHColor.canvas)
            .navigationTitle("Simuleret position")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Luk") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var unavailable: some View {
        ContentUnavailableView(
            "Kører på rigtig GPS",
            systemImage: "location.fill",
            description: Text("Simuleringen bruges kun i simulatoren. På en telefon kommer positionen fra CoreLocation.")
        )
    }

    private var status: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Text("Hvor du står nu")
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.inkMuted)

                if let point = engine.currentLocation {
                    Text(String(format: "%.5f, %.5f", point.latitude, point.longitude))
                        .font(BHFont.body.monospaced())
                        .foregroundStyle(BHColor.ink)
                } else {
                    Text("Ingen position endnu — tryk på en knap nedenfor.")
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                }

                Text(presenceDescription)
                    .font(BHFont.caption)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var presenceDescription: String {
        switch engine.presence {
        case .idle: "Ingen mission i gang."
        case .acquiring: "Leder efter position."
        case .authorizationNeeded(let problem): "Mangler tilladelse: \(problem)."
        case .tooFar(let d, _): "Langt væk — \(Int(d)) m."
        case .approaching(let d, _): "På vej — \(Int(d)) m."
        case .accuracyInsufficient(let a, let r): "Signal for usikkert — \(Int(a)) m, kræver \(Int(r)) m."
        case .dwelling(let credit, let required): "Står stille — \(Int(credit)) af \(Int(required)) sekunder."
        case .softOverrideOffered: "Tilbyder selvbekræftelse."
        case .verified(let evidence): "Verificeret via \(evidence.method.rawValue)."
        }
    }

    private var pacePicker: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Text("Tempo")
                .font(BHFont.eyebrow)
                .foregroundStyle(BHColor.inkMuted)
            Picker("Tempo", selection: $pace) {
                ForEach(ScriptedLocationProvider.Pace.allCases, id: \.self) { pace in
                    Text(pace.danishName).tag(pace)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var signalToggle: some View {
        Toggle(isOn: $poorSignal) {
            VStack(alignment: .leading) {
                Text("Dårligt signal")
                    .font(BHFont.body)
                Text("Sætter nøjagtigheden til 60 m, som ved en høj facade over vand.")
                    .font(BHFont.caption)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: poorSignal) { _, poor in
            provider?.setAccuracy(poor ? 60 : 8)
        }
    }

    private var missionControls: some View {
        VStack(alignment: .leading, spacing: BHSpacing.regular) {
            Text("Opgaver")
                .font(BHFont.heading)
                .foregroundStyle(BHColor.ink)

            ForEach(engine.playableMissions) { mission in
                if let vantage = engine.vantagePoint(for: mission) {
                    BHCard {
                        VStack(alignment: .leading, spacing: BHSpacing.snug) {
                            Text(mission.shortTitle)
                                .font(BHFont.heading)
                                .foregroundStyle(BHColor.ink)

                            if let distance = engine.distanceMetres(to: mission) {
                                Text("\(Int(distance)) m herfra")
                                    .font(BHFont.caption)
                                    .foregroundStyle(BHColor.inkMuted)
                            }

                            Button("Sæt mig 200 m væk") {
                                provider?.teleport(
                                    to: ScriptedLocationProvider.offset(vantage, northMetres: 200)
                                )
                            }
                            .buttonStyle(.bhSecondary)

                            Button("Gå hen til standpunktet") {
                                provider?.walk(to: vantage, pace: pace)
                            }
                            .buttonStyle(.bhPrimary)

                            Button("Gå forbi uden at standse") {
                                provider?.walkPast(vantage, pace: pace)
                            }
                            .buttonStyle(.bhSecondary)
                            .accessibilityHint("Afprøver SC-010: en forbipasserende må aldrig låse opgaven op")
                        }
                    }
                }
            }

            Button("Stop bevægelse") {
                provider?.stop()
            }
            .buttonStyle(.bhSecondary)

            // Dwell-tiden er 20 sekunder og komprimeres ikke — `PresenceGate`
            // ville kassere sine egne fixes som forældede, hvis uret løj. Under
            // udvikling er ventetiden sjældent det, der skal afprøves, så her er
            // en eksplicit genvej. Den bruger den samme selvbekræftelse, en
            // spiller får tilbudt ved dårligt signal (FR-027), og stemples som
            // sådan i hændelsesloggen — den forfalsker ikke en GPS-verifikation.
            Button("Spring ventetiden over") {
                Task { await engine.acceptSoftOverride() }
            }
            .buttonStyle(.bhSecondary)
            .accessibilityHint("Bekræfter tilstedeværelse uden at vente på dwell")
        }
    }
}

#endif
