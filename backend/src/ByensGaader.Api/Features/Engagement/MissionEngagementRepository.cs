using System.Collections.Concurrent;

namespace ByensGaader.Api.Features.Engagement;

internal interface IMissionEngagementRepository
{
    public Task SetFavoriteAsync(
        Guid accountId,
        string missionId,
        bool isFavorite,
        DateTimeOffset now,
        CancellationToken ct);

    public Task<IReadOnlyList<string>> GetFavoritesAsync(Guid accountId, CancellationToken ct);

    public Task<IReadOnlyList<MissionFavorite>> GetAllFavoritesAsync(CancellationToken ct);

    public Task DeleteForAccountAsync(Guid accountId, CancellationToken ct);
}

internal sealed class InMemoryMissionEngagementRepository : IMissionEngagementRepository
{
    private readonly ConcurrentDictionary<(Guid AccountId, string MissionId), DateTimeOffset>
        _favorites = new();

    public Task SetFavoriteAsync(
        Guid accountId,
        string missionId,
        bool isFavorite,
        DateTimeOffset now,
        CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        var key = (accountId, missionId);
        if (isFavorite)
        {
            // Et gentaget PUT må ikke flytte favoritdatoen og dermed kunstigt
            // holde en opgave i 30-dages-listen.
            _favorites.TryAdd(key, now);
        }
        else
        {
            _favorites.TryRemove(key, out _);
        }
        return Task.CompletedTask;
    }

    public Task<IReadOnlyList<string>> GetFavoritesAsync(
        Guid accountId,
        CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        IReadOnlyList<string> result = _favorites.Keys
            .Where(key => key.AccountId == accountId)
            .Select(key => key.MissionId)
            .Order(StringComparer.Ordinal)
            .ToArray();
        return Task.FromResult(result);
    }

    public Task<IReadOnlyList<MissionFavorite>> GetAllFavoritesAsync(CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        IReadOnlyList<MissionFavorite> result = _favorites
            .Select(item => new MissionFavorite(
                item.Key.AccountId,
                item.Key.MissionId,
                item.Value))
            .ToArray();
        return Task.FromResult(result);
    }

    public Task DeleteForAccountAsync(Guid accountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        foreach (var key in _favorites.Keys.Where(key => key.AccountId == accountId))
        {
            _favorites.TryRemove(key, out _);
        }
        return Task.CompletedTask;
    }
}
