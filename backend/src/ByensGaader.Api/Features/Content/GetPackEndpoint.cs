using ByensGaader.Api.Storage;
using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Leverer en indholdspakke. Spillerappens eneste faste kald.
/// </summary>
/// <remarks>
/// Svarer <c>304 Not Modified</c>, når klienten allerede har den nyeste udgave.
/// Appens <c>ContentPackSource</c> sender sin kendte ETag i <c>If-None-Match</c>
/// og forstår svaret — grænsefladen fandtes, længe før serveren gjorde.
///
/// Pakken sendes videre som de bytes, der ligger på lageret. Serveren afkoder
/// den ikke, så kontrakten kan udvides i appen uden en udrulning her.
/// </remarks>
internal sealed class GetPackEndpoint(IContentStore store) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/content/{locale}/pack");
        AllowAnonymous();
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var file = await store.ReadAsync(Path.Combine(locale, "content-pack.json"), ct);

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
        await SendBytesAsync(file.Content, contentType: file.ContentType, cancellation: ct);
    }
}
