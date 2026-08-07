import BHAuthenticationKit
import Foundation
import Testing

@testable import ByensGaaderAdmin

@MainActor
@Suite("Admin-login")
struct AuthenticationTests {
    @Test("Designer-session åbner redaktionen")
    func designerCanEnter() async throws {
        let authentication = makeAuthentication(role: "Designer")

        await authentication.restore()

        #expect(authentication.state == .signedIn)
        #expect(authentication.account?.role == "Designer")
    }

    @Test("En almindelig User afvises uden at åbne redaktionen")
    func userIsDenied() async throws {
        let authentication = makeAuthentication(role: "User")

        await authentication.restore()

        #expect(authentication.state == .accessDenied)
    }

    private func makeAuthentication(role: String) -> AdminAuthentication {
        let now = Date()
        let session = AuthenticationSession(
            accessToken: "test-access",
            accessExpiresAt: now.addingTimeInterval(300),
            refreshToken: "test-refresh",
            refreshExpiresAt: now.addingTimeInterval(86_400),
            account: AuthenticatedAccount(
                accountId: UUID(), email: "test@example.invalid", publicName: nil,
                role: role, state: "Active"))
        let client = AuthenticationClient(
            baseURL: URL(string: "https://api.example.invalid")!,
            clientId: "dk.example.admin",
            clientKind: .iOSAdmin,
            store: AdminMemorySessionStore(session: session),
            now: { now })
        return AdminAuthentication(client: client)
    }
}

private actor AdminMemorySessionStore: AuthenticationSessionStoring {
    private var session: AuthenticationSession?

    init(session: AuthenticationSession) { self.session = session }

    func load() -> AuthenticationSession? { session }
    func save(_ session: AuthenticationSession) { self.session = session }
    func clear() { session = nil }
}
