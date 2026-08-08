import BHAuthenticationKit
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing

@Suite(.serialized)
struct AuthenticationClientTests {
    @Test func keychain_kan_gemme_indlaese_og_rydde_en_session() async throws {
        let store = KeychainAuthenticationSessionStore(
            namespace: "test-\(UUID().uuidString)")
        let expected = session(access: "lokal-access", refresh: "lokal-refresh", accessOffset: 300)

        try await store.save(expected)
        #expect(try await store.load() == expected)

        try await store.clear()
        #expect(try await store.load() == nil)
    }

    @Test func login_gemmer_session_og_authorizedData_sender_bearer() async throws {
        let store = MemorySessionStore()
        let transport = MockTransport()
        transport.responses = [
            .json(201, sessionJSON(access: "access-1", refresh: "refresh-1")),
            .json(200, "{}"),
        ]
        let client = makeClient(store: store, transport: transport)

        let account = try await client.signIn(
            identityToken: Data("identity".utf8),
            authorizationCode: Data("code".utf8),
            rawNonce: String(repeating: "n", count: 32))
        _ = try await client.authorizedData(
            for: URLRequest(url: URL(string: "https://api.test/authoring")!))

        #expect(account.role == "Designer")
        #expect(await store.value?.accessToken == "access-1")
        #expect(transport.requests.last?.value(forHTTPHeaderField: "Authorization")
            == "Bearer access-1")
    }

    @Test func udloebet_access_roterer_refresh_og_gemmer_det_nye_token() async throws {
        let store = MemorySessionStore()
        await store.set(session(access: "gammelt", refresh: "refresh-1", accessOffset: -1))
        let transport = MockTransport()
        transport.responses = [
            .json(200, sessionJSON(access: "nyt", refresh: "refresh-2")),
            .json(200, "{}"),
        ]
        let client = makeClient(store: store, transport: transport)
        _ = try await client.restore()

        _ = try await client.authorizedData(
            for: URLRequest(url: URL(string: "https://api.test/beskyttet")!))

        #expect(await store.value?.refreshToken == "refresh-2")
        #expect(transport.requests.last?.value(forHTTPHeaderField: "Authorization")
            == "Bearer nyt")
    }

    @Test func logout_rydder_keychain_selv_hvis_netvaerket_fejler() async throws {
        let store = MemorySessionStore()
        await store.set(session(access: "access", refresh: "refresh", accessOffset: 300))
        let transport = MockTransport()
        transport.responses = [.json(500, "{}")]
        let client = makeClient(store: store, transport: transport)
        _ = try await client.restore()

        await client.logout()

        #expect(await store.value == nil)
        #expect(await client.account() == nil)
    }

    @Test func kontosletning_kraever_serversucces_og_rydder_derefter_sessionen() async throws {
        let store = MemorySessionStore()
        await store.set(session(access: "access", refresh: "refresh", accessOffset: 300))
        let transport = MockTransport()
        transport.responses = [.json(204, "")]
        let client = makeClient(store: store, transport: transport)
        _ = try await client.restore()

        try await client.deleteAccount()

        #expect(await store.value == nil)
        #expect(await client.account() == nil)
        #expect(transport.requests.last?.httpMethod == "DELETE")
        #expect(transport.requests.last?.url?.path == "/auth/me")
    }

    @Test func fejlet_kontosletning_bevarer_sessionen() async throws {
        let store = MemorySessionStore()
        await store.set(session(access: "access", refresh: "refresh", accessOffset: 300))
        let transport = MockTransport()
        transport.responses = [.json(500, "{}")]
        let client = makeClient(store: store, transport: transport)
        _ = try await client.restore()

        await #expect(throws: AuthenticationError.server(500)) {
            try await client.deleteAccount()
        }

        #expect(await store.value != nil)
        #expect(await client.account() != nil)
    }

    @Test func profilnavn_opdateres_paa_serveren_og_i_keychain() async throws {
        let store = MemorySessionStore()
        await store.set(session(access: "access", refresh: "refresh", accessOffset: 300))
        let transport = MockTransport()
        transport.responses = [.json(200, accountJSON(publicName: "Åse Ørn"))]
        let client = makeClient(store: store, transport: transport)
        _ = try await client.restore()

        let account = try await client.updatePublicName("Åse Ørn")

        #expect(account.publicName == "Åse Ørn")
        #expect(await store.value?.account.publicName == "Åse Ørn")
        #expect(transport.requests.last?.httpMethod == "PUT")
        #expect(transport.requests.last?.url?.path == "/auth/me/profile")
    }

    @Test func navnerapport_sendes_med_fast_kategori() async throws {
        let store = MemorySessionStore()
        await store.set(session(access: "access", refresh: "refresh", accessOffset: 300))
        let transport = MockTransport()
        transport.responses = [.json(204, "")]
        let client = makeClient(store: store, transport: transport)
        _ = try await client.restore()

        try await client.reportPublicName("Uegnet navn", category: .offensive)

        #expect(transport.requests.last?.httpMethod == "POST")
        #expect(transport.requests.last?.url?.path == "/scores/name-reports")
    }

    private func makeClient(
        store: MemorySessionStore,
        transport: MockTransport
    ) -> AuthenticationClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.transport = transport
        return AuthenticationClient(
            baseURL: URL(string: "https://api.test")!,
            clientId: "dk.example.app",
            clientKind: .iOSAdmin,
            store: store,
            network: URLSession(configuration: configuration),
            now: { Date(timeIntervalSince1970: 1_786_016_000) })
    }
}

