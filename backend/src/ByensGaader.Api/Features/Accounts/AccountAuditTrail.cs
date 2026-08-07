using System.Collections.Concurrent;
using Azure.Data.Tables;
using ByensGaader.Api.Features.Authentication;

namespace ByensGaader.Api.Features.Accounts;

internal sealed record RoleChangeAudit(
    Guid AuditId,
    DateTimeOffset At,
    Guid ActorAccountId,
    Guid TargetAccountId,
    AccountRole FromRole,
    AccountRole ToRole,
    string? Reason);

internal interface IAccountAuditRepository
{
    public Task AppendAsync(RoleChangeAudit value, CancellationToken ct);

    public Task<IReadOnlyList<RoleChangeAudit>> GetForTargetAsync(
        Guid targetAccountId, CancellationToken ct);
}

internal sealed class InMemoryAccountAuditRepository : IAccountAuditRepository
{
    private readonly ConcurrentQueue<RoleChangeAudit> _items = new();

    public Task AppendAsync(RoleChangeAudit value, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        _items.Enqueue(value);
        return Task.CompletedTask;
    }

    public Task<IReadOnlyList<RoleChangeAudit>> GetForTargetAsync(
        Guid targetAccountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        IReadOnlyList<RoleChangeAudit> result = _items
            .Where(item => item.TargetAccountId == targetAccountId)
            .OrderByDescending(item => item.At)
            .ToArray();
        return Task.FromResult(result);
    }
}

internal sealed class TableAccountAuditRepository(
    TableServiceClient service,
    AuthenticationOptions options) : IAccountAuditRepository
{
    private readonly TableClient _table = service.GetTableClient(options.TablePrefix + "RoleAudit");
    private readonly SemaphoreSlim _initialisation = new(1, 1);
    private volatile bool _ready;

    public async Task AppendAsync(RoleChangeAudit value, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var reverseTicks = DateTimeOffset.MaxValue.Ticks - value.At.Ticks;
        await _table.AddEntityAsync(new TableEntity(
            value.TargetAccountId.ToString("D"),
            $"{reverseTicks:D19}-{value.AuditId:N}")
        {
            ["At"] = value.At,
            ["ActorAccountId"] = value.ActorAccountId.ToString("D"),
            ["FromRole"] = value.FromRole.ToString(),
            ["ToRole"] = value.ToRole.ToString(),
            ["Reason"] = value.Reason,
        }, ct);
    }

    public async Task<IReadOnlyList<RoleChangeAudit>> GetForTargetAsync(
        Guid targetAccountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var result = new List<RoleChangeAudit>();
        await foreach (var entity in _table.QueryAsync<TableEntity>(
                           filter: $"PartitionKey eq '{targetAccountId:D}'",
                           cancellationToken: ct))
        {
            var idPart = entity.RowKey[(entity.RowKey.LastIndexOf('-') + 1)..];
            result.Add(new RoleChangeAudit(
                Guid.ParseExact(idPart, "N"),
                entity.GetDateTimeOffset("At")!.Value,
                Guid.Parse(entity.GetString("ActorAccountId")!),
                targetAccountId,
                Enum.Parse<AccountRole>(entity.GetString("FromRole")!),
                Enum.Parse<AccountRole>(entity.GetString("ToRole")!),
                entity.GetString("Reason")));
        }
        return result.OrderByDescending(item => item.At).ToArray();
    }

    private async Task EnsureReadyAsync(CancellationToken ct)
    {
        if (_ready) return;
        await _initialisation.WaitAsync(ct);
        try
        {
            if (_ready) return;
            await _table.CreateIfNotExistsAsync(ct);
            _ready = true;
        }
        finally
        {
            _initialisation.Release();
        }
    }
}
