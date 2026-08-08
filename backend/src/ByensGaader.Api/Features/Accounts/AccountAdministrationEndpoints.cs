using System.Security.Claims;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints;

namespace ByensGaader.Api.Features.Accounts;

internal sealed record AccountAdministrationDto(
    Guid AccountId,
    string? Email,
    string? PublicName,
    string Role,
    string State,
    string NameModerationState,
    string? NameModerationReason,
    DateTimeOffset LastSignedInAt);

internal sealed record ChangeAccountRoleRequest(string Role, string? Reason);
internal sealed record ChangeAccountModerationRequest(bool Hidden, string? Reason);
internal sealed record ChangeAccountStateRequest(string State, string? Reason);

internal enum ChangeRoleResult
{
    Updated,
    NotFound,
    ProtectedRole,
    Conflict,
}

internal sealed class AccountAdministrationService(
    IAuthenticationRepository accounts,
    IAccountAuditRepository audit,
    TimeProvider time)
{
    public async Task<IReadOnlyList<AccountAdministrationDto>> SearchAsync(
        string query, CancellationToken ct) =>
        (await accounts.SearchAccountsAsync(query, 100, ct))
        .Select(ToDto)
        .ToArray();

    public async Task<(ChangeRoleResult Result, Account? Account)> ChangeRoleAsync(
        Guid actorAccountId,
        Guid targetAccountId,
        AccountRole role,
        string? reason,
        CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var current = await accounts.GetAccountAsync(targetAccountId, ct);
            if (current is null || current.State is AccountState.Deleted)
            {
                return (ChangeRoleResult.NotFound, null);
            }
            if (current.Role is AccountRole.Admin)
            {
                return (ChangeRoleResult.ProtectedRole, current);
            }
            if (current.Role == role)
            {
                return (ChangeRoleResult.Updated, current);
            }

            var updated = current with { Role = role };
            if (!await accounts.UpdateAccountAsync(updated, current.ETag, ct))
            {
                continue;
            }

            await audit.AppendAsync(new RoleChangeAudit(
                Guid.NewGuid(),
                time.GetUtcNow(),
                actorAccountId,
                targetAccountId,
                current.Role,
                role,
                string.IsNullOrWhiteSpace(reason) ? null : reason.Trim()), ct);
            return (ChangeRoleResult.Updated, updated);
        }
        return (ChangeRoleResult.Conflict, null);
    }

    public async Task<(ChangeRoleResult Result, Account? Account)> ChangeModerationAsync(
        Guid targetAccountId,
        bool hidden,
        string? reason,
        CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var current = await accounts.GetAccountAsync(targetAccountId, ct);
            if (current is null || current.State is AccountState.Deleted)
            {
                return (ChangeRoleResult.NotFound, null);
            }
            var state = hidden ? NameModerationState.Hidden : NameModerationState.Visible;
            var updated = current with
            {
                NameModerationState = state,
                NameModerationReason = hidden && !string.IsNullOrWhiteSpace(reason)
                    ? reason.Trim()
                    : null,
                NameModeratedAt = time.GetUtcNow(),
            };
            if (await accounts.UpdateAccountAsync(updated, current.ETag, ct))
            {
                return (ChangeRoleResult.Updated, updated);
            }
        }
        return (ChangeRoleResult.Conflict, null);
    }

    public async Task<(ChangeRoleResult Result, Account? Account)> ChangeStateAsync(
        Guid targetAccountId,
        AccountState state,
        string? reason,
        CancellationToken ct)
    {
        for (var attempt = 0; attempt < 3; attempt++)
        {
            var current = await accounts.GetAccountAsync(targetAccountId, ct);
            if (current is null || current.State is AccountState.Deleted)
            {
                return (ChangeRoleResult.NotFound, null);
            }
            if (current.Role is AccountRole.Admin)
            {
                return (ChangeRoleResult.ProtectedRole, current);
            }
            var updated = current with
            {
                State = state,
                StateReason = state is AccountState.Blocked
                    && !string.IsNullOrWhiteSpace(reason)
                        ? reason.Trim()
                        : null,
                StateChangedAt = time.GetUtcNow(),
            };
            if (await accounts.UpdateAccountAsync(updated, current.ETag, ct))
            {
                return (ChangeRoleResult.Updated, updated);
            }
        }
        return (ChangeRoleResult.Conflict, null);
    }

    internal static AccountAdministrationDto ToDto(Account account) => new(
        account.AccountId,
        account.Email,
        account.PublicName,
        account.Role.ToString(),
        account.State.ToString(),
        account.NameModerationState.ToString(),
        account.NameModerationReason,
        account.LastSignedInAt);
}

