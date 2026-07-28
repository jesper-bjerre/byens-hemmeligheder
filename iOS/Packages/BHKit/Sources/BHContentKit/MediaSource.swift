import BHContracts
import Foundation

/// Hvor billedernes bytes kommer fra.
///
/// ## Hvorfor der er en protokol, når der kun findes én implementering
///
/// Al kode og alt indhold bliver i appen, indtil quizmasterne har prøvet en
/// TestFlight-version. Først derefter flyttes det til en server.
///
/// Netop derfor står grænsefladen her allerede. `ContentPackSource` fik samme
/// behandling og har båret sig selv hjem: fordi opgaverne hentes gennem en
/// protokol med ETag, er skiftet til en server et spørgsmål om at tilføje en
/// implementering — ikke om at rive kaldesteder op. Billederne skulle have haft
/// det samme fra begyndelsen, men blev læst direkte fra `Bundle.main` inde i en
/// visning.
///
/// Det, der gør forskellen senere, er ikke protokollen i sig selv, men at
/// **ingen** kalder `Bundle.main` uden om den.
public protocol MediaSource: Sendable {
    /// Rå bytes for et medie. `nil`, hvis mediet ikke findes.
    ///
    /// - Parameter etag: kendt version. En kilde, der understøtter det, kan
    ///   svare ``MediaResponse/unchanged`` frem for at sende det hele igen.
    func fetch(_ asset: MediaAsset, ifNoneMatch etag: String?) async throws -> MediaResponse
}

public enum MediaResponse: Hashable, Sendable {
    case data(Data, etag: String?)
    case unchanged
    case missing
}

/// Mediet ligger i appens bundle.
///
/// Filerne bor i mappereferencen `media`, så et nyt billede kun kræver en
/// indholdsændring og ikke en ændring af `project.pbxproj`.
public struct BundledMediaSource: MediaSource {
    private let bundle: Bundle
    private let subdirectory: String

    public init(bundle: Bundle, subdirectory: String = "media") {
        self.bundle = bundle
        self.subdirectory = subdirectory
    }

    public func fetch(_ asset: MediaAsset, ifNoneMatch etag: String?) async throws -> MediaResponse {
        let name = (asset.filename as NSString).deletingPathExtension
        let ext = (asset.filename as NSString).pathExtension

        guard let url = bundle.url(forResource: name, withExtension: ext, subdirectory: subdirectory),
              let data = try? Data(contentsOf: url)
        else { return .missing }

        // Bundlede filer har ingen version at sammenligne med: de ændrer sig
        // kun, når appen selv gør. En server vil svare `.unchanged` her.
        return .data(data, etag: nil)
    }
}
