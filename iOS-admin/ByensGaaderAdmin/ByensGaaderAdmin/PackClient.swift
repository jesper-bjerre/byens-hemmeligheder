import Foundation

/// Taler med backenden om redaktionelle objekter og deres medier.
///
/// ## Pakken behandles som JSON, ikke som modeller
///
/// Klienten afkoder **ikke** kontrakten. Den henter bytes, lader
/// ``PackDocument`` rette i dem og sender dem tilbage.
///
/// Det er et bevidst valg. Modellerede admin-appen kontrakten, ville den tabe
/// ethvert felt, den ikke kendte, i det øjeblik den gemte — og spillerappens
/// kontrakt udvides oftere end denne app opdateres. Serveren gør det samme af
/// samme grund.
struct PackClient {

    /// Egen session frem for `URLSession.shared`.
    ///
    /// Standardens 60 sekunder er for længe at stirre på en spinner ved
    /// Bølgen og for lidt til at lægge et billede op over mobilnet. De to tal
    /// skal være forskellige: et kald, der ikke svarer på tyve sekunder,
    /// svarer ikke — men en overførsel, der er i gang, skal have lov at blive
    /// færdig.
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 180
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()

    private var base: URL { AdminConfiguration.backendURL }

    /// Værten, quizmasteren taler med. Vises i appen, så ingen retter i det
    /// forkerte indhold uden at opdage det.
    var host: String { base.host() ?? base.absoluteString }
    private var locale: String { AdminConfiguration.locale }

    private var packURL: URL {
        base.appending(path: "content").appending(path: locale).appending(path: "pack")
    }

    private var authoringURL: URL {
        base.appending(path: "authoring").appending(path: "content").appending(path: locale)
    }

    private var mediaURL: URL {
        base.appending(path: "content").appending(path: locale).appending(path: "media")
    }

    private var auditURL: URL {
        base.appending(path: "content").appending(path: locale).appending(path: "audit")
    }

    /// Adressen på et billede, så det kan vises direkte i editoren.
    func url(forMediaNamed filename: String) -> URL {
        mediaURL.appending(path: filename)
    }

    // MARK: - Redaktionelt indhold

    func load() async throws -> PackDocument {
        let (packData, _) = try await get(packURL)
        guard var root = try JSONSerialization.jsonObject(with: packData) as? [String: Any]
        else { throw AdminError.message("Pakken er ikke et JSON-objekt.") }

        let (indexData, _) = try await get(authoringURL.appending(path: "missions"))
        guard let index = try JSONSerialization.jsonObject(with: indexData) as? [String: Any],
              let summaries = index["missions"] as? [[String: Any]]
        else { throw AdminError.message("Opgaveindekset kunne ikke læses.") }

        var missions: [[String: Any]] = []
        var locations: [[String: Any]] = []
        var revisions = ObjectRevisions.empty
        for summary in summaries {
            guard let id = summary["id"] as? String else { continue }
            let (data, http) = try await get(
                authoringURL.appending(path: "missions").appending(path: id))
            guard let aggregate = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mission = aggregate["mission"] as? [String: Any],
                  let location = aggregate["location"] as? [String: Any]
            else { throw AdminError.message("Opgaven \(id) kunne ikke læses.") }
            missions.append(mission)
            locations.append(location)
            if let etag = http.value(forHTTPHeaderField: "ETag") {
                revisions.missions[id] = etag
            }
            if let schemaVersion = aggregate["schemaVersion"] {
                root["schemaVersion"] = schemaVersion
            }
        }

        let media = try await loadCatalog(collection: "media", objectKey: "asset")
        let sources = try await loadCatalog(collection: "sources", objectKey: "source")
        revisions.media = media.revisions
        revisions.sources = sources.revisions
        root["locale"] = index["locale"] ?? locale
        root["missions"] = missions
        root["locations"] = locations
        root["media"] = media.objects
        root["sources"] = sources.objects
        return PackDocument(root: root, base: root, revisions: revisions)
    }

