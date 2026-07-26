import Foundation

/// Et medie med fuld rettighedskæde.
///
/// Alle rettighedsfelter er obligatoriske — det er sådan forfatningens princip
/// IV bliver umulig at glemme (FR-042, FR-048, FR-038). Et billede uden
/// `owner`, `licence` og `credit` kan ikke afkodes, og dermed heller ikke
/// shippes.
public struct MediaAsset: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let filename: String
    /// Forfattet af mennesket, der valgte billedet — ikke genereret (FR-038).
    /// VoiceOver læser præcis denne tekst.
    public let altText: String
    public let owner: String
    public let licence: String
    public let credit: String
    /// AI-genererede billeder må aldrig præsenteres som autentiske historiske
    /// fotografier (forfatningens princip III).
    public let kind: Tolerant<MediaKind>
    public let restrictions: String?
    public let expiresAt: String?

    public init(
        id: String,
        filename: String,
        altText: String,
        owner: String,
        licence: String,
        credit: String,
        kind: Tolerant<MediaKind>,
        restrictions: String? = nil,
        expiresAt: String? = nil
    ) {
        self.id = id
        self.filename = filename
        self.altText = altText
        self.owner = owner
        self.licence = licence
        self.credit = credit
        self.kind = kind
        self.restrictions = restrictions
        self.expiresAt = expiresAt
    }
}

public enum MediaKind: String, TolerantEnum {
    case historical
    case contemporary
    case aiGenerated
}

/// Den dokumenterede kilde bag opgavens fakta (FR-042).
public struct Source: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let publisher: String
    public let url: String
    public let kind: Tolerant<SourceKind>

    public init(id: String, title: String, publisher: String, url: String, kind: Tolerant<SourceKind>) {
        self.id = id
        self.title = title
        self.publisher = publisher
        self.url = url
        self.kind = kind
    }
}

public enum SourceKind: String, TolerantEnum {
    case officialTourism
    case architectPrimary
    case archive
    case press
    case municipal
    case other
}
