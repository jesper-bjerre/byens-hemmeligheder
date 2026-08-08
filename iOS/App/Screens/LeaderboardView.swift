import BHAuthenticationKit
import BHDesignSystem
import SwiftUI

/// Highscorelisterne, adskilt fra spillerens egne point.
///
/// Listen viser kun serverens rigtige indrapporteringer. En tom liste er mere
/// ærlig end opdigtede spillere — især i en app, børn kan bruge.
struct LeaderboardView: View {
    private enum Scope: String, CaseIterable, Identifiable {
        case week = "Denne uge"
        case allTime = "Alle tider"

        var id: Self { self }
    }

    @Environment(PlayerScoresStore.self) private var scores
    @Environment(PlayerAuthentication.self) private var authentication
    @State private var scope: Scope = .week
    @State private var nameToReport: String?
    @State private var reportMessage: String?

    private var entries: [PlayerScoresStore.Entry] {
        scope == .week ? scores.weekly : scores.allTime
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                header

                Picker("Periode", selection: $scope) {
                    ForEach(Scope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)

                if scores.isLoading && entries.isEmpty {
                    ProgressView("Henter placeringer …")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if entries.isEmpty {
                    ContentUnavailableView(
                        scores.leaderboardMessage == nil
                            ? "Ingen resultater endnu"
                            : "Highscore er ikke tilgængelig",
                        systemImage: scores.leaderboardMessage == nil ? "trophy" : "wifi.exclamationmark",
                        description: Text(scores.leaderboardMessage
                            ?? "Den første indloggede spiller, der løser en opgave, åbner listen."))
                } else {
                    leaderboard
                }
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle("Highscore")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("leaderboard.screen")
        .task { await scores.refresh() }
        .confirmationDialog(
            "Hvorfor vil du rapportere navnet?",
            isPresented: Binding(
                get: { nameToReport != nil },
                set: { if !$0 { nameToReport = nil } }),
            titleVisibility: .visible
        ) {
            Button("Krænkende eller upassende") { report(.offensive) }
            Button("Indeholder personlige oplysninger") { report(.personalInfo) }
            Button("Udgiver sig for at være en anden") { report(.impersonation) }
            Button("Andet") { report(.other) }
            Button("Annuller", role: .cancel) { nameToReport = nil }
        }
        .alert("Rapportering", isPresented: Binding(
            get: { reportMessage != nil },
            set: { if !$0 { reportMessage = nil } }
        )) {
            Button("OK") { reportMessage = nil }
        } message: {
            Text(reportMessage ?? "")
        }
    }

    private var header: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                HStack(spacing: BHSpacing.tight) {
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundStyle(BHColor.caution)
                    Text("Bedste i Vejle")
                        .font(BHFont.title)
                        .foregroundStyle(BHColor.ink)
                }

                Text("Rigtige point fra spillere, der er logget ind. E-mail og Apple-identitet vises aldrig.")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var leaderboard: some View {
        VStack(spacing: BHSpacing.tight) {
            ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                HStack(spacing: BHSpacing.snug) {
                    HStack(spacing: BHSpacing.snug) {
                        rank(index + 1)
                        Text(entry.name)
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: BHSpacing.tight)
                        Text("\(entry.points)")
                            .font(BHFont.heading)
                            .foregroundStyle(BHColor.accent)
                            .monospacedDigit()
                        Text("point")
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.inkMuted)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Nummer \(index + 1): \(entry.name), \(entry.points) point")
                    if entry.name != "Anonym spiller" {
                        Button {
                            if authentication.state == .signedIn {
                                nameToReport = entry.name
                            } else {
                                reportMessage = "Log ind fra Profil for at rapportere et profilnavn."
                            }
                        } label: {
                            Image(systemName: "exclamationmark.bubble")
                                .frame(width: BHMetrics.minimumTapTarget,
                                       height: BHMetrics.minimumTapTarget)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(BHColor.inkMuted)
                        .accessibilityLabel("Rapportér profilnavnet \(entry.name)")
                    }
                }
                .padding(BHSpacing.regular)
                .background(
                    RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                        .fill(BHColor.surface)
                )
            }
        }
        .accessibilityIdentifier("scoreboard.leaderboard")
    }

    private func rank(_ value: Int) -> some View {
        Text("\(value)")
            .font(BHFont.heading)
            .foregroundStyle(value <= 3 ? BHColor.onAccent : BHColor.inkMuted)
            .monospacedDigit()
            .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
            .background(
                Circle().fill(value <= 3 ? BHColor.accent : BHColor.accentSoft)
            )
    }

    private func report(_ category: PublicNameReportCategory) {
        guard let name = nameToReport else { return }
        nameToReport = nil
        Task {
            do {
                try await authentication.reportPublicName(name, category: category)
                reportMessage = "Tak. Rapporten er sendt til en administrator."
            } catch {
                authentication.handleAuthenticationFailure(error)
                reportMessage = "Rapporten kunne ikke sendes. Prøv igen senere."
            }
        }
    }
}
