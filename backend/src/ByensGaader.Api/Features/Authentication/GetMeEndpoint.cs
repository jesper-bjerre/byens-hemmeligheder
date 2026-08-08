using System.Security.Claims;
using FastEndpoints;

namespace ByensGaader.Api.Features.Authentication;

internal sealed class GetMeEndpoint(IAuthenticationRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/auth/me");
        Policies(Security.AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var raw = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(raw, out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var account = await repository.GetAccountAsync(accountId, ct);
        if (account is null || account.State is not AccountState.Active)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        await SendAsync(new AuthenticatedAccountDto(
            account.AccountId,
            account.Email,
            account.PublicName,
            account.Role.ToString(),
            account.State.ToString(),
            account.NameModerationState.ToString()), cancellation: ct);
    }
}
