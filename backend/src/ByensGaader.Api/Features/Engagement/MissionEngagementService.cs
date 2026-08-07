using Microsoft.Extensions.Caching.Memory;

namespace ByensGaader.Api.Features.Engagement;

internal sealed class MissionEngagementService(
    IMissionEngagementRepository repository,
    IMemoryCache cache,
    TimeProvider timeProvider)
{
    private const string MetricsCacheKey = "mission-engagement-metrics";

    public async Task SetFavoriteAsync(
        Guid accountId,
        string missionId,
        bool isFavorite,
        CancellationToken ct)
    {
        await repository.SetFavoriteAsync(
            accountId, missionId, isFavorite, timeProvider.GetUtcNow(), ct);
        cache.Remove(MetricsCacheKey);
    }

    public Task<IReadOnlyList<string>> GetFavoritesAsync(Guid accountId, CancellationToken ct) =>
        repository.GetFavoritesAsync(accountId, ct);

    public async Task<IReadOnlyList<MissionEngagementDto>> GetMetricsAsync(CancellationToken ct)
    {
        if (cache.TryGetValue<IReadOnlyList<MissionEngagementDto>>(
                MetricsCacheKey, out var cached))
        {
            return cached!;
        }

        var since = timeProvider.GetUtcNow().AddDays(-30);
        var favorites = await repository.GetAllFavoritesAsync(ct);
        IReadOnlyList<MissionEngagementDto> result = favorites
            .GroupBy(item => item.MissionId, StringComparer.Ordinal)
            .Select(group => new MissionEngagementDto(
                group.Key,
                group.Count(),
                group.Count(item => item.CreatedAt >= since)))
            .OrderByDescending(item => item.FavoriteCount)
            .ThenBy(item => item.MissionId, StringComparer.Ordinal)
            .ToArray();

        cache.Set(MetricsCacheKey, result, TimeSpan.FromMinutes(1));
        return result;
    }
}
