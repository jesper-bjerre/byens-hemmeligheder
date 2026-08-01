import SwiftUI

/// Faneblad 3: opgavens detaljer — billede og lidt tekst, som i et escape room
/// (FR-108).
///
/// Hedder `cards` i kontrakten, men "kort" betyder map på dansk, og fanebladet
/// stod ved siden af "Stedet". To ord for to helt forskellige ting.
struct CardsTab: View {
    let document: PackDocument
    let missionIndex: Int

    /// Kortet, der venter på et nyt billede. `nil` når arket er lukket.
    @State private var uploadingInto: Int?

    private var cardsPath: [JSONStep] { .mission(missionIndex, .key("cards")) }
    private var cards: [[String: Any]] { document.objects(at: cardsPath) }

    /// Stammen i filnavnene.
    ///
    /// Opgavens slug og ikke stedets navn. Navnet ligger under Avanceret og
    /// står som "Nyt sted" på en frisk opgave — så ville hvert eneste billede,
    /// nogen lagde op, hedde `nyt-sted-000`, og det andet blive afvist med
    /// `409`.
    private var mediaStem: String {
        let slug = document.string(at: .mission(missionIndex, .key("slug")))
        return slug.isEmpty ? "opgave" : slug
    }

    var body: some View {
        List {
            ForEach(Array(cards.enumerated()), id: \.element.cardId) { position, _ in
                card(at: position)
            }
            .onDelete { offsets in
                for position in offsets.sorted(by: >) {
                    document.remove(at: position, in: cardsPath)
                }
                document.renumber(cardsPath)
            }
            .onMove { source, destination in
                document.move(fromOffsets: source, toOffset: destination, in: cardsPath)
                document.renumber(cardsPath)
            }

            Section {
                Button {
                    addCard()
                } label: {
                    Label("Tilføj detalje", systemImage: "plus.circle")
                }
            } footer: {
                Text("Den første detalje bærer introduktionen. Træk i kanten for at bytte "
                     + "om, og stryg til venstre for at fjerne en.")
            }
        }
        .environment(\.editMode, .constant(.active))
        .sheet(item: Binding(
            get: { uploadingInto.map(CardSlot.init(index:)) },
            set: { uploadingInto = $0?.index }
        )) { slot in
            MediaUploadSheet(document: document, stem: mediaStem) { mediaId in
                document.setValue(mediaId, at: cardsPath + [.index(slot.index), .key("mediaId")])
            }
        }
    }

    // MARK: - Ét kort

    /// Billedet og dets knap er ét element.
    ///
    /// Knappen sad tidligere som sin egen række under teksten. Når kortene
    /// flyttes rundt, er det ikke længere til at se, hvilket billede den hører
    /// til — og et billede lagt op på det forkerte kort kan ikke fjernes igen,
    /// kun erstattes. Nu trykker man på selve billedet.
    @ViewBuilder
    private func card(at position: Int) -> some View {
        let mediaId = cards[position]["mediaId"] as? String
        let filename = document.filename(forMediaId: mediaId)

        Section("Detalje \(position + 1)") {
            Button {
                uploadingInto = position
            } label: {
                VStack(spacing: 8) {
                    if let filename {
                        MediaThumbnail(filename: filename)
                    } else if let mediaId {
                        Label("Billedet \(mediaId) findes ikke i pakken",
                              systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, minHeight: 120)
                    } else {
                        Image("Icon-Photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 96)
                            .frame(maxWidth: .infinity)
                    }

                    Label(filename == nil ? "Vælg billede" : "Erstat billedet",
                          systemImage: "photo.badge.plus")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)

            TextField("Tekst", text: document.text(cardsPath + [.index(position), .key("text")]),
                      axis: .vertical)
                .lineLimit(3...)
        }
    }

    // MARK: - Handlinger

    private func addCard() {
        let slug = document.string(at: .mission(missionIndex, .key("slug")))
        let order = cards.count + 1
        document.append([
            "id": "card.\(slug).\(order)",
            "order": order,
            "mediaId": NSNull(),
            "text": "",
        ], to: cardsPath)
    }

}

/// `sheet(item:)` skal have noget identificerbart. Et `Int` er det ikke.
private struct CardSlot: Identifiable {
    let index: Int
    var id: Int { index }
}

extension Dictionary where Key == String, Value == Any {
    /// Kortets id, eller en stabil erstatning. `ForEach` skal kunne kende det
    /// samme kort igen efter en omrokering — bruges pladsen som identitet,
    /// tegner SwiftUI ét korts billede over et andets.
    var cardId: String { self["id"] as? String ?? String(describing: self["order"] ?? "?") }
}
