import SwiftUI

/// Editoren for én opgave.
///
/// ## Hvorfor fem faneblade og ikke tre
///
/// Tre — Opgaven, Kort, Hints — dækker ikke felterne. Stedet bærer alene et
/// dusin: kvarter, adresse, koordinat, aktiveringsradius, sikkerhed og
/// tilgængelighed. Lagt sammen med opgavens egne ville det blive en rulle, hvor
/// quizmasteren ikke kan se, hvor hen er. Spørgsmålet er skilt ud af samme
/// grund: facit, accepterede svar og feedback hører sammen og ingen andre
/// steder.
///
/// Standardvisningen viser kun det, en opgave ikke kan undvære. Resten ligger
/// under Avanceret, som quizmasteren selv skal slå til.
struct MissionEditorView: View {
    let document: PackDocument
    let mission: MissionSummary
    let onSave: () -> Void

    /// Standard hver gang editoren åbnes.
    ///
    /// Valget huskes med vilje **ikke**. Avanceret bærer felter, der sjældent
    /// skal røres — aktiveringsradius, tilgængelighed, kilder — og et tilvalg,
    /// der hænger ved fra i går, er ikke længere et tilvalg. Quizmasteren skal
    /// gøre noget aktivt for at se dem.
    @State private var isAdvanced = false

    var body: some View {
        TabView {
            // SF Symbols og ikke grafikpakkens illustrationer.
            //
            // Illustrationerne er 512 px detaljerede tegninger. En fanebladslinje
            // giver dem 25 punkter, og grafikpakkens egen README siger det
            // samme: standardnavigation hører til i SF Symbols. De bruges i
            // stedet, hvor der er plads — tomme skærme, fortællingen og
            // billedpladsen på et kort.
            Tab("Opgaven", systemImage: "doc.text") {
                MissionTab(document: document, index: mission.index, isAdvanced: isAdvanced)
            }
            Tab("Stedet", systemImage: "mappin.and.ellipse") {
                PlaceTab(
                    document: document, missionIndex: mission.index, isAdvanced: isAdvanced)
            }
            Tab("Detaljer", systemImage: "rectangle.stack") {
                CardsTab(document: document, missionIndex: mission.index)
            }
            Tab("Spørgsmål", systemImage: "questionmark.circle") {
                QuestionTab(document: document, index: mission.index, isAdvanced: isAdvanced)
            }
            Tab("Hints", systemImage: "lightbulb") {
                HintsTab(document: document, index: mission.index)
            }
        }
        .navigationTitle(document.string(at: .mission(mission.index, .key("title"))))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Visning", selection: $isAdvanced) {
                        Text("Standard").tag(false)
                        Text("Avanceret").tag(true)
                    }
                } label: {
                    Label("Visning", systemImage: isAdvanced
                          ? "slider.horizontal.3"
                          : "slider.horizontal.below.rectangle")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                // Uden titel kan opgaven hverken findes på forsiden eller få et
                // id, der siger noget. Den er ikke halvfærdig — den er unavngiven.
                Button("Gem", action: onSave)
                    .disabled(document.string(at: .mission(mission.index, .key("title")))
                        .trimmed.isEmpty)
            }
        }
    }
}

/// Faneblad 1: hvad opgaven er.
struct MissionTab: View {
    let document: PackDocument
    let index: Int
    let isAdvanced: Bool

    @State private var showsNewSource = false

    var body: some View {
        Form {
            Section("Titel") {
                TextField("Titel", text: title)
                if isAdvanced {
                    TextField("Kort titel",
                              text: document.text(.mission(index, .key("shortTitle"))))
                }
            }

            Section("Beskrivelse") {
                TextField("Beskrivelse",
                          text: document.text(.mission(index, .key("description"))),
                          axis: .vertical)
                    .lineLimit(3...)
            }

            Section {
                // Alle quizmastere må flytte enhver opgave. Der er ingen
                // godkendelsesgang, og derfor heller ingen låst vælger (FR-110).
                Picker("Status", selection: document.text(.mission(index, .key("status")))) {
                    ForEach(
                        Vocabulary.statusChoices(
                            current: document.string(at: .mission(index, .key("status")))),
                        id: \.self
                    ) {
                        Text(Vocabulary.statusName($0)).tag($0)
                    }
                }

                if document.string(at: .mission(index, .key("status"))) == "fieldTestReady" {
                    Image("EmptyState-ReadyForTest")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .accessibilityLabel("Opgaven er frigivet og klar til test")
                }
            }

            NarrationSection(document: document, missionIndex: index)

            Section("Spillet") {
                Stepper(
                    "Sværhedsgrad: \(document.integer(at: .mission(index, .key("difficulty"))) ?? 3)",
                    value: document.integer(.mission(index, .key("difficulty")), default: 3),
                    in: 1...5)
                Stepper(
                    "Point: \(document.integer(at: .mission(index, .key("basePoints"))) ?? 100)",
                    value: document.integer(.mission(index, .key("basePoints")), default: 100),
                    in: 1...1000, step: 10)

                if isAdvanced {
                    Stepper(
                        "Tid: \(document.integer(at: .mission(index, .key("estimatedMinutes"))) ?? 15) min",
                        value: document.integer(
                            .mission(index, .key("estimatedMinutes")), default: 15),
                        in: 1...180)
                }
            }

            if isAdvanced {
                EditableLines(
                    title: "Tags",
                    placeholder: "fx arkitektur",
                    lines: document.lines(.mission(index, .key("tags"))))
            }

            if isAdvanced {
                Section {
                    TextField("Fiktionsmarkering",
                              text: document.text(.mission(index, .key("fictionLabel"))),
                              axis: .vertical)
                        .lineLimit(2...)
                } header: {
                    Text("Hvad er digtet")
                } footer: {
                    Text("Spilleren skal kunne se, hvad der er opfundet, og hvad der er "
                         + "dokumenteret. Teksten vises sammen med opgaven.")
                }

                sources
            }
        }
        .sheet(isPresented: $showsNewSource) {
            NewSourceSheet(document: document) { id in
                var ids = document.strings(at: .mission(index, .key("sourceIds")))
                ids.append(id)
                document.setValue(ids, at: .mission(index, .key("sourceIds")))
            }
        }
    }

