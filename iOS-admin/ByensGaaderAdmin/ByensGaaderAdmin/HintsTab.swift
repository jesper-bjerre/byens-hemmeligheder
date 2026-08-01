import SwiftUI

/// Faneblad 5: de tre hints (FR-109).
///
/// Antallet er tre — hverken to eller fire. Kontrakten kræver det, og
/// pointmodellen er regnet på det: 3, 4 og 5 procent i fradrag giver de 88
/// point, en fuldt hjulpet gennemførelse skal give. Derfor er der ingen knap
/// til at tilføje eller fjerne et.
struct HintsTab: View {
    let document: PackDocument
    let index: Int

    private var hintsPath: [JSONStep] { .mission(index, .key("hints")) }

    var body: some View {
        Form {
            let hints = document.objects(at: hintsPath)

            if hints.count != 3 {
                Section {
                    Label("Opgaven har \(hints.count) hints, ikke tre. Pakken er ugyldig.",
                          systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            ForEach(hints.indices, id: \.self) { position in
                hint(at: position)
            }
        }
    }

    @ViewBuilder
    private func hint(at position: Int) -> some View {
        let path = hintsPath + [.index(position)]

        Section {
            // Kun ét felt. Overskriften vises for spilleren som "Hint 1 · Hvor",
            // men den er den samme for alle opgaver — så den skrives af sig
            // selv efter hintets nummer og er ikke noget, nogen skal opfinde.
            TextField("Hint", text: document.text(path + [.key("text")]), axis: .vertical)
                .lineLimit(3...)

            Stepper(
                "Fradrag: \(document.integer(at: path + [.key("penaltyPercent")]) ?? 0) %",
                value: document.integer(path + [.key("penaltyPercent")], default: 0),
                in: 0...100)
        } header: {
            Text("Hint \(position + 1) · \(document.string(at: path + [.key("title")]))")
        } footer: {
            Text(Self.purpose(position))
        }
    }

    /// Hvad hvert hint er til for. Uden det bliver alle tre til den samme
    /// halve løsning, og så er de to første kun spild af point.
    private static func purpose(_ position: Int) -> String {
        switch position {
        case 0: "Peger på, hvor spilleren skal kigge — ikke på hvad hen skal se."
        case 1: "Forklarer fremgangsmåden. Stadig uden tal og uden facit."
        default: "Næsten løsningen. Efter dette skal opgaven kunne løses."
        }
    }
}
