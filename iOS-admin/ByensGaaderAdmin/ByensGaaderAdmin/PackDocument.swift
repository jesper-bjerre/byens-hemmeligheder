import Foundation

/// Ét skridt ned gennem indholdspakkens JSON.
///
/// Findes, så en rettelse kan skrives som en sti —
/// `missions[3].completion.headline` — i stedet for som endnu en metode pr.
/// felt. Uden den ville denne fil rumme halvtreds næsten ens funktioner, og
/// hvert nyt felt i kontrakten ville kræve en til.
enum JSONStep: Sendable, Hashable {
    case key(String)
    case index(Int)
}

extension Array where Element == JSONStep {
    static func mission(_ index: Int, _ rest: JSONStep...) -> [JSONStep] {
        [.key("missions"), .index(index)] + rest
    }

    static func location(_ index: Int, _ rest: JSONStep...) -> [JSONStep] {
        [.key("locations"), .index(index)] + rest
    }

}

/// Indholdspakken som redigerbar JSON.
///
/// Holder hele dokumentet og retter enkeltfelter i det. Felter, appen ikke
/// kender, røres aldrig og overlever derfor en gemning uændret — det er hele
/// pointen med ikke at modellere kontrakten her.
@Observable
final class PackDocument {

    private(set) var root: [String: Any]
    /// Kun bevaret for kladder fra den gamle hel-pakke-klient og dens tests.
    /// Nye gemninger bruger ét revisionsnummer pr. objekt.
    private(set) var etag: String?
    private(set) var revisions: ObjectRevisions

    /// Pakken, som den så ud, da den blev hentet.
    ///
    /// Findes for fletningen: uden den kan man ikke se forskel på "jeg har
    /// ændret dette felt" og "jeg har ikke rørt det", og en gemning ville
    /// skrive alle urørte felter tilbage oven i en andens arbejde.
    private(set) var base: [String: Any]

    /// Sandt, når der er noget, serveren ikke har set endnu.
    var hasUnsavedChanges: Bool { !NSDictionary(dictionary: root).isEqual(to: base) }

    /// Kaldes efter hver ændring, så kladden kan skrives til disken.
    var onChange: (() -> Void)?

