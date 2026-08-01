import BHContracts
import Foundation

/// Indgangen til indholdet for resten af appen.
///
/// En actor, fordi kilden en dag bliver netværk. At gøre den til en actor nu
/// koster intet og sparer en gennemgribende ændring senere.
public actor ContentRepository {
    private let source: any ContentPackSource
    private let locale: String

    private var cachedPack: ContentPack?
    private var cachedEtag: String?

    public init(source: any ContentPackSource, locale: String = "da-DK") {
        self.source = source
        self.locale = locale
    }

    /// Indlæser pakken. Efterfølgende kald returnerer den samme instans.
    @discardableResult
    public func pack() async throws -> ContentPack {
        if let cachedPack { return cachedPack }

        switch try await source.fetchPack(locale: locale, ifNoneMatch: cachedEtag) {
        case .pack(let pack, let etag):
            cachedPack = pack
            cachedEtag = etag
            return pack
        case .notModified:
            guard let cachedPack else {
                throw ContentPackError.resourceNotFound(name: "content-pack", locale: locale)
            }
            return cachedPack
        }
    }

    /// Missionerne, spilleren må se.
    ///
    /// `draft` og `paused` filtreres fra — en pauset opgave må ikke kunne
    /// startes, heller ikke fra et gammelt kortudsnit (forfatningens princip IV).
    public func playableMissions() async throws -> [Mission] {
        try await pack().missions.filter(\.isPlayable)
    }

    public func mission(id: String) async throws -> Mission? {
        try await pack().mission(id: id)
    }

    public func location(for mission: Mission) async throws -> Location? {
        try await pack().location(id: mission.locationId)
    }
}
