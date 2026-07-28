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

    /// Billede eller lyd. Udeladt betyder billede — feltet kom til efter de
    /// første medier, og additive felter er altid optional (ADR 0001).
    public let mediaType: Tolerant<MediaType>?

    /// Hvad der er lavet om på fotografiet.
    ///
    /// Stemningsbearbejdning er tilladt: farvegradering, mørke, regn, lys,
    /// beskæring, fjernelse af personer og nummerplader. Det, spilleren skal
    /// **observere**, er fredet — ændres det, er facit ikke længere bevisbart
    /// (ADR 0003, forfatningens princip II).
    ///
    /// Feltet er dokumentation til den næste redaktør, ikke til spilleren. Er
    /// noget rørt, skal det stå her.
    public let manipulation: String?

    public init(
        id: String,
        filename: String,
        altText: String,
        owner: String,
        licence: String,
        credit: String,
        kind: Tolerant<MediaKind>,
        restrictions: String? = nil,
        expiresAt: String? = nil,
        mediaType: Tolerant<MediaType>? = nil,
        manipulation: String? = nil
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
        self.mediaType = mediaType
        self.manipulation = manipulation
    }

    /// Behandler et udeladt felt som billede.
    public var resolvedMediaType: MediaType {
        mediaType?.known ?? .image
    }
}

/// Hvilken slags fil medieposten peger på.
public enum MediaType: String, TolerantEnum {
    case image
    /// Indtalt fortællerstemme. Sætter stemning — bærer aldrig et spor,
    /// teksten ikke også bærer (ADR 0003).
    case audio
}

public enum MediaKind: String, TolerantEnum {
    case historical
    case contemporary
    case aiGenerated
    /// Et ægte fotografi, bearbejdet for stemningens skyld.
    ///
    /// Hverken `contemporary` — det er ikke længere som virkeligheden så ud —
    /// eller `aiGenerated`, for motivet er ægte og optaget på stedet. ``MediaAsset/manipulation``
    /// skal beskrive hvad der er rørt (ADR 0003).
    case enhanced
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
