import BHContracts
import Foundation

/// Henter billeder og lyd fra serveren.
///
/// ## Hvorfor medier må caches på disk, når pakken ikke må
///
/// Det ser inkonsekvent ud, men de to ting ændrer sig forskelligt.
///
/// En **indholdspakke** rettes: en opgave sættes på pause, et facit korrigeres,
/// en tekst skrives om. En gammel kopi kan sende en familie hen til et sted,
/// hvor opgaven ikke længere gælder. Derfor hentes den hver gang.
///
/// Et **medie** ændrer sig ikke. Skal billedet være et andet, får det et andet
/// filnavn — det er derfor filerne hedder `boelgen-001` og ikke `boelgen`.
/// Serveren sender dem med `Cache-Control: immutable` og et års levetid.
///
/// Derfor er det `URLSession`s egen disk-cache, der bruges her. Den er
/// gennemtestet, den rydder op efter sig selv, og den er allerede i appen.
/// At skrive en til ville være at bygge noget dårligere.
public struct NetworkMediaSource: MediaSource {

    private let baseURL: URL
    private let locale: String
    private let session: URLSession

    public init(baseURL: URL, locale: String = "da-DK", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.locale = locale
        self.session = session
    }

    public func fetch(
        _ asset: MediaAsset,
        ifNoneMatch etag: String?
    ) async throws -> MediaResponse {
        let url = baseURL
            .appending(path: "content")
            .appending(path: locale)
            .appending(path: "media")
            .appending(path: asset.filename)

        var request = URLRequest(url: url)
        // Modsat pakken må denne gerne komme fra disken.
        request.cachePolicy = .useProtocolCachePolicy
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            // Et manglende billede må aldrig standse en opgave. Teksten bærer
            // gåden; billedet sætter stemningen (ADR 0003). Derfor `.missing`
            // og ikke en fejl, der bobler op til spilleren.
            return .missing
        }

        guard let http = response as? HTTPURLResponse else { return .missing }

        switch http.statusCode {
        case 200:
            return .data(data, etag: http.value(forHTTPHeaderField: "ETag"))
        case 304:
            return .unchanged
        default:
            return .missing
        }
    }
}
