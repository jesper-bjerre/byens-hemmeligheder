using FastEndpoints;

namespace ByensGaader.Api.Features.Health;

/// <summary>
/// Svarer på, om API'et kører. Bruges af Azure Container Apps til at afgøre,
/// om en instans er sund, og af os til at se, at en udrulning faktisk virkede.
/// </summary>
/// <remarks>
/// Anonymt med vilje. Et sundhedstjek, der kræver login, kan ikke bruges af det,
/// der skal overvåge det.
/// </remarks>
internal sealed class HealthEndpoint : EndpointWithoutRequest<HealthResponse>
{
    public override void Configure()
    {
        Get("/health");
        // Ingen version i stien. En probe skal kunne kaldes uden at kende API-versionen.
        AllowAnonymous();
        Description(b => b.WithTags("Drift"));
    }

    public override Task HandleAsync(CancellationToken ct)
    {
        var version = typeof(HealthEndpoint).Assembly.GetName().Version?.ToString() ?? "ukendt";
        return SendAsync(new HealthResponse("kører", version), cancellation: ct);
    }
}

internal sealed record HealthResponse(string Status, string Version);