    /// Gemmer kun de objekter, der er ændret siden indlæsningen.
    func save(_ document: PackDocument) async throws -> AuthoringSaveSummary {
        guard AdminConfiguration.isReady else { throw AdminError.noQuizmaster }
        let changes = try document.authoringChanges()
        var revisions = document.revisions
        var summary = AuthoringSaveSummary(revisions: revisions)

        // Metadata oprettes før opgaverne, så nye referencer altid peger på
        // noget, der allerede findes. Sletninger kommer omvendt til sidst.
        for object in changes.media.updates {
            let result = try await put(
                object, collection: "media", etag: revisions.media[object.id])
            revisions.media[object.id] = result.etag
            summary.record(result)
        }
        for object in changes.sources.updates {
            let result = try await put(
                object, collection: "sources", etag: revisions.sources[object.id])
            revisions.sources[object.id] = result.etag
            summary.record(result)
        }
        for object in changes.missions.updates {
            let result = try await put(
                object, collection: "missions", etag: revisions.missions[object.id])
            revisions.missions[object.id] = result.etag
            summary.record(result)
        }
        for id in changes.missions.deletions {
            let etag = try requiredRevision(revisions.missions[id], id: id)
            summary.record(try await deleteObject(collection: "missions", id: id, etag: etag))
            revisions.missions.removeValue(forKey: id)
        }
        for id in changes.media.deletions {
            let etag = try requiredRevision(revisions.media[id], id: id)
            summary.record(try await deleteObject(collection: "media", id: id, etag: etag))
            revisions.media.removeValue(forKey: id)
        }
        for id in changes.sources.deletions {
            let etag = try requiredRevision(revisions.sources[id], id: id)
            summary.record(try await deleteObject(collection: "sources", id: id, etag: etag))
            revisions.sources.removeValue(forKey: id)
        }
        summary.revisions = revisions
        return summary
    }

    private func loadCatalog(
        collection: String, objectKey: String
    ) async throws -> (objects: [[String: Any]], revisions: [String: String]) {
        let (data, _) = try await get(authoringURL.appending(path: collection))
        guard let wrapped = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { throw AdminError.message("Listen over \(collection) kunne ikke læses.") }
        var objects: [[String: Any]] = []
        var revisions: [String: String] = [:]
        for item in wrapped {
            guard let object = item[objectKey] as? [String: Any],
                  let id = object["id"] as? String,
                  let etag = item["etag"] as? String
            else { continue }
            objects.append(object)
            revisions[id] = etag
        }
        return (objects, revisions)
    }

