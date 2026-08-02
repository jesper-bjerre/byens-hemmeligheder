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
                MissionTab(document: document, index: mission.index)
            }
            Tab("Stedet", systemImage: "mappin.and.ellipse") {
                PlaceTab(document: document, missionIndex: mission.index)
            }
            Tab("Detaljer", systemImage: "rectangle.stack") {
                CardsTab(document: document, missionIndex: mission.index)
            }
            Tab("Spørgsmål", systemImage: "questionmark.circle") {
                QuestionTab(document: document, index: mission.index)
            }
            Tab("Hints", systemImage: "lightbulb") {
                HintsTab(document: document, index: mission.index)
            }
        }
        .navigationTitle(document.string(at: .mission(mission.index, .key("title"))))
        .navigationBarTitleDisplayMode(.inline)
        // Ingen Gem-knap. Der gemmes, når editoren forlades — en knap, man kan
        // glemme, er en, der taber arbejde, og quizmasteren står i felten med
        // én hånd på telefonen.
        .onDisappear(perform: onSave)
    }
}

/// Faneblad 1: hvad opgaven er.
struct MissionTab: View {
    let document: PackDocument
    let index: Int

    var body: some View {
        Form {
            Section("Titel") {
                TextField("Titel", text: title)
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

            Section("Spillet") {
                Stepper(
                    "Sværhedsgrad: \(document.integer(at: .mission(index, .key("difficulty"))) ?? 3)",
                    value: document.integer(.mission(index, .key("difficulty")), default: 3),
                    in: 1...5)
                Stepper(
                    "Point: \(document.integer(at: .mission(index, .key("basePoints"))) ?? 100)",
                    value: document.integer(.mission(index, .key("basePoints")), default: 100),
                    in: 1...1000, step: 10)
            }

            Section {
                TextField("Fiktionsmarkering",
                          text: document.text(.mission(index, .key("fictionLabel"))),
                          axis: .vertical)
                    .lineLimit(2...)
            } header: {
                Text("Hvad er digtet")
            } footer: {
                Text("Spilleren skal kunne se, hvad der er opfundet, og hvad der er "
                     + "dokumenteret. Rammen om gåden er fiktion; stedet, formerne og "
                     + "årstallene er det ikke — og det er dem, facit hviler på.")
            }
        }
        .dismissableKeyboard()
    }

    // MARK: - Titlen

    /// Der er ét titelfelt i standardvisningen, men kontrakten har to.
    ///
    /// `shortTitle` følger titlen. Der er ikke længere et felt til den, så
    /// den holder aldrig op med at følge med — men feltet står stadig i
    /// pakken, fordi kontrakten kræver det.
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

}

/// En ny kilde i pakkens fælles liste.
///
/// Bruges ikke af editoren længere — kilder redigeres ikke i appen. Beholdt,
/// fordi kontrakten stadig kræver, at de kilder, der *er* angivet, findes.
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
            .dismissableKeyboard()
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
