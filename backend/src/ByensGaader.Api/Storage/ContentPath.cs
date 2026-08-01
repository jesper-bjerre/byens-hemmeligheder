using System.Security.Cryptography;

namespace ByensGaader.Api.Storage;

/// <summary>
/// Det, de to lagre skal være enige om.
/// </summary>
/// <remarks>
/// Indholdstypen og ETag'en må ikke afhænge af, om der køres mod en mappe på
/// disken eller mod Azure. Gjorde de det, ville en app, der havde hentet en
/// pakke lokalt, hente den hele igen efter udrulningen — og en test mod
/// filsystemet ville bevise noget andet end det, der kører i drift.
/// </remarks>
internal static class ContentPath
{
    /// <summary>
    /// Stabilt kendetegn for indholdet, beregnet af indholdet selv.
    /// </summary>
    /// <remarks>
    /// Ikke af ændringstidspunktet og ikke af lagerets egen version. En fil,
    /// der kopieres, migreres eller genskabes uændret, skal have samme ETag —
    /// ellers henter hver eneste app alt igen, hver gang vi flytter noget.
    /// </remarks>
    public static string ETagFor(ReadOnlySpan<byte> content) =>
        $"\"{Convert.ToHexString(SHA256.HashData(content))[..32].ToLowerInvariant()}\"";

    public static string ContentTypeFor(string path) =>
        Path.GetExtension(path).ToLowerInvariant() switch
        {
            ".json" => "application/json; charset=utf-8",
            ".jsonl" => "application/x-ndjson; charset=utf-8",
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".m4a" => "audio/mp4",
            ".mp3" => "audio/mpeg",
            _ => "application/octet-stream",
        };

    /// <summary>
    /// Gør en sti fra klienten til et lagernavn — eller afviser den.
    /// </summary>
    /// <remarks>
    /// Endepunkterne er anonyme, så <c>../../../etc/passwd</c> må aldrig kunne
    /// slippe igennem. Mod filsystemet er det en katastrofe; mod blob er det
    /// "bare" et navn, der ikke findes — men de to lagre skal opføre sig ens,
    /// og en kontrol, der kun findes ét sted, er en, nogen fjerner ved et uheld.
    ///
    /// Omvendt skråstreg oversættes, fordi <see cref="Path.Combine"/> laver
    /// <c>\</c> på Windows, og en blob-sti kun kender <c>/</c>.
    /// </remarks>
    public static bool TryNormalise(string relativePath, out string normalised)
    {
        normalised = string.Empty;

        if (string.IsNullOrWhiteSpace(relativePath) || Path.IsPathRooted(relativePath))
        {
            return false;
        }

        var candidate = relativePath.Replace('\\', '/').Trim('/');
        if (candidate.Length is 0)
        {
            return false;
        }

        var segments = candidate.Split('/', StringSplitOptions.RemoveEmptyEntries);
        if (segments.Any(s => s is "." or ".."))
        {
            return false;
        }

        normalised = string.Join('/', segments);
        return true;
    }
}
