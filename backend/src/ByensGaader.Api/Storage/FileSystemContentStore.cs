using System.Security.Cryptography;
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
        var etag = Convert.ToHexString(SHA256.HashData(bytes))[..32].ToLowerInvariant();

        return new StoredFile(bytes, $"\"{etag}\"", ContentTypeFor(fullPath));
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

        if (string.IsNullOrWhiteSpace(relativePath) || Path.IsPathRooted(relativePath))
        {
            return false;
        }

        var candidate = Path.GetFullPath(Path.Combine(_root, relativePath));
        if (!candidate.StartsWith(_root + Path.DirectorySeparatorChar, StringComparison.Ordinal))
        {
            return false;
        }

        fullPath = candidate;
        return true;
    }

    private static string ContentTypeFor(string path) => Path.GetExtension(path).ToLowerInvariant() switch
    {
        ".json" => "application/json; charset=utf-8",
        ".jpg" or ".jpeg" => "image/jpeg",
        ".png" => "image/png",
        ".m4a" => "audio/mp4",
        ".mp3" => "audio/mpeg",
        _ => "application/octet-stream",
    };
}

internal sealed class ContentStoreOptions
{
    public const string Section = "ContentStore";

    /// <summary>Mappen, indhold læses fra. Absolut eller relativ til arbejdsmappen.</summary>
    public string RootPath { get; set; } = "content";
}
