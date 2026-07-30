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
    @Environment(AmbiencePlayer.self) private var ambience
    @Environment(\.dismiss) private var dismiss

    @State private var pace: ScriptedLocationProvider.Pace = .walking
    @State private var poorSignal = false
    @State private var confirmsReset = false
    @State private var didReset = false

    private var provider: ScriptedLocationProvider? { engine.simulatedLocationProvider }

    /// Slår simuleret position til og fra.
    ///
    /// Findes i **alle** bygninger, ikke kun i simulatoren. En quizmaster, der
    /// retter en opgave, skal kunne prøve den igennem uden først at gå derhen —
    /// og det er netop på telefonen, den slags rettelser sker.
    ///
    /// Slås den til, begynder manuskriptet dér, hvor telefonen sidst så en
    /// rigtig position. Ellers ville kortet springe til et fast punkt i Vejle,
    /// og man havde mistet sig selv.
    @ViewBuilder
    private var simulationToggle: some View {
        if let locationSwitch = engine.locationSwitch {
            BHCard {
                VStack(alignment: .leading, spacing: BHSpacing.snug) {
                    Text("Positionskilde")
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)

                    Text(locationSwitch.isSimulating
                         ? "Simuleret. Brug knapperne nedenfor til at flytte dig."
                         : "Telefonens rigtige GPS.")
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(locationSwitch.isSimulating
                           ? "Brug rigtig GPS"
                           : "Simulér min position") {
                        locationSwitch.setSimulating(!locationSwitch.isSimulating)
                    }
                    .buttonStyle(.bhSecondary)
                    .accessibilityIdentifier("admin.simulation.toggle")
                }
            }
        }
    }

    /// Vist, når der køres på rigtig GPS: bevægelsesknapperne gør intet der.
    private var realLocationNote: some View {
        BHCard {
            Text("Bevægelsesknapperne virker først, når positionen er simuleret.")
                .font(BHFont.body)
                .foregroundStyle(BHColor.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Nulstiller alt, spilleren har svaret på.
    ///
    /// Med bekræftelse, fordi handlingen er endelig: hændelsesloggen er hele
    /// sandheden om progressionen, og der findes ingen anden kopi at fortryde
    /// fra. Det er den slags, der skal koste ét ekstra tryk — modsat hint, hvor
    /// bekræftelsen blev fjernet, fordi den intet beskyttede.
    private var progressControls: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                Text("Progression")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)

                Text("Sletter løste gåder, brugte hints og point, så de samme opgaver kan prøves forfra.")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

                Text(summary)
                    .font(BHFont.caption)
                    .foregroundStyle(didReset ? BHColor.success : BHColor.inkMuted)
                    .accessibilityIdentifier("admin.progress.summary")

                Button("Nulstil alle svar") { confirmsReset = true }
                    .buttonStyle(.bhSecondary)
                    .accessibilityIdentifier("admin.reset")
            }
        }
        .confirmationDialog(
            "Nulstil alle svar?",
            isPresented: $confirmsReset,
            titleVisibility: .visible
        ) {
            Button("Nulstil", role: .destructive) {
                Task {
                    await engine.resetProgress()
                    didReset = true
                }
            }
            Button("Fortryd", role: .cancel) {}
        } message: {
            Text("Alle løste gåder, brugte hints og point slettes. Det kan ikke fortrydes.")
        }
    }

    private var summary: String {
        let solved = engine.playableMissions.filter(engine.isCompleted).count
        let points = engine.playableMissions.filter(engine.isCompleted)
            .reduce(0) { $0 + engine.points(for: $1) }
        if didReset, solved == 0 { return "Nulstillet. Ingen løste gåder." }
        return "\(solved) løste gåder, \(points) point."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BHSpacing.loose) {
                    // Nulstillingen står **uden for** provider-betingelsen.
                    //
                    // På en fysisk enhed findes der ingen simuleret GPS, og
                    // panelet viser derfor kun "utilgængelig". Men det er
                    // netop på enheden — ude i felten, med rigtige testere —
                    // at behovet for at prøve den samme opgave igen er størst.
                    simulationToggle
                    progressControls

                    if provider == nil {
                        unavailable
                    } else if engine.locationSwitch?.isSimulating == false {
                        realLocationNote
                    } else {
                        status
                        audioStatus
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

    /// Lydens tilstand, så en tavs afspiller kan fejlsøges frem for gættes på.
    private var audioStatus: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Text("Baggrundslyd")
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.inkMuted)
                Text(ambience.isEnabled ? "Slået til" : "Slået fra")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.ink)
                Text(ambience.isPlaying ? "Spiller nu" : "Spiller ikke")
                    .font(BHFont.body)
                    .foregroundStyle(ambience.isPlaying ? BHColor.success : BHColor.caution)
                if let failure = ambience.lastFailure {
                    Text(failure)
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.danger)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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

                            Button("Sæt mig 20 m væk") {
                                provider?.teleport(
                                    to: ScriptedLocationProvider.offset(vantage, northMetres: 20)
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
