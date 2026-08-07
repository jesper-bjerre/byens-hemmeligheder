using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints.Testing;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AuthenticationEndpointApp : AppFixture<Program>
{
    protected override void ConfigureApp(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        builder.UseSetting("ContentStore:Provider", "FileSystem");
        builder.UseSetting("ContentStore:RootPath", App.FindContentRootForTests());
        builder.UseSetting("Authentication:Enabled", "true");
        builder.UseSetting("Authentication:Provider", "InMemory");
        builder.UseSetting(
            "Authentication:Apple:BootstrapAdminEmail", "admin@example.invalid");
        builder.UseSetting(
            "Authentication:Apple:AllowedWebRedirectUris:0", "https://admin.example.invalid/auth/callback");
        builder.ConfigureServices(services =>
        {
            services.RemoveAll<IAppleIdentityValidator>();
            services.RemoveAll<IAppleTokenClient>();
            services.RemoveAll<IProviderTokenProtector>();
            services.AddSingleton<IAppleIdentityValidator, FakeAppleIdentityValidator>();
            services.AddSingleton<IAppleTokenClient, FakeAppleTokenClient>();
            services.AddSingleton<IProviderTokenProtector, FakeProviderTokenProtector>();
        });
    }
}

public sealed class AuthenticationEndpointTests(AuthenticationEndpointApp app)
    : TestBase<AuthenticationEndpointApp>
{
    [Fact]
    public async Task Foerste_login_opretter_konto_og_naeste_login_genbruger_den()
    {
        var login = Identity("konto-genbrug");

        var first = await ExchangeAsync(login);
        var second = await ExchangeAsync(login);

        Assert.Equal(HttpStatusCode.Created, first.Status);
        Assert.Equal(HttpStatusCode.OK, second.Status);
        Assert.Equal(first.Body.Account.AccountId, second.Body.Account.AccountId);
        Assert.Equal("User", first.Body.Account.Role);
        Assert.NotEqual(first.Body.AccessToken, second.Body.AccessToken);
    }

    [Fact]
    public async Task Access_token_giver_adgang_til_den_aktuelle_konto()
    {
        var login = await ExchangeAsync(Identity("aktuel-konto"));
        using var request = new HttpRequestMessage(HttpMethod.Get, "/auth/me");
        request.Headers.Authorization = new AuthenticationHeaderValue(
            "Bearer", login.Body.AccessToken);

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        var account = await response.Content.ReadFromJsonAsync<AuthenticatedAccountDto>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.NotNull(account);
        Assert.Equal(login.Body.Account.AccountId, account.AccountId);
    }

    [Fact]
    public async Task Samtidige_bootstrapforsoeg_opretter_praecis_en_admin()
    {
        var results = await Task.WhenAll(Enumerable.Range(0, 8).Select(index =>
            ExchangeAsync(Identity($"bootstrap-{index}", "admin@example.invalid"))));

        Assert.Single(results, result => result.Body.Account.Role == "Admin");
        Assert.Equal(7, results.Count(result => result.Body.Account.Role == "User"));
    }

    [Fact]
    public async Task Samtidige_login_med_samme_Apple_identitet_faar_samme_konto()
    {
        var login = Identity("samtidig-identity");

        var results = await Task.WhenAll(
            Enumerable.Range(0, 8).Select(_ => ExchangeAsync(login)));

        Assert.Single(results.Select(result => result.Body.Account.AccountId).Distinct());
        Assert.All(results, result => Assert.True(
            result.Status is HttpStatusCode.OK or HttpStatusCode.Created));
    }

    [Fact]
    public async Task Ugyldig_kode_eller_forskellige_subjects_opretter_ingen_session()
    {
        var rejected = await ExchangeRawAsync(new NativeAppleExchangeRequest(
            "dk.example.byensgaader",
            Identity("afvist"),
            "reject",
            ValidNonce,
            "IOSPlayer"));
        var mismatch = await ExchangeRawAsync(new NativeAppleExchangeRequest(
            "dk.example.byensgaader",
            Identity("forventet"),
            "mismatch",
            ValidNonce,
            "IOSPlayer"));

        Assert.Equal(HttpStatusCode.Unauthorized, rejected.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, mismatch.StatusCode);
    }

    [Fact]
    public async Task Samme_authorization_code_kan_kun_bruges_en_gang()
    {
        var identity = Identity("code-replay");
        var code = identity["valid:".Length..] + "#samme-kode";
        var request = new NativeAppleExchangeRequest(
            "dk.example.byensgaader", identity, code, ValidNonce, "IOSPlayer");

        using var first = await ExchangeRawAsync(request);
        using var replay = await ExchangeRawAsync(request);

        Assert.Equal(HttpStatusCode.Created, first.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, replay.StatusCode);
    }

    [Fact]
    public async Task Refresh_roteres_og_genbrug_tilbagekalder_sessionen()
    {
        var login = await ExchangeAsync(Identity("rotation"));
        Assert.NotNull(login.Body.RefreshToken);

        using var rotatedResponse = await app.Client.PostAsJsonAsync(
            "/auth/refresh",
            new RefreshSessionRequest(login.Body.RefreshToken),
            TestContext.Current.CancellationToken);
        var rotated = await rotatedResponse.Content.ReadFromJsonAsync<SessionResponse>(
            TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, rotatedResponse.StatusCode);
        Assert.NotNull(rotated?.RefreshToken);

        using var replay = await app.Client.PostAsJsonAsync(
            "/auth/refresh",
            new RefreshSessionRequest(login.Body.RefreshToken),
            TestContext.Current.CancellationToken);
        using var afterReplay = await app.Client.PostAsJsonAsync(
            "/auth/refresh",
            new RefreshSessionRequest(rotated.RefreshToken),
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Unauthorized, replay.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, afterReplay.StatusCode);
    }

    [Fact]
    public async Task Logout_goer_access_token_ubrugelig_med_det_samme()
    {
        var login = await ExchangeAsync(Identity("logout"));
        using var logout = new HttpRequestMessage(HttpMethod.Post, "/auth/logout");
        logout.Headers.Authorization = new AuthenticationHeaderValue(
            "Bearer", login.Body.AccessToken);
        using var logoutResponse = await app.Client.SendAsync(
            logout, TestContext.Current.CancellationToken);

        using var me = new HttpRequestMessage(HttpMethod.Get, "/auth/me");
        me.Headers.Authorization = new AuthenticationHeaderValue(
            "Bearer", login.Body.AccessToken);
        using var meResponse = await app.Client.SendAsync(
            me, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NoContent, logoutResponse.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, meResponse.StatusCode);
    }

    [Fact]
    public async Task Weblogin_udsteder_kun_kort_access_token_og_afviser_ukendt_return_url()
    {
        var identity = Identity("webadmin");
        var body = new WebAppleExchangeRequest(
            "dk.example.byensgaader.webadmin",
            identity,
            identity["valid:".Length..] + "#" + Guid.NewGuid().ToString("N"),
            ValidNonce,
            "https://admin.example.invalid/auth/callback",
            "WebAdmin");

        using var accepted = await app.Client.PostAsJsonAsync(
            "/auth/apple/web/exchange", body, TestContext.Current.CancellationToken);
        var session = await accepted.Content.ReadFromJsonAsync<SessionResponse>(
            TestContext.Current.CancellationToken);
        using var rejected = await app.Client.PostAsJsonAsync(
            "/auth/apple/web/exchange",
            body with
            {
                AuthorizationCode = body.AuthorizationCode + "-nyt",
                RedirectUri = "https://angriber.example/auth/callback",
            },
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Created, accepted.StatusCode);
        Assert.NotNull(session);
        Assert.Null(session.RefreshToken);
        Assert.Null(session.RefreshExpiresAt);
        Assert.Equal(HttpStatusCode.BadRequest, rejected.StatusCode);
    }

    private const string ValidNonce = "en-ra-nonce-med-mindst-toogtredive-tegn";

    private async Task<(HttpStatusCode Status, SessionResponse Body)> ExchangeAsync(
        string identity)
    {
        using var response = await ExchangeRawAsync(new NativeAppleExchangeRequest(
            "dk.example.byensgaader",
            identity,
            identity["valid:".Length..] + "#" + Guid.NewGuid().ToString("N"),
            ValidNonce,
            "IOSPlayer"));
        var body = await response.Content.ReadFromJsonAsync<SessionResponse>(
            TestContext.Current.CancellationToken);
        Assert.NotNull(body);
        return (response.StatusCode, body);
    }

    private Task<HttpResponseMessage> ExchangeRawAsync(NativeAppleExchangeRequest request) =>
        app.Client.PostAsJsonAsync(
            "/auth/apple/native/exchange", request, TestContext.Current.CancellationToken);

    private static string Identity(string subject, string? email = null) =>
        $"valid:{subject}|{email ?? subject + "@example.invalid"}";
}

