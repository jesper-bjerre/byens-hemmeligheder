using System.Security.Claims;
using ByensGaader.Api.Features.Engagement;
using ByensGaader.Api.Security;
using FastEndpoints;

namespace ByensGaader.Api.Features.Scoring;

internal sealed class SubmitScoreEndpoint(ScoreService service)
    : Endpoint<SubmitScoreRequest>
{
    private static readonly HashSet<string> Reasons =
        new(StringComparer.Ordinal) { "missionCompleted", "hintUsed", "wrongAnswer" };

    public override void Configure()
    {
        Put("/scores/missions/{missionId}");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Point"));
    }

    public override async Task HandleAsync(SubmitScoreRequest request, CancellationToken ct)
    {
        var missionId = Route<string>("missionId") ?? string.Empty;
        if (!AddFavoriteEndpoint.MissionId.IsMatch(missionId))
        {
            AddError("Opgave-id'et er ugyldigt.");
        }
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        if (request.EventId == Guid.Empty
            || request.ContentVersion.Length is < 8 or > 128
            || request.Points is < 1 or > 10_000
            || request.CompletedAt > DateTimeOffset.UtcNow.AddMinutes(5)
            || request.Transactions.Count is < 1 or > 20
            || request.Transactions.Any(item =>
                string.IsNullOrWhiteSpace(item.Id)
                || item.Id.Length > 100
                || !Reasons.Contains(item.Reason))
            || request.Transactions.Sum(item => item.Points) != request.Points)
        {
            AddError("Pointindrapporteringen er ugyldig.");
        }
        if (ValidationFailures.Count > 0)
        {
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        if (!await service.MatchesPublishedMissionAsync(
                missionId, request.Points, request.Transactions, ct))
        {
            AddError("Pointene matcher ikke en frigivet opgave.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }

        await service.SubmitAsync(new PlayerScore(
            accountId,
            missionId,
            request.EventId,
            request.ContentVersion,
            request.Points,
            request.CompletedAt,
            request.Transactions), ct);
        await SendNoContentAsync(ct);
    }
}

internal sealed class GetLeaderboardEndpoint(ScoreService service) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/scores/leaderboard");
        AllowAnonymous();
        Description(builder => builder.WithTags("Point"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var period = Query<string>("period", isRequired: false) ?? "allTime";
        if (period is not ("week" or "allTime"))
        {
            AddError("Perioden skal være 'week' eller 'allTime'.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        await SendAsync(await service.LeaderboardAsync(period == "week", ct), cancellation: ct);
    }
}
