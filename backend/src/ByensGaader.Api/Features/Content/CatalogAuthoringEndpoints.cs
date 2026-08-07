using System.Text.Json;
using System.Text.Json.Nodes;
using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

internal sealed class ListMediaMetadataEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/media");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        await publisher.EnsureReadyAsync(locale, ct);
        var snapshot = await repository.ReadSnapshotAsync(locale, ct);
        await SendAsync(
            snapshot.Media.Select(item => new { asset = item.Json, etag = item.ETag }),
            cancellation: ct);
    }
}

internal sealed class ListSourcesEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/sources");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        await publisher.EnsureReadyAsync(locale, ct);
        var snapshot = await repository.ReadSnapshotAsync(locale, ct);
        await SendAsync(
            snapshot.Sources.Select(item => new { source = item.Json, etag = item.ETag }),
            cancellation: ct);
    }
}

internal sealed class GetMediaMetadataEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/media/{mediaId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await CatalogEndpoints.GetAsync(
            HttpContext,
            Route<string>("locale")!,
            Route<string>("mediaId")!,
            publisher,
            repository.ReadMediaAsync,
            ct);
}

internal sealed class GetSourceEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/sources/{sourceId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await CatalogEndpoints.GetAsync(
            HttpContext,
            Route<string>("locale")!,
            Route<string>("sourceId")!,
            publisher,
            repository.ReadSourceAsync,
            ct);
}

internal sealed class PutMediaMetadataEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    AuditTrail audit) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Put("/authoring/content/{locale}/media/{mediaId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await CatalogEndpoints.PutAsync(
            HttpContext,
            Route<string>("locale")!,
            Route<string>("mediaId")!,
            "Mediet",
            publisher,
            repository.ReadMediaAsync,
            repository.WriteMediaAsync,
            audit,
            ct);
}

internal sealed class PutSourceEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    AuditTrail audit) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Put("/authoring/content/{locale}/sources/{sourceId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await CatalogEndpoints.PutAsync(
            HttpContext,
            Route<string>("locale")!,
            Route<string>("sourceId")!,
            "Kilden",
            publisher,
            repository.ReadSourceAsync,
            repository.WriteSourceAsync,
            audit,
            ct);
}

internal sealed class DeleteMediaMetadataEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    AuditTrail audit) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Delete("/authoring/content/{locale}/media/{mediaId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await CatalogEndpoints.DeleteAsync(
            HttpContext,
            Route<string>("locale")!,
            Route<string>("mediaId")!,
            "Mediet",
            media: true,
            publisher,
            repository,
            repository.ReadMediaAsync,
            repository.DeleteMediaAsync,
            audit,
            ct);
}

internal sealed class DeleteSourceEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    AuditTrail audit) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Delete("/authoring/content/{locale}/sources/{sourceId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await CatalogEndpoints.DeleteAsync(
            HttpContext,
            Route<string>("locale")!,
            Route<string>("sourceId")!,
            "Kilden",
            media: false,
            publisher,
            repository,
            repository.ReadSourceAsync,
            repository.DeleteSourceAsync,
            audit,
            ct);
}

internal static class CatalogEndpoints
{
    internal delegate Task<AuthoringDocument?> Read(
        string locale, string id, CancellationToken ct);
    internal delegate Task<ByensGaader.Api.Storage.WriteOutcome> Write(
        string locale, string id, JsonObject value, string? etag, CancellationToken ct);
    internal delegate Task<ByensGaader.Api.Storage.WriteOutcome> Delete(
        string locale, string id, string etag, CancellationToken ct);

    public static async Task GetAsync(
        HttpContext context,
        string locale,
        string id,
        ContentPublisher publisher,
        Read read,
        CancellationToken ct)
    {
        try
        {
            await publisher.EnsureReadyAsync(locale, ct);
            var document = await read(locale, id, ct);
            if (document is null)
            {
                // En response uden body bliver overskrevet til 204, når det
                // ydre FastEndpoints-endpoint returnerer. Problem-svaret
                // starter responsen og bevarer derfor den tilsigtede 404.
                await Results.Problem(
                    title: "Katalogobjektet findes ikke",
                    statusCode: StatusCodes.Status404NotFound).ExecuteAsync(context);
                return;
            }
            context.Response.Headers.ETag = document.ETag;
            await Results.Json(document.Json).ExecuteAsync(context);
        }
        catch (ArgumentException exception)
        {
            await Results.Problem(
                title: "Ugyldig rute", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest).ExecuteAsync(context);
        }
    }

