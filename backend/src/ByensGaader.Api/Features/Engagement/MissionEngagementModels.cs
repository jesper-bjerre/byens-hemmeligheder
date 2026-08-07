namespace ByensGaader.Api.Features.Engagement;

internal sealed record MissionEngagementDto(
    string MissionId,
    int FavoriteCount,
    int TrendingCount);

internal sealed record FavoriteMissionIdsResponse(IReadOnlyList<string> MissionIds);

internal sealed record MissionFavorite(
    Guid AccountId,
    string MissionId,
    DateTimeOffset CreatedAt);
