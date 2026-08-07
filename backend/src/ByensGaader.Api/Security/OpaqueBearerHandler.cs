using System.Security.Claims;
using System.Text.Encodings.Web;
using ByensGaader.Api.Features.Authentication;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Security;

internal static class AuthenticationPolicies
{
    public const string Scheme = "ByensGaaderBearer";
    public const string User = "User";
    public const string DesignerOrAdmin = "DesignerOrAdmin";
    public const string AdminOnly = "AdminOnly";
}

internal static class AuthenticationClaims
{
    public const string SessionId = "session_id";
}

internal sealed class OpaqueBearerHandler(
    IOptionsMonitor<AuthenticationSchemeOptions> schemes,
    ILoggerFactory logger,
    UrlEncoder encoder,
    IOptions<ByensGaader.Api.Features.Authentication.AuthenticationOptions> options,
    SessionAuthenticator authenticator)
    : AuthenticationHandler<AuthenticationSchemeOptions>(schemes, logger, encoder)
{
    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!options.Value.Enabled)
        {
            return AuthenticateResult.NoResult();
        }

        var header = Request.Headers.Authorization.ToString();
        if (!header.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return AuthenticateResult.NoResult();
        }

        var raw = header["Bearer ".Length..].Trim();
        var authentication = await authenticator.AuthenticateAsync(raw, Context.RequestAborted);
        if (authentication is null)
        {
            return AuthenticateResult.Fail("Sessionen eller kontoen er ugyldig eller udløbet.");
        }
        var account = authentication.Account;
        var session = authentication.Session;

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, account.AccountId.ToString("D")),
            new(ClaimTypes.Role, account.Role.ToString()),
            new(AuthenticationClaims.SessionId, session.SessionId),
        };
        if (!string.IsNullOrWhiteSpace(account.PublicName))
        {
            claims.Add(new Claim(ClaimTypes.Name, account.PublicName));
        }

        var identity = new ClaimsIdentity(claims, AuthenticationPolicies.Scheme);
        var principal = new ClaimsPrincipal(identity);
        return AuthenticateResult.Success(
            new AuthenticationTicket(principal, AuthenticationPolicies.Scheme));
    }
}
