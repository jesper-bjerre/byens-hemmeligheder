using System.Text.Json;
using ByensGaader.Api.Storage;
using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Gemmer en indholdspakke. Admin-appens vej væk fra håndredigeret JSON.
/// </summary>
/// <remarks>
/// ## Samtidighed
///
/// Klienten sender den ETag, hen hentede pakken med, i <c>If-Match</c>.
/// Stemmer den ikke, har en anden quizmaster gemt i mellemtiden, og der svares
/// <c>412</c>. Alle quizmastere kan rette i alt, så uden dette taber den, der
/// gemmer sidst, den andens arbejde uden at nogen opdager det.
///
/// ## Hvorfor kun JSON'en valideres, ikke forstås
///
/// Serveren kontrollerer, at kroppen er gyldig JSON og har de yderste felter.
/// Den validerer **ikke** kontrakten i dybden — det gør appen og dens tests
/// bedre, og en server, der kender kontrakten, skal udrulles hver gang den
/// udvides.
///
/// Det er en bevidst grænse: serveren beskytter mod ulæselige filer, ikke mod
/// dårligt indhold. Dårligt indhold er quizmasterens ansvar og fanges i test.
///
/// ## Hvem der gemmer
///
/// Quizmasterens navn står i <c>X-Quizmaster</c>, og mangler det, afvises
/// gemningen. Det er ikke godtgørelse — der er ingen adgangskontrol endnu — men
/// FR-111 kræver et spor over hvem, og et spor, klienten kan springe over,
/// efterlader huller netop der, hvor nogen havde travlt.
/// </remarks>
internal sealed class PutPackEndpoint(
    IContentStore store,
    AuditTrail audit,
    AuthoringRepository authoring)
    : EndpointWithoutRequest
{
    /// <summary>Navnet skal kunne læses af et menneske, ikke andet.</summary>
    private const int MaxNameLength = 60;

    public override void Configure()
    {
        Put("/content/{locale}/pack");
        AllowAnonymous();
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var packPath = Path.Combine(locale, "content-pack.json");

        // Den gamle TestFlight-admin gemmer hele pakken. Den må fortsat virke,
        // indtil authoring-kilden er taget i brug, men derefter ville et PUT
        // her skabe to sandheder og kunne slette kladder, den gamle app ikke
        // længere kan se. Afvisning er den eneste sikre overgang.
        if (await authoring.ReadStateAsync(locale, ct) is not null)
        {
            await SendResultAsync(Results.Problem(
                title: "Admin-appen skal opdateres",
                detail: "Opgaver gemmes nu enkeltvis. Installér den nyeste TestFlight-build "
                        + "og hent opgaverne igen.",
                statusCode: StatusCodes.Status409Conflict));
            return;
        }

        // Procentafkodet. En HTTP-header kan ikke bære andet end ASCII, og
        // halvdelen af navnene i et dansk hold har æ, ø eller å i sig.
        var by = Uri.UnescapeDataString(
            HttpContext.Request.Headers["X-Quizmaster"].FirstOrDefault() ?? string.Empty).Trim();
        if (by.Length is 0 || by.Length > MaxNameLength)
        {
            await SendResultAsync(Results.Problem(
                title: "Ingen quizmaster på gemningen",
                detail: $"Send dit navn i 'X-Quizmaster', højst {MaxNameLength} tegn. "
                        + "Alle kan rette i alt, så sporet skal kunne svare på hvem.",
                statusCode: StatusCodes.Status400BadRequest));
            return;
        }

        using var buffer = new MemoryStream();
        await HttpContext.Request.Body.CopyToAsync(buffer, ct);
        var content = buffer.ToArray();

        if (!IsPlausiblePack(content))
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldig indholdspakke",
                detail: "Kroppen er ikke gyldig JSON med felterne 'contentVersion' og 'missions'.",
                statusCode: StatusCodes.Status400BadRequest));
            return;
        }

        // Læses **før** skrivningen. Bagefter er den gamle udgave væk, og så er
        // der intet at sammenligne statusserne med.
        var before = await store.ReadAsync(packPath, ct);

        var ifMatch = HttpContext.Request.Headers.IfMatch.FirstOrDefault();
        var outcome = await store.WriteAsync(packPath, content, ifMatch, ct);

        switch (outcome)
        {
            case WriteOutcome.Written:
                await audit.RecordAsync(locale, before?.Content, content, by, ct);
                var saved = await store.ReadAsync(packPath, ct);
                HttpContext.Response.Headers.ETag = saved!.ETag;
                await SendNoContentAsync(ct);
                return;

            case WriteOutcome.Conflict:
                await SendResultAsync(Results.Problem(
                    title: "Pakken er ændret af en anden",
                    detail: "Hent pakken igen, læg dine rettelser oveni, og gem på ny.",
                    statusCode: StatusCodes.Status412PreconditionFailed));
                return;

            default:
                await SendResultAsync(Results.Problem(
                    title: "Ugyldig sti",
                    statusCode: StatusCodes.Status400BadRequest));
                return;
        }
    }

    /// <summary>Fanger det ulæselige, ikke det uigennemtænkte.</summary>
    private static bool IsPlausiblePack(byte[] content)
    {
        try
        {
            using var document = JsonDocument.Parse(content);
            var root = document.RootElement;
            return root.ValueKind == JsonValueKind.Object
                && root.TryGetProperty("contentVersion", out _)
                && root.TryGetProperty("missions", out var missions)
                && missions.ValueKind == JsonValueKind.Array;
        }
        catch (JsonException)
        {
            return false;
        }
    }
}
