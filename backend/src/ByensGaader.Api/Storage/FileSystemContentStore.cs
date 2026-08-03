using System.Collections.Concurrent;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Storage;

/// <summary>
/// Læser indhold fra en mappe på disk — i udvikling repoets egen
/// <c>contracts/content</c>.
/// </summary>
/// <remarks>
/// Findes, så hele læsevejen kan bevises uden en Azure-konto. Afløses af en
/// blob-baseret variant, når hostingen er på plads.
/// </remarks>
internal sealed class FileSystemContentStore(IOptions<ContentStoreOptions> options)
    : IContentStore
{
    private readonly string _root = Path.GetFullPath(options.Value.RootPath);

    /// <summary>Én tilføjelse ad gangen. Se <see cref="AppendAsync"/>.</summary>
    private static readonly SemaphoreSlim AppendLock = new(1, 1);
    private static readonly ConcurrentDictionary<string, SemaphoreSlim> Leases = new();

    public async Task<StoredFile?> ReadAsync(string relativePath, CancellationToken ct)
    {
        if (!TryResolve(relativePath, out var fullPath))
        {
            return null;
        }

        if (!File.Exists(fullPath))
        {
            return null;
        }

        var bytes = await File.ReadAllBytesAsync(fullPath, ct);

        return new StoredFile(
            bytes, ContentPath.ETagFor(bytes), ContentPath.ContentTypeFor(fullPath));
    }

    public async Task<WriteOutcome> WriteAsync(
        string relativePath, byte[] content, string? expectedETag, CancellationToken ct)
    {
        if (!TryResolve(relativePath, out var fullPath))
        {
            return WriteOutcome.Rejected;
        }

        var current = await ReadAsync(relativePath, ct);
        if (current?.ETag != expectedETag)
        {
            return WriteOutcome.Conflict;
        }

        Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);

        // Skriv til en midlertidig fil og byt om. Afbrydes processen midtvejs,
        // efterlades den gamle fil hel frem for en halv ny — og en halv
        // indholdspakke gør appen ubrugelig for alle på én gang.
        var temp = fullPath + ".tmp";
        await File.WriteAllBytesAsync(temp, content, ct);
        File.Move(temp, fullPath, overwrite: true);

        return WriteOutcome.Written;
    }

    public async Task<WriteOutcome> CreateAsync(
        string relativePath, byte[] content, CancellationToken ct)
    {
        if (!TryResolve(relativePath, out var fullPath))
        {
            return WriteOutcome.Rejected;
        }

        if (File.Exists(fullPath))
        {
            return WriteOutcome.AlreadyExists;
        }

        Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);
        var temp = fullPath + ".tmp";
        await File.WriteAllBytesAsync(temp, content, ct);
        File.Move(temp, fullPath, overwrite: false);
        return WriteOutcome.Written;
    }

    public async Task<WriteOutcome> AppendAsync(
        string relativePath, byte[] content, CancellationToken ct)
    {
        if (!TryResolve(relativePath, out var fullPath))
        {
            return WriteOutcome.Rejected;
        }

        Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);

        // Serialiseret, og det er ikke overforsigtighed: `FileMode.Append`
        // søger til enden, når strømmen åbnes, og husker derefter sin egen
        // position. Åbnes to strømme samtidig, finder de den samme ende og
        // skriver oven i hinanden — kontrakttesten fangede præcis det med
        // tolv samtidige tilføjelser, hvor den ene linje forsvandt.
        //
        // Låsen dækker kun denne proces. Det er nok her, fordi lageret er
        // udviklingens; det er `BlobContentStore` med sin append blob, der
        // holder på tværs af instanser i drift.
        await AppendLock.WaitAsync(ct);
        try
        {
            await using var file = new FileStream(
                fullPath, FileMode.Append, FileAccess.Write, FileShare.Read);
            await file.WriteAsync(content, ct);
        }
        finally
        {
            AppendLock.Release();
        }

        return WriteOutcome.Written;
    }

    public Task<bool> DeleteAsync(string relativePath, CancellationToken ct)
    {
        if (!TryResolve(relativePath, out var fullPath) || !File.Exists(fullPath))
        {
            return Task.FromResult(false);
        }
        File.Delete(fullPath);
        return Task.FromResult(true);
    }

    public async Task<WriteOutcome> DeleteIfMatchAsync(
        string relativePath, string expectedETag, CancellationToken ct)
    {
        var current = await ReadAsync(relativePath, ct);
        if (current is null || current.ETag != expectedETag)
        {
            return WriteOutcome.Conflict;
        }

        return await DeleteAsync(relativePath, ct)
            ? WriteOutcome.Written
            : WriteOutcome.Conflict;
    }

    public Task<IReadOnlyList<string>> ListAsync(string relativeDirectory, CancellationToken ct)
    {
        if (!TryResolve(relativeDirectory, out var fullPath) || !Directory.Exists(fullPath))
        {
            return Task.FromResult<IReadOnlyList<string>>([]);
        }

        var names = Directory.EnumerateFiles(fullPath)
            .Select(Path.GetFileName)
            .OfType<string>()
            .Where(n => !n.EndsWith(".tmp", StringComparison.Ordinal))
            .Order(StringComparer.Ordinal)
            .ToArray();

        return Task.FromResult<IReadOnlyList<string>>(names);
    }

    public async Task<IContentLease> AcquireLeaseAsync(
        string relativePath, CancellationToken ct)
    {
        if (!TryResolve(relativePath, out var fullPath))
        {
            throw new ArgumentException("Ugyldig lease-sti.", nameof(relativePath));
        }

        var gate = Leases.GetOrAdd(fullPath, static _ => new SemaphoreSlim(1, 1));
        var immediate = await gate.WaitAsync(TimeSpan.Zero, ct);
        if (!immediate)
        {
            await gate.WaitAsync(ct);
        }
        return new FileLease(gate, !immediate);
    }

    /// <summary>
    /// Oversætter en sti fra klienten til en fil under roden — eller afviser.
    /// </summary>
    /// <remarks>
    /// Uden denne kontrol kan <c>../../../etc/passwd</c> læses gennem et
    /// anonymt endepunkt. Stien normaliseres, og resultatet skal stadig ligge
    /// under roden; det fanger både <c>..</c> og symlinks, der peger ud.
    /// </remarks>
    private bool TryResolve(string relativePath, out string fullPath)
    {
        fullPath = string.Empty;

        if (!ContentPath.TryNormalise(relativePath, out var safe))
        {
            return false;
        }

        var candidate = Path.GetFullPath(Path.Combine(_root, safe));
        if (!candidate.StartsWith(_root + Path.DirectorySeparatorChar, StringComparison.Ordinal))
        {
            return false;
        }

        fullPath = candidate;
        return true;
    }

}