    private func put(
        _ object: AuthoringObject, collection: String, etag: String?
    ) async throws -> AuthoringWriteResponse {
        var request = URLRequest(
            url: authoringURL.appending(path: collection).appending(path: object.id))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            AdminConfiguration.quizmaster.percentEncodedForHeader,
            forHTTPHeaderField: "X-Quizmaster")
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-Match")
        } else {
            request.setValue("*", forHTTPHeaderField: "If-None-Match")
        }
        request.httpBody = try JSONSerialization.data(
            withJSONObject: object.json, options: [.sortedKeys, .withoutEscapingSlashes])

        let (data, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)
        if http.statusCode == 412 { throw AdminError.conflict }
        guard http.statusCode == 200 || http.statusCode == 201,
              let etag = http.value(forHTTPHeaderField: "ETag"),
              let body = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { throw AdminError.message("Serveren afviste \(object.id) med \(http.statusCode).") }
        return AuthoringWriteResponse(
            id: object.id,
            etag: etag,
            publication: body["publication"] as? String ?? "unchanged",
            contentVersion: body["publishedContentVersion"] as? String)
    }

    private func deleteObject(
        collection: String, id: String, etag: String
    ) async throws -> AuthoringWriteResponse {
        var request = URLRequest(
            url: authoringURL.appending(path: collection).appending(path: id))
        request.httpMethod = "DELETE"
        request.setValue(etag, forHTTPHeaderField: "If-Match")
        request.setValue(
            AdminConfiguration.quizmaster.percentEncodedForHeader,
            forHTTPHeaderField: "X-Quizmaster")
        let (_, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)
        if http.statusCode == 412 { throw AdminError.conflict }
        guard http.statusCode == 204 else {
            throw AdminError.message("Serveren afviste sletning af \(id) med \(http.statusCode).")
        }
        return AuthoringWriteResponse(
            id: id,
            etag: nil,
            publication: http.value(forHTTPHeaderField: "X-Content-Publication") ?? "unchanged",
            contentVersion: nil)
    }

    private func get(_ url: URL) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)
        guard http.statusCode == 200 else {
            throw AdminError.message("Serveren svarede \(http.statusCode).")
        }
        return (data, http)
    }

    private func requiredRevision(_ value: String?, id: String) throws -> String {
        guard let value, !value.isEmpty else {
            throw AdminError.message("Mangler revisionsnummer for \(id). Hent opgaverne igen.")
        }
        return value
    }

    // MARK: - Medier

    /// Lægger et billede op under et navn, der ikke er brugt før.
    ///
    /// Serveren svarer `409` på et kendt filnavn og gør det med vilje: medier
    /// sendes med et års cache, så en fil, der skifter indhold uden at skifte
    /// navn, ville stå gammel på telefonerne i et år. Nummeret **er** versionen.
    func upload(_ data: Data, filename: String, contentType: String) async throws {
        var request = URLRequest(url: mediaURL.appending(path: filename))
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (_, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)

        switch http.statusCode {
        case 200, 201:
            return
        case 409:
            throw AdminError.message(
                "Filnavnet \(filename) er brugt. Billeder overskrives aldrig — tæl nummeret op.")
        default:
            throw AdminError.message("Billedet blev afvist med \(http.statusCode).")
        }
    }

    /// Lægger quizmasterens lydfil op til konvertering. Outputnavnet er MP3;
    /// headeren fortæller serveren, hvilket format de rå bytes kommer fra.
    func uploadNarration(
        _ data: Data, filename: String, sourceExtension: String
    ) async throws {
        let url = base
            .appending(path: "content")
            .appending(path: locale)
            .appending(path: "narration")
            .appending(path: filename)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(sourceExtension, forHTTPHeaderField: "X-Source-Format")
        request.httpBody = data

        let (_, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)

        switch http.statusCode {
        case 200, 201:
            return
        case 409:
            throw AdminError.message(
                "Filnavnet \(filename) er brugt. Medier overskrives aldrig — prøv igen.")
        case 413:
            throw AdminError.message("Lydfilen er for stor. Vælg en fil på højst 25 MB.")
        case 415:
            throw AdminError.message(
                "Lydformatet kunne ikke læses. Prøv MP3, M4A, WAV, AAC, AIFF, CAF, OGG, Opus eller FLAC.")
        case 429:
            throw AdminError.message(
                "Serveren gør allerede en anden fortælling klar. Prøv igen om et øjeblik.")
        default:
            throw AdminError.message("Fortællingen blev afvist med \(http.statusCode).")
        }
    }

    func deleteMedia(filename: String) async throws {
        var request = URLRequest(url: mediaURL.appending(path: filename))
        request.httpMethod = "DELETE"

        let (_, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)
        guard http.statusCode == 204 || http.statusCode == 404 else {
            throw AdminError.message("Sletningen blev afvist med \(http.statusCode).")
        }
    }

    // MARK: - Sporet

    func audit(limit: Int = 100) async throws -> [AuditEntry] {
        var components = URLComponents(url: auditURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        guard let url = components?.url else { throw AdminError.message("Ugyldig adresse.") }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)
        guard http.statusCode == 200 else {
            throw AdminError.message("Sporet svarede \(http.statusCode).")
        }

        return try JSONDecoder.audit.decode(AuditResponse.self, from: data).entries
    }

    private static func http(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let http = response as? HTTPURLResponse else {
            throw AdminError.message("Svaret var ikke HTTP.")
        }
        return http
    }

    /// Oversætter netværkets egne fejl til noget, der kan læses i felten.
    static func describe(_ error: any Error) -> String {
        guard let url = error as? URLError else { return error.localizedDescription }
        return switch url.code {
        case .timedOut:
            "Serveren svarede ikke i tide. Dine rettelser er gemt på telefonen — prøv igen, "
            + "når du har bedre dækning."
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            "Ingen forbindelse. Dine rettelser er gemt på telefonen og forsvinder ikke."
        case .cannotFindHost, .cannotConnectToHost:
            "Kunne ikke få fat i serveren. Står adressen rigtigt i bygningen?"
        default:
            url.localizedDescription
        }
    }
}

