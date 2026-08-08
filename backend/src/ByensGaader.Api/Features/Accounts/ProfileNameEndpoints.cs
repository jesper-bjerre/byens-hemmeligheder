using System.Globalization;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints;

namespace ByensGaader.Api.Features.Accounts;

internal sealed record UpdateProfileRequest(string? PublicName);

internal enum UpdateProfileResult
{
    Updated,
    Invalid,
    RateLimited,
    NotFound,
    Conflict,
}

internal sealed record ProfileNameValidation(string? Value, string? Error)
{
    public bool IsValid => Error is null;
}

internal static partial class ProfileNameValidator
{
    private static readonly string[] Reserved =
    [
        "admin", "administrator", "moderator", "officiel", "support",
        "vejles koder", "koder admin",
    ];

    private static readonly HashSet<string> BlockedWords = new(StringComparer.Ordinal)
    {
        "fuck", "fucking", "kusse", "luder", "nazi", "nazist", "pik", "racist",
    };

    public static ProfileNameValidation Validate(string? input)
    {
        if (string.IsNullOrWhiteSpace(input)) return new(null, null);
        if (input.Length > 100)
        {
            return new(null, "Profilnavnet må højst være 20 tegn.");
        }

        var normalized = CollapseWhitespace(input.Normalize(NormalizationForm.FormKC));
        if (!HasOnlyVisibleCharacters(normalized))
        {
            return new(null, "Profilnavnet må ikke indeholde skjulte tegn eller linjeskift.");
        }

        var length = normalized.EnumerateRunes().Count();
        if (length is < 3 or > 20)
        {
            return new(null, "Profilnavnet skal være mellem 3 og 20 tegn.");
        }

        var comparable = normalized.ToLowerInvariant();
        if (ContactOrLink().IsMatch(comparable))
        {
            return new(null, "Profilnavnet må ikke indeholde links eller kontaktoplysninger.");
        }
        var words = Word().Matches(comparable).Select(match => match.Value).ToArray();
        if (Reserved.Any(value => value.Contains(' ')
                ? comparable.Contains(value, StringComparison.Ordinal)
                : words.Contains(value, StringComparer.Ordinal)))
        {
            return new(null, "Profilnavnet kan forveksles med appens administration.");
        }

        if (words.Any(BlockedWords.Contains))
        {
            return new(null, "Vælg et andet profilnavn.");
        }
        return new(normalized, null);
    }

    public static string? NormalizeReportedName(string? input)
    {
        if (string.IsNullOrWhiteSpace(input) || input.Length > 100) return null;
        var normalized = CollapseWhitespace(input.Normalize(NormalizationForm.FormKC));
        var length = normalized.EnumerateRunes().Count();
        return length is >= 3 and <= 20 && HasOnlyVisibleCharacters(normalized)
            ? normalized
            : null;
    }

    private static string CollapseWhitespace(string value) =>
        Whitespace().Replace(value.Trim(), " ");

    private static bool HasOnlyVisibleCharacters(string value) =>
        value.EnumerateRunes().All(rune => Rune.GetUnicodeCategory(rune) is not (
            UnicodeCategory.Control
            or UnicodeCategory.Format
            or UnicodeCategory.Surrogate
            or UnicodeCategory.OtherNotAssigned
            or UnicodeCategory.LineSeparator
            or UnicodeCategory.ParagraphSeparator));

    [GeneratedRegex(@"\s+", RegexOptions.CultureInvariant)]
    private static partial Regex Whitespace();

    [GeneratedRegex(
        @"https?://|www\.|\b[\p{L}\p{N}._%+\-]+@[\p{L}\p{N}.\-]+\.[\p{L}]{2,}\b|\b(?:\+?45[\s-]*)?(?:\d[\s-]*){8}\b|\.(?:dk|com|net|org|io)\b",
        RegexOptions.IgnoreCase | RegexOptions.CultureInvariant)]
    private static partial Regex ContactOrLink();

    [GeneratedRegex(@"[\p{L}\p{N}]+", RegexOptions.CultureInvariant)]
    private static partial Regex Word();
}

internal sealed class ProfileService(
    IAuthenticationRepository accounts,
    TimeProvider time)
{
    private static readonly TimeSpan ChangeInterval = TimeSpan.FromHours(24);

    public async Task<(UpdateProfileResult Result, Account? Account, string? Error)> UpdateAsync(
        Guid accountId,
        string? requestedName,
        CancellationToken ct)
    {
        var validation = ProfileNameValidator.Validate(requestedName);
        if (!validation.IsValid)
        {
            return (UpdateProfileResult.Invalid, null, validation.Error);
        }

        for (var attempt = 0; attempt < 3; attempt++)
        {
            var current = await accounts.GetAccountAsync(accountId, ct);
            if (current is null || current.State is AccountState.Deleted)
            {
                return (UpdateProfileResult.NotFound, null, null);
            }
            if (string.Equals(current.PublicName, validation.Value, StringComparison.Ordinal))
            {
                return (UpdateProfileResult.Updated, current, null);
            }

            var now = time.GetUtcNow();
            if (validation.Value is not null
                && current.PublicNameChangedAt is { } changedAt
                && changedAt.Add(ChangeInterval) > now)
            {
                return (UpdateProfileResult.RateLimited, current,
                    "Profilnavnet kan ændres igen 24 timer efter den seneste ændring.");
            }

            var updated = current with
            {
                PublicName = validation.Value,
                // At fjerne et navn er altid tilladt og må ikke starte en ny
                // ventetid. Det seneste ikke-tomme navneskift bevares, så
                // fjern-og-tilføj ikke kan omgå 24-timersgrænsen.
                PublicNameChangedAt = validation.Value is null
                    ? current.PublicNameChangedAt
                    : now,
                NameModerationState = NameModerationState.Visible,
                NameModerationReason = null,
                NameModeratedAt = null,
            };
            if (await accounts.UpdateAccountAsync(updated, current.ETag, ct))
            {
                return (UpdateProfileResult.Updated, updated, null);
            }
        }
        return (UpdateProfileResult.Conflict, null, null);
    }
}

internal sealed class UpdateProfileEndpoint(ProfileService service)
    : Endpoint<UpdateProfileRequest, AuthenticatedAccountDto>
{
    public override void Configure()
    {
        Put("/auth/me/profile");
        Policies(AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Konti"));
    }

    public override async Task HandleAsync(UpdateProfileRequest request, CancellationToken ct)
    {
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var accountId))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var result = await service.UpdateAsync(accountId, request.PublicName, ct);
        switch (result.Result)
        {
            case UpdateProfileResult.Updated:
                var account = result.Account!;
                await SendAsync(new AuthenticatedAccountDto(
                    account.AccountId,
                    account.Email,
                    account.PublicName,
                    account.Role.ToString(),
                    account.State.ToString(),
                    account.NameModerationState.ToString()), cancellation: ct);
                break;
            case UpdateProfileResult.Invalid:
                AddError(result.Error!);
                await SendErrorsAsync(cancellation: ct);
                break;
            case UpdateProfileResult.RateLimited:
                AddError(result.Error!);
                await SendErrorsAsync(StatusCodes.Status429TooManyRequests, cancellation: ct);
                break;
            case UpdateProfileResult.NotFound:
                await SendNotFoundAsync(ct);
                break;
            default:
                AddError("Kontoen blev ændret samtidig. Prøv igen.");
                await SendErrorsAsync(StatusCodes.Status409Conflict, cancellation: ct);
                break;
        }
    }
}
