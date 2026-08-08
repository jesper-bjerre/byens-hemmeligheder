using System.Security.Claims;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints;

namespace ByensGaader.Api.Features.Accounts;

internal sealed record CreateNameReportRequest(string ReportedName, string Category);

internal sealed class NameReportService(
    INameReportRepository reports,
    IAuthenticationRepository accounts,
    TimeProvider time)
{
    private static readonly TimeSpan Retention = TimeSpan.FromDays(90);

    public async Task<bool> AddAsync(
        Guid reporterAccountId,
        string reportedName,
        NameReportCategory category,
        CancellationToken ct)
    {
        var now = time.GetUtcNow();
        var matches = await accounts.SearchAccountsAsync(reportedName, 100, ct);
        if (!matches.Any(account =>
                account.State is AccountState.Active
                && account.NameModerationState is NameModerationState.Visible
                && string.Equals(account.PublicName, reportedName, StringComparison.Ordinal)))
        {
            return false;
        }
        await reports.DeleteBeforeAsync(now.Subtract(Retention), ct);
        await reports.AddOncePerDayAsync(new NameReport(
            Guid.NewGuid(), reporterAccountId, reportedName, category, now), ct);
        return true;
    }

    public async Task<IReadOnlyList<NameReportDto>> GetAsync(CancellationToken ct)
    {
        var since = time.GetUtcNow().Subtract(Retention);
        await reports.DeleteBeforeAsync(since, ct);
        return (await reports.GetSinceAsync(since, ct))
            .Select(item => new NameReportDto(
                item.ReportId,
                item.ReporterAccountId,
                item.ReportedName,
                item.Category.ToString(),
                item.CreatedAt))
            .ToArray();
    }
}

internal sealed class CreateNameReportEndpoint(NameReportService service)
    : Endpoint<CreateNameReportRequest>
{
    public override void Configure()
    {
        Post("/scores/name-reports");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Point"));
    }

    public override async Task HandleAsync(CreateNameReportRequest request, CancellationToken ct)
    {
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var reporterId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        var name = ProfileNameValidator.NormalizeReportedName(request.ReportedName);
        if (name is null
            || !Enum.TryParse<NameReportCategory>(request.Category, out var category))
        {
            AddError("Navnet eller rapportkategorien er ugyldig.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }

        if (!await service.AddAsync(reporterId, name, category, ct))
        {
            AddError("Profilnavnet findes ikke længere på highscorelisten.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        // Gentagne rapporter samme dag behandles idempotent og afslører ikke,
        // om den første allerede fandtes.
        await SendNoContentAsync(ct);
    }
}

internal sealed class GetNameReportsEndpoint(NameReportService service)
    : EndpointWithoutRequest<IReadOnlyList<NameReportDto>>
{
    public override void Configure()
    {
        Get("/admin/name-reports");
        Policies(AuthenticationPolicies.AdminOnly);
        Description(builder => builder.WithTags("Konti"));
    }

    public override async Task HandleAsync(CancellationToken ct) =>
        await SendAsync(await service.GetAsync(ct), cancellation: ct);
}
