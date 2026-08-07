using ByensGaader.Api.Security;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Features.Authentication;

internal sealed record AppleSignInResult(IssuedSession Session, bool AccountCreated);

internal sealed class AccountService(
    IAuthenticationRepository repository,
    IProviderTokenProtector tokenProtector,
    SessionService sessions,
    IOptions<AuthenticationOptions> options,
    TimeProvider time)
{
    public async Task<AppleSignInResult?> SignInWithAppleAsync(
        ValidatedAppleIdentity apple,
        string providerRefreshToken,
        string providerClientId,
        AuthenticationClientKind clientKind,
        CancellationToken ct)
    {
        var now = time.GetUtcNow();
        var protectedRefresh = tokenProtector.Protect(providerRefreshToken);
        var identity = await repository.GetIdentityAsync(
            "apple", apple.SubjectHash, ct);

        if (identity is null)
        {
            var candidate = new ExternalIdentity(
                "apple",
                apple.SubjectHash,
                Guid.NewGuid(),
                now,
                now,
                protectedRefresh,
                ProviderClientId: providerClientId);
            if (await repository.CreateIdentityAsync(candidate, ct))
            {
                identity = candidate;
            }
            else
            {
                identity = await repository.GetIdentityAsync(
                    "apple", apple.SubjectHash, ct);
            }
        }

        if (identity is null)
        {
            return null;
        }

        var account = await repository.GetAccountAsync(identity.AccountId, ct);
        var accountCreated = false;
        if (account is null)
        {
            var role = await ShouldBootstrapAdminAsync(apple, identity.AccountId, ct)
                ? AccountRole.Admin
                : AccountRole.User;
            var candidate = new Account(
                identity.AccountId,
                apple.EmailVerified ? apple.Email : null,
                null,
                role,
                AccountState.Active,
                now,
                now);
            accountCreated = await repository.CreateAccountAsync(candidate, ct);
            account = accountCreated
                ? candidate
                : await repository.GetAccountAsync(identity.AccountId, ct);
        }

        if (account?.State is not AccountState.Active)
        {
            return null;
        }

        // Et login må ikke lykkes, hvis den roterede provider-legitimation
        // ikke kan gemmes. Ellers udsteder vi en lokal session oven på en
        // identitet, hvis revocation-/genvalideringsspor allerede er forældet.
        if (!await UpdateIdentityAsync(
                identity, protectedRefresh, providerClientId, now, ct))
        {
            return null;
        }
        account = await UpdateLastSignInAsync(account, apple, now, ct);
        var session = clientKind is AuthenticationClientKind.WebAdmin
            or AuthenticationClientKind.WebPlayer
            ? await sessions.IssueWebAsync(account, clientKind, ct)
            : await sessions.IssueNativeAsync(account, clientKind, ct);
        return session is null ? null : new AppleSignInResult(session, accountCreated);
    }

    private async Task<bool> ShouldBootstrapAdminAsync(
        ValidatedAppleIdentity apple, Guid accountId, CancellationToken ct)
    {
        var configured = options.Value.Apple.BootstrapAdminEmail.Trim();
        return apple.EmailVerified
            && !string.IsNullOrWhiteSpace(apple.Email)
            && !string.IsNullOrWhiteSpace(configured)
            && string.Equals(
                apple.Email.Trim(), configured, StringComparison.OrdinalIgnoreCase)
            && await repository.TryClaimBootstrapAdminAsync(accountId, ct);
    }

    private async Task<bool> UpdateIdentityAsync(
        ExternalIdentity identity,
        string protectedRefresh,
        string providerClientId,
        DateTimeOffset now,
        CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var updated = identity with
            {
                LastValidatedAt = now,
                EncryptedProviderRefreshToken = protectedRefresh,
                ProviderClientId = providerClientId,
                RevokedAt = null,
            };
            if (await repository.UpdateIdentityAsync(updated, identity.ETag, ct))
            {
                return true;
            }
            identity = await repository.GetIdentityAsync(
                identity.Provider, identity.ProviderSubjectHash, ct) ?? identity;
        }
        return false;
    }

    private async Task<Account> UpdateLastSignInAsync(
        Account account,
        ValidatedAppleIdentity apple,
        DateTimeOffset now,
        CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var updated = account with
            {
                Email = apple.EmailVerified && !string.IsNullOrWhiteSpace(apple.Email)
                    ? apple.Email
                    : account.Email,
                LastSignedInAt = now,
            };
            if (await repository.UpdateAccountAsync(updated, account.ETag, ct))
            {
                return updated;
            }
            account = await repository.GetAccountAsync(account.AccountId, ct) ?? account;
        }
        return account;
    }
}
