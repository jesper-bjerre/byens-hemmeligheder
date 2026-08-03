using System.Diagnostics;
using System.Diagnostics.Metrics;
using ByensGaader.Api.Storage;

namespace ByensGaader.Api.Features.Content;

internal sealed class ContentPublisher(
    AuthoringRepository repository,
    ContentStores stores,
    TimeProvider time,
    ILogger<ContentPublisher> logger)
{
    private static readonly Meter Meter = new("ByensGaader.Content", "1.0");
    private static readonly Histogram<double> Duration = Meter.CreateHistogram<double>(
        "content.publish.duration", "ms");
    private static readonly Counter<long> LeaseConflicts = Meter.CreateCounter<long>(
        "content.publish.lease_contentions");

    public async Task EnsureReadyAsync(string locale, CancellationToken ct)
    {
        await repository.EnsureBootstrappedAsync(locale, ct);
        await PublishPendingAsync(locale, ct);
    }

    public async Task<AuthoringWriteResult> ExecuteAsync(
        string locale,
        string id,
        Func<CancellationToken, Task<WriteOutcome>> mutation,
        Func<CancellationToken, Task<AuthoringDocument?>> readAfter,
        CancellationToken ct)
    {
        await EnsureReadyAsync(locale, ct);
        await using var lease = await stores.Authoring.AcquireLeaseAsync(
            AuthoringPaths.Lock(locale), ct);
        RecordContention(lease);

        var original = await repository.ReadStateAsync(locale, ct)
            ?? throw new InvalidOperationException("Publication-state mangler efter bootstrap.");
        var requestId = Guid.NewGuid().ToString("N");
        var dirty = original.Value with
        {
            RequestedId = requestId,
            RequestedAt = time.GetUtcNow(),
            LastErrorCode = null,
            Attempts = 0,
        };
        if (await repository.WriteStateAsync(locale, dirty, original.ETag, ct)
            is not WriteOutcome.Written)
        {
            throw new InvalidOperationException("Publication-state ændrede sig under lease.");
        }

        var dirtyStored = await repository.ReadStateAsync(locale, ct)
            ?? throw new InvalidOperationException("Publication-state forsvandt under lease.");
        var outcome = await mutation(ct);
        if (outcome is not WriteOutcome.Written)
        {
            await repository.WriteStateAsync(locale, original.Value, dirtyStored.ETag, ct);
            return new AuthoringWriteResult(
                outcome is WriteOutcome.Conflict ? WriteKind.Conflict : WriteKind.Rejected,
                null,
                ContentPublication.Unchanged,
                original.Value.ContentVersion);
        }

        var written = await readAfter(ct);
        var publication = await PublishUnderLeaseAsync(locale, dirtyStored, ct);
        return new AuthoringWriteResult(
            WriteKind.Written,
            written?.ETag,
            publication.Status,
            publication.ContentVersion);
    }

    public async Task<(ContentPublication Status, string? ContentVersion)> PublishPendingAsync(
        string locale, CancellationToken ct)
    {
        await repository.EnsureBootstrappedAsync(locale, ct);
        await using var lease = await stores.Authoring.AcquireLeaseAsync(
            AuthoringPaths.Lock(locale), ct);
        RecordContention(lease);

        var state = await repository.ReadStateAsync(locale, ct);
        if (state is null || !state.Value.IsDirty)
        {
            return (ContentPublication.Unchanged, state?.Value.ContentVersion);
        }
        return await PublishUnderLeaseAsync(locale, state, ct);
    }

    private async Task<(ContentPublication Status, string? ContentVersion)> PublishUnderLeaseAsync(
        string locale, StoredPublicationState state, CancellationToken ct)
    {
        var started = Stopwatch.GetTimestamp();
        try
        {
            var snapshot = await repository.ReadSnapshotAsync(locale, ct);
            var published = PublishedPackBuilder.Build(snapshot, time.GetUtcNow());

            await WriteReplacingAsync(
                stores.Authoring, AuthoringPaths.Index(locale), published.Index, ct);

            var versionOutcome = await stores.Public.CreateAsync(
                AuthoringPaths.VersionedPack(locale, published.ContentVersion),
                published.Pack,
                ct);
            if (versionOutcome is not (WriteOutcome.Written or WriteOutcome.AlreadyExists))
            {
                throw new InvalidOperationException(
                    $"Versionspakken kunne ikke skrives: {versionOutcome}.");
            }

            var unchanged = state.Value.ContentVersion == published.ContentVersion;
            if (!unchanged)
            {
                await WriteReplacingAsync(
                    stores.Public, AuthoringPaths.PublicPack(locale), published.Pack, ct);
            }

            var currentState = await repository.ReadStateAsync(locale, ct)
                ?? throw new InvalidOperationException("Publication-state forsvandt.");
            var clean = currentState.Value with
            {
                PublishedId = currentState.Value.RequestedId,
                ContentVersion = published.ContentVersion,
                PublishedAt = time.GetUtcNow(),
                LastErrorCode = null,
                Attempts = 0,
            };
            if (await repository.WriteStateAsync(locale, clean, currentState.ETag, ct)
                is not WriteOutcome.Written)
            {
                throw new InvalidOperationException("Kunne ikke markere publiceringen færdig.");
            }

            Duration.Record(Stopwatch.GetElapsedTime(started).TotalMilliseconds);
            logger.LogInformation(
                "Publicerede {Locale} som {ContentVersion} på {Milliseconds:F0} ms",
                locale,
                published.ContentVersion,
                Stopwatch.GetElapsedTime(started).TotalMilliseconds);
            return (
                unchanged ? ContentPublication.Unchanged : ContentPublication.Published,
                published.ContentVersion);
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            logger.LogError(exception, "Publicering af {Locale} afventer nyt forsøg", locale);
            var current = await repository.ReadStateAsync(locale, ct);
            if (current is not null)
            {
                var failed = current.Value with
                {
                    LastErrorCode = exception.GetType().Name,
                    Attempts = current.Value.Attempts + 1,
                };
                _ = await repository.WriteStateAsync(locale, failed, current.ETag, ct);
            }
            return (ContentPublication.Pending, current?.Value.ContentVersion);
        }
    }

    private static async Task WriteReplacingAsync(
        IContentStore store, string path, byte[] content, CancellationToken ct)
    {
        var current = await store.ReadAsync(path, ct);
        var outcome = await store.WriteAsync(path, content, current?.ETag, ct);
        if (outcome is not WriteOutcome.Written)
        {
            throw new InvalidOperationException($"Kunne ikke skrive {path}: {outcome}.");
        }
    }

    private static void RecordContention(IContentLease lease)
    {
        if (lease.WasContended)
        {
            LeaseConflicts.Add(1);
        }
    }
}
