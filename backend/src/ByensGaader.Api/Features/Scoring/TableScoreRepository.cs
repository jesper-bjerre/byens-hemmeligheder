using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Azure;
using Azure.Data.Tables;
using ByensGaader.Api.Features.Authentication;

namespace ByensGaader.Api.Features.Scoring;

internal sealed class TableScoreRepository(
    TableServiceClient service,
    AuthenticationOptions options) : IScoreRepository
{
    private readonly TableClient _scores = service.GetTableClient(options.TablePrefix + "Scores");
    private readonly SemaphoreSlim _initialisation = new(1, 1);
    private volatile bool _ready;

    public async Task<PlayerScore> AddOrGetAsync(PlayerScore score, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var entity = ToEntity(score);
        try
        {
            await _scores.AddEntityAsync(entity, ct);
            return score;
        }
        catch (RequestFailedException exception) when (exception.Status is 409)
        {
            // Første indrapportering for opgave/version vinder. Et retry eller
            // et genspil kan derfor aldrig give dobbeltpoint.
            var existing = await _scores.GetEntityAsync<TableEntity>(
                entity.PartitionKey, entity.RowKey, cancellationToken: ct);
            return FromEntity(existing.Value);
        }
    }

    public async Task<IReadOnlyList<PlayerScore>> GetAllAsync(CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var result = new List<PlayerScore>();
        await foreach (var entity in _scores.QueryAsync<TableEntity>(cancellationToken: ct))
        {
            result.Add(FromEntity(entity));
        }
        return result;
    }

    public async Task DeleteForAccountAsync(Guid accountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var partition = accountId.ToString("D");
        await foreach (var entity in _scores.QueryAsync<TableEntity>(
                           item => item.PartitionKey == partition,
                           cancellationToken: ct))
        {
            await _scores.DeleteEntityAsync(
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
            await _scores.CreateIfNotExistsAsync(ct);
            _ready = true;
        }
        finally
        {
            _initialisation.Release();
        }
    }

    private static TableEntity ToEntity(PlayerScore value) => new(
        value.AccountId.ToString("D"), RowKey(value.MissionId, value.ContentVersion))
    {
        ["MissionId"] = value.MissionId,
        ["EventId"] = value.EventId.ToString("D"),
        ["ContentVersion"] = value.ContentVersion,
        ["Points"] = value.Points,
        ["CompletedAt"] = value.CompletedAt,
        ["Transactions"] = JsonSerializer.Serialize(value.Transactions),
    };

    private static PlayerScore FromEntity(TableEntity value) => new(
        Guid.Parse(value.PartitionKey),
        value.GetString("MissionId")!,
        Guid.Parse(value.GetString("EventId")!),
        value.GetString("ContentVersion")!,
        value.GetInt32("Points")!.Value,
        value.GetDateTimeOffset("CompletedAt")!.Value,
        JsonSerializer.Deserialize<ScoreLineDto[]>(value.GetString("Transactions")!) ?? []);

    private static string RowKey(string missionId, string contentVersion)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes($"{missionId}|{contentVersion}"));
        return Convert.ToHexStringLower(bytes);
    }
}
