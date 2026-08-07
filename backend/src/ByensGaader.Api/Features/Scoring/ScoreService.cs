using System.Text.Json.Nodes;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Storage;

namespace ByensGaader.Api.Features.Scoring;

internal sealed class ScoreService(
    IScoreRepository scores,
    IAuthenticationRepository accounts,
    IContentStore content,
    TimeProvider time)
{
    public Task<PlayerScore> SubmitAsync(PlayerScore score, CancellationToken ct) =>
        scores.AddOrGetAsync(score, ct);

    public async Task<bool> MatchesPublishedMissionAsync(
        string missionId,
        int points,
        IReadOnlyList<ScoreLineDto> transactions,
        CancellationToken ct)
    {
        var file = await content.ReadAsync(Path.Combine("da-DK", "content-pack.json"), ct);
        if (file is null) return false;
        var missions = JsonNode.Parse(file.Content)?["missions"]?.AsArray();
        var mission = missions?.FirstOrDefault(item =>
            item?["id"]?.GetValue<string>() == missionId);
        var basePoints = mission?["basePoints"]?.GetValue<int>();
        if (basePoints is null || points > basePoints) return false;

        var completion = transactions.Where(item => item.Reason == "missionCompleted").ToArray();
        return completion.Length == 1
            && completion[0].Points == basePoints
            && transactions.Where(item => item.Reason != "missionCompleted")
                .All(item => item.Points <= 0);
    }

    public async Task<IReadOnlyList<LeaderboardEntryDto>> LeaderboardAsync(
        bool weekly,
        CancellationToken ct)
    {
        var from = time.GetUtcNow().AddDays(-7);
        var raw = await scores.GetAllAsync(ct);

        // Ved en ny indholdsversion tæller kun spillerens seneste resultat for
        // samme opgave. Det forhindrer, at en redaktionel rettelse giver
        // mulighed for at samle grundpointene igen.
        var currentPerMission = raw
            .Where(item => !weekly || item.CompletedAt >= from)
            .GroupBy(item => (item.AccountId, item.MissionId))
            .Select(group => group.MaxBy(item => item.CompletedAt)!)
            .GroupBy(item => item.AccountId)
            .Select(group => new
            {
                AccountId = group.Key,
                Points = group.Sum(item => item.Points),
            })
            .OrderByDescending(item => item.Points)
            .ThenBy(item => item.AccountId)
            .Take(100)
            .ToArray();

        var result = new List<LeaderboardEntryDto>(currentPerMission.Length);
        foreach (var item in currentPerMission)
        {
            var account = await accounts.GetAccountAsync(item.AccountId, ct);
            if (account is null || account.State is not AccountState.Active) continue;
            var name = string.IsNullOrWhiteSpace(account.PublicName)
                ? "Anonym spiller"
                : account.PublicName.Trim();
            result.Add(new LeaderboardEntryDto(name, item.Points));
        }
        return result;
    }
}
