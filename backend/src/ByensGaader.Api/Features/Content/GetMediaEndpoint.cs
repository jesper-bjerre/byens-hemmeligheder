using ByensGaader.Api.Storage;
using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Leverer ét billede eller én lydfil.
/// </summary>
/// <remarks>
/// Hentes dovent pr. opgave i stedet for at ligge i appens bundle. I dag fylder
/// medierne 14 MB af en app på 24 MB — og det tal vokser med hver ny opgave,
/// også for den spiller, der kun løser én.
///
/// Filnavnet kommer fra klienten og valideres i lageret: en sti, der peger uden
/// for indholdsmappen, afvises. Endepunktet er anonymt, så det er ikke en
/// teoretisk bekymring.
/// </remarks>
internal sealed class GetMediaEndpoint(IContentStore store) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/content/{locale}/media/{filename}");
        AllowAnonymous();
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var filename = Route<string>("filename")!;
        var file = await store.ReadAsync(Path.Combine(locale, "media", filename), ct);

        if (file is null)
        {
            await SendNotFoundAsync(ct);
            return;
        }

        if (HttpContext.Request.Headers.IfNoneMatch.Contains(file.ETag))
        {
            // Sendes som et resultat. Sættes statuskoden blot på svaret,
            // svarer FastEndpoints selv 204 bagefter, fordi handleren ikke
            // har sendt noget — og 204 betyder noget helt andet end 304.
            HttpContext.Response.Headers.ETag = file.ETag;
            await SendResultAsync(Results.StatusCode(StatusCodes.Status304NotModified));
            return;
        }

        HttpContext.Response.Headers.ETag = file.ETag;
        // Medier ændrer sig ikke uden at skifte navn. Et år er sikkert, og det
        // sparer et kald pr. billede pr. spilstart.
        HttpContext.Response.Headers.CacheControl = "public, max-age=31536000, immutable";
        await SendBytesAsync(file.Content, contentType: file.ContentType, cancellation: ct);
    }
}
