using ByensGaader.Api.Security;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Features.Authentication;

internal sealed class SessionService(
    IAuthenticationRepository repository,
    IOptions<AuthenticationOptions> options,
    TimeProvider time)
{
    public async Task<IssuedSession?> IssueNativeAsync(
        Account account, AuthenticationClientKind clientKind, CancellationToken ct)
    {
        if (clientKind is not (AuthenticationClientKind.IOSPlayer
            or AuthenticationClientKind.IOSAdmin))
        {
            return null;
        }

        var now = time.GetUtcNow();
        var access = OpaqueTokenService.Create();
        var refresh = OpaqueTokenService.CreateForId(access.Id);
        var accessExpires = now.AddMinutes(options.Value.AccessMinutes);
        var refreshExpires = now.AddDays(options.Value.NativeRefreshDays);
        var session = new AuthenticationSession(
            access.Id,
            account.AccountId,
            clientKind,
            access.SecretHash,
            accessExpires,
            refresh.SecretHash,
            null,
            refreshExpires,
            now,
            now);
        return await repository.CreateSessionAsync(session, ct)
            ? new IssuedSession(
                access.Value, accessExpires, refresh.Value, refreshExpires, account)
            : null;
    }

    public async Task<IssuedSession?> IssueWebAsync(
        Account account, AuthenticationClientKind clientKind, CancellationToken ct)
    {
        if (clientKind is not (AuthenticationClientKind.WebPlayer
            or AuthenticationClientKind.WebAdmin))
        {
            return null;
        }

        var now = time.GetUtcNow();
        var access = OpaqueTokenService.Create();
        var accessExpires = now.AddMinutes(options.Value.WebAccessMinutes);
        var session = new AuthenticationSession(
            access.Id,
            account.AccountId,
            clientKind,
            access.SecretHash,
            accessExpires,
            null,
            null,
            null,
            now,
            now);
        return await repository.CreateSessionAsync(session, ct)
            ? new IssuedSession(access.Value, accessExpires, null, null, account)
            : null;
    }

    public async Task<IssuedSession?> RefreshNativeAsync(
        string rawRefreshToken, CancellationToken ct)
    {
        if (!OpaqueTokenService.TryParse(
                rawRefreshToken, out var sessionId, out var presentedHash))
        {
            return null;
        }

        for (var attempt = 0; attempt < 3; attempt++)
        {
            var now = time.GetUtcNow();
            var session = await repository.GetSessionAsync(sessionId, ct);
            if (session is null
                || session.ClientKind is not (AuthenticationClientKind.IOSPlayer
                    or AuthenticationClientKind.IOSAdmin)
                || session.RevokedAt is not null
                || session.RefreshExpiresAt is null
                || session.RefreshExpiresAt <= now)
            {
                return null;
            }

            if (session.PreviousRefreshHash is not null
                && OpaqueTokenService.Matches(
                    session.PreviousRefreshHash, presentedHash))
            {
                var revoked = session with
                {
                    RevokedAt = now,
                    RevokeReason = "refresh-replay",
                };
                if (await repository.UpdateSessionAsync(revoked, session.ETag, ct))
                {
                    return null;
                }
                continue;
            }

            if (session.RefreshSecretHash is null
                || !OpaqueTokenService.Matches(session.RefreshSecretHash, presentedHash))
            {
                return null;
            }

            var account = await repository.GetAccountAsync(session.AccountId, ct);
            if (account?.State is not AccountState.Active)
            {
                return null;
            }

            var access = OpaqueTokenService.CreateForId(session.SessionId);
            var refresh = OpaqueTokenService.CreateForId(session.SessionId);
            var accessExpires = now.AddMinutes(options.Value.AccessMinutes);
            var rotated = session with
            {
                AccessSecretHash = access.SecretHash,
                AccessExpiresAt = accessExpires,
                PreviousRefreshHash = session.RefreshSecretHash,
                RefreshSecretHash = refresh.SecretHash,
                RotatedAt = now,
            };
            if (await repository.UpdateSessionAsync(rotated, session.ETag, ct))
            {
                return new IssuedSession(
                    access.Value,
                    accessExpires,
                    refresh.Value,
                    session.RefreshExpiresAt,
                    account);
            }
        }

        return null;
    }

    public async Task<bool> RevokeAsync(string sessionId, string reason, CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var current = await repository.GetSessionAsync(sessionId, ct);
            if (current is null || current.RevokedAt is not null)
            {
                return true;
            }
            var revoked = current with
            {
                RevokedAt = time.GetUtcNow(),
                RevokeReason = reason,
            };
            if (await repository.UpdateSessionAsync(revoked, current.ETag, ct))
            {
                return true;
            }
        }
        return false;
    }
}