internal sealed class SearchAccountsEndpoint(AccountAdministrationService service)
    : EndpointWithoutRequest<IReadOnlyList<AccountAdministrationDto>>
{
    public override void Configure()
    {
        Get("/admin/accounts");
        Policies(AuthenticationPolicies.AdminOnly);
        Description(builder => builder.WithTags("Konti"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var query = Query<string>("query", isRequired: false)?.Trim() ?? string.Empty;
        if (query.Length > 100)
        {
            AddError("Søgningen må højst være 100 tegn.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        await SendAsync(await service.SearchAsync(query, ct), cancellation: ct);
    }
}

internal sealed class ChangeAccountModerationEndpoint(AccountAdministrationService service)
    : Endpoint<ChangeAccountModerationRequest, AccountAdministrationDto>
{
    public override void Configure()
    {
        Put("/admin/accounts/{accountId:guid}/moderation");
        Policies(AuthenticationPolicies.AdminOnly);
        Description(builder => builder.WithTags("Konti"));
    }

    public override async Task HandleAsync(
        ChangeAccountModerationRequest request, CancellationToken ct)
    {
        if (!Guid.TryParse(Route<string>("accountId"), out var targetId))
        {
            await SendNotFoundAsync(ct);
            return;
        }
        if (request.Reason?.Length > 200)
        {
            AddError("Begrundelsen må højst være 200 tegn.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        var result = await service.ChangeModerationAsync(
            targetId, request.Hidden, request.Reason, ct);
        await SendResultAsync(result, ct);
    }

    private async Task SendResultAsync(
        (ChangeRoleResult Result, Account? Account) result,
        CancellationToken ct)
    {
        switch (result.Result)
        {
            case ChangeRoleResult.Updated:
                await SendAsync(AccountAdministrationService.ToDto(result.Account!), cancellation: ct);
                break;
            case ChangeRoleResult.NotFound:
                await SendNotFoundAsync(ct);
                break;
            default:
                AddError("Kontoen blev ændret samtidig. Hent listen igen og prøv på ny.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
        }
    }
}

internal sealed class ChangeAccountStateEndpoint(AccountAdministrationService service)
    : Endpoint<ChangeAccountStateRequest, AccountAdministrationDto>
{
    public override void Configure()
    {
        Put("/admin/accounts/{accountId:guid}/state");
        Policies(AuthenticationPolicies.AdminOnly);
        Description(builder => builder.WithTags("Konti"));
    }

    public override async Task HandleAsync(ChangeAccountStateRequest request, CancellationToken ct)
    {
        if (!Guid.TryParse(Route<string>("accountId"), out var targetId))
        {
            await SendNotFoundAsync(ct);
            return;
        }
        if (!Enum.TryParse<AccountState>(request.State, ignoreCase: false, out var state)
            || state is not (AccountState.Active or AccountState.Blocked)
            || request.Reason?.Length > 200)
        {
            AddError("Tilstanden skal være Active eller Blocked, og begrundelsen må højst være 200 tegn.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }
        var result = await service.ChangeStateAsync(targetId, state, request.Reason, ct);
        switch (result.Result)
        {
            case ChangeRoleResult.Updated:
                await SendAsync(AccountAdministrationService.ToDto(result.Account!), cancellation: ct);
                break;
            case ChangeRoleResult.NotFound:
                await SendNotFoundAsync(ct);
                break;
            case ChangeRoleResult.ProtectedRole:
                AddError("En Admin-konto kan ikke blokeres gennem brugeradministrationen.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
            default:
                AddError("Kontoen blev ændret samtidig. Hent listen igen og prøv på ny.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
        }
    }
}

internal sealed class ChangeAccountRoleEndpoint(AccountAdministrationService service)
    : Endpoint<ChangeAccountRoleRequest, AccountAdministrationDto>
{
    public override void Configure()
    {
        Put("/admin/accounts/{accountId:guid}/role");
        Policies(AuthenticationPolicies.AdminOnly);
        Description(builder => builder.WithTags("Konti"));
    }

    public override async Task HandleAsync(ChangeAccountRoleRequest request, CancellationToken ct)
    {
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var actorId)
            || !Guid.TryParse(Route<string>("accountId"), out var targetId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        if (!Enum.TryParse<AccountRole>(request.Role, ignoreCase: false, out var role)
            || role is not (AccountRole.User or AccountRole.Designer)
            || request.Reason?.Length > 200)
        {
            AddError("Rollen skal være User eller Designer, og begrundelsen må højst være 200 tegn.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }

        var result = await service.ChangeRoleAsync(actorId, targetId, role, request.Reason, ct);
        switch (result.Result)
        {
            case ChangeRoleResult.Updated:
                await SendAsync(AccountAdministrationService.ToDto(result.Account!), cancellation: ct);
                break;
            case ChangeRoleResult.NotFound:
                await SendNotFoundAsync(ct);
                break;
            case ChangeRoleResult.ProtectedRole:
                AddError("Adminrollen kan ikke ændres gennem brugeradministrationen.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
            default:
                AddError("Kontoen blev ændret samtidig. Hent listen igen og prøv på ny.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
        }
    }
}
