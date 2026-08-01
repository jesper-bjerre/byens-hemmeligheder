import SwiftUI

/// Faneblad 3: opgavens detaljer — billede og tekst, som i et escape room
/// (FR-108).
///
/// Hedder `cards` i kontrakten, men "kort" betyder map på dansk, og fanebladet
/// stod ved siden af "Stedet". To ord for to helt forskellige ting.
///
/// ## Pile frem for træk
///
/// Rækkefølgen skiftes med to knapper. Træk-og-slip krævede, at listen stod i
/// redigeringstilstand hele tiden, og det fyldte hver eneste række med et
/// håndtag og en rød cirkel. Med tre detaljer er et træk desuden besværligere
/// end et tryk.
///
/// Billedet og teksten hører sammen og flytter sig sammen. Det er ét kort,
/// spilleren får at se, ikke to lister, der skal holdes i takt.
struct CardsTab: View {
    let document: PackDocument
    let missionIndex: Int

    /// Detaljen, der venter på et nyt billede. `nil` når arket er lukket.
    @State private var uploadingInto: Int?

    private var cardsPath: [JSONStep] { .mission(missionIndex, .key("cards")) }
    private var cards: [[String: Any]] { document.objects(at: cardsPath) }

    /// Stammen i filnavnene. Opgavens slug — billederne hører til opgaven.
    private var mediaStem: String {
        let slug = document.string(at: .mission(missionIndex, .key("slug")))
        return slug.isEmpty ? "opgave" : slug
    }

    var body: some View {
        Form {
            ForEach(Array(cards.enumerated()), id: \.element.cardId) { position, _ in
                card(at: position)
            }

            Section {
                Button {
                    addCard()
                } label: {
                    Label("Tilføj detalje", systemImage: "plus.circle")
                }
            } footer: {
                Text("Den første detalje bærer introduktionen.")
            }
        }
        .sheet(item: Binding(
            get: { uploadingInto.map(CardSlot.init(index:)) },
            set: { uploadingInto = $0?.index }
        )) { slot in
            MediaUploadSheet(document: document, stem: mediaStem) { mediaId in
                document.setValue(mediaId, at: cardsPath + [.index(slot.index), .key("mediaId")])
            }
        }
    }

    // MARK: - Én detalje

    @ViewBuilder
    private func card(at position: Int) -> some View {
        let mediaId = cards[position]["mediaId"] as? String
        let filename = document.filename(forMediaId: mediaId)

        Section {
            // Billedet er selv knappen. En knap ved siden af er ikke til at se,
            // hvilket billede hører til, når der er tre detaljer.
            Button {
                uploadingInto = position
            } label: {
                VStack(spacing: 8) {
                    if let filename {
                        MediaThumbnail(filename: filename)
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

            // Beskrivelsen læses højt for den, der ikke kan se billedet. Den
            // skrives ved oplægningen og hører til her, hvor billedet er.
            if let mediaId, let index = document.mediaAssetIndex(id: mediaId) {
                TextField(
                    "Beskrivelse af billedet",
                    text: document.text([.key("media"), .index(index), .key("altText")]),
                    axis: .vertical)
                    .font(.footnote)
                    .lineLimit(2...)
            }

            controls(at: position)
        } header: {
            Text("Detalje \(position + 1)")
        }
    }

    private func controls(at position: Int) -> some View {
        HStack(spacing: 24) {
            Button {
                move(position, to: position - 1)
            } label: {
                Label("Flyt op", systemImage: "arrow.up")
            }
            .disabled(position == 0)

            Button {
                move(position, to: position + 1)
            } label: {
                Label("Flyt ned", systemImage: "arrow.down")
            }
            .disabled(position == cards.count - 1)

            Spacer()

            Button(role: .destructive) {
                document.remove(at: position, in: cardsPath)
                document.renumber(cardsPath)
            } label: {
                Label("Fjern", systemImage: "trash")
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .font(.title3)
    }

    // MARK: - Handlinger

    /// Bytter to detaljer om — billede, tekst og beskrivelse under ét.
    private func move(_ from: Int, to destination: Int) {
        guard cards.indices.contains(from), cards.indices.contains(destination) else { return }
        // `toOffset` tælles i listen *før* flytningen, så et skridt ned er to
        // pladser frem. Den regel er nem at tage fejl af, og derfor står den her.
        document.move(
            fromOffsets: IndexSet(integer: from),
            toOffset: destination > from ? destination + 1 : destination,
            in: cardsPath)
        document.renumber(cardsPath)
    }

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
    /// Detaljens id, eller en stabil erstatning. `ForEach` skal kunne kende den
    /// samme detalje igen efter en ombytning — bruges pladsen som identitet,
    /// tegner SwiftUI én detaljes billede over en andens.
    var cardId: String { self["id"] as? String ?? String(describing: self["order"] ?? "?") }
}
