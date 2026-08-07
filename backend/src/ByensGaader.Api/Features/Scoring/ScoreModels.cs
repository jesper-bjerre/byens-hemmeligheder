namespace ByensGaader.Api.Features.Scoring;

internal sealed record ScoreLineDto(string Id, string Reason, int Points);

internal sealed record SubmitScoreRequest(
    Guid EventId,
    string ContentVersion,
    int Points,
    DateTimeOffset CompletedAt,
    IReadOnlyList<ScoreLineDto> Transactions);

internal sealed record PlayerScore(
    Guid AccountId,
    string MissionId,
    Guid EventId,
    string ContentVersion,
    int Points,
    DateTimeOffset CompletedAt,
    IReadOnlyList<ScoreLineDto> Transactions);

internal sealed record LeaderboardEntryDto(string Name, int Points);
