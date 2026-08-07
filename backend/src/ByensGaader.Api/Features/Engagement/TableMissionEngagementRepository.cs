using Azure;
using Azure.Data.Tables;
using ByensGaader.Api.Features.Authentication;

namespace ByensGaader.Api.Features.Engagement;

internal sealed class TableMissionEngagementRepository(
    TableServiceClient service,
    AuthenticationOptions options) : IMissionEngagementRepository
{
    private readonly TableClient _favorites =
        service.GetTableClient(options.TablePrefix + "Favorites");
    private readonly SemaphoreSlim _initialisation = new(1, 1);
    private volatile bool _ready;

    public async Task SetFavoriteAsync(
        Guid accountId,
        string missionId,
        bool isFavorite,
        DateTimeOffset now,
        CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var partition = accountId.ToString("D");
        if (isFavorite)
        {
            try
            {
                await _favorites.AddEntityAsync(new TableEntity(partition, missionId)
                {
                    ["CreatedAt"] = now,
                }, ct);
            }
            catch (RequestFailedException exception) when (exception.Status is 409)
            {
                // PUT er idempotent. Den oprindelige dato bevares, så gentagne
                // kald ikke kan manipulere 30-dages-rangeringen.
            }
            return;
        }

        try
        {
            await _favorites.DeleteEntityAsync(partition, missionId, ETag.All, ct);
        }
        catch (RequestFailedException exception) when (exception.Status is 404)
        {
            // DELETE er idempotent.
        }
    }

    public async Task<IReadOnlyList<string>> GetFavoritesAsync(
        Guid accountId,
        CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var result = new List<string>();
        await foreach (var entity in _favorites.QueryAsync<TableEntity>(
                           item => item.PartitionKey == accountId.ToString("D"),
                           cancellationToken: ct))
        {
            result.Add(entity.RowKey);
        }
        result.Sort(StringComparer.Ordinal);
        return result;
    }

    public async Task<IReadOnlyList<MissionFavorite>> GetAllFavoritesAsync(
        CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var result = new List<MissionFavorite>();
        await foreach (var entity in _favorites.QueryAsync<TableEntity>(cancellationToken: ct))
        {
            if (Guid.TryParse(entity.PartitionKey, out var accountId)
                && entity.GetDateTimeOffset("CreatedAt") is { } createdAt)
            {
                result.Add(new MissionFavorite(accountId, entity.RowKey, createdAt));
            }
        }
        return result;
    }

    public async Task DeleteForAccountAsync(Guid accountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var partition = accountId.ToString("D");
        await foreach (var entity in _favorites.QueryAsync<TableEntity>(
                           item => item.PartitionKey == partition,
                           cancellationToken: ct))
        {
            await _favorites.DeleteEntityAsync(
                entity.PartitionKey, entity.RowKey, ETag.All, ct);
        }
    }

    private async Task EnsureReadyAsync(CancellationToken ct)
    {
        if (_ready) return;
        await _initialisation.WaitAsync(ct);
        try
        {
            if (_ready) return;
            await _favorites.CreateIfNotExistsAsync(ct);
            _ready = true;
        }
        finally
        {
            _initialisation.Release();
        }
    }
}
