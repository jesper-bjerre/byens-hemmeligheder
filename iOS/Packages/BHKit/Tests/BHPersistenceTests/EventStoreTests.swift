import BHContracts
import Foundation
import Testing

@testable import BHPersistence

/// Hændelsesloggen på disken.
///
/// Skriver til en midlertidig mappe pr. test, så kørslerne ikke deler tilstand
/// og kan køre parallelt.
@Suite("Hændelseslog")
struct EventStoreTests {

    static let epoch = Date(timeIntervalSince1970: 1_800_000_000)

    func makeStore() -> (EventStore, URL) {
        let directory = URL.temporaryDirectory
            .appending(path: "bh-tests-\(UUID().uuidString)", directoryHint: .isDirectory)
        let url = directory.appending(path: "events-v1.jsonl")
        return (EventStore(fileURL: url), directory)
    }

    func event(sequence: Int, id: UUID = UUID()) -> GameEvent {
        GameEvent(
            id: id,
            sequence: sequence,
            occurredAt: Self.epoch.addingTimeInterval(Double(sequence)),
            contentVersion: "2026-07-25.1",
            kind: .known(.stepViewed),
            payload: GameEventPayload(missionId: "mission.test", stepId: "step.\(sequence)")
        )
    }

    @Test("En tom log læses uden fejl")
    func emptyStoreLoads() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        #expect(try await store.allEvents().isEmpty)
        #expect(try await store.nextSequence() == 1)
    }

    @Test("Hændelser overlever en genindlæsning")
    func eventsSurviveReload() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        try await store.append(event(sequence: 1))
        try await store.append(event(sequence: 2))

        // Ny instans mod samme fil — som efter en appgenstart.
        let url = directory.appending(path: "events-v1.jsonl")
        let reopened = EventStore(fileURL: url)
        let events = try await reopened.allEvents()

        #expect(events.count == 2)
        #expect(events.map(\.sequence) == [1, 2])
        #expect(try await reopened.nextSequence() == 3)
    }

    /// FR-033. Den egenskab, en fremtidig synkronisering hviler på.
    @Test("Samme hændelses-id tilføjes aldrig to gange")
    func appendIsIdempotent() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let id = UUID()
        let first = try await store.append(event(sequence: 1, id: id))
        let second = try await store.append(event(sequence: 2, id: id))

        #expect(first == true)
        #expect(second == false, "En kendt id skal afvises stille")
        #expect(try await store.allEvents().count == 1)
    }

    @Test("Loggen skrives som JSON Lines — én hændelse pr. linje")
    func fileIsJSONLines() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        try await store.append(contentsOf: [event(sequence: 1), event(sequence: 2)])

        let url = directory.appending(path: "events-v1.jsonl")
        let text = try String(contentsOf: url, encoding: .utf8)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)

        #expect(lines.count == 2)
        for line in lines {
            #expect(line.hasPrefix("{") && line.hasSuffix("}"), "Hver linje skal være ét komplet JSON-objekt")
        }
    }

    @Test("Hændelser sorteres efter sekvensnummer")
    func eventsAreSortedBySequence() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        try await store.append(event(sequence: 3))
        try await store.append(event(sequence: 1))
        try await store.append(event(sequence: 2))

        #expect(try await store.allEvents().map(\.sequence) == [1, 2, 3])
    }

    /// En beskadiget linje må koste sin egen hændelse — ikke hele turen.
    @Test("En ulæselig linje springes over uden at vælte loggen")
    func corruptLineIsSkipped() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        try await store.append(event(sequence: 1))

        let url = directory.appending(path: "events-v1.jsonl")
        var text = try String(contentsOf: url, encoding: .utf8)
        text += "{ dette er ikke gyldig JSON\n"
        try text.write(to: url, atomically: true, encoding: .utf8)

        let reopened = EventStore(fileURL: url)
        #expect(try await reopened.allEvents().count == 1)
    }

    @Test("Sletning fjerner både hukommelse og fil")
    func removeAllClearsEverything() async throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        try await store.append(event(sequence: 1))
        try await store.removeAll()

        #expect(try await store.allEvents().isEmpty)
        let url = directory.appending(path: "events-v1.jsonl")
        #expect(FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) == false)
    }
}
