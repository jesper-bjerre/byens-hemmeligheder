using System.Security.Claims;
using System.Text.RegularExpressions;
using ByensGaader.Api.Security;
using FastEndpoints;

namespace ByensGaader.Api.Features.Engagement;

internal sealed class GetMissionEngagementEndpoint(MissionEngagementService service)
    : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/engagement/missions");
        AllowAnonymous();
        Description(builder => builder.WithTags("Engagement"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await SendAsync(await service.GetMetricsAsync(ct), cancellation: ct);
}
internal sealed class GetMyFavoritesEndpoint(MissionEngagementService service)
    : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/engagement/favorites");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Engagement"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        if (!TryAccountId(User, out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        await SendAsync(
            new FavoriteMissionIdsResponse(await service.GetFavoritesAsync(accountId, ct)),
            cancellation: ct);
    }

    internal static bool TryAccountId(ClaimsPrincipal user, out Guid accountId) =>
        Guid.TryParse(user.FindFirstValue(ClaimTypes.NameIdentifier), out accountId);
}

internal sealed class AddFavoriteEndpoint(MissionEngagementService service)
    : EndpointWithoutRequest
{
    public override void Configure()
    {
        Put("/engagement/missions/{missionId}/favorite");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Engagement"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await ChangeAsync(true, ct);

    private async Task ChangeAsync(bool isFavorite, CancellationToken ct)
    {
        var missionId = Route<string>("missionId") ?? string.Empty;
        if (!MissionId.IsMatch(missionId))
        {
            AddError("Opgave-id'et er ugyldigt.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        if (!GetMyFavoritesEndpoint.TryAccountId(User, out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        await service.SetFavoriteAsync(accountId, missionId, isFavorite, ct);
        await SendNoContentAsync(ct);
    }

    internal static readonly Regex MissionId = new(
        "^mission\\.[a-z0-9][a-z0-9.-]{1,158}$",
        RegexOptions.CultureInvariant | RegexOptions.Compiled);
}

internal sealed class RemoveFavoriteEndpoint(MissionEngagementService service)
    : EndpointWithoutRequest
{
    public override void Configure()
    {
        Delete("/engagement/missions/{missionId}/favorite");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Engagement"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var missionId = Route<string>("missionId") ?? string.Empty;
        if (!AddFavoriteEndpoint.MissionId.IsMatch(missionId))
        {
            AddError("Opgave-id'et er ugyldigt.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        if (!GetMyFavoritesEndpoint.TryAccountId(User, out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        await service.SetFavoriteAsync(accountId, missionId, false, ct);
        await SendNoContentAsync(ct);
    }
}
