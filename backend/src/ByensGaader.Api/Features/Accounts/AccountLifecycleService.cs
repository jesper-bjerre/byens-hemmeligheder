using System.Security.Claims;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Features.Engagement;
using ByensGaader.Api.Features.Scoring;
using ByensGaader.Api.Security;
using FastEndpoints;

namespace ByensGaader.Api.Features.Accounts;

internal enum DeleteAccountResult
{
    Deleted,
    NotFound,
    RequiresDemotion,
    Conflict,
}

internal sealed class AccountLifecycleService(
    IAuthenticationRepository accounts,
    SessionService sessions,
    IAppleTokenClient appleTokens,
    IProviderTokenProtector tokenProtector,
    IMissionEngagementRepository engagement,
    IScoreRepository scores,
    TimeProvider time,
    ILogger<AccountLifecycleService> logger)
{
    public Task<DeleteAccountResult> DeleteAsync(Guid accountId, CancellationToken ct) =>
        DeleteCoreAsync(accountId, allowEditorialAccount: false, revokeAtApple: true, ct);

    public Task<DeleteAccountResult> DeleteFromProviderAsync(
        Guid accountId, CancellationToken ct) =>
        DeleteCoreAsync(accountId, allowEditorialAccount: true, revokeAtApple: false, ct);

    private async Task<DeleteAccountResult> DeleteCoreAsync(
        Guid accountId,
        bool allowEditorialAccount,
        bool revokeAtApple,
        CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var account = await accounts.GetAccountAsync(accountId, ct);
            if (account is null) return DeleteAccountResult.NotFound;
            if (account.State is AccountState.Deleted) return DeleteAccountResult.Deleted;
            if (!allowEditorialAccount && account.Role is not AccountRole.User)
            {
                return DeleteAccountResult.RequiresDemotion;
            }

            var deleted = account with
            {
                Email = null,
                PublicName = null,
                State = AccountState.Deleted,
                DeletedAt = time.GetUtcNow(),
            };
            if (!await accounts.UpdateAccountAsync(deleted, account.ETag, ct))
            {
                continue;
            }

            // Kontoens tilstand afviser straks alle tokens. De eksplicitte
            // revocations bevarer også forklaringen i sessionslageret.
            foreach (var session in await accounts.GetSessionsForAccountAsync(accountId, ct))
            {
                await sessions.RevokeAsync(session.SessionId, "account-deleted", ct);
            }
            foreach (var identity in await accounts.GetIdentitiesForAccountAsync(accountId, ct))
            {
                if (revokeAtApple)
                {
                    await RevokeProviderTokenAsync(identity, ct);
                }
                await DeleteIdentityWithRetryAsync(identity, ct);
            }
            await engagement.DeleteForAccountAsync(accountId, ct);
            await scores.DeleteForAccountAsync(accountId, ct);
            return DeleteAccountResult.Deleted;
        }
        return DeleteAccountResult.Conflict;
    }

    private async Task RevokeProviderTokenAsync(
        ExternalIdentity identity, CancellationToken ct)
    {
        if (identity.Provider is not "apple"
            || string.IsNullOrWhiteSpace(identity.EncryptedProviderRefreshToken)
            || string.IsNullOrWhiteSpace(identity.ProviderClientId))
        {
            return;
        }
        var refreshToken = tokenProtector.Unprotect(identity.EncryptedProviderRefreshToken);
        if (refreshToken is null
            || !await appleTokens.RevokeRefreshTokenAsync(
                refreshToken, identity.ProviderClientId, ct))
        {
            // Brugerens lokale sletning må ikke afhænge af Apples oppetid. Der
            // logges ingen identifikator eller token, kun den driftsmæssige fejl.
            logger.LogWarning(
                "Apple-legitimationen kunne ikke tilbagekaldes under kontosletning.");
        }
    }

    private async Task DeleteIdentityWithRetryAsync(
        ExternalIdentity identity, CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            if (await accounts.DeleteIdentityAsync(identity, identity.ETag, ct)) return;
            identity = await accounts.GetIdentityAsync(
                identity.Provider, identity.ProviderSubjectHash, ct) ?? identity;
        }
        throw new InvalidOperationException(
            "Apple-identiteten kunne ikke fjernes efter kontosletning.");
    }
}

internal sealed class DeleteMeEndpoint(AccountLifecycleService lifecycle)
    : EndpointWithoutRequest
{
    public override void Configure()
    {
        Delete("/auth/me");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        switch (await lifecycle.DeleteAsync(accountId, ct))
        {
            case DeleteAccountResult.Deleted:
                await SendNoContentAsync(ct);
                break;
            case DeleteAccountResult.NotFound:
                await SendNotFoundAsync(ct);
                break;
            case DeleteAccountResult.RequiresDemotion:
                AddError("Designer- og Admin-konti skal ændres til User af en Admin før sletning.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
            default:
                AddError("Kontoen blev ændret samtidig. Prøv igen.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
        }
    }
}