    init(data: Data, etag: String?) throws {
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AdminError.message("Pakken er ikke et JSON-objekt.")
        }
        self.root = object
        self.base = object
        self.etag = etag
        self.revisions = .empty
    }

    /// Genskaber en kladde. Basis er den udgave, kladden blev bygget oven på —
    /// ikke kladden selv, ellers ser alt ud som om det aldrig blev rettet.
    init(
        root: [String: Any],
        base: [String: Any],
        etag: String? = nil,
        revisions: ObjectRevisions = .empty
    ) {
        self.root = root
        self.base = base
        self.etag = etag
        self.revisions = revisions
    }

    // MARK: - Rå adgang

    func value(at path: [JSONStep]) -> Any? {
        Self.read(root, path[...])
    }

    /// Skriver ét felt. `nil` fjerner nøglen; skal feltet stå som JSON-null,
    /// sendes `NSNull()`.
    func setValue(_ value: Any?, at path: [JSONStep]) {
        guard !path.isEmpty,
              let updated = Self.write(root, path[...], value) as? [String: Any]
        else { return }
        root = updated
        onChange?()
    }

    private static func read(_ container: Any?, _ path: ArraySlice<JSONStep>) -> Any? {
        guard let first = path.first else { return container }
        switch first {
        case .key(let key):
            guard let object = container as? [String: Any] else { return nil }
            return read(object[key], path.dropFirst())
        case .index(let index):
            guard let array = container as? [Any], array.indices.contains(index) else { return nil }
            return read(array[index], path.dropFirst())
        }
    }

    private static func write(
        _ container: Any?, _ path: ArraySlice<JSONStep>, _ value: Any?
    ) -> Any? {
        guard let first = path.first else { return value }

        switch first {
        case .key(let key):
            var object = container as? [String: Any] ?? [:]
            if path.count == 1, value == nil {
                object.removeValue(forKey: key)
            } else {
                object[key] = write(object[key], path.dropFirst(), value)
            }
            return object

        case .index(let index):
            // En manglende plads i en liste oprettes ikke. Ville den det, kunne
            // en tastefejl i et indeks lave huller i pakken uden at nogen så det.
            guard var array = container as? [Any], array.indices.contains(index),
                  let child = write(array[index], path.dropFirst(), value)
            else { return container }
            array[index] = child
            return array
        }
    }

    // MARK: - Typet adgang

    func string(at path: [JSONStep]) -> String { value(at: path) as? String ?? "" }
    func number(at path: [JSONStep]) -> Double? { (value(at: path) as? NSNumber)?.doubleValue }
    func integer(at path: [JSONStep]) -> Int? { (value(at: path) as? NSNumber)?.intValue }
    func bool(at path: [JSONStep]) -> Bool { (value(at: path) as? NSNumber)?.boolValue ?? false }
    func strings(at path: [JSONStep]) -> [String] { value(at: path) as? [String] ?? [] }
    func objects(at path: [JSONStep]) -> [[String: Any]] { value(at: path) as? [[String: Any]] ?? [] }

    // MARK: - Lister

    func append(_ element: Any, to path: [JSONStep]) {
        var array = value(at: path) as? [Any] ?? []
        array.append(element)
        setValue(array, at: path)
    }

    func remove(at index: Int, in path: [JSONStep]) {
        guard var array = value(at: path) as? [Any], array.indices.contains(index) else { return }
        array.remove(at: index)
        setValue(array, at: path)
    }

    /// Flytter elementer. Skrevet ud i stedet for `Array.move(fromOffsets:)`,
    /// som kommer fra SwiftUI — denne fil kender kun JSON.
    func move(fromOffsets source: IndexSet, toOffset destination: Int, in path: [JSONStep]) {
        guard var array = value(at: path) as? [Any] else { return }

        let moving = source.filter(array.indices.contains).map { array[$0] }
        guard !moving.isEmpty else { return }

        for index in source.sorted(by: >) where array.indices.contains(index) {
            array.remove(at: index)
        }

        // Målet er talt i den gamle liste. Hvert fjernet element før det
        // rykker indsættelsespunktet et skridt tilbage.
        let insertion = destination - source.count(where: { $0 < destination })
        array.insert(contentsOf: moving, at: Swift.min(Swift.max(insertion, 0), array.count))

        setValue(array, at: path)
    }

    /// Skriver `order` igen efter en omrokering, så feltet og rækkefølgen på
    /// disken siger det samme. Gør de ikke det, bestemmer `order` — og så
    /// flytter kortene sig tilbage næste gang pakken hentes.
    func renumber(_ path: [JSONStep]) {
        guard var array = value(at: path) as? [[String: Any]] else { return }
        for index in array.indices {
            array[index]["order"] = index + 1
        }
        setValue(array, at: path)
    }

    // MARK: - Pakken som helhed

    var contentVersion: String { string(at: [.key("contentVersion")]) }

    var missions: [MissionSummary] {
        objects(at: [.key("missions")]).enumerated().map { index, mission in
            MissionSummary(
                index: index,
                id: mission["id"] as? String ?? "?",
                title: mission["title"] as? String ?? "Uden titel",
                status: mission["status"] as? String ?? "?",
                cardCount: (mission["cards"] as? [[String: Any]])?.count ?? 0,
                postalCode: postalCode(forLocation: mission["locationId"] as? String)
            )
        }
    }

    private func postalCode(forLocation locationId: String?) -> String? {
        guard let locationId else { return nil }
        return objects(at: [.key("locations")])
            .first { $0["id"] as? String == locationId }?["postalCode"] as? String
    }

    /// Stedet, en opgave peger på. `nil` hvis `locationId` ikke resolver — det
    /// sker for en pakke, der er rettet i hånden, og editoren skal kunne åbne
    /// opgaven alligevel.
    func locationIndex(forMissionAt index: Int) -> Int? {
        let locationId = string(at: .mission(index, .key("locationId")))
        return objects(at: [.key("locations")])
            .firstIndex { $0["id"] as? String == locationId }
    }

    // MARK: - Medier

    func mediaAsset(id: String?) -> [String: Any]? {
        guard let id else { return nil }
        return objects(at: [.key("media")]).first { $0["id"] as? String == id }
    }

    /// Pladsen i `media`, så beskrivelsen kan rettes gennem en binding.
    func mediaAssetIndex(id: String?) -> Int? {
        guard let id else { return nil }
        return objects(at: [.key("media")]).firstIndex { $0["id"] as? String == id }
    }

    func filename(forMediaId id: String?) -> String? {
        mediaAsset(id: id)?["filename"] as? String
    }

    /// Registrerer et medie, der allerede er lagt op på serveren.
    func addMediaAsset(_ asset: [String: Any]) {
        append(asset, to: [.key("media")])
    }

    /// Det næste ledige nummer i `<stamme>-000`-mønsteret.
    ///
    /// Medier overskrives aldrig — serveren svarer `409` på et kendt filnavn,
    /// fordi billeder sendes med et års cache. Nummeret **er** versionen, så
    /// det skal tælles op og aldrig genbruges.
    func nextMediaNumber(stem: String) -> Int {
        let used = objects(at: [.key("media")]).compactMap { asset -> Int? in
            guard let filename = asset["filename"] as? String,
                  filename.hasPrefix(stem + "-")
            else { return nil }
            let rest = filename.dropFirst(stem.count + 1).prefix(while: \.isNumber)
            return Int(rest)
        }
        return (used.max() ?? -1) + 1
    }

    /// Fjerner en opgave og det sted, kun den brugte.
    ///
    /// Stedet ryger med, når ingen anden opgave peger på det. Blev det stående,
    /// ville pakken samle steder op, ingen kan se og ingen kan slette — og
    /// stedet er det eneste, der bærer koordinatet.
    func deleteMission(at index: Int) {
        let missions = objects(at: [.key("missions")])
        guard missions.indices.contains(index) else { return }

        let locationId = missions[index]["locationId"] as? String
        remove(at: index, in: [.key("missions")])

        guard let locationId,
              !objects(at: [.key("missions")]).contains(where: {
                  $0["locationId"] as? String == locationId
              }),
              let position = objects(at: [.key("locations")])
                  .firstIndex(where: { $0["id"] as? String == locationId })
        else { return }

        remove(at: position, in: [.key("locations")])
    }

    // MARK: - Gemning

    /// De enkelte objekter, der faktisk er rettet siden indlæsningen.
    /// Stedet ligger sammen med sin opgave, så en koordinatrettelse udløser
    /// samme mission-PUT som en titelrettelse.
    func authoringChanges() throws -> AuthoringChanges {
        let currentMissions = Self.byID(objects(at: [.key("missions")]))
        let baseMissions = Self.byID(Self.objects(in: base, key: "missions"))
        let currentLocations = Self.byID(objects(at: [.key("locations")]))
        let baseLocations = Self.byID(Self.objects(in: base, key: "locations"))
        let schemaVersion = root["schemaVersion"] ?? "1.0.0"
        let baseSchemaVersion = base["schemaVersion"] ?? schemaVersion

        var missionUpdates: [AuthoringObject] = []
        for mission in objects(at: [.key("missions")]) {
            let id = try Self.requiredID(mission)
            let locationID = mission["locationId"] as? String ?? ""
            guard let location = currentLocations[locationID] else {
                throw AdminError.message("Opgaven \(id) mangler sit sted.")
            }
            let aggregate: [String: Any] = [
                "schemaVersion": schemaVersion,
                "mission": mission,
                "location": location,
            ]
            let oldMission = baseMissions[id]
            let oldLocationID = oldMission?["locationId"] as? String ?? ""
            let oldAggregate: [String: Any]? = oldMission.flatMap { value in
                guard let oldLocation = baseLocations[oldLocationID] else { return nil }
                return [
                    "schemaVersion": baseSchemaVersion,
                    "mission": value,
                    "location": oldLocation,
                ]
            }
            if oldAggregate == nil || !Self.equal(aggregate, oldAggregate!) {
                missionUpdates.append(AuthoringObject(id: id, json: aggregate))
            }
        }

        return AuthoringChanges(
            missions: .init(
                updates: missionUpdates,
                deletions: baseMissions.keys.filter { currentMissions[$0] == nil }.sorted()),
            media: Self.catalogChanges(current: objects(at: [.key("media")]),
                                       base: Self.objects(in: base, key: "media")),
            sources: Self.catalogChanges(current: objects(at: [.key("sources")]),
                                         base: Self.objects(in: base, key: "sources")))
    }

    func serialised() throws -> Data {
        // Sorterede nøgler, så to gemninger af det samme giver den samme fil —
        // ellers ændrer ETag'en sig, uden at noget er ændret.
        try JSONSerialization.data(
            withJSONObject: root,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
    }

    /// Efter en gemning er serverens udgave og vores den samme.
    func adopt(etag: String?) {
        self.etag = etag
        base = root
    }

    /// Efter objektvise gemninger er både basis og alle revisionsnumre nye.
    func adopt(revisions: ObjectRevisions, contentVersion: String?) {
        self.revisions = revisions
        if let contentVersion { root["contentVersion"] = contentVersion }
        etag = nil
        base = root
    }

    /// Lægger vores rettelser oven på serverens udgave efter en `412`.
    ///
    /// - Returns: felterne, hvor begge havde rettet forskelligt. Vores værdi
    ///   står, men quizmasteren skal se listen.
    @discardableResult
    func rebase(onto server: PackDocument) -> [String] {
        let result = PackMerge.merge(base: base, ours: root, theirs: server.root)
        root = result.root
        base = server.root
        etag = server.etag
        revisions = server.revisions
        onChange?()
        return result.conflicts
    }

    private static func objects(in root: [String: Any], key: String) -> [[String: Any]] {
        root[key] as? [[String: Any]] ?? []
    }

    private static func byID(_ objects: [[String: Any]]) -> [String: [String: Any]] {
        Dictionary(uniqueKeysWithValues: objects.compactMap { object in
            (object["id"] as? String).map { ($0, object) }
        })
    }

    private static func requiredID(_ object: [String: Any]) throws -> String {
        guard let id = object["id"] as? String, !id.isEmpty else {
            throw AdminError.message("Et redaktionelt objekt mangler id.")
        }
        return id
    }

    private static func catalogChanges(
        current: [[String: Any]], base: [[String: Any]]
    ) -> AuthoringCollectionChanges {
        let currentByID = byID(current)
        let baseByID = byID(base)
        let updates = current.compactMap { object -> AuthoringObject? in
            guard let id = object["id"] as? String,
                  baseByID[id] == nil || !equal(object, baseByID[id]!)
            else { return nil }
            return AuthoringObject(id: id, json: object)
        }
        return .init(
            updates: updates,
            deletions: baseByID.keys.filter { currentByID[$0] == nil }.sorted())
    }

    private static func equal(_ left: [String: Any], _ right: [String: Any]) -> Bool {
        NSDictionary(dictionary: left).isEqual(to: right)
    }
}

struct ObjectRevisions: Codable, Equatable {
    var missions: [String: String]
    var media: [String: String]
    var sources: [String: String]

    static let empty = ObjectRevisions(missions: [:], media: [:], sources: [:])
}

struct AuthoringObject {
    let id: String
    let json: [String: Any]
}

struct AuthoringCollectionChanges {
    let updates: [AuthoringObject]
    let deletions: [String]
}

struct AuthoringChanges {
    let missions: AuthoringCollectionChanges
    let media: AuthoringCollectionChanges
    let sources: AuthoringCollectionChanges
}

struct MissionSummary: Identifiable, Hashable {
    let index: Int
    let id: String
    let title: String
    let status: String
    let cardCount: Int
    /// Stedets postnummer. By og landsdel slås op i ``Postnumre``.
    let postalCode: String?
}
