import SwiftUI

/// Felter i editoren bindes direkte til en sti i pakken.
///
/// Alternativet var en `@State` pr. felt og en gemmeknap, der skrev dem alle
/// tilbage. Fem faneblade med halvfjerds felter ville så have halvfjerds steder,
/// hvor et felt kunne blive glemt i tilbageskrivningen — og en glemt
/// tilbageskrivning ser ud som om, rettelsen aldrig blev lavet.
extension PackDocument {

    func text(_ path: [JSONStep]) -> Binding<String> {
        Binding(
            get: { self.string(at: path) },
            set: { self.setValue($0, at: path) }
        )
    }

    /// Som ``text(_:)``, men en tom streng bliver til JSON-null.
    ///
    /// Kontrakten skelner: `heroMediaId: null` betyder "intet billede", mens
    /// `""` er et id, der ikke resolver. Spillerappen viser en tom plads for
    /// det første og bryder på det andet.
    func nullableText(_ path: [JSONStep]) -> Binding<String> {
        Binding(
            get: { self.string(at: path) },
            set: { self.setValue($0.isEmpty ? NSNull() : $0, at: path) }
        )
    }

    func integer(_ path: [JSONStep], default fallback: Int) -> Binding<Int> {
        Binding(
            get: { self.integer(at: path) ?? fallback },
            set: { self.setValue($0, at: path) }
        )
    }

    func flag(_ path: [JSONStep]) -> Binding<Bool> {
        Binding(
            get: { self.bool(at: path) },
            set: { self.setValue($0, at: path) }
        )
    }

    /// Et tal, der må mangle — koordinater og radier står som `null`, indtil
    /// nogen har været på stedet.
    func decimalText(_ path: [JSONStep]) -> Binding<String> {
        Binding(
            get: {
                guard let number = self.number(at: path) else { return "" }
                return number == number.rounded()
                    ? String(Int(number))
                    : String(format: "%.6f", number)
            },
            set: { raw in
                let cleaned = raw
                    .replacingOccurrences(of: ",", with: ".")
                    .trimmingCharacters(in: .whitespaces)
                if cleaned.isEmpty {
                    self.setValue(NSNull(), at: path)
                } else if let value = Double(cleaned) {
                    self.setValue(value, at: path)
                }
                // Halvskrevne tal — "55." — kasseres og efterlader det gemte
                // som det var. Feltet viser dem stadig, mens der tastes.
            }
        )
    }

    /// En liste af fritekstlinjer: accepterede svar, tags, kilder.
    func lines(_ path: [JSONStep]) -> Binding<[String]> {
        Binding(
            get: { self.strings(at: path) },
            set: { self.setValue($0, at: path) }
        )
    }

    /// En værdi fra en fast liste. Står der noget uventet i pakken, beholdes
    /// det, indtil quizmasteren selv vælger om.
    func choice(_ path: [JSONStep], fallback: String) -> Binding<String> {
        Binding(
            get: {
                let raw = self.string(at: path)
                return raw.isEmpty ? fallback : raw
            },
            set: { self.setValue($0, at: path) }
        )
    }
}

/// Redigerbar liste af enkeltlinjer.
///
/// Bruges til accepterede svar, tags og svarmuligheder — alle steder, hvor
/// antallet er quizmasterens valg og ikke kontraktens.
struct EditableLines: View {
    let title: String
    let placeholder: String
    @Binding var lines: [String]

    var body: some View {
        Section(title) {
            ForEach(lines.indices, id: \.self) { index in
                TextField(placeholder, text: binding(at: index))
            }
            .onDelete { lines.remove(atOffsets: $0) }
            .onMove { lines.move(fromOffsets: $0, toOffset: $1) }

            Button {
                lines.append("")
            } label: {
                Label("Tilføj", systemImage: "plus.circle")
            }
        }
    }

    private func binding(at index: Int) -> Binding<String> {
        Binding(
            get: { lines.indices.contains(index) ? lines[index] : "" },
            set: { new in
                guard lines.indices.contains(index) else { return }
                lines[index] = new
            }
        )
    }
}