// MARK: - Sporet over ændringer

private struct AuditResponse: Decodable {
    let entries: [AuditEntry]
}

/// Én linje i sporet: hvem, hvornår, fra og til hvilken status (FR-111).
struct AuditEntry: Decodable, Identifiable, Hashable {
    let at: Date
    let by: String
    let change: String
    let missionId: String?
    let from: String?
    let to: String?
    let contentVersion: String

    /// Sporet bærer ingen nøgle. To linjer med samme tidspunkt og samme
    /// quizmaster hører til den samme gemning og skelnes på opgaven.
    var id: String { "\(at.timeIntervalSince1970)-\(missionId ?? "-")-\(change)" }
}

extension JSONDecoder {
    static let audit: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return decoder
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    /// .NET skriver `2026-07-30T18:04:12.1234567+00:00`. `.iso8601` alene
    /// kaster på brøkdelen af sekundet, og hele sporet ville så være tomt.
    static let iso8601WithFractionalSeconds = custom { decoder in
        let raw = try decoder.singleValueContainer().decode(String.self)
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: raw) { return date }

        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: raw) { return date }

        throw DecodingError.dataCorruptedError(
            in: try decoder.singleValueContainer(), debugDescription: "Ulæseligt tidspunkt: \(raw)")
    }
}

extension String {
    /// Procentkodning af alt uden for ASCII-bogstaver og -tal.
    ///
    /// `.urlQueryAllowed` er ikke nok: den lader `%`, `+` og `&` stå, og de
    /// betyder noget i en header, serveren afkoder igen.
    var percentEncodedForHeader: String {
        let safe = CharacterSet(charactersIn:
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~ ")
        return addingPercentEncoding(withAllowedCharacters: safe) ?? self
    }
}

enum AdminError: LocalizedError {
    case message(String)
    case conflict
    case noQuizmaster

    var errorDescription: String? {
        switch self {
        case .message(let text): text
        case .conflict:
            "En anden quizmaster har gemt, siden du hentede. Hent igen, og læg dine rettelser oveni."
        case .noQuizmaster:
            "Skriv dit navn under Quizmaster, før du gemmer. Sporet skal kunne svare på hvem."
        }
    }
}

private struct AuthoringWriteResponse {
    let id: String
    let etag: String?
    let publication: String
    let contentVersion: String?
}

struct AuthoringSaveSummary {
    var revisions: ObjectRevisions
    private(set) var publicationPending = false
    private(set) var didPublish = false
    private(set) var contentVersion: String?

    init(revisions: ObjectRevisions) {
        self.revisions = revisions
    }

    fileprivate mutating func record(_ response: AuthoringWriteResponse) {
        if response.publication == "pending" { publicationPending = true }
        if response.publication == "published" { didPublish = true }
        if let version = response.contentVersion { contentVersion = version }
    }
}
