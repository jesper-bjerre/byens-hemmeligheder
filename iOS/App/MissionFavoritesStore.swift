import BHAuthenticationKit
import Foundation
import Observation

/// Favoritter og de aggregerede tal, der driver forsidens rangeringer.
///
/// Gæster kan læse summerne, men vi opfinder ikke et skjult device-id for at
/// lade dem skrive. En favorit tilhører en verificeret konto og synkroniseres
/// gennem den samme kortlivede session som resten af kontofunktionerne.
@MainActor
@Observable
final class MissionFavoritesStore {
    struct Metrics: Codable, Equatable, Sendable {
        let missionId: String
        let favoriteCount: Int
        let trendingCount: Int
    }

    private struct FavoritesResponse: Codable, Sendable {
        let missionIds: [String]
    }

    private(set) var favoriteMissionIds: Set<String> = []
    private(set) var metricsByMissionId: [String: Metrics] = [:]
    private(set) var errorMessage: String?
    private var isRefreshing = false

    func isFavorite(_ missionId: String) -> Bool {
        favoriteMissionIds.contains(missionId)
    }

    func metrics(for missionId: String) -> Metrics? {
        metricsByMissionId[missionId]
    }

    func refresh(using authentication: PlayerAuthentication) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        await refreshMetrics()
        guard authentication.state == .signedIn else {
            favoriteMissionIds = []
            return
        }

        do {
            var request = URLRequest(
                url: ContentEndpoint.requiredBaseURL.appending(path: "engagement/favorites"))
            request.httpMethod = "GET"
            let (data, response) = try await authentication.client.authorizedData(for: request)
            guard response.statusCode == 200 else { throw FavoriteError.server }
            favoriteMissionIds = Set(try JSONDecoder().decode(FavoritesResponse.self, from: data).missionIds)
            errorMessage = nil
        } catch {
            authentication.handleAuthenticationFailure(error)
            // De offentlige summer kan stadig bruges. En kort netværksfejl må
            // ikke få alle opgaver til at se permanent upopulære ud.
            if let authenticationError = error as? AuthenticationError,
               authenticationError == .notAuthenticated
                || authenticationError == .sessionExpired {
                favoriteMissionIds = []
                errorMessage = "Din session er udløbet. Log ind igen under Profil."
            } else {
                errorMessage = "Dine favoritter kunne ikke hentes. Prøv igen om lidt."
            }
        }
    }

    /// Opdaterer hjertet med det samme og ruller tilbage, hvis serveren afviser.
    func toggle(_ missionId: String, using authentication: PlayerAuthentication) async {
        guard authentication.state == .signedIn else {
            errorMessage = "Log ind under Profil for at gemme favoritter."
            return
        }

        let wasFavorite = favoriteMissionIds.contains(missionId)
        if wasFavorite {
            favoriteMissionIds.remove(missionId)
        } else {
            favoriteMissionIds.insert(missionId)
        }

        do {
            var request = URLRequest(
                url: ContentEndpoint.requiredBaseURL
                    .appending(path: "engagement/missions")
                    .appending(path: missionId)
                    .appending(path: "favorite"))
            request.httpMethod = wasFavorite ? "DELETE" : "PUT"
            let (_, response) = try await authentication.client.authorizedData(for: request)
            guard response.statusCode == 204 else { throw FavoriteError.server }
            errorMessage = nil
            // Skrivekaldet rydder serverens korte cache. Genlæsningen giver
            // korrekte 30-dages-tal, også når en gammel favorit fjernes.
            await refreshMetrics()
        } catch {
            authentication.handleAuthenticationFailure(error)
            if wasFavorite {
                favoriteMissionIds.insert(missionId)
            } else {
                favoriteMissionIds.remove(missionId)
            }
            if let authenticationError = error as? AuthenticationError,
               authenticationError == .notAuthenticated
                || authenticationError == .sessionExpired {
                errorMessage = "Din session er udløbet. Log ind igen under Profil."
            } else {
                errorMessage = "Favoritten kunne ikke gemmes. Prøv igen."
            }
        }
    }

    func clearMessage() {
        errorMessage = nil
    }

    private func refreshMetrics() async {
        do {
            let url = ContentEndpoint.requiredBaseURL.appending(path: "engagement/missions")
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw FavoriteError.server
            }
            let metrics = try JSONDecoder().decode([Metrics].self, from: data)
            metricsByMissionId = Dictionary(uniqueKeysWithValues: metrics.map { ($0.missionId, $0) })
        } catch {
            // Bevar sidste kendte summer. Tomt betyder kun, at serveren aldrig
            // er nået; UI'et viser så en ærlig tom tilstand.
        }
    }

    private enum FavoriteError: Error {
        case server
    }
}
