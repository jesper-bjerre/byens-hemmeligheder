using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>Leverer felttestklare og udgivne opgaver til en verificeret
/// Designer eller Admin. Kladder forlader ikke redigeringsfladen.</summary>
internal sealed class GetPreviewPackEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    TimeProvider time) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/preview");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        try
        {
            var locale = Route<string>("locale")!;
            await publisher.EnsureReadyAsync(locale, ct);
            var snapshot = await repository.ReadSnapshotAsync(locale, ct);
            var preview = PublishedPackBuilder.BuildPreview(snapshot, time.GetUtcNow());

            HttpContext.Response.Headers.ETag = $"\"{preview.ContentVersion}\"";
            await SendBytesAsync(
                preview.Pack,
                contentType: "application/json; charset=utf-8",
                cancellation: ct);
        }
        catch (ArgumentException exception)
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldigt locale",
                detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest));
        }
    }
}
