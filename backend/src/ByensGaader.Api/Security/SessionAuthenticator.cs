using ByensGaader.Api.Features.Authentication;

namespace ByensGaader.Api.Security;

internal sealed record SessionAuthentication(
    Account Account,
    AuthenticationSession Session);

internal sealed class SessionAuthenticator(
    IAuthenticationRepository repository,
    TimeProvider timeProvider)
{
    public async Task<SessionAuthentication?> AuthenticateAsync(
        string rawToken, CancellationToken ct)
    {
        if (!OpaqueTokenService.TryParse(rawToken, out var sessionId, out var actualHash))
        {
            return null;
        }

        var session = await repository.GetSessionAsync(sessionId, ct);
        var now = timeProvider.GetUtcNow();
        if (session is null || !session.CanAuthenticate(now)
            || !OpaqueTokenService.Matches(session.AccessSecretHash, actualHash))
        {
            return null;
        }

        var account = await repository.GetAccountAsync(session.AccountId, ct);
        return account?.State is AccountState.Active
            ? new SessionAuthentication(account, session)
            : null;
    }
}