internal sealed class FakeAppleIdentityValidator : IAppleIdentityValidator
{
    public Task<ValidatedAppleIdentity?> ValidateAsync(
        string identityToken, string clientId, string rawNonce, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        if (!identityToken.StartsWith("valid:", StringComparison.Ordinal)
            || rawNonce.Length < 32)
        {
            return Task.FromResult<ValidatedAppleIdentity?>(null);
        }
        var values = identityToken["valid:".Length..].Split('|', 2);
        var subject = values[0];
        var email = values.Length is 2 ? values[1] : null;
        return Task.FromResult<ValidatedAppleIdentity?>(new(
            subject,
            OpaqueTokenService.Hash(subject),
            email,
            !string.IsNullOrWhiteSpace(email)));
    }

    public Task<ValidatedAppleNotification?> ValidateNotificationAsync(
        string signedPayload, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult<ValidatedAppleNotification?>(null);
    }
}

internal sealed class FakeAppleTokenClient : IAppleTokenClient
{
    private readonly System.Collections.Concurrent.ConcurrentDictionary<string, byte> _usedCodes =
        new(StringComparer.Ordinal);

    public Task<AppleTokenExchange?> ExchangeCodeAsync(
        string authorizationCode, string clientId, string? redirectUri, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        if (authorizationCode is "reject" || !_usedCodes.TryAdd(authorizationCode, 0))
        {
            return Task.FromResult<AppleTokenExchange?>(null);
        }
        var identity = authorizationCode is "mismatch"
            ? "valid:et-andet-subject|andet@example.invalid"
            : "valid:" + authorizationCode.Split('#', 2)[0];
        return Task.FromResult<AppleTokenExchange?>(new(
            identity, "apple-refresh-" + authorizationCode));
    }

    public Task<bool> RevokeRefreshTokenAsync(
        string refreshToken, string clientId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(true);
    }
}

internal sealed class FakeProviderTokenProtector : IProviderTokenProtector
{
    public string Protect(string token) => "test-beskyttet-" + OpaqueTokenService.Hash(token);

    public string? Unprotect(string protectedToken) => null;
}
