import BHContracts
import Foundation

/// Append-only hændelseslog som JSON Lines.
///
/// ## Hvorfor en log og ikke en database
///
/// Domænet *er* en ledger. Projektgrundlaget navngiver allerede `Attempt`,
/// `Completion` og `ScoreTransaction`, og forfatningens princip V kræver
/// idempotent synkronisering. Med klientgenererede UUID'er bliver sync senere
/// en `POST` af det ubekræftede suffiks, som serveren deduplikerer på `id`
/// (research.md R-005).
///
/// ## Om atomiciteten
///
/// Hver tilføjelse skriver hele filen til en midlertidig fil og udfører derefter
/// en atomisk erstatning. Det er O(n) pr. skrivning, hvilket er ligegyldigt ved
/// nogle hundrede hændelser, og det er den eneste form, der overlever at appen
/// bliver dræbt midt i en skrivning. En halv linje i en JSON Lines-fil er en
/// korrupt log, og en korrupt log er en tabt tur.
public actor EventStore {

    public enum StoreError: Error, Sendable {
        case notWritable(URL)
    }

    private let fileURL: URL
    private let fileManager: FileManager

    private var events: [GameEvent] = []
    private var knownIds: Set<UUID> = []
    private var isLoaded = false

    /// Standardplaceringen: `Application Support/BH/events-v1.jsonl`.
    ///
    /// Versionsnummeret står i filnavnet, så et fremtidigt formatskifte kan
    /// lade den gamle fil ligge urørt frem for at migrere destruktivt.
    public static func defaultFileURL(fileManager: FileManager = .default) throws -> URL {
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appending(path: "BH", directoryHint: .isDirectory)
            .appending(path: "events-v1.jsonl", directoryHint: .notDirectory)
    }

    public init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    // MARK: - Læsning

    /// Genindlæser loggen fra disk. Idempotent.
    public func load() throws {
        guard !isLoaded else { return }
        defer { isLoaded = true }

        guard fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return }

        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        let decoder = BHJSON.decoder

        for line in contents.split(separator: "\n", omittingEmptySubsequences: true) {
            guard let data = line.data(using: .utf8) else { continue }
            // En linje, der ikke kan læses, springes over frem for at vælte
            // hele loggen. Resten af turen er stadig gyldig.
            guard let event = try? decoder.decode(GameEvent.self, from: data) else { continue }
            guard knownIds.insert(event.id).inserted else { continue }
            events.append(event)
        }
        events.sort { $0.sequence < $1.sequence }
    }

    public func allEvents() throws -> [GameEvent] {
        try load()
        return events
    }

    /// Næste sekvensnummer. Monotont pr. enhed.
    public func nextSequence() throws -> Int {
        try load()
        return (events.last?.sequence ?? 0) + 1
    }

    // MARK: - Skrivning

    /// Tilføjer en hændelse.
    ///
    /// Er `id` set før, sker der intet — og der returneres `false`. Det er dét,
    /// der gør et gentaget kald ufarligt: ingen dubletter, ingen dobbeltpoint
    /// (FR-033, FR-023).
    @discardableResult
    public func append(_ event: GameEvent) throws -> Bool {
        try load()
        guard knownIds.insert(event.id).inserted else { return false }
        events.append(event)
        events.sort { $0.sequence < $1.sequence }
        try persist()
        return true
    }

    @discardableResult
    public func append(contentsOf newEvents: [GameEvent]) throws -> Int {
        try load()
        var added = 0
        for event in newEvents where knownIds.insert(event.id).inserted {
            events.append(event)
            added += 1
        }
        guard added > 0 else { return 0 }
        events.sort { $0.sequence < $1.sequence }
        try persist()
        return added
    }

    private func persist() throws {
        let encoder = BHJSON.encoder
        var body = Data()
        for event in events {
            body.append(try encoder.encode(event))
            body.append(0x0A)  // \n
        }

        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        // `.atomic` skriver til en midlertidig fil og udfører en atomisk
        // erstatning. Loggen er enten den gamle eller den nye, aldrig halv.
        try body.write(to: fileURL, options: [.atomic])
    }

    /// Kun til test og til "slet mine data".
    public func removeAll() throws {
        events.removeAll()
        knownIds.removeAll()
        isLoaded = true
        if fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
