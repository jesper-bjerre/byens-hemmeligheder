import BHContracts
import Foundation

/// Hvor indholdspakken kommer fra.
///
/// Abstraktionen findes fra dag 1, selvom der ikke er nogen server. Formen med
/// `ifNoneMatch` og ``ContentPackResponse/notModified`` er allerede på plads,
/// selvom ``BundledContentPackSource`` altid returnerer `.pack` — så koster
/// ETag-caching senere ingen signaturændring, og dermed ingen ændring hos
/// kaldstederne (research.md R-003).
public protocol ContentPackSource: Sendable {
    func fetchPack(locale: String, ifNoneMatch etag: String?) async throws -> ContentPackResponse
}

public enum ContentPackResponse: Hashable, Sendable {
    case pack(ContentPack, etag: String?)
    case notModified
}

public enum ContentPackError: Error, Hashable, Sendable {
    case resourceNotFound(name: String, locale: String)
    case decodingFailed(String)

    public var errorDescription: String {
        switch self {
        case .resourceNotFound(let name, let locale):
            "Indholdspakken '\(name)' for '\(locale)' findes ikke i bundlen."
        case .decodingFailed(let detail):
            "Indholdspakken kunne ikke afkodes: \(detail)"
        }
    }
}

/// Fase 1's kilde: pakken ligger i app-bundlen og shipper med binæren.
///
/// App-versionen *er* indholdsversionen i feature 001 (plan.md, princip V).
public struct BundledContentPackSource: ContentPackSource {
    private let bundle: Bundle
    private let resourceName: String

    public init(bundle: Bundle, resourceName: String = "content-pack") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    public func fetchPack(locale: String, ifNoneMatch etag: String?) async throws -> ContentPackResponse {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw ContentPackError.resourceNotFound(name: resourceName, locale: locale)
        }
        let data = try Data(contentsOf: url)
        return try Self.decode(data)
    }

    /// Delt af den bundlede kilde og af testene, så begge går gennem præcis
    /// samme afkodning.
    public static func decode(_ data: Data) throws -> ContentPackResponse {
        do {
            let pack = try BHJSON.decoder.decode(ContentPack.self, from: data)
            return .pack(pack, etag: nil)
        } catch {
            throw ContentPackError.decodingFailed(String(describing: error))
        }
    }
}
