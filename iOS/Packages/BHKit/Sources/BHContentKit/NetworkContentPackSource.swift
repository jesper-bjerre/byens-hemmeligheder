import BHContracts
import Foundation

/// Henter indholdspakken fra serveren.
///
/// ## Hvorfor den ikke gemmer pakken på disk
///
/// ADR 0004 og forfatningens princip V: appen kræver forbindelse. Det er ikke
/// en mangel, men et valg — indholdet rettes af quizmastere, og en gammel kopi
/// på disk kan sende en familie hen til et sted, hvor opgaven er trukket
/// tilbage.
///
/// `ContentRepository` holder pakken i hukommelsen for den enkelte kørsel. Det
/// er nok: den er hentet én gang, når appen åbnes, og ETag'en gør det næste
/// kald til et `304` på nogle få hundrede bytes.
///
/// ## Fejl skal kunne skelnes
///
/// Der er forskel på "der er intet netværk", "serveren svarede med en fejl" og
/// "pakken kunne ikke afkodes". Spilleren skal have at vide hvad hen kan gøre,
/// og de tre har hvert sit svar. Derfor bevares årsagen frem for at falde
/// sammen til én generisk fejl.
public struct NetworkContentPackSource: ContentPackSource {

    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchPack(
        locale: String,
        ifNoneMatch etag: String?
    ) async throws -> ContentPackResponse {
        let url = baseURL
            .appending(path: "content")
            .appending(path: locale)
            .appending(path: "pack")

        var request = URLRequest(url: url)
        // Ingen egen cache. `ContentRepository` holder pakken, og ETag'en
        // afgør resten — to lag cache, der er uenige, er værre end ingen.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ContentPackError.unreachable(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw ContentPackError.unreachable("Svaret var ikke HTTP.")
        }

        switch http.statusCode {
        case 200:
            let pack = try ContentPack.decode(data)
            return .pack(pack, etag: http.value(forHTTPHeaderField: "ETag"))
        case 304:
            return .notModified
        case 404:
            throw ContentPackError.resourceNotFound(name: "content-pack", locale: locale)
        default:
            throw ContentPackError.serverError(status: http.statusCode)
        }
    }
}

extension ContentPack {
    /// Afkoder en pakke og bevarer årsagen, hvis det mislykkes.
    static func decode(_ data: Data) throws -> ContentPack {
        do {
            return try JSONDecoder().decode(ContentPack.self, from: data)
        } catch {
            throw ContentPackError.decodingFailed(String(describing: error))
        }
    }
}
