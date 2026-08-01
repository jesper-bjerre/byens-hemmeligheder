import Foundation

/// Quizmasterens uafsluttede rettelser, skrevet til telefonen.
///
/// ## Hvorfor
///
/// Slår en gemning fejl i felten — og det gør den, for der er hverken dækning
/// ved Bølgen eller på Tirsbæk Bakker — ligger dokumentet kun i hukommelsen.
/// iOS lukker en app i baggrunden, når kameraet har brugt hukommelse, og
/// kameraet er præcis dét, quizmasteren lige har brugt. En halv times arbejde
/// er så væk uden en fejlmeddelelse.
///
/// ## Hvorfor basis gemmes med
///
/// Kladden er ikke bare "pakken som den ser ud nu". Den er en pakke **plus** de
/// rettelser, der er lagt oven på en bestemt udgave. Uden at vide hvilken, kan
/// fletningen ikke se, hvad quizmasteren selv har rørt — se ``PackMerge``.
enum DraftStore {

    private struct Draft: Codable {
        let root: Data
        let base: Data
        let etag: String?
        let savedAt: Date
    }

    private static var url: URL {
        let folder = URL.applicationSupportDirectory
            .appending(path: "ByensGaaderAdmin", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: "kladde.json")
    }

    // MARK: - Skrivning

    /// Skriver kladden. Gør intet, hvis der ikke er noget at gemme.
    static func save(_ document: PackDocument) {
        guard document.hasUnsavedChanges else { clear(); return }

        do {
            let draft = Draft(
                root: try JSONSerialization.data(withJSONObject: document.root),
                base: try JSONSerialization.data(withJSONObject: document.base),
                etag: document.etag,
                savedAt: .now)
            try JSONEncoder().encode(draft).write(to: url, options: [.atomic])
        } catch {
            // En kladde, der ikke kan skrives, må ikke vælte redigeringen. Det
            // værste, der sker, er, at vi står, hvor vi stod før den fandtes.
        }
    }

    static func clear() {
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Læsning

    struct Restored {
        let document: PackDocument
        let savedAt: Date
    }

    /// Kladden, hvis der er en, og hvis den stadig kan læses.
    static func restore() -> Restored? {
        guard let data = try? Data(contentsOf: url),
              let draft = try? JSONDecoder().decode(Draft.self, from: data),
              let root = try? JSONSerialization.jsonObject(with: draft.root) as? [String: Any],
              let base = try? JSONSerialization.jsonObject(with: draft.base) as? [String: Any]
        else {
            // Ulæselig kladde ryddes. Den kan ikke bruges, og den ville blive
            // ved med at spørge ved hver start.
            clear()
            return nil
        }

        return Restored(
            document: PackDocument(root: root, base: base, etag: draft.etag),
            savedAt: draft.savedAt)
    }
}

/// Skriver kladden lidt efter den seneste tastetryk.
///
/// Hele pakken er over hundrede kilobyte. At skrive den ved hvert bogstav i et
/// tekstfelt ville få tastaturet til at hakke; at vente til appen lukkes virker
/// ikke, for iOS lukker den uden at spørge.
@Observable
final class DraftWriter {
    private var pending: Task<Void, Never>?

    /// Bindes til dokumentets ``PackDocument/onChange``.
    func schedule(_ document: PackDocument) {
        pending?.cancel()
        pending = Task { [weak document] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled, let document else { return }
            DraftStore.save(document)
        }
    }

    /// Skriver med det samme. Bruges, når appen går i baggrunden — der er ikke
    /// to sekunder til overs.
    func flush(_ document: PackDocument?) {
        pending?.cancel()
        guard let document else { return }
        DraftStore.save(document)
    }
}
