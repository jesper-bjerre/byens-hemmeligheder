import AuthenticationServices
import BHAuthenticationKit
import CryptoKit
import Observation
import Security
import SwiftUI

@MainActor
@Observable
final class AdminAuthentication {
    enum State: Equatable {
        case checking
        case signedOut
        case signedIn
        case accessDenied
        case failed(String)
    }

    static let shared = AdminAuthentication()

    let client: AuthenticationClient
    private(set) var state: State = .checking
    private(set) var account: AuthenticatedAccount?

    private convenience init() {
        self.init(client: AuthenticationClient(
            baseURL: AdminConfiguration.backendURL,
            clientId: Bundle.main.bundleIdentifier ?? "dk.hyldenbrandt.byensgaader.admin",
            clientKind: .iOSAdmin,
            store: KeychainAuthenticationSessionStore(namespace: "ios-admin")))
    }

    init(client: AuthenticationClient) {
        self.client = client
    }

    func restore() async {
        state = .checking
        do {
            guard let restored = try await client.restore() else {
                state = .signedOut
                return
            }
            accept(restored)
        } catch {
            state = .signedOut
        }
    }

    func complete(_ result: Result<ASAuthorization, any Error>, rawNonce: String) async {
        state = .checking
        do {
            guard case .success(let authorization) = result,
                  let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = credential.identityToken,
                  let authorizationCode = credential.authorizationCode
            else {
                if case .failure(let error) = result {
                    state = .failed(error.localizedDescription)
                } else {
                    state = .failed(AuthenticationError.invalidAppleCredential.localizedDescription)
                }
                return
            }
            let signedIn = try await client.signIn(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                rawNonce: rawNonce)
            accept(signedIn)
        } catch AuthenticationError.accessDenied {
            state = .accessDenied
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func logout() async {
        await client.logout()
        account = nil
        state = .signedOut
    }

    private func accept(_ value: AuthenticatedAccount) {
        account = value
        if value.role == "Designer" || value.role == "Admin" {
            state = .signedIn
        } else {
            Task { await client.logout() }
            state = .accessDenied
        }
    }
}

struct AdminLoginView: View {
    @Environment(AdminAuthentication.self) private var authentication
    @State private var rawNonce = ""

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "map.fill")
                .font(.system(size: 58))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            VStack(spacing: 8) {
                Text("Koder Admin")
                    .font(.largeTitle.bold())
                Text(message)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if authentication.state == .checking {
                ProgressView("Kontrollerer login …")
            } else {
                SignInWithAppleButton(.signIn) { request in
                    rawNonce = Self.makeNonce()
                    request.requestedScopes = [.email]
                    request.nonce = Self.hash(rawNonce)
                } onCompletion: { result in
                    Task { await authentication.complete(result, rawNonce: rawNonce) }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(32)
        .frame(maxWidth: 460)
    }

    private var message: String {
        switch authentication.state {
        case .accessDenied:
            "Kontoen er godkendt, men har ikke Designer- eller Admin-adgang."
        case .failed(let text): text
        default: "Log ind for at se og vedligeholde opgaver."
        }
    }

    private static func makeNonce() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess
        else { return UUID().uuidString + UUID().uuidString }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func hash(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
