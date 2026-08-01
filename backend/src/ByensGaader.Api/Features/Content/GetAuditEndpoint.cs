using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Sporet over hvem der ændrede hvad hvornår (FR-111). Nyeste først.
/// </summary>
/// <remarks>
/// Læses af quizmasterens app, så en statusflytning kan spores tilbage til et
/// navn og et tidspunkt uden at nogen skal på serveren.
///
/// Sporet skrives af <see cref="PutPackEndpoint"/> og kan ikke rettes gennem
/// API'et. Et revisionsspor, der kan redigeres af dem, det holder øje med,
/// beviser ingenting.
/// </remarks>
internal sealed class GetAuditEndpoint(AuditTrail audit) : EndpointWithoutRequest
{
    private const int DefaultLimit = 100;
    private const int MaxLimit = 1000;

    public override void Configure()
    {
        Get("/content/{locale}/audit");
        AllowAnonymous();
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var limit = Math.Clamp(Query<int?>("limit", isRequired: false) ?? DefaultLimit, 1, MaxLimit);

        var entries = await audit.ReadAsync(locale, limit, ct);
        await SendAsync(new { locale, entries }, cancellation: ct);
    }
}
