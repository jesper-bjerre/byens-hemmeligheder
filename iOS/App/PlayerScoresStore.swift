import BHGameCore
import Foundation
import Observation

/// Synkroniserer den lokale, forklarlige pointledger med spillerens konto.
///
/// Den lokale hændelseslog er køen: ved netudfald udleder næste synkronisering
/// præcis samme completion-id og sender igen. Serverens PUT er idempotent, så
/// det kan aldrig give dobbeltpoint.
@MainActor
@Observable
final class PlayerScoresStore {
    struct Entry: Codable, Identifiable, Equatable, Sendable {
        var id: String { "\(name)|\(points)" }
        let name: String
        let points: Int
    }

    private struct ScoreLine: Codable, Sendable {
        let id: String
        let reason: String
        let points: Int
    }

    private struct Submission: Codable, Sendable {
        let eventId: UUID
        let contentVersion: String
        let points: Int
        let completedAt: Date
        let transactions: [ScoreLine]
    }

    private(set) var weekly: [Entry] = []
    private(set) var allTime: [Entry] = []
    private(set) var isLoading = false
    private(set) var scoreSyncMessage: String?
    private(set) var leaderboardMessage: String?
    private var submissionsInFlight: Set<String> = []

    func syncAll(from engine: MissionEngine, using authentication: PlayerAuthentication) async {
        guard authentication.state == .signedIn else { return }
        for mission in engine.playableMissions where engine.isCompleted(mission) {
            await submit(missionId: mission.id, from: engine, using: authentication)
        }
        await refresh()
    }

    func submit(
        missionId: String,
        from engine: MissionEngine,
        using authentication: PlayerAuthentication
    ) async {
        guard authentication.state == .signedIn,
              submissionsInFlight.insert(missionId).inserted
        else { return }
        defer { submissionsInFlight.remove(missionId) }

        let state = engine.playerState
        guard let eventId = state.completionEventIds[missionId],
              let completedAt = state.completionDates[missionId],
              let contentVersion = state.completionContentVersions[missionId]
        else { return }

        let transactions = engine.playerState.transactions(forMission: missionId)
        let points = transactions.reduce(0) { $0 + $1.points }
        guard points > 0 else { return }

        let body = Submission(
            eventId: eventId,
            contentVersion: contentVersion,
            points: points,
            completedAt: completedAt,
            transactions: transactions.map {
                ScoreLine(id: $0.id, reason: $0.reason.rawValue, points: $0.points)
            })

        do {
            var request = URLRequest(
                url: ContentEndpoint.requiredBaseURL
                    .appending(path: "scores/missions")
                    .appending(path: missionId))
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
            let (_, response) = try await authentication.client.authorizedData(for: request)
            guard response.statusCode == 204 else { throw ScoreError.server }
            scoreSyncMessage = nil
        } catch {
            authentication.handleAuthenticationFailure(error)
            // Completion-hændelsen bliver liggende lokalt og prøves igen ved
            // næste login eller næste besøg på forsiden.
            scoreSyncMessage = "Dine point er gemt på telefonen og synkroniseres, når forbindelsen er tilbage."
        }
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            async let week = fetch(period: "week")
            async let all = fetch(period: "allTime")
            (weekly, allTime) = try await (week, all)
            leaderboardMessage = nil
        } catch {
            leaderboardMessage = "Highscorelisten kunne ikke hentes. Prøv igen om lidt."
        }
    }

    private func fetch(period: String) async throws -> [Entry] {
        var components = URLComponents(
            url: ContentEndpoint.requiredBaseURL.appending(path: "scores/leaderboard"),
            resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "period", value: period)]
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ScoreError.server
        }
        return try JSONDecoder().decode([Entry].self, from: data)
    }

    private enum ScoreError: Error { case server }
}
