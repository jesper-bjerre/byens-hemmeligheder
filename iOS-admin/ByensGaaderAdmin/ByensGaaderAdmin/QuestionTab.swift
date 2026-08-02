import SwiftUI

/// Faneblad 4: spørgsmålet, facit og belønningen.
///
/// ## Kun ét trin redigeres
///
/// En opgave kan i kontrakten have flere trin, men alle de opgaver, der findes,
/// har ét, der bedømmes. Editoren retter derfor det første trin, der ikke er en
/// ren fortælling, og lader eventuelle andre stå urørt. En editor, der viste
/// alle trin, ville bruge halvdelen af pladsen på et tilfælde, der ikke er
/// opstået.
struct QuestionTab: View {
    let document: PackDocument
    let index: Int

    private var stepsPath: [JSONStep] { .mission(index, .key("steps")) }
    private var steps: [[String: Any]] { document.objects(at: stepsPath) }

    /// Trinnet, der bedømmes.
    private var stepIndex: Int? {
        steps.firstIndex { ($0["kind"] as? String) != "narrative" } ?? (steps.isEmpty ? nil : 0)
    }

    var body: some View {
        Group {
            if let stepIndex {
                form(stepIndex)
            } else {
                ContentUnavailableView {
                    Label("Opgaven har ingen trin", systemImage: "questionmark.circle")
                } description: {
                    Text("Kontrakten kræver mindst ét. Opret opgaven på ny, eller ret pakken "
                         + "i hånden.")
                }
            }
        }
    }

    private func form(_ step: Int) -> some View {
        let path = stepsPath + [.index(step)]
        let kind = document.string(at: path + [.key("kind")])

        return Form {
            Section {
                Picker("Svartype", selection: Binding(
                    get: { kind },
                    set: { change(kind: $0, at: path, from: kind) }
                )) {
                    ForEach(Vocabulary.stepKinds, id: \.self) {
                        Text(Vocabulary.stepKindName($0)).tag($0)
                    }
                }
            } footer: {
                Text(hint(for: kind))
            }

            Section("Spørgsmålet") {
                // Ét felt. Trinnet har også en `title` i kontrakten, men den
                // vises aldrig for spilleren — kun som reservetekst for
                // skærmlæseren, hvis spørgsmålet mangler. Den skrives af sig
                // selv ud fra opgavens titel.
                TextField("Spørgsmål", text: document.text(path + [.key("question")]),
                          axis: .vertical)
                    .lineLimit(2...)

                if kind == "freeText" {
                    TextField("Vejledende tekst i feltet",
                              text: document.text(path + [.key("placeholder")]))
                }
            }

            if kind == "singleChoice" {
                options(path)
            }

            answerRule(path)
            completion
        }
        .dismissableKeyboard()
    }

    private func hint(for kind: String) -> String {
        switch kind {
        case "singleChoice":
            "Mindst to svarmuligheder. Facit skal stå blandt dem, ellers kan opgaven ikke løses."
        case "numericCode":
            "Foranstillede nuller er betydende. Facit gemmes som tekst og aldrig som et tal."
        default:
            "Alt, spilleren kan finde på at skrive rigtigt, skal stå under accepterede svar."
        }
    }

    // MARK: - Svarmuligheder

    @ViewBuilder
    private func options(_ path: [JSONStep]) -> some View {
        let optionsPath = path + [.key("options")]
        let options = document.objects(at: optionsPath)

        Section {
            ForEach(options.indices, id: \.self) { position in
                TextField(
                    "Svarmulighed",
                    text: document.text(optionsPath + [.index(position), .key("label")]))
            }
            .onDelete { offsets in
                for position in offsets.sorted(by: >) {
                    document.remove(at: position, in: optionsPath)
                }
            }

            Button {
                document.append(
                    ["id": "valg-\(options.count + 1)", "label": ""], to: optionsPath)
            } label: {
                Label("Tilføj svarmulighed", systemImage: "plus.circle")
            }
        } header: {
            Text("Svarmuligheder")
        } footer: {
            Text(options.count < 2
                 ? "Der skal være mindst to. Med én er der intet at vælge imellem."
                 : "")
                .foregroundStyle(options.count < 2 ? .red : .secondary)
        }
    }

    // MARK: - Facit

