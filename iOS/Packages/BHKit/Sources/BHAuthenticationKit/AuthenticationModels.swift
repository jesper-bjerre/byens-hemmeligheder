import Foundation

public enum AuthenticationClientKind: String, Codable, Sendable {
    case iOSPlayer = "IOSPlayer"
    case iOSAdmin = "IOSAdmin"
}

public struct AuthenticatedAccount: Codable, Equatable, Sendable {
    public let accountId: UUID
    public let email: String?
    public let publicName: String?
    public let role: String
    public let state: String

    public init(
        accountId: UUID,
        email: String?,
        publicName: String?,
        role: String,
        state: String
    ) {
        self.accountId = accountId
        self.email = email
        self.publicName = publicName
        self.role = role
        self.state = state
    }
}

public struct AuthenticationSession: Codable, Equatable, Sendable {
    public let accessToken: String
    public let accessExpiresAt: Date
    public let refreshToken: String?
    public let refreshExpiresAt: Date?
    public let account: AuthenticatedAccount

    public init(
        accessToken: String,
        accessExpiresAt: Date,
        refreshToken: String?,
        refreshExpiresAt: Date?,
        account: AuthenticatedAccount
    ) {
        self.accessToken = accessToken
        self.accessExpiresAt = accessExpiresAt
        self.refreshToken = refreshToken
        self.refreshExpiresAt = refreshExpiresAt
        self.account = account
    }
}

public enum AuthenticationError: LocalizedError, Equatable {
    case notAuthenticated
    case accessDenied
    case invalidAppleCredential
    case sessionExpired
    case server(Int)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated: "Log ind for at fortsætte."
        case .accessDenied: "Din konto har ikke adgang til denne funktion."
        case .invalidAppleCredential: "Apple-login kunne ikke godkendes. Prøv igen."
        case .sessionExpired: "Din session er udløbet. Log ind igen."
        case .server: "Serveren kunne ikke gennemføre login. Prøv igen om lidt."
        case .invalidResponse: "Serverens login-svar kunne ikke læses."
        }
    }
}
