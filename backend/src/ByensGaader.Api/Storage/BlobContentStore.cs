using Azure;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Storage;

/// <summary>
/// Indhold i Azure Blob Storage. Det, der kører i drift.
/// </summary>
/// <remarks>
/// ## Hvorfor ETag'en er to ting
///
/// Klienterne får en **indholdshash**. Den er stabil: en pakke, der migreres
/// eller genskabes uændret, beholder sin ETag, og alle apps får `304` frem for
/// at hente 100 kB igen. Blobbens egen ETag ændrer sig ved hver skrivning, også
/// når indholdet er det samme — den kan ikke bruges til det.
///
/// Til gengæld er blobbens ETag det eneste, der gør en skrivning **atomisk**.
/// <see cref="FileSystemContentStore"/> læser, sammenligner og skriver i tre
/// trin; to samtidige gemninger kan begge nå at læse det samme og begge skrive.
/// Her sendes blobbens ETag med som `If-Match`, og Azure afviser den anden.
///
/// Derfor bæres begge: hashen ligger som metadata på blobben, så en skrivning
/// kun behøver at hente egenskaberne — ikke hele indholdet — for at kontrollere,
/// om klienten skrev oven på den udgave, hen troede.
///
/// ## Hvorfor sporet er en append blob
///
/// <see cref="AppendAsync"/> har med vilje ingen ETag. To quizmastere, der
/// gemmer samtidig, skal **begge** ende i revisionssporet, og en block blob
/// ville kræve læs-ret-skriv, hvor den ene linje kunne overskrive den anden.
/// `AppendBlock` er atomisk pr. kald.
/// </remarks>
internal sealed class BlobContentStore : IContentStore
{
    /// <summary>Hvor indholdshashen gemmes på blobben.</summary>
    private const string HashKey = "contenthash";

    private readonly BlobContainerClient _container;

    public BlobContentStore(BlobServiceClient service, IOptions<ContentStoreOptions> options)
    {
        _container = service.GetBlobContainerClient(options.Value.Container);
    }

    public async Task<StoredFile?> ReadAsync(string relativePath, CancellationToken ct)
    {
        if (!ContentPath.TryNormalise(relativePath, out var name))
        {
            return null;
        }

        try
        {
            var blob = _container.GetBlobClient(name);
            var response = await blob.DownloadContentAsync(cancellationToken: ct);
            var content = response.Value.Content.ToArray();

            // Hashen fra metadata, når den er der. Ellers regnes den — det
            // sker for blobs, der er lagt op i hånden eller migreret ind.
            var etag = response.Value.Details.Metadata.TryGetValue(HashKey, out var stored)
                && !string.IsNullOrEmpty(stored)
                    ? stored
                    : ContentPath.ETagFor(content);

            return new StoredFile(content, etag, ContentPath.ContentTypeFor(name));
        }
        catch (RequestFailedException e) when (e.Status is 404)
        {
            return null;
        }
    }

    public async Task<WriteOutcome> WriteAsync(
        string relativePath, byte[] content, string? expectedETag, CancellationToken ct)
    {
        if (!ContentPath.TryNormalise(relativePath, out var name))
        {
            return WriteOutcome.Rejected;
        }

        var blob = _container.GetBlobClient(name);
        var current = await CurrentAsync(blob, ct);

        // `null` betyder "filen fandtes ikke". Stemmer det ikke, har en anden
        // skrevet siden — også når det er den anden vej rundt.
        if (current?.ContentETag != expectedETag)
        {
            return WriteOutcome.Conflict;
        }

        var conditions = current is null
            // Findes den ikke, må ingen anden nå at oprette den imens.
            ? new BlobRequestConditions { IfNoneMatch = ETag.All }
            : new BlobRequestConditions { IfMatch = current.BlobETag };

        return await UploadAsync(blob, name, content, conditions, ct)
            ? WriteOutcome.Written
            : WriteOutcome.Conflict;
    }

