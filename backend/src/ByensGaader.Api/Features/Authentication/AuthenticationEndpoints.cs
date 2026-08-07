using System.Security.Claims;
using FastEndpoints;

namespace ByensGaader.Api.Features.Authentication;

internal sealed record NativeAppleExchangeRequest(
    string ClientId,
    string IdentityToken,
    string AuthorizationCode,
    string Nonce,
    string ClientKind);

internal sealed record RefreshSessionRequest(string RefreshToken);

internal sealed record WebAppleExchangeRequest(
    string ClientId,
    string IdentityToken,
    string AuthorizationCode,
    string Nonce,
    string RedirectUri,
    string ClientKind);

internal sealed record SessionResponse(
    string AccessToken,
    DateTimeOffset AccessExpiresAt,
    string? RefreshToken,
    DateTimeOffset? RefreshExpiresAt,
    AuthenticatedAccountDto Account);

internal sealed class NativeAppleExchangeEndpoint(
    IAppleIdentityValidator validator,
    IAppleTokenClient appleTokens,
    AccountService accounts) : Endpoint<NativeAppleExchangeRequest, SessionResponse>
{
    public override void Configure()
    {
        Post("/auth/apple/native/exchange");
        AllowAnonymous();
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(NativeAppleExchangeRequest request, CancellationToken ct)
    {
        if (!Enum.TryParse<AuthenticationClientKind>(
                request.ClientKind, ignoreCase: false, out var clientKind)
            || clientKind is not (AuthenticationClientKind.IOSPlayer
                or AuthenticationClientKind.IOSAdmin))
        {
            AddError(item => item.ClientKind, "Ukendt native klienttype.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }

        var suppliedIdentity = await validator.ValidateAsync(
            request.IdentityToken, request.ClientId, request.Nonce, ct);
        if (suppliedIdentity is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var exchange = await appleTokens.ExchangeCodeAsync(
            request.AuthorizationCode, request.ClientId, redirectUri: null, ct);
        if (exchange is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var exchangedIdentity = await validator.ValidateAsync(
            exchange.IdentityToken, request.ClientId, request.Nonce, ct);
        if (exchangedIdentity is null
            || !Security.OpaqueTokenService.Matches(
                suppliedIdentity.SubjectHash, exchangedIdentity.SubjectHash))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var signIn = await accounts.SignInWithAppleAsync(
            exchangedIdentity, exchange.RefreshToken, request.ClientId, clientKind, ct);
        if (signIn is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        await SendAsync(
            ToResponse(signIn.Session),
            signIn.AccountCreated
                ? StatusCodes.Status201Created
                : StatusCodes.Status200OK,
            ct);
    }

    internal static SessionResponse ToResponse(IssuedSession session) => new(
        session.AccessToken,
        session.AccessExpiresAt,
        session.RefreshToken,
        session.RefreshExpiresAt,
        new AuthenticatedAccountDto(
            session.Account.AccountId,
            session.Account.Email,
            session.Account.PublicName,
            session.Account.Role.ToString(),
            session.Account.State.ToString()));
}

/// Veksler Apples engangskode direkte fra web-popup'en. Browseren ejer
/// state/nonce under popup-forløbet; API'et validerer nonce igen i det signerede
/// identity-token og Apples token-endpoint gør authorization code til engangsbrug.
internal sealed class WebAppleExchangeEndpoint(
    IAppleIdentityValidator validator,
    IAppleTokenClient appleTokens,
    AccountService accounts,
    Microsoft.Extensions.Options.IOptions<AuthenticationOptions> options)
    : Endpoint<WebAppleExchangeRequest, SessionResponse>
{
    public override void Configure()
    {
        Post("/auth/apple/web/exchange");
        AllowAnonymous();
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(WebAppleExchangeRequest request, CancellationToken ct)
    {
        if (!Enum.TryParse<AuthenticationClientKind>(
                request.ClientKind, ignoreCase: false, out var clientKind)
            || clientKind is not AuthenticationClientKind.WebAdmin
            || !options.Value.Apple.AllowedWebRedirectUris.Contains(
                request.RedirectUri, StringComparer.Ordinal))
        {
            AddError("Ukendt webklient eller return URL.");
            await SendErrorsAsync(cancellation: ct);
            return;
        }

        var suppliedIdentity = await validator.ValidateAsync(
            request.IdentityToken, request.ClientId, request.Nonce, ct);
        if (suppliedIdentity is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var exchange = await appleTokens.ExchangeCodeAsync(
            request.AuthorizationCode, request.ClientId, request.RedirectUri, ct);
        if (exchange is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var exchangedIdentity = await validator.ValidateAsync(
            exchange.IdentityToken, request.ClientId, request.Nonce, ct);
        if (exchangedIdentity is null
            || !Security.OpaqueTokenService.Matches(
                suppliedIdentity.SubjectHash, exchangedIdentity.SubjectHash))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        var signIn = await accounts.SignInWithAppleAsync(
            exchangedIdentity, exchange.RefreshToken, request.ClientId, clientKind, ct);
        if (signIn is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }

        await SendAsync(
            NativeAppleExchangeEndpoint.ToResponse(signIn.Session),
            signIn.AccountCreated
                ? StatusCodes.Status201Created
                : StatusCodes.Status200OK,
            ct);
    }
}

internal sealed class RefreshSessionEndpoint(SessionService sessions)
    : Endpoint<RefreshSessionRequest, SessionResponse>
{
    public override void Configure()
    {
        Post("/auth/refresh");
        AllowAnonymous();
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(RefreshSessionRequest request, CancellationToken ct)
    {
        var refreshed = await sessions.RefreshNativeAsync(request.RefreshToken, ct);
        if (refreshed is null)
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        await SendAsync(NativeAppleExchangeEndpoint.ToResponse(refreshed), cancellation: ct);
    }
}

internal sealed class LogoutEndpoint(SessionService sessions) : EndpointWithoutRequest
{
    public override void Configure()
    {
        Post("/auth/logout");
        Policies(Security.AuthenticationPolicies.User);
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var sessionId = User.FindFirstValue(Security.AuthenticationClaims.SessionId);
        if (string.IsNullOrWhiteSpace(sessionId)
            || !await sessions.RevokeAsync(sessionId, "logout", ct))
        {
            await SendUnauthorizedAsync(ct);
            return;
        }
        await SendNoContentAsync(ct);
    }
}
