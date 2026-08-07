using ByensGaader.Api.Storage;
using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Lægger et billede eller en lydfil op.
/// </summary>
/// <remarks>
/// ## Rå krop, ikke multipart
///
/// Filnavnet står i stien, og kroppen er filens bytes. En iOS-app kan sende det
/// med tre linjer; multipart ville kræve en formkoder på begge sider uden at
/// give noget igen, når der kun er én fil.
///
/// ## Filer overskrives ikke
///
/// Findes navnet, svares <c>409</c>. Medier sendes med et års cache, så en fil,
/// der skifter indhold uden at skifte navn, ville stå gammel på telefonerne i et
/// år. Skal billedet være et andet, skal det hedde noget andet.
///
/// Det er også derfor, quizmasterens app skal navngive efter mønsteret
/// <c>&lt;opgave&gt;-000</c>: nummeret er versionen.
/// </remarks>
internal sealed class PostMediaEndpoint(IContentStore store) : EndpointWithoutRequest
{
    /// Et telefonfoto i fuld opløsning er sjældent over 10 MB. Grænsen findes,
    /// så en fejl i klienten ikke kan fylde disken.
    private const int MaxBytes = 10 * 1024 * 1024;

    private static readonly string[] Allowed = [".jpg", ".jpeg", ".png", ".m4a", ".mp3"];

    public override void Configure()
    {
        Post("/content/{locale}/media/{filename}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        // **Ikke** `AllowFileUploads()` — den forventer multipart og afviser en
        // rå krop med 415, før handleren overhovedet kører. Her er kroppen
        // filens bytes, og filnavnet står i stien.
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var filename = Route<string>("filename")!;

        if (!Allowed.Contains(Path.GetExtension(filename).ToLowerInvariant()))
        {
            await SendResultAsync(Results.Problem(
                title: "Filtypen understøttes ikke",
                detail: $"Tilladt: {string.Join(", ", Allowed)}.",
                statusCode: StatusCodes.Status415UnsupportedMediaType));
            return;
        }

        using var buffer = new MemoryStream();
        await HttpContext.Request.Body.CopyToAsync(buffer, ct);
        var content = buffer.ToArray();

        if (content.Length is 0 or > MaxBytes)
        {
            await SendResultAsync(Results.Problem(
                title: content.Length == 0 ? "Tom fil" : "Filen er for stor",
                detail: $"Højst {MaxBytes / 1024 / 1024} MB.",
                statusCode: StatusCodes.Status413PayloadTooLarge));
            return;
        }

        var path = Path.Combine(locale, "media", filename);
        switch (await store.CreateAsync(path, content, ct))
        {
            case WriteOutcome.Written:
                var saved = await store.ReadAsync(path, ct);
                HttpContext.Response.Headers.ETag = saved!.ETag;
                await SendCreatedAtAsync<GetMediaEndpoint>(
                    new { locale, filename }, null, cancellation: ct);
                return;

            case WriteOutcome.AlreadyExists:
                await SendResultAsync(Results.Problem(
                    title: "Filnavnet er optaget",
                    detail: "Medier overskrives ikke. Giv filen et nyt navn — nummeret er versionen.",
                    statusCode: StatusCodes.Status409Conflict));
                return;

            default:
                await SendResultAsync(Results.Problem(
                    title: "Ugyldigt filnavn", statusCode: StatusCodes.Status400BadRequest));
                return;
        }
    }
}

/// <summary>Hvad der ligger af medier. Så appen kan vise, hvad der er at vælge.</summary>
internal sealed class ListMediaEndpoint(IContentStore store) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/content/{locale}/media");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var names = await store.ListAsync(Path.Combine(locale, "media"), ct);
        await SendAsync(new { locale, files = names }, cancellation: ct);
    }
}

/// <summary>Fjerner et medie, der ikke bruges længere.</summary>
internal sealed class DeleteMediaEndpoint(IContentStore store) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Delete("/content/{locale}/media/{filename}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var filename = Route<string>("filename")!;

        // Der kontrolleres **ikke**, om pakken stadig peger på filen. Serveren
        // kender ikke kontrakten, og en sletning, der kræver at den gør, ville
        // binde de to sammen igen. Et manglende billede standser desuden ikke
        // en opgave — teksten bærer gåden (ADR 0003).
        var deleted = await store.DeleteAsync(Path.Combine(locale, "media", filename), ct);
        if (deleted)
        {
            await SendNoContentAsync(ct);
        }
        else
        {
            await SendNotFoundAsync(ct);
        }
    }
}