    public async Task<WriteOutcome> CreateAsync(
        string relativePath, byte[] content, CancellationToken ct)
    {
        if (!ContentPath.TryNormalise(relativePath, out var name))
        {
            return WriteOutcome.Rejected;
        }

        var blob = _container.GetBlobClient(name);
        var conditions = new BlobRequestConditions { IfNoneMatch = ETag.All };

        return await UploadAsync(blob, name, content, conditions, ct)
            ? WriteOutcome.Written
            : WriteOutcome.AlreadyExists;
    }

    public async Task<WriteOutcome> AppendAsync(
        string relativePath, byte[] content, CancellationToken ct)
    {
        if (!ContentPath.TryNormalise(relativePath, out var name))
        {
            return WriteOutcome.Rejected;
        }

        var blob = _container.GetAppendBlobClient(name);
        await blob.CreateIfNotExistsAsync(
            new AppendBlobCreateOptions
            {
                HttpHeaders = new BlobHttpHeaders { ContentType = ContentPath.ContentTypeFor(name) },
            },
            cancellationToken: ct);

        using var stream = new MemoryStream(content, writable: false);
        await blob.AppendBlockAsync(stream, cancellationToken: ct);

        return WriteOutcome.Written;
    }

    public async Task<bool> DeleteAsync(string relativePath, CancellationToken ct)
    {
        if (!ContentPath.TryNormalise(relativePath, out var name))
        {
            return false;
        }

        var response = await _container.GetBlobClient(name)
            .DeleteIfExistsAsync(cancellationToken: ct);
        return response.Value;
    }

    public async Task<IReadOnlyList<string>> ListAsync(
        string relativeDirectory, CancellationToken ct)
    {
        if (!ContentPath.TryNormalise(relativeDirectory, out var prefix))
        {
            return [];
        }

        var names = new List<string>();
        // Hierarkisk, så en undermappe ikke render med i listen over en mappe.
        var pages = _container.GetBlobsByHierarchyAsync(
            prefix: prefix + "/", delimiter: "/", cancellationToken: ct);

        await foreach (var item in pages)
        {
            if (item.IsBlob)
            {
                names.Add(item.Blob.Name[(prefix.Length + 1)..]);
            }
        }

        names.Sort(StringComparer.Ordinal);
        return names;
    }

    // MARK: - Småting

    private sealed record Current(string ContentETag, ETag BlobETag);

    /// <summary>Hashen og blobbens version — uden at hente indholdet.</summary>
    private static async Task<Current?> CurrentAsync(BlobClient blob, CancellationToken ct)
    {
        try
        {
            var properties = await blob.GetPropertiesAsync(cancellationToken: ct);
            var hash = properties.Value.Metadata.TryGetValue(HashKey, out var stored)
                && !string.IsNullOrEmpty(stored)
                    ? stored
                    : null;

            // Uden metadata må indholdet hentes for at kunne sammenlignes.
            // Sker kun for blobs, ingen af vores kode har skrevet.
            if (hash is null)
            {
                var content = await blob.DownloadContentAsync(cancellationToken: ct);
                return new Current(
                    ContentPath.ETagFor(content.Value.Content.ToArray()),
                    content.Value.Details.ETag);
            }

            return new Current(hash, properties.Value.ETag);
        }
        catch (RequestFailedException e) when (e.Status is 404)
        {
            return null;
        }
    }

    private static async Task<bool> UploadAsync(
        BlobClient blob, string name, byte[] content, BlobRequestConditions conditions,
        CancellationToken ct)
    {
        using var stream = new MemoryStream(content, writable: false);
        try
        {
            await blob.UploadAsync(
                stream,
                new BlobUploadOptions
                {
                    Conditions = conditions,
                    HttpHeaders = new BlobHttpHeaders
                    {
                        ContentType = ContentPath.ContentTypeFor(name),
                    },
                    // Hashen skrives med, så næste skrivning kan sammenligne
                    // uden at hente hele indholdet igen.
                    Metadata = new Dictionary<string, string>
                    {
                        [HashKey] = ContentPath.ETagFor(content),
                    },
                },
                cancellationToken: ct);
            return true;
        }
        catch (RequestFailedException e) when (e.Status is 409 or 412)
        {
            // 409: nogen nåede at oprette den. 412: nogen nåede at ændre den.
            // Begge betyder det samme for den, der skrev.
            return false;
        }
    }
}
