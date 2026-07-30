namespace ByensGaader.Api.Storage;

/// <summary>
/// Hvor indholdspakker og medier ligger.
/// </summary>
/// <remarks>
/// Grænsefladen findes, fordi lageret skal skiftes: i dag filer på disk, i
/// morgen Azure Blob Storage. Skiftet må ikke røre endepunkterne.
///
/// Bemærk at der returneres bytes og ikke afkodede modeller. Serveren har intet
/// ærinde at forstå en indholdspakke — den leverer den. Så kan kontrakten
/// udvides i appen uden en serverudrulning.
/// </remarks>
internal interface IContentStore
{
    /// <returns><c>null</c> hvis filen ikke findes.</returns>
    public Task<StoredFile?> ReadAsync(string relativePath, CancellationToken ct);
}

/// <param name="Content">Filens bytes.</param>
/// <param name="ETag">
/// Stabilt kendetegn for indholdet. Beregnes af indholdet selv og ikke af
/// ændringstidspunktet: en fil, der kopieres eller genskabes uændret, skal have
/// samme ETag, ellers henter alle apps alt igen uden grund.
/// </param>
internal sealed record StoredFile(byte[] Content, string ETag, string ContentType);
