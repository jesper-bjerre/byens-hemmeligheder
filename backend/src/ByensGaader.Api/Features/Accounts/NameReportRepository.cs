using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
using Azure;
using Azure.Data.Tables;
using ByensGaader.Api.Features.Authentication;

namespace ByensGaader.Api.Features.Accounts;

internal enum NameReportCategory
{
    Offensive,
    PersonalInfo,
    Impersonation,
    Other,
}

internal sealed record NameReport(
    Guid ReportId,
    Guid ReporterAccountId,
    string ReportedName,
    NameReportCategory Category,
    DateTimeOffset CreatedAt);

internal sealed record NameReportDto(
    Guid ReportId,
    Guid ReporterAccountId,
    string ReportedName,
    string Category,
    DateTimeOffset CreatedAt);

internal interface INameReportRepository
{
    public Task<bool> AddOncePerDayAsync(NameReport report, CancellationToken ct);
    public Task<IReadOnlyList<NameReport>> GetSinceAsync(DateTimeOffset since, CancellationToken ct);
    public Task DeleteBeforeAsync(DateTimeOffset before, CancellationToken ct);
}

internal sealed class InMemoryNameReportRepository : INameReportRepository
{
    private readonly ConcurrentDictionary<string, NameReport> _items = new(StringComparer.Ordinal);

    public Task<bool> AddOncePerDayAsync(NameReport report, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_items.TryAdd(Key(report), report));
    }

    public Task<IReadOnlyList<NameReport>> GetSinceAsync(DateTimeOffset since, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        IReadOnlyList<NameReport> result = _items.Values
            .Where(item => item.CreatedAt >= since)
            .OrderByDescending(item => item.CreatedAt)
            .ToArray();
        return Task.FromResult(result);
    }

    public Task DeleteBeforeAsync(DateTimeOffset before, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        foreach (var item in _items.Where(item => item.Value.CreatedAt < before))
        {
            _items.TryRemove(item.Key, out _);
        }
        return Task.CompletedTask;
    }

    private static string Key(NameReport report) =>
        $"{report.ReporterAccountId:D}|{report.CreatedAt:yyyyMMdd}|{report.ReportedName.ToUpperInvariant()}";
}

internal sealed class TableNameReportRepository(
    TableServiceClient service,
    AuthenticationOptions options) : INameReportRepository
{
    private readonly TableClient _table = service.GetTableClient(options.TablePrefix + "NameReports");
    private readonly SemaphoreSlim _initialisation = new(1, 1);
    private volatile bool _ready;

    public async Task<bool> AddOncePerDayAsync(NameReport report, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var entity = new TableEntity(
            report.CreatedAt.ToString("yyyyMM"),
            DailyKey(report))
        {
            ["ReportId"] = report.ReportId.ToString("D"),
            ["ReporterAccountId"] = report.ReporterAccountId.ToString("D"),
            ["ReportedName"] = report.ReportedName,
            ["Category"] = report.Category.ToString(),
            ["CreatedAt"] = report.CreatedAt,
        };
        try
        {
            await _table.AddEntityAsync(entity, ct);
            return true;
        }
        catch (RequestFailedException exception) when (exception.Status is 409)
        {
            return false;
        }
    }

    public async Task<IReadOnlyList<NameReport>> GetSinceAsync(
        DateTimeOffset since, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var result = new List<NameReport>();
        var filter = TableClient.CreateQueryFilter($"CreatedAt ge {since}");
        await foreach (var entity in _table.QueryAsync<TableEntity>(
                           filter: filter,
                           cancellationToken: ct))
        {
            result.Add(ToModel(entity));
        }
        return result.OrderByDescending(item => item.CreatedAt).ToArray();
    }

    public async Task DeleteBeforeAsync(DateTimeOffset before, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var filter = TableClient.CreateQueryFilter($"CreatedAt lt {before}");
        await foreach (var entity in _table.QueryAsync<TableEntity>(
                           filter: filter,
                           cancellationToken: ct))
        {
            await _table.DeleteEntityAsync(entity.PartitionKey, entity.RowKey, ETag.All, ct);
        }
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

    private static string DailyKey(NameReport report)
    {
        var source = $"{report.ReporterAccountId:D}|{report.CreatedAt:yyyyMMdd}|{report.ReportedName.ToUpperInvariant()}";
        return Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(source)));
    }

    private static NameReport ToModel(TableEntity value) => new(
        Guid.Parse(value.GetString("ReportId")!),
        Guid.Parse(value.GetString("ReporterAccountId")!),
        value.GetString("ReportedName")!,
        Enum.Parse<NameReportCategory>(value.GetString("Category")!),
        value.GetDateTimeOffset("CreatedAt")!.Value);
}