    private func answerRule(_ path: [JSONStep]) -> some View {
        let rule = path + [.key("answerRule")]
        let answers = document.strings(at: rule + [.key("acceptedAnswers")])

        return Group {
            EditableLines(
                title: "Svar",
                placeholder: "fx 592",
                lines: document.lines(rule + [.key("acceptedAnswers")]))

            Section {
                if answers.filter({ !$0.trimmed.isEmpty }).isEmpty {
                    Label("Opgaven kan ikke løses uden mindst ét svar.",
                          systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            } footer: {
                Text("Det første er facit. Skriv derunder de former, spilleren kan finde "
                     + "på at bruge — 5 9 2, 5-9-2, \"en gulerod\". Alle former tæller "
                     + "som rigtige.")
            }
        }
    }

    /// Registrerede fejlsvar med hver sin vejledning.
    ///
    /// De er det, der skiller en gåde fra en gætteleg: den, der har talt bølger
    /// og fået 529, skal have at vide, at rækkefølgen er forkert — ikke bare at
    /// svaret er det.
    @ViewBuilder
    private func nearMisses(_ path: [JSONStep]) -> some View {
        let missesPath = path + [.key("answerRule"), .key("nearMissResponses")]
        let misses = document.objects(at: missesPath)

        Section {
            ForEach(misses.indices, id: \.self) { position in
                VStack(alignment: .leading, spacing: 6) {
                    TextField(
                        "Fejlsvar",
                        text: document.text(missesPath + [.index(position), .key("answer")]))
                        .autocorrectionDisabled()
                    TextField(
                        "Vejledning",
                        text: document.text(missesPath + [.index(position), .key("feedback")]),
                        axis: .vertical)
                        .font(.footnote)
                }
            }
            .onDelete { offsets in
                for position in offsets.sorted(by: >) {
                    document.remove(at: position, in: missesPath)
                }
            }

            Button {
                document.append(["answer": "", "feedback": ""], to: missesPath)
            } label: {
                Label("Tilføj fejlsvar", systemImage: "plus.circle")
            }
        } header: {
            Text("Nær ved")
        } footer: {
            Text("Et registreret fejlsvar må aldrig være rigtigt. Skriv den vejledning, "
                 + "der bringer spilleren videre uden at give svaret.")
        }
    }

    // MARK: - Belønningen

    private var completion: some View {
        let path: [JSONStep] = .mission(index, .key("completion"))

        return Section {
            TextField("Overskrift", text: document.text(path + [.key("headline")]))
            TextField("Underoverskrift", text: document.text(path + [.key("subheadline")]))
            TextField("Etiket på beskeden", text: document.text(path + [.key("messageLabel")]))
            TextField("Beskeden", text: document.text(path + [.key("message")]), axis: .vertical)
                .lineLimit(3...)
            TextField("Den historiske forklaring",
                      text: document.text(path + [.key("historyFact")]), axis: .vertical)
                .lineLimit(3...)
        } header: {
            Text("Belønningen")
        } footer: {
            Text("Der overrækkes ingen genstande. Belønningen er teksten og det, "
                 + "spilleren nu ved om stedet.")
        }
    }

    // MARK: - Skift af svartype

    /// Skifter trinnets art og lægger de felter til, den nye art kræver.
    ///
    /// Felterne fra den gamle art fjernes **ikke**. Fortryder quizmasteren,
    /// står svarmulighederne der endnu — og et skift, der sletter en halv times
    /// arbejde uden at spørge, bliver aldrig fortrudt to gange.
    private func change(kind new: String, at path: [JSONStep], from old: String) {
        guard new != old else { return }
        document.setValue(new, at: path + [.key("kind")])

        switch new {
        case "singleChoice" where document.objects(at: path + [.key("options")]).count < 2:
            document.setValue(
                [["id": "valg-1", "label": ""], ["id": "valg-2", "label": ""]],
                at: path + [.key("options")])
        case "numericCode":
            if document.integer(at: path + [.key("length")]) == nil {
                document.setValue(3, at: path + [.key("length")])
            }
            // Cifferkoder sammenlignes som cifre; ellers ville "0592" og "592"
            // være det samme svar.
            document.setValue("digitsOnly", at: path + [.key("answerRule"), .key("kind")])
        default:
            break
        }
    }
}