    public static async Task PutAsync(
        HttpContext context,
        string locale,
        string id,
        string subject,
        ContentPublisher publisher,
        Read read,
        Write write,
        AuditTrail audit,
        CancellationToken ct)
    {
        var precondition = AuthoringHttp.Precondition(context.Request.Headers);
        if (!precondition.Present)
        {
            await AuthoringHttp.SendPreconditionRequiredAsync(context);
            return;
        }
        var by = AuthoringHttp.Actor(context.User);

        try
        {
            var value = await AuthoringHttp.ReadObjectAsync(context.Request, ct);
            await publisher.EnsureReadyAsync(locale, ct);
            var before = await read(locale, id, ct);
            var result = await publisher.ExecuteAsync(
                locale,
                id,
                token => write(locale, id, value, precondition.ExpectedETag, token),
                token => read(locale, id, token),
                ct);
            if (result.Kind is WriteKind.Conflict)
            {
                await AuthoringHttp.SendConflictAsync(context, subject, ct);
                return;
            }
            if (result.Kind is not WriteKind.Written)
            {
                await Results.Problem(
                    title: subject + " kunne ikke gemmes",
                    statusCode: StatusCodes.Status400BadRequest).ExecuteAsync(context);
                return;
            }

            await audit.RecordObjectAsync(
                locale,
                by,
                before is null ? "created" : "content",
                id,
                null,
                null,
                result.ContentVersion,
                ct);
            context.Response.Headers.ETag = result.ETag;
            context.Response.Headers["X-Content-Publication"] =
                AuthoringHttp.Publication(result.Publication);
            context.Response.StatusCode = before is null
                ? StatusCodes.Status201Created
                : StatusCodes.Status200OK;
            await Results.Json(new SaveResultDto(
                id,
                AuthoringHttp.Publication(result.Publication),
                result.ContentVersion)).ExecuteAsync(context);
        }
        catch (JsonException exception)
        {
            await Results.Problem(
                title: subject + " er ugyldigt", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest).ExecuteAsync(context);
        }
        catch (ArgumentException exception)
        {
            await Results.Problem(
                title: "Ugyldig rute", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest).ExecuteAsync(context);
        }
    }

    public static async Task DeleteAsync(
        HttpContext context,
        string locale,
        string id,
        string subject,
        bool media,
        ContentPublisher publisher,
        AuthoringRepository repository,
        Read read,
        Delete delete,
        AuditTrail audit,
        CancellationToken ct)
    {
        var etag = context.Request.Headers.IfMatch.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(etag))
        {
            await AuthoringHttp.SendPreconditionRequiredAsync(context);
            return;
        }
        var by = AuthoringHttp.Actor(context.User);

        await publisher.EnsureReadyAsync(locale, ct);
        var before = await read(locale, id, ct);
        if (before is null)
        {
            context.Response.StatusCode = StatusCodes.Status404NotFound;
            return;
        }
        var referencedUnderLease = false;
        var result = await publisher.ExecuteAsync(
            locale,
            id,
            async token =>
            {
                // Referencetjekket skal ligge under samme locale-lease som
                // sletningen. Ellers kan en anden gemning nå at tilføje en
                // reference mellem tjek og DELETE.
                if (await repository.IsReferencedAsync(locale, id, media, token))
                {
                    referencedUnderLease = true;
                    return ByensGaader.Api.Storage.WriteOutcome.Rejected;
                }
                return await delete(locale, id, etag, token);
            },
            _ => Task.FromResult<AuthoringDocument?>(null),
            ct);
        if (referencedUnderLease)
        {
            await Results.Problem(
                title: subject + " bruges af en opgave",
                detail: "Fjern referencen fra opgaven, før metadata slettes.",
                statusCode: StatusCodes.Status409Conflict).ExecuteAsync(context);
            return;
        }
        if (result.Kind is WriteKind.Conflict)
        {
            await AuthoringHttp.SendConflictAsync(context, subject, ct);
            return;
        }
        if (result.Kind is not WriteKind.Written)
        {
            await Results.Problem(
                title: subject + " kunne ikke slettes",
                statusCode: StatusCodes.Status400BadRequest).ExecuteAsync(context);
            return;
        }

        await audit.RecordObjectAsync(
            locale, by, "removed", id, null, null, result.ContentVersion, ct);
        context.Response.Headers["X-Content-Publication"] =
            AuthoringHttp.Publication(result.Publication);
        context.Response.StatusCode = StatusCodes.Status204NoContent;
    }
}
