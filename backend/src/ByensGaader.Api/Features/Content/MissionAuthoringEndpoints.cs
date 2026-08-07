using System.Text.Json;
using System.Text.Json.Nodes;
using ByensGaader.Api.Storage;
using FastEndpoints;
using Microsoft.Extensions.Primitives;

namespace ByensGaader.Api.Features.Content;

internal sealed class ListMissionsEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/missions");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        try
        {
            await publisher.EnsureReadyAsync(locale, ct);
            await SendAsync(await repository.ReadMissionIndexAsync(locale, ct), cancellation: ct);
        }
        catch (ArgumentException exception)
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldigt locale", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest));
        }
    }
}

internal sealed class GetMissionEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Get("/authoring/content/{locale}/missions/{missionId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        try
        {
            var locale = Route<string>("locale")!;
            var id = Route<string>("missionId")!;
            await publisher.EnsureReadyAsync(locale, ct);
            var document = await repository.ReadMissionAsync(locale, id, ct);
            if (document is null)
            {
                await SendNotFoundAsync(ct);
                return;
            }
            HttpContext.Response.Headers.ETag = document.ETag;
            await SendAsync(document.Json, cancellation: ct);
        }
        catch (ArgumentException exception)
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldig rute", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest));
        }
    }
}

internal sealed class PutMissionEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    AuditTrail audit,
    TimeProvider time) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Put("/authoring/content/{locale}/missions/{missionId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var precondition = AuthoringHttp.Precondition(HttpContext.Request.Headers);
        if (!precondition.Present)
        {
            await AuthoringHttp.SendPreconditionRequiredAsync(HttpContext);
            return;
        }
        var by = AuthoringHttp.Actor(User);

        try
        {
            var locale = Route<string>("locale")!;
            var id = Route<string>("missionId")!;
            var aggregate = await AuthoringHttp.ReadObjectAsync(HttpContext.Request, ct);
            await publisher.EnsureReadyAsync(locale, ct);
            var before = await repository.ReadMissionAsync(locale, id, ct);
            SetReleasedAt(aggregate, before?.Json, time.GetUtcNow());
            var result = await publisher.ExecuteAsync(
                locale,
                id,
                token => repository.WriteMissionAsync(
                    locale, id, aggregate, precondition.ExpectedETag, token),
                token => repository.ReadMissionAsync(locale, id, token),
                ct);

            if (result.Kind is WriteKind.Conflict)
            {
                await AuthoringHttp.SendConflictAsync(HttpContext, "Opgaven", ct);
                return;
            }
            if (result.Kind is not WriteKind.Written)
            {
                await SendResultAsync(Results.Problem(
                    title: "Opgaven kunne ikke gemmes",
                    statusCode: StatusCodes.Status400BadRequest));
                return;
            }

            var afterStatus = aggregate["mission"]?["status"]?.GetValue<string>();
            var beforeStatus = before?.Json["mission"]?["status"]?.GetValue<string>();
            var change = before is null ? "created"
                : beforeStatus != afterStatus ? "status"
                : "content";
            await audit.RecordObjectAsync(
                locale, by, change, id, beforeStatus, afterStatus, result.ContentVersion, ct);

            HttpContext.Response.Headers.ETag = result.ETag;
            HttpContext.Response.Headers["X-Content-Publication"] =
                AuthoringHttp.Publication(result.Publication);
            HttpContext.Response.StatusCode = before is null
                ? StatusCodes.Status201Created
                : StatusCodes.Status200OK;
            await SendAsync(new SaveResultDto(
                id,
                AuthoringHttp.Publication(result.Publication),
                result.ContentVersion), cancellation: ct);
        }
        catch (JsonException exception)
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldigt opgaveaggregate", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest));
        }
        catch (ArgumentException exception)
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldig rute", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest));
        }
    }

    /// <summary>
    /// Publiceringsdatoen er en serverkendsgerning. En klient må hverken kunne
    /// tilbagedatere en ny opgave eller nulstille datoen ved en almindelig
    /// tekstrettelse af en allerede frigivet opgave.
    /// </summary>
    internal static void SetReleasedAt(
        JsonObject aggregate,
        JsonObject? previousAggregate,
        DateTimeOffset now)
    {
        var mission = aggregate["mission"]?.AsObject()
            ?? throw new JsonException("Opgaveaggregatet mangler mission.");
        var currentStatus = mission["status"]?.GetValue<string>();
        var previousMission = previousAggregate?["mission"]?.AsObject();
        var previousStatus = previousMission?["status"]?.GetValue<string>();
        var isReleased = currentStatus is "published" or "publishReady";
        var wasReleased = previousStatus is "published" or "publishReady";

        if (isReleased && !wasReleased)
        {
            mission["releasedAt"] = now;
        }
        else if (isReleased && wasReleased)
        {
            mission["releasedAt"] = previousMission?["releasedAt"]?.DeepClone()
                ?? mission["releasedAt"]?.DeepClone()
                ?? JsonValue.Create(now);
        }
        else
        {
            // Datoen bevares som historik. En senere genfrigivelse overskriver
            // den med det nye tidspunkt gennem grenen ovenfor.
            mission["releasedAt"] = previousMission?["releasedAt"]?.DeepClone()
                ?? mission["releasedAt"]?.DeepClone();
        }
    }
}

