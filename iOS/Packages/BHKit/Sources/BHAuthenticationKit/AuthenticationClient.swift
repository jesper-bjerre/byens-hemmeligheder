import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public actor AuthenticationClient {
    private let baseURL: URL
    private let clientId: String
    private let clientKind: AuthenticationClientKind
    private let store: any AuthenticationSessionStoring
    private let network: URLSession
    private let now: @Sendable () -> Date
    private var session: AuthenticationSession?

    public init(
        baseURL: URL,
        clientId: String,
        clientKind: AuthenticationClientKind,
        store: any AuthenticationSessionStoring,
        network: URLSession = .shared,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.baseURL = baseURL
        self.clientId = clientId
        self.clientKind = clientKind
        self.store = store
        self.network = network
        self.now = now
    }

    public func restore() async throws -> AuthenticatedAccount? {
        session = try await store.load()
        guard session != nil else { return nil }
        do {
            _ = try await validAccessToken()
            return session?.account
        } catch {
            try? await store.clear()
            session = nil
            return nil
        }
    }

    @discardableResult
    public func signIn(
        identityToken: Data,
        authorizationCode: Data,
        rawNonce: String
    ) async throws -> AuthenticatedAccount {
        guard let identityToken = String(data: identityToken, encoding: .utf8),
              let authorizationCode = String(data: authorizationCode, encoding: .utf8)
        else { throw AuthenticationError.invalidAppleCredential }

        let body = NativeExchangeBody(
            clientId: clientId,
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            nonce: rawNonce,
            clientKind: clientKind.rawValue)
        let response: AuthenticationSession = try await send(
            path: "auth/apple/native/exchange", body: body)
        session = response
        try await store.save(response)
        return response.account
    }

    public func account() -> AuthenticatedAccount? { session?.account }

    public func authorizedData(for original: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var request = original
        request.setValue("Bearer \(try await validAccessToken())", forHTTPHeaderField: "Authorization")
        let (data, response) = try await network.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AuthenticationError.invalidResponse
        }
        if http.statusCode == 403 { throw AuthenticationError.accessDenied }
        if http.statusCode != 401 { return (data, http) }

        // En access-session kan være udløbet på serveren et øjeblik før uret
        // på telefonen mener det. Roter én gang og gentag præcis samme request.
        _ = try await refresh()
        request.setValue("Bearer \(session!.accessToken)", forHTTPHeaderField: "Authorization")
        let (retryData, retryResponse) = try await network.data(for: request)
        guard let retryHTTP = retryResponse as? HTTPURLResponse else {
            throw AuthenticationError.invalidResponse
        }
        if retryHTTP.statusCode == 401 {
            try? await store.clear()
            session = nil
            throw AuthenticationError.sessionExpired
        }
        if retryHTTP.statusCode == 403 { throw AuthenticationError.accessDenied }
        return (retryData, retryHTTP)
    }

    public func logout() async {
        if let token = session?.accessToken {
            var request = URLRequest(url: baseURL.appending(path: "auth/logout"))
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            _ = try? await network.data(for: request)
        }
        session = nil
        try? await store.clear()
    }

    /// Sletter spillerkontoen på serveren og fjerner derefter den lokale
    /// session. Sessionen ryddes kun efter et bekræftet serversvar, så en
    /// netværksfejl ikke efterlader brugeren i tvivl om kontoen blev slettet.
    public func deleteAccount() async throws {
        var request = URLRequest(url: baseURL.appending(path: "auth/me"))
        request.httpMethod = "DELETE"
        let (_, response) = try await authorizedData(for: request)
        switch response.statusCode {
        case 204:
            session = nil
            try await store.clear()
        case 409:
            throw AuthenticationError.accessDenied
        default:
            throw AuthenticationError.server(response.statusCode)
        }
    }

    /// Opdaterer det frivillige offentlige navn og erstatter kontokopien i
    /// Keychain-sessionen med serverens normaliserede svar.
    @discardableResult
    public func updatePublicName(_ publicName: String?) async throws -> AuthenticatedAccount {
        var request = URLRequest(url: baseURL.appending(path: "auth/me/profile"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(UpdateProfileBody(publicName: publicName))
        let (data, response) = try await authorizedData(for: request)
        guard response.statusCode == 200 else {
            throw AuthenticationError.server(response.statusCode)
        }
        let account: AuthenticatedAccount
        do {
            account = try JSONDecoder.authentication.decode(AuthenticatedAccount.self, from: data)
        } catch {
            throw AuthenticationError.invalidResponse
        }
        guard let current = session else { throw AuthenticationError.notAuthenticated }
        let updated = AuthenticationSession(
            accessToken: current.accessToken,
            accessExpiresAt: current.accessExpiresAt,
            refreshToken: current.refreshToken,
            refreshExpiresAt: current.refreshExpiresAt,
            account: account)
        session = updated
        try await store.save(updated)
        return account
    }

    public func reportPublicName(
        _ publicName: String,
        category: PublicNameReportCategory
    ) async throws {
        var request = URLRequest(url: baseURL.appending(path: "scores/name-reports"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(NameReportBody(
            reportedName: publicName,
            category: category.rawValue))
        let (_, response) = try await authorizedData(for: request)
        guard response.statusCode == 204 else {
            throw AuthenticationError.server(response.statusCode)
        }
    }

    private func validAccessToken() async throws -> String {
        guard let session else { throw AuthenticationError.notAuthenticated }
        if session.accessExpiresAt > now().addingTimeInterval(30) {
            return session.accessToken
        }
        return try await refresh().accessToken
    }

    private func refresh() async throws -> AuthenticationSession {
        guard let refreshToken = session?.refreshToken,
              let refreshExpiresAt = session?.refreshExpiresAt,
              refreshExpiresAt > now()
        else { throw AuthenticationError.sessionExpired }
        do {
            let refreshed: AuthenticationSession = try await send(
                path: "auth/refresh", body: RefreshBody(refreshToken: refreshToken))
            session = refreshed
            try await store.save(refreshed)
            return refreshed
        } catch {
            try? await store.clear()
            session = nil
            throw AuthenticationError.sessionExpired
        }
    }

    private func send<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await network.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AuthenticationError.invalidResponse
        }
        switch http.statusCode {
        case 200, 201: break
        case 401: throw AuthenticationError.invalidAppleCredential
        case 403: throw AuthenticationError.accessDenied
        default: throw AuthenticationError.server(http.statusCode)
        }
        do {
            return try JSONDecoder.authentication.decode(Response.self, from: data)
        } catch {
            throw AuthenticationError.invalidResponse
        }
    }
}

private struct NativeExchangeBody: Encodable {
    let clientId: String
    let identityToken: String
    let authorizationCode: String
    let nonce: String
    let clientKind: String
}

private struct RefreshBody: Encodable {
    let refreshToken: String
}

private struct UpdateProfileBody: Encodable {
    let publicName: String?
}

private struct NameReportBody: Encodable {
    let reportedName: String
    let category: String
}
