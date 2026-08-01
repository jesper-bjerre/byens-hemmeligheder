import SwiftUI

/// Quizmasterens forside: opgaverne, grupperet som landsdel → postnummer.
///
/// Der er ingen pakke-sektion (FR-101) og ingen serveradresse (FR-102).
/// Forsiden svarer på ét spørgsmål — hvilken opgave skal jeg rette — og alt
/// andet på den gjorde det spørgsmål langsommere at besvare.
struct ContentView: View {
    @State private var document: PackDocument?
    @State private var status: String?
    @State private var isBusy = false
    @State private var showsQuizmaster = false
    @State private var showsAudit = false
    @State private var newMission: MissionSummary?
    @State private var pendingDeletion: MissionSummary?
    @State private var conflicts: [String] = []
    @State private var pendingBackend: AdminConfiguration.Backend?
    @State private var draft: DraftStore.Restored?
    @State private var drafts = DraftWriter()

    @Environment(\.scenePhase) private var scenePhase

    private let client = PackClient()

    var body: some View {
        NavigationStack {
            Group {
                if let document {
                    missionList(document)
                } else if isBusy {
                    // Første indlæsning tager et øjeblik over netværket. Uden
                    // dette ser appen tom ud, og quizmasteren trykker igen.
                    ProgressView("Henter opgaver \u{2026}")
                        .controlSize(.large)
                } else {
                    VStack(spacing: 16) {
                        Image("EmptyState-NoTasks")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 320)
                            .accessibilityHidden(true)
                        Text(status ?? "Tryk Genindlæs opgaver for at begynde.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Genindlæs opgaver", action: load)
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Byens Gåder")
            .toolbar { toolbar }
            .overlay(alignment: .bottom) { banner }
            .sheet(isPresented: $showsQuizmaster) { QuizmasterSheet() }
            // Sletningen bekræftes. Den fjerner opgaven, dens sted og alt, der
            // stod i dem — og der er ingen fortrydelse ud over at lade være med
            // at gemme.
            .confirmationDialog(
                "Slet \(pendingDeletion?.title ?? "opgaven")?",
                isPresented: Binding(
                    get: { pendingDeletion != nil },
                    set: { if !$0 { pendingDeletion = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Slet opgaven", role: .destructive) {
                    if let mission = pendingDeletion { delete(mission) }
                    pendingDeletion = nil
                }
                Button("Behold", role: .cancel) { pendingDeletion = nil }
            } message: {
                Text("Opgaven og dens sted fjernes fra pakken. Først når du gemmer, "
                     + "er den væk for de andre quizmastere.")
            }
            .sheet(isPresented: $showsAudit) { AuditView() }
            // At skifte server med ugemte rettelser er farligt: rettelserne
            // hører til den pakke, de blev lagt oven på, og den ligger et
            // andet sted.
            .confirmationDialog(
                "Skift til \(pendingBackend?.name ?? "")?",
                isPresented: Binding(
                    get: { pendingBackend != nil },
                    set: { if !$0 { pendingBackend = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Skift og kassér mine rettelser", role: .destructive) {
                    if let pendingBackend { switchTo(pendingBackend) }
                    pendingBackend = nil
                }
                Button("Bliv her", role: .cancel) { pendingBackend = nil }
            } message: {
                Text("Du har rettelser, der ikke er gemt. De hører til "
                     + "\(AdminConfiguration.backend.name) og kan ikke lægges over på en "
                     + "anden server.")
            }
            // Skubbes på stakken og vises ikke som et ark. Den nye opgave
            // åbnes samme sted som alle andre, og tilbageknappen fører hen,
            // hvor quizmasteren kom fra.
            .navigationDestination(item: $newMission) { created in
                if let document {
                    MissionEditorView(document: document, mission: created, onSave: save)
                }
            }
            // Konflikterne vises som en liste og ikke som én linje. Er der
            // fire, skal quizmasteren se alle fire.
            .alert("Flettet med en andens rettelser", isPresented: Binding(
                get: { !conflicts.isEmpty },
                set: { if !$0 { conflicts = [] } }
            )) {
                Button("Forstået") { conflicts = [] }
            } message: {
                Text("Dine rettelser står, men en anden havde rettet det samme:\n\n"
                     + conflicts.prefix(8).joined(separator: "\n")
                     + (conflicts.count > 8 ? "\n… og \(conflicts.count - 8) mere" : ""))
            }
            .alert("Du har uafsluttede rettelser", isPresented: Binding(
                get: { draft != nil },
                set: { if !$0 { draft = nil } }
            )) {
                Button("Genopret") { restoreDraft() }
                Button("Kassér", role: .destructive) {
                    DraftStore.clear()
                    draft = nil
                }
            } message: {
                if let draft {
                    Text("Fra \(draft.savedAt.formatted(date: .abbreviated, time: .shortened)). "
                         + "De blev aldrig gemt på serveren.")
                }
            }
            .onChange(of: scenePhase) { _, phase in
                // iOS lukker en app i baggrunden uden at spørge — og kameraet,
                // quizmasteren lige har brugt, er dét, der udløser det.
                if phase != .active { drafts.flush(document) }
            }
            .task {
                if document == nil { load() }
                showsQuizmaster = !AdminConfiguration.isReady
            }
        }
    }

    // MARK: - Listen

    private func missionList(_ document: PackDocument) -> some View {
        List {
            ForEach(document.hierarchy) { region in
                Section(Vocabulary.regionName(region.region)) {
                    ForEach(region.places) { place in
                        DisclosureGroup(place.title) {
                            ForEach(place.missions) { mission in
                                NavigationLink {
                                    MissionEditorView(
                                        document: document, mission: mission, onSave: save)
                                } label: {
                                    row(mission)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Slet", systemImage: "trash", role: .destructive) {
                                        pendingDeletion = mission
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .refreshable { await reload() }
    }

    private func row(_ mission: MissionSummary) -> some View {
        HStack(spacing: 10) {
            // Publicér-mærket kun på det, der faktisk er frigivet. Sad det på
            // alle rækker, ville det ikke sige noget.
            if mission.status == "fieldTestReady" {
                Image("Icon-Publish")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(mission.title)
                Text("\(Vocabulary.statusName(mission.status)) · \(mission.cardCount) kort")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    showsQuizmaster = true
                } label: {
                    Label(
                        AdminConfiguration.isReady ? AdminConfiguration.quizmaster : "Sæt dit navn",
                        systemImage: "person.crop.circle")
                }
                Button {
                    showsAudit = true
                } label: {
                    Label {
                        Text("Hvem har rettet hvad")
                    } icon: {
                        Image("Icon-Route")
                    }
                }
                Divider()

                if AdminConfiguration.canChooseBackend {
                    Picker("Server", selection: Binding(
                        get: { AdminConfiguration.backend },
                        set: { choose($0) }
                    )) {
                        ForEach(AdminConfiguration.Backend.allCases) { backend in
                            Text(backend.name).tag(backend)
                        }
                    }
                } else {
                    // Hvilket indhold retter jeg i. Uden det kan man rette i
                    // det forkerte uden at opdage det.
                    Label(client.host, systemImage: "server.rack")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Genindlæs opgaver", action: load).disabled(isBusy)
        }

        ToolbarItem(placement: .bottomBar) {
            Button {
                createMission()
            } label: {
                Label("Ny opgave", systemImage: "plus")
            }
            .disabled(document == nil || isBusy)
        }
    }

    @ViewBuilder
    private var banner: some View {
        if let status {
            Text(status)
                .font(.footnote)
                .padding(8)
                .background(.thinMaterial, in: .rect(cornerRadius: 8))
                .padding()
        }
    }

    // MARK: - Handlinger

    private func load() {
        isBusy = true
        Task {
            await reload()
            isBusy = false
        }
    }

    private func reload() async {
        do {
            let fresh = try await client.load()
            adopt(fresh)
            status = nil
            // Kladden tilbydes først, når serveren har svaret. Ellers ville
            // quizmasteren skulle vælge, før hen kan se, hvad der står.
            draft = DraftStore.restore()
        } catch {
            status = PackClient.describe(error)
        }
    }

    /// Tager et dokument i brug og binder kladdeskrivningen til det.
    private func adopt(_ fresh: PackDocument) {
        fresh.onChange = { [drafts] in drafts.schedule(fresh) }
        document = fresh
    }

    private func restoreDraft() {
        guard let restored = draft?.document else { return }
        adopt(restored)
        draft = nil
        status = "Dine rettelser er genoprettet. De er ikke gemt endnu."
    }

    /// Gemmer og henter straks igen.
    ///
    /// Genhentningen er ikke pynt: serveren beregner ETag'en af indholdet, og
    /// uden den nye ville næste gemning blive afvist som en konflikt med sig selv.
    private func save() {
        guard let document else { return }
        isBusy = true
        Task {
            do {
                let etag = try await client.save(document)
                document.adopt(etag: etag)
                DraftStore.clear()
                status = "Gemt."
            } catch AdminError.conflict {
                await mergeAndRetry(document)
            } catch {
                status = PackClient.describe(error)
            }
            isBusy = false
        }
    }

    /// En anden har gemt imens.
    ///
    /// I stedet for at bede quizmasteren hente igen og taste sine rettelser
    /// forfra, hentes serverens udgave, og de lokale rettelser lægges oven på
    /// den felt for felt. Kun felter, begge har rettet forskelligt, kræver et
    /// menneske — og de bliver vist.
    private func mergeAndRetry(_ document: PackDocument) async {
        do {
            let server = try await client.load()
            let clashes = document.rebase(onto: server)

            let etag = try await client.save(document)
            document.adopt(etag: etag)
            DraftStore.clear()

            conflicts = clashes
            status = clashes.isEmpty
                ? "Gemt. En andens rettelser blev flettet ind."
                : "Gemt, men \(clashes.count) felter var rettet af begge."
        } catch {
            status = "Kunne ikke flette: \(PackClient.describe(error)) "
                + "Dine rettelser er gemt på telefonen."
        }
    }

    /// Skifter server.
    ///
    /// Har quizmasteren ugemte rettelser, spørges der først — de hører til den
    /// pakke, de blev lagt oven på, og den ligger på den server, hen forlader.
    private func choose(_ backend: AdminConfiguration.Backend) {
        guard backend != AdminConfiguration.backend else { return }
        if document?.hasUnsavedChanges == true {
            pendingBackend = backend
        } else {
            switchTo(backend)
        }
    }

    private func switchTo(_ backend: AdminConfiguration.Backend) {
        AdminConfiguration.select(backend)
        // Kladden hørte til den gamle server. Genoprettet mod en anden ville
        // den skrive fremmed indhold ind som "mine rettelser".
        DraftStore.clear()
        document = nil
        status = "Skiftet til \(backend.name)."
        load()
    }

    /// Fjerner opgaven fra dokumentet. Der gemmes ikke — sletningen står først
    /// ved magt, når quizmasteren trykker Gem, og indtil da er en genindlæsning
    /// nok til at fortryde.
    private func delete(_ mission: MissionSummary) {
        document?.deleteMission(at: mission.index)
        status = "\(mission.title) er fjernet. Gem for at gøre det endeligt."
    }

    /// FR-106. Opgaven skrives ind i dokumentet med det samme og åbnes i
    /// editoren — den er ikke gemt på serveren, før quizmasteren trykker Gem.
    private func createMission() {
        guard let document else { return }
        newMission = document.createMission()
        drafts.schedule(document)
        status = "Ny opgave oprettet. Udfyld stedet, og gem."
    }
}

/// Hvem der retter. Navnet følger med hver gemning (FR-111).
struct QuizmasterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = AdminConfiguration.quizmaster

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dit navn", text: $name)
                        .textContentType(.name)
                } footer: {
                    Text("Alle quizmastere kan rette i alt, og der er ingen godkendelsesgang. "
                         + "Navnet er derfor det eneste, der bagefter kan svare på, hvem der "
                         + "flyttede en opgave — og serveren afviser en gemning uden det.")
                }
            }
            .navigationTitle("Quizmaster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gem") {
                        AdminConfiguration.quizmaster = name
                        dismiss()
                    }
                    .disabled(name.trimmed.isEmpty)
                }
            }
        }
    }
}