internal sealed class FileLease(SemaphoreSlim gate, bool wasContended) : IContentLease
{
    private int _released;

    public bool WasContended { get; } = wasContended;

    public ValueTask DisposeAsync()
    {
        if (Interlocked.Exchange(ref _released, 1) is 0)
        {
            gate.Release();
        }
        return ValueTask.CompletedTask;
    }
}

internal sealed class ContentStoreOptions
{
    public const string Section = "ContentStore";

    /// <summary>
    /// Hvilket lager der bruges.
    /// </summary>
    /// <remarks>
    /// Eksplicit og ikke udledt af, om <see cref="StorageAccountUri"/> er sat.
    /// En tastefejl i adressen ville ellers falde tilbage til filsystemet, og
    /// API'et ville se ud til at virke, mens det skrev et sted, ingen læser.
    /// </remarks>
    public ContentStoreProvider Provider { get; set; } = ContentStoreProvider.FileSystem;

    /// <summary>Mappen, indhold læses fra. Absolut eller relativ til arbejdsmappen.</summary>
    public string RootPath { get; set; } = "content";

    /// <summary>Privat, redaktionel JSON. Skal være gitignoreret lokalt.</summary>
    public string AuthoringRootPath { get; set; } = ".local/authoring";

    /// <summary>
    /// Read-only fixture, der kopieres til <see cref="RootPath"/> første gang
    /// udviklingsserveren starter. Der skrives aldrig tilbage hertil.
    /// </summary>
    public string FixtureRootPath { get; set; } = "../../../contracts/content";

    /// <summary>
    /// Fx <c>https://byensgaaderdev.blob.core.windows.net</c>. Aldrig en
    /// connection string — der er ingen nøgle at lække med managed identity.
    /// </summary>
    public string StorageAccountUri { get; set; } = string.Empty;

    public string Container { get; set; } = "content";

    /// <summary>Privat container; spilleridentiteten får aldrig læseadgang.</summary>
    public string AuthoringContainer { get; set; } = "authoring";
}

internal enum ContentStoreProvider
{
    FileSystem,
    Blob,
}
