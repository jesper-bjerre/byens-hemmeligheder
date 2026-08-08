import AuthenticationServices
import BHAuthenticationKit
import BHDesignSystem
import CryptoKit
import Observation
import Security
import SwiftUI

/// Frivillig konto for spillerappen.
///
/// Gæstespil er et fuldt flow. Derfor må hverken manglende netværk, en udløbet
/// session eller et afbrudt Apple-login blokere kortet og opgaverne.
@MainActor
@Observable
final class PlayerAuthentication {
    enum State: Equatable {
        case checking
        case guest
        case signedIn
        case failed(String)
    }

    static let shared = PlayerAuthentication()

    let client: AuthenticationClient
    private(set) var state: State = .checking
    private(set) var account: AuthenticatedAccount?

    private init() {
        client = AuthenticationClient(
            baseURL: ContentEndpoint.requiredBaseURL,
            clientId: Bundle.main.bundleIdentifier ?? "dk.hyldenbrandt.byensgaader",
            clientKind: .iOSPlayer,
            store: KeychainAuthenticationSessionStore(namespace: "ios-player"))
    }

    func restore() async {
        do {
            guard let restored = try await client.restore() else {
                state = .guest
                return
            }
            account = restored
            state = .signedIn
        } catch {
            // Kontoen er frivillig. En fejl må aldrig blive en startskærm, der
            // spærrer en familie ude fra de lokale opgaver.
            account = nil
            state = .guest
        }
    }

    func complete(_ result: Result<ASAuthorization, any Error>, rawNonce: String) async {
        do {
            guard case .success(let authorization) = result,
                  let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = credential.identityToken,
                  let authorizationCode = credential.authorizationCode
            else {
                if case .failure(let error) = result,
                   (error as? ASAuthorizationError)?.code == .canceled {
                    state = .guest
                } else {
                    state = .failed("Apple-login kunne ikke gennemføres. Prøv igen.")
                }
                return
            }

            state = .checking
            account = try await client.signIn(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                rawNonce: rawNonce)
            state = .signedIn
        } catch {
            account = nil
            state = .failed(error.localizedDescription)
        }
    }

    func logout() async {
        await client.logout()
        account = nil
        state = .guest
    }

    func deleteAccount() async throws {
        try await client.deleteAccount()
        account = nil
        state = .guest
    }

    func updatePublicName(_ publicName: String?) async throws {
        account = try await client.updatePublicName(publicName)
    }

    func reportPublicName(
        _ publicName: String,
        category: PublicNameReportCategory
    ) async throws {
        try await client.reportPublicName(publicName, category: category)
    }

    /// Holder UI'et i takt med klientens Keychain-session.
    ///
    /// ``AuthenticationClient`` rydder selv en afvist refresh-session. Uden
    /// denne tilbagemelding blev spillerappen imidlertid stående som logget
    /// ind og forsøgte efterfølgende konto-kald med en session, der ikke
    /// længere fandtes.
    func handleAuthenticationFailure(_ error: any Error) {
        guard let authenticationError = error as? AuthenticationError,
              authenticationError == .notAuthenticated
                || authenticationError == .sessionExpired
        else { return }
        account = nil
        state = .guest
    }
}

/// Loginfladen ejer nonce-værdien, så den samme tilfældige værdi kan bindes
/// til Apples request og backendens efterfølgende validering.
struct PlayerAccountCard: View {
    enum Purpose {
        case general
        case leaderboard
    }

    var purpose: Purpose = .general

    @Environment(PlayerAuthentication.self) private var authentication
    @State private var rawNonce = ""

    var body: some View {
        BHCard {
            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                Label(title, systemImage: authentication.state == .signedIn ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle")
                    .font(BHFont.heading)
                    .foregroundStyle(BHColor.ink)

                Text(message)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

                switch authentication.state {
                case .signedIn:
                    Button("Log ud", role: .destructive) {
                        Task { await authentication.logout() }
                    }
                    .buttonStyle(.bordered)

                case .checking:
                    ProgressView("Kontrollerer login …")

                case .guest, .failed:
                    SignInWithAppleButton(.signIn) { request in
                        rawNonce = Self.makeNonce()
                        request.requestedScopes = [.email]
                        request.nonce = Self.hash(rawNonce)
                    } onCompletion: { result in
                        Task { await authentication.complete(result, rawNonce: rawNonce) }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("scoreboard.account")
    }

    private var title: String {
        if authentication.state == .signedIn { return "Du er logget ind" }
        return purpose == .leaderboard ? "Gem favoritter og point" : "Spil med eller uden konto"
    }

    private var message: String {
        switch authentication.state {
        case .signedIn:
            authentication.account?.email ?? "Din Apple-konto er forbundet."
        case .failed(let text):
            "\(text) Du kan stadig spille videre som gæst."
        default:
            if purpose == .leaderboard {
                "Log ind med Apple for at gemme favoritter og få dine point med på highscorelisterne. Som gæst kan du stadig finde og løse alle frigivne gåder."
            } else {
                "Login er frivilligt. Som gæst kan du stadig finde og løse alle frigivne gåder."
            }
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