private actor MemorySessionStore: AuthenticationSessionStoring {
    var value: AuthenticationSession?

    func set(_ value: AuthenticationSession?) { self.value = value }
    func load() -> AuthenticationSession? { value }
    func save(_ session: AuthenticationSession) { value = session }
    func clear() { value = nil }
}

private final class MockTransport: @unchecked Sendable {
    var responses: [MockResponse] = []
    var requests: [URLRequest] = []

    func next(_ request: URLRequest) -> MockResponse {
        requests.append(request)
        return responses.removeFirst()
    }
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var transport: MockTransport!

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let response = Self.transport.next(request)
        client?.urlProtocol(
            self,
            didReceive: HTTPURLResponse(
                url: request.url!,
                statusCode: response.status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private struct MockResponse {
    let status: Int
    let data: Data

    static func json(_ status: Int, _ value: String) -> Self {
        Self(status: status, data: Data(value.utf8))
    }
}

private func session(access: String, refresh: String, accessOffset: TimeInterval)
    -> AuthenticationSession {
    let now = Date(timeIntervalSince1970: 1_786_016_000)
    return AuthenticationSession(
        accessToken: access,
        accessExpiresAt: now.addingTimeInterval(accessOffset),
        refreshToken: refresh,
        refreshExpiresAt: now.addingTimeInterval(86_400),
        account: AuthenticatedAccount(
            accountId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            email: nil,
            publicName: nil,
            role: "Designer",
            state: "Active"))
}

private func sessionJSON(access: String, refresh: String) -> String {
    """
    {
      "accessToken":"\(access)",
      "accessExpiresAt":"2030-01-01T12:00:00Z",
      "refreshToken":"\(refresh)",
      "refreshExpiresAt":"2030-01-30T12:00:00Z",
      "account":{
        "accountId":"11111111-1111-1111-1111-111111111111",
        "email":null,
        "publicName":null,
        "role":"Designer",
        "state":"Active"
      }
    }
    """
}

private func accountJSON(publicName: String) -> String {
    """
    {
      "accountId":"11111111-1111-1111-1111-111111111111",
      "email":null,
      "publicName":"\(publicName)",
      "role":"Designer",
      "state":"Active",
      "nameModerationState":"Visible"
    }
    """
}