    // MARK: - Titlen

    /// Der er ét titelfelt i standardvisningen, men kontrakten har to.
    ///
    /// `shortTitle` følger med, så længe den ikke er sat til noget andet.
    /// Rettes den i Avanceret, holder den op med at følge med — ellers ville
    /// et tilbageslag i titlen slette en kort titel, nogen havde valgt.
    private var title: Binding<String> {
        Binding(
            get: { document.string(at: .mission(index, .key("title"))) },
            set: { new in
                let previous = document.string(at: .mission(index, .key("title")))
                let short = document.string(at: .mission(index, .key("shortTitle")))
                document.setValue(new, at: .mission(index, .key("title")))
                if short.isEmpty || short == previous {
                    document.setValue(new, at: .mission(index, .key("shortTitle")))
                }
            }
        )
    }

    // MARK: - Kilder

    /// Listen må være tom.
    ///
    /// En bærende opgave skal kunne bevise sit facit (forfatningens princip
    /// II), men en lille gåde på vejen hen til den næste opgave hviler ikke på
    /// noget, der skal dokumenteres. Kravet er redaktionelt og ikke teknisk —
    /// og en opdigtet kilde, tilføjet for at få en advarsel til at gå væk, er
    /// værre end ingen.
    @ViewBuilder
    private var sources: some View {
        let selected = document.strings(at: .mission(index, .key("sourceIds")))
        let all = document.objects(at: [.key("sources")])

        Section {
            ForEach(all.indices, id: \.self) { position in
                let source = all[position]
                let id = source["id"] as? String ?? ""
                Button {
                    toggle(sourceId: id)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(source["title"] as? String ?? id)
                            Text(source["publisher"] as? String ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selected.contains(id) {
                            Image(systemName: "checkmark").foregroundStyle(.tint)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                showsNewSource = true
            } label: {
                Label("Tilføj kilde", systemImage: "plus.circle")
            }
        } header: {
            Text("Kilder")
        } footer: {
            Text(selected.isEmpty
                 ? "Ingen kilder valgt. Det er i orden for en lille gåde på vejen — en bærende "
                   + "opgave skal kunne bevise sit facit."
                 : "Vælg de kilder, facit hviler på.")
        }
    }

    private func toggle(sourceId: String) {
        var ids = document.strings(at: .mission(index, .key("sourceIds")))
        if let position = ids.firstIndex(of: sourceId) {
            ids.remove(at: position)
        } else {
            ids.append(sourceId)
        }
        document.setValue(ids, at: .mission(index, .key("sourceIds")))
    }
}

/// En ny kilde i pakkens fælles liste.
struct NewSourceSheet: View {
    let document: PackDocument
    let onCreated: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var publisher = ""
    @State private var url = ""
    @State private var kind = "officialTourism"

    private static let kinds = [
        "officialTourism", "architectPrimary", "archive", "press", "municipal", "other",
    ]

    private static func kindName(_ raw: String) -> String {
        switch raw {
        case "officialTourism": "Officiel turisme"
        case "architectPrimary": "Arkitekten selv"
        case "archive": "Arkiv"
        case "press": "Presse"
        case "municipal": "Kommunen"
        default: "Andet"
        }
    }

    private var isComplete: Bool {
        !title.trimmed.isEmpty && !publisher.trimmed.isEmpty
            && URL(string: url.trimmed)?.scheme != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Titel", text: $title)
                TextField("Udgiver", text: $publisher)
                TextField("Adresse", text: $url)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                Picker("Slags", selection: $kind) {
                    ForEach(Self.kinds, id: \.self) { Text(Self.kindName($0)).tag($0) }
                }
            }
            .navigationTitle("Ny kilde")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fortryd") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tilføj", action: create).disabled(!isComplete)
                }
            }
        }
    }

    private func create() {
        let existing = Set(
            document.objects(at: [.key("sources")]).compactMap { $0["id"] as? String })

        var id = "source.\(publisher.packSlug).\(title.packSlug)"
        var counter = 2
        while existing.contains(id) {
            id = "source.\(publisher.packSlug).\(title.packSlug)-\(counter)"
            counter += 1
        }

        document.append([
            "id": id,
            "title": title.trimmed,
            "publisher": publisher.trimmed,
            "url": url.trimmed,
            "kind": kind,
        ], to: [.key("sources")])

        onCreated(id)
        dismiss()
    }
}
