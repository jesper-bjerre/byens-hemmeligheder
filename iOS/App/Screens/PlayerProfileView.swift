import BHAuthenticationKit
import BHDesignSystem
import SwiftUI

/// Konto, indstillinger og de permanente informationssider.
struct PlayerProfileView: View {
    @Environment(AmbiencePlayer.self) private var ambience
    @Environment(PlayerAuthentication.self) private var authentication
    @Environment(Router.self) private var router
    @State private var showsLocationTools = false
    @State private var showsDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var accountError: String?
    @State private var publicName = ""
    @State private var isSavingPublicName = false
    @State private var publicNameMessage: String?

    private var canUseLocationTools: Bool {
        guard authentication.state == .signedIn,
              let role = authentication.account?.role.lowercased()
        else { return false }
        return role == "designer" || role == "admin"
    }

    private var version: String {
        let marketing = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(marketing) (\(build))"
    }

    var body: some View {
        VStack(spacing: 0) {
            PlayerTopBar()

            ScrollView {
                VStack(alignment: .leading, spacing: BHSpacing.section) {
                    VStack(alignment: .leading, spacing: BHSpacing.tight) {
                        Text("Profil")
                            .font(BHFont.title)
                            .foregroundStyle(BHColor.ink)
                            .accessibilityAddTraits(.isHeader)
                        Text("Din konto, appens indstillinger og information om Vejles Koder.")
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                    }

                    PlayerAccountCard()
                    if authentication.state == .signedIn {
                        publicProfile
                    }
                    settings
                    if canUseLocationTools {
                        designerTools
                    }
                    accountActions
                    information
                }
                .padding(BHSpacing.regular)
                .padding(.bottom, BHSpacing.section)
            }
        }
        .background(BHColor.canvas)
        .accessibilityIdentifier("profile.screen")
        .sheet(isPresented: $showsLocationTools) {
            DevLocationPanel()
        }
        .alert("Slet konto?", isPresented: $showsDeleteConfirmation) {
            Button("Annuller", role: .cancel) {}
            Button("Slet konto permanent", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("Din konto, dine servergemte favoritter og din placering på highscorelisterne fjernes. Handlingen kan ikke fortrydes.")
        }
        .task(id: authentication.account?.publicName) {
            publicName = authentication.account?.publicName ?? ""
        }
    }

    private var publicProfile: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(title: "Offentligt profilnavn")

            BHCard {
                VStack(alignment: .leading, spacing: BHSpacing.snug) {
                    TextField("Fx Gådeholdet", text: $publicName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit { Task { await savePublicName() } }
                        .accessibilityIdentifier("profile.public-name")

                    Text("3–20 tegn. Kun dette navn kan ses på highscorelisten — aldrig din e-mail eller Apple-konto.")
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    if authentication.account?.nameModerationState == "Hidden" {
                        Label("Navnet er skjult af en administrator og vises som Anonym spiller.",
                              systemImage: "eye.slash.fill")
                            .font(BHFont.caption)
                            .foregroundStyle(BHColor.caution)
                    }

                    HStack(spacing: BHSpacing.snug) {
                        Button("Gem navn") {
                            Task { await savePublicName() }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isSavingPublicName)

                        if authentication.account?.publicName != nil {
                            Button("Fjern navn", role: .destructive) {
                                publicName = ""
                                Task { await savePublicName() }
                            }
                            .buttonStyle(.bordered)
                            .disabled(isSavingPublicName)
                        }
                    }

                    if isSavingPublicName {
                        ProgressView("Gemmer navn …")
                    } else if let publicNameMessage {
                        Text(publicNameMessage)
                            .font(BHFont.caption)
                            .foregroundStyle(publicNameMessage == "Profilnavnet er gemt."
                                             ? BHColor.success
                                             : Color.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    @MainActor
    private func savePublicName() async {
        isSavingPublicName = true
        publicNameMessage = nil
        defer { isSavingPublicName = false }
        do {
            let value = publicName.trimmingCharacters(in: .whitespacesAndNewlines)
            try await authentication.updatePublicName(value.isEmpty ? nil : value)
            publicName = authentication.account?.publicName ?? ""
            publicNameMessage = "Profilnavnet er gemt."
        } catch AuthenticationError.server(429) {
            publicNameMessage = "Navnet kan ændres igen 24 timer efter den seneste ændring."
        } catch {
            authentication.handleAuthenticationFailure(error)
            publicNameMessage = "Profilnavnet kunne ikke gemmes. Kontrollér navnet og prøv igen."
        }
    }

    /// Rollen kommer fra den verificerede serversession. Synligheden er god
    /// UX, ikke sikkerhedsgrænsen; API'et afgør fortsat, hvilke data kontoen
    /// faktisk må hente og ændre.
    private var designerTools: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(title: "Designer-værktøjer")

            BHCard {
                Button {
                    showsLocationTools = true
                } label: {
                    HStack(spacing: BHSpacing.snug) {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(BHColor.accent)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: BHSpacing.hairline) {
                            Text("Simuler GPS-position")
                                .font(BHFont.body)
                                .foregroundStyle(BHColor.ink)
                            Text("Test opgaver uden at stå på stedet")
                                .font(BHFont.caption)
                                .foregroundStyle(BHColor.inkMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(BHColor.inkMuted)
                    }
                    .frame(minHeight: BHMetrics.minimumTapTarget)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("profile.location-tools")
            }
        }
    }
    private var settings: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(title: "Indstillinger")

            BHCard {
                VStack(spacing: 0) {
                    settingRow(symbol: "speaker.wave.2.fill", title: "Baggrundslyd") {
                        Toggle("Baggrundslyd", isOn: Binding(
                            get: { ambience.isEnabled },
                            set: { ambience.setEnabled($0) }
                        ))
                        .labelsHidden()
                        .accessibilityLabel("Baggrundslyd")
                        .accessibilityIdentifier("profile.ambience.toggle")
                    }

                    Divider().padding(.leading, 36)

                    settingRow(symbol: "globe", title: "Sprog") {
                        Menu("Dansk") {
                            Button {
                                // Version 1 har kun dansk indhold. Menupunktet
                                // viser den valgte værdi uden at love et sprog,
                                // appen endnu ikke kan levere.
                            } label: {
                                Label("Dansk", systemImage: "checkmark")
                            }
                        }
                    }
                }
            }
        }
    }

    private var accountActions: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(title: "Konto")

            BHCard {
                VStack(alignment: .leading, spacing: BHSpacing.snug) {
                    Button {
                        router.push(.scoreboard)
                    } label: {
                        Label("Mine point", systemImage: "diamond.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(BHColor.ink)
                    .frame(minHeight: BHMetrics.minimumTapTarget)

                    Divider()

                    if authentication.state == .signedIn {
                        Button("Slet konto", role: .destructive) {
                            showsDeleteConfirmation = true
                        }
                        .disabled(isDeletingAccount)
                        .frame(minHeight: BHMetrics.minimumTapTarget)
                    }

                    if isDeletingAccount {
                        ProgressView("Sletter konto …")
                    }

                    Text(accountError ?? (authentication.state == .signedIn
                         ? "Kontosletning fjerner login og personlige serverdata permanent."
                         : "Log ind for at administrere eller slette en konto."))
                        .font(BHFont.caption)
                        .foregroundStyle(accountError == nil ? BHColor.inkMuted : Color.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @MainActor
    private func deleteAccount() async {
        isDeletingAccount = true
        accountError = nil
        defer { isDeletingAccount = false }
        do {
            try await authentication.deleteAccount()
        } catch {
            accountError = error.localizedDescription
        }
    }

    private var information: some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            DiscoverySectionHeader(title: "Om og juridisk")

            BHCard {
                VStack(spacing: 0) {
                    externalInformationLink(
                        "Vilkår og juridisk",
                        symbol: "doc.text",
                        url: URL(string: "https://agreeable-island-016468f03.7.azurestaticapps.net/vilkaar")!
                    )
                    Divider().padding(.leading, 36)
                    externalInformationLink(
                        "Privatlivspolitik",
                        symbol: "hand.raised.fill",
                        url: URL(string: "https://agreeable-island-016468f03.7.azurestaticapps.net/privatliv")!
                    )
                    Divider().padding(.leading, 36)
                    informationLink(
                        "Om Vejles Koder",
                        symbol: "info.circle.fill",
                        body: "Vejles Koder er en stedsbaseret oplevelse for familier. Gå hen til et sted i Vejle, undersøg omgivelserne, og løs koden sammen."
                    )
                    Divider().padding(.leading, 36)
                    HStack {
                        Label("Version", systemImage: "number")
                            .foregroundStyle(BHColor.ink)
                        Spacer()
                        Text(version)
                            .foregroundStyle(BHColor.inkMuted)
                            .monospacedDigit()
                    }
                    .font(BHFont.body)
                    .frame(minHeight: BHMetrics.minimumTapTarget)
                }
            }
        }
    }

    private func settingRow<Trailing: View>(
        symbol: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: BHSpacing.snug) {
            Image(systemName: symbol)
                .foregroundStyle(BHColor.accent)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
                .font(BHFont.body)
                .foregroundStyle(BHColor.ink)
            Spacer(minLength: BHSpacing.tight)
            trailing()
        }
        .frame(minHeight: BHMetrics.minimumTapTarget)
    }

    private func informationLink(_ title: String, symbol: String, body: String) -> some View {
        NavigationLink {
            ProfileInformationPage(title: title, text: body)
        } label: {
            HStack(spacing: BHSpacing.snug) {
                Image(systemName: symbol)
                    .foregroundStyle(BHColor.accent)
                    .frame(width: 24)
                Text(title)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(BHColor.inkMuted)
            }
            .frame(minHeight: BHMetrics.minimumTapTarget)
        }
    }

    private func externalInformationLink(_ title: String, symbol: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: BHSpacing.snug) {
                Image(systemName: symbol)
                    .foregroundStyle(BHColor.accent)
                    .frame(width: 24)
                Text(title)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.ink)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.bold())
                    .foregroundStyle(BHColor.inkMuted)
            }
            .frame(minHeight: BHMetrics.minimumTapTarget)
        }
    }
}

private struct ProfileInformationPage: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                Text(title)
                    .font(BHFont.title)
                    .foregroundStyle(BHColor.ink)
                Text(text)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
