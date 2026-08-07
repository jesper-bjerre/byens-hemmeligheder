using System.Collections.Concurrent;

namespace ByensGaader.Api.Features.Scoring;

internal interface IScoreRepository
{
    public Task<PlayerScore> AddOrGetAsync(PlayerScore score, CancellationToken ct);
    public Task<IReadOnlyList<PlayerScore>> GetAllAsync(CancellationToken ct);
    public Task DeleteForAccountAsync(Guid accountId, CancellationToken ct);
}

internal sealed class InMemoryScoreRepository : IScoreRepository
{
    private readonly ConcurrentDictionary<string, PlayerScore> _scores =
        new(StringComparer.Ordinal);

    public Task<PlayerScore> AddOrGetAsync(PlayerScore score, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_scores.GetOrAdd(Key(score), score));
    }

    public Task<IReadOnlyList<PlayerScore>> GetAllAsync(CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult<IReadOnlyList<PlayerScore>>(_scores.Values.ToArray());
    }

    public Task DeleteForAccountAsync(Guid accountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        foreach (var item in _scores.Where(item => item.Value.AccountId == accountId))
        {
            _scores.TryRemove(item.Key, out _);
        }
        return Task.CompletedTask;
    }

    private static string Key(PlayerScore score) =>
        $"{score.AccountId:D}|{score.MissionId}|{score.ContentVersion}";
}