internal sealed class DeleteMissionAuthoringEndpoint(
    ContentPublisher publisher,
    AuthoringRepository repository,
    AuditTrail audit) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Delete("/authoring/content/{locale}/missions/{missionId}");
        Policies(Security.AuthenticationPolicies.DesignerOrAdmin);
        Description(builder => builder.WithTags("Redaktionelt indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var ifMatch = HttpContext.Request.Headers.IfMatch.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(ifMatch))
        {
            await AuthoringHttp.SendPreconditionRequiredAsync(HttpContext);
            return;
        }
        var by = AuthoringHttp.Actor(User);

        try
        {
            var locale = Route<string>("locale")!;
            var id = Route<string>("missionId")!;
            await publisher.EnsureReadyAsync(locale, ct);
            var before = await repository.ReadMissionAsync(locale, id, ct);
            if (before is null)
            {
                await SendNotFoundAsync(ct);
                return;
            }
            var result = await publisher.ExecuteAsync(
                locale,
                id,
                token => repository.DeleteMissionAsync(locale, id, ifMatch, token),
                _ => Task.FromResult<AuthoringDocument?>(null),
                ct);
            if (result.Kind is WriteKind.Conflict)
            {
                await AuthoringHttp.SendConflictAsync(HttpContext, "Opgaven", ct);
                return;
            }

            await audit.RecordObjectAsync(
                locale,
                by,
                "removed",
                id,
                before.Json["mission"]?["status"]?.GetValue<string>(),
                null,
                result.ContentVersion,
                ct);
            HttpContext.Response.Headers["X-Content-Publication"] =
                AuthoringHttp.Publication(result.Publication);
            await SendNoContentAsync(ct);
        }
        catch (ArgumentException exception)
        {
            await SendResultAsync(Results.Problem(
                title: "Ugyldig rute", detail: exception.Message,
                statusCode: StatusCodes.Status400BadRequest));
        }
    }
}

internal static class AuthoringHttp
{
    public static (bool Present, string? ExpectedETag) Precondition(IHeaderDictionary headers)
    {
        var ifMatch = headers.IfMatch.FirstOrDefault();
        var create = headers.IfNoneMatch.Any(value => value == "*");
        return (!string.IsNullOrWhiteSpace(ifMatch) || create, create ? null : ifMatch);
    }

    public static string Actor(System.Security.Claims.ClaimsPrincipal user) =>
        user.Identity?.Name
        ?? user.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
        ?? throw new InvalidOperationException("Det beskyttede endpoint mangler en kontoidentitet.");

    public static async Task<JsonObject> ReadObjectAsync(HttpRequest request, CancellationToken ct)
    {
        using var buffer = new MemoryStream();
        await request.Body.CopyToAsync(buffer, ct);
        return JsonNode.Parse(buffer.ToArray())?.AsObject()
            ?? throw new JsonException("Kroppen er ikke et JSON-objekt.");
    }

    public static string Publication(ContentPublication publication) => publication switch
    {
        ContentPublication.Published => "published",
        ContentPublication.Pending => "pending",
        _ => "unchanged",
    };

    public static Task SendPreconditionRequiredAsync(HttpContext context) =>
        Results.Problem(
            title: "Samtidighedsbetingelse mangler",
            detail: "Send If-Match ved rettelse eller If-None-Match: * ved oprettelse.",
            statusCode: StatusCodes.Status428PreconditionRequired).ExecuteAsync(context);

    public static Task SendConflictAsync(
        HttpContext context, string subject, CancellationToken ct) =>
        Results.Problem(
            title: subject + " er ændret af en anden",
            detail: "Hent objektet igen, læg dine rettelser oveni, og gem på ny.",
            statusCode: StatusCodes.Status412PreconditionFailed).ExecuteAsync(context);
}
