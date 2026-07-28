import BHContracts
import BHDesignSystem
import SwiftUI

/// Missionsdetaljen — det ark, spilleren beslutter sig ud fra.
///
/// **Sikkerhedsnoterne står her, ikke i en fodnote.** Forfatningens princip IV
/// kræver, at spilleren kender risikoen, før turen begynder, og begge
/// lokationer i feature 001 ligger ved åbent vand (FR-006).
struct MissionSheet: View {
    let mission: Mission

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    private var location: Location? { engine.location(for: mission) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                header
                fictionLabel
                facts
                if let location { safety(location) }
                if let location { accessibility(location) }
                startButton
                sources
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle(mission.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Text(mission.title)
                .font(BHFont.title)
                .foregroundStyle(BHColor.ink)
            Text(mission.teaser)
                .font(BHFont.body)
                .foregroundStyle(BHColor.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    /// FR-007. Skal være synlig, ikke skjult bag en informationsknap.
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

    private var facts: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                factRow("Sværhedsgrad", "\(mission.difficulty) af 5", "brain.head.profile")
                factRow("Varighed", "ca. \(mission.estimatedMinutes) minutter", "clock")
                factRow("Point", "\(mission.basePoints) at hente", "star")
                if let location {
                    factRow("Sted", location.name, "mappin.and.ellipse")
                    if let vantage = location.vantagePoint {
                        Text(vantage.instruction)
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func factRow(_ label: String, _ value: String, _ symbol: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BHSpacing.tight) {
            Image(systemName: symbol)
                .foregroundStyle(BHColor.accent)
                .accessibilityHidden(true)
            Text(label)
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
            Spacer(minLength: BHSpacing.tight)
            Text(value)
                .font(BHFont.body)
                .foregroundStyle(BHColor.ink)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private func safety(_ location: Location) -> some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Label("Sikkerhed", systemImage: "exclamationmark.triangle.fill")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.caution)
                    .labelStyle(.titleAndIcon)

                if !location.safety.flags.isEmpty {
                    Text(location.safety.flags.map(\.danishName).joined(separator: " · "))
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                }
                Text(location.safety.notes)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func accessibility(_ location: Location) -> some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Label("Adgang", systemImage: "figure.roll")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)
                    .labelStyle(.titleAndIcon)

                Text("Underlag: \(location.accessibility.surface)")
                Text("Hældning: \(location.accessibility.incline)")
                Text("Kørestol: \(location.accessibility.wheelchair.danishName)")
                Text("Barnevogn: \(location.accessibility.stroller.danishName)")
                Text(location.accessibility.notes)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(BHFont.body)
            .foregroundStyle(BHColor.ink)
        }
        .accessibilityElement(children: .combine)
    }

    private var startButton: some View {
        Button("Tag afsted") {
            Task {
                guard await engine.startSession(for: mission) else { return }
                if engine.hasSeenSafetyInterstitial {
                    router.push(.approach(missionId: mission.id))
                } else {
                    router.presentedSheet = .safety(missionId: mission.id)
                }
            }
        }
        .buttonStyle(.bhPrimary)
        .accessibilityHint("Starter opgaven og viser vej til stedet")
    }

    private var sources: some View {
        VStack(alignment: .leading, spacing: BHSpacing.tight) {
            Text("Kilder")
                .font(BHFont.caption)
                .foregroundStyle(BHColor.inkMuted)
            ForEach(mission.sourceIds, id: \.self) { sourceId in
                if let source = engine.pack?.source(id: sourceId) {
                    Text("\(source.title) — \(source.publisher)")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Danske navne til kontraktens enums

extension Tolerant where Known == SafetyFlag {
    var danishName: String {
        switch known {
        case .traffic: "Trafik"
        case .water: "Vand"
        case .steepSlope: "Stigning"
        case .darkness: "Mørke"
        case .privateProperty: "Privat område"
        case .cyclePath: "Cykelsti"
        case .construction: "Byggeri"
        case .crowding: "Mange mennesker"
        case nil: rawValue
        }
    }
}

extension Tolerant where Known == AccessLevel {
    var danishName: String {
        switch known {
        case .yes: "Ja"
        case .partial: "Delvist"
        case .no: "Nej"
        case .unknown: "Ikke registreret endnu"
        case nil: rawValue
        }
    }
}
