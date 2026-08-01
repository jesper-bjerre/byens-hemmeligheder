import Foundation

/// Taler med backenden om indholdspakken og dens medier.
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

    // MARK: - Pakken

    func load() async throws -> PackDocument {
        var request = URLRequest(url: packURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)
        guard http.statusCode == 200 else {
            throw AdminError.message("Serveren svarede \(http.statusCode).")
        }
        return try PackDocument(data: data, etag: http.value(forHTTPHeaderField: "ETag"))
    }

    /// - Returns: den nye ETag.
    func save(_ document: PackDocument) async throws -> String? {
        guard AdminConfiguration.isReady else { throw AdminError.noQuizmaster }

        var request = URLRequest(url: packURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Uden denne overskriver to quizmastere hinanden i tavshed.
        if let etag = document.etag {
            request.setValue(etag, forHTTPHeaderField: "If-Match")
        }
        // Uden dette kan sporet ikke svare på hvem, og serveren afviser (FR-111).
        //
        // Procentkodet, fordi en HTTP-header ikke kan bære andet end ASCII.
        // "Søren" ville ellers stå som "SÃ¸ren" i sporet — eller blive tabt
        // undervejs, alt efter hvad de to ender gætter på.
        request.setValue(
            AdminConfiguration.quizmaster.percentEncodedForHeader,
            forHTTPHeaderField: "X-Quizmaster")
        request.httpBody = try document.serialised()

        let (_, response) = try await Self.session.data(for: request)
        let http = try Self.http(response)

        switch http.statusCode {
        case 200, 204:
            return http.value(forHTTPHeaderField: "ETag")
        case 412:
            throw AdminError.conflict
        default:
            throw AdminError.message("Serveren afviste med \(http.statusCode).")
        }
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
