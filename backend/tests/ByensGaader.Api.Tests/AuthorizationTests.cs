using System.Net;
using System.Net.Http.Headers;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints.Testing;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AuthorizationApp : WritableApp;

/// <summary>Rollegrænsen testes ved HTTP-laget, så en ny eller flyttet rute
/// ikke ved et uheld kan springe sikkerhedspolitikken over.</summary>
public sealed class AuthorizationTests(AuthorizationApp app) : TestBase<AuthorizationApp>
{
    private static readonly (HttpMethod Method, string Path)[] ProtectedRoutes =
    [
        (HttpMethod.Get, "/authoring/content/da-DK/missions"),
        (HttpMethod.Get, "/authoring/content/da-DK/missions/mission.proeve"),
        (HttpMethod.Put, "/authoring/content/da-DK/missions/mission.proeve"),
        (HttpMethod.Delete, "/authoring/content/da-DK/missions/mission.proeve"),
        (HttpMethod.Get, "/authoring/content/da-DK/media"),
        (HttpMethod.Get, "/authoring/content/da-DK/media/media.proeve"),
        (HttpMethod.Put, "/authoring/content/da-DK/media/media.proeve"),
        (HttpMethod.Delete, "/authoring/content/da-DK/media/media.proeve"),
        (HttpMethod.Get, "/authoring/content/da-DK/sources"),
        (HttpMethod.Get, "/authoring/content/da-DK/sources/source.proeve"),
        (HttpMethod.Put, "/authoring/content/da-DK/sources/source.proeve"),
        (HttpMethod.Delete, "/authoring/content/da-DK/sources/source.proeve"),
        (HttpMethod.Get, "/authoring/content/da-DK/preview"),
        (HttpMethod.Get, "/content/da-DK/media"),
        (HttpMethod.Post, "/content/da-DK/media/proeve.jpg"),
        (HttpMethod.Delete, "/content/da-DK/media/proeve.jpg"),
        (HttpMethod.Post, "/content/da-DK/narration/proeve.mp3"),
        (HttpMethod.Get, "/content/da-DK/audit"),
        (HttpMethod.Put, "/content/da-DK/pack"),
    ];

    [Fact]
    public async Task Alle_redaktionelle_ruter_afviser_en_gaest()
    {
        var previous = app.Client.DefaultRequestHeaders.Authorization;
        app.Client.DefaultRequestHeaders.Authorization = null;
        try
        {
            foreach (var route in ProtectedRoutes)
            {
                using var request = new HttpRequestMessage(route.Method, route.Path);
                using var response = await app.Client.SendAsync(
                    request, TestContext.Current.CancellationToken);
                Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
            }
        }
        finally
        {
            app.Client.DefaultRequestHeaders.Authorization = previous;
        }
    }

    [Fact]
    public async Task Alle_redaktionelle_ruter_afviser_en_almindelig_bruger()
    {
        var token = await CreateTokenAsync(AccountRole.User);

        foreach (var route in ProtectedRoutes)
        {
            using var request = new HttpRequestMessage(route.Method, route.Path);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            using var response = await app.Client.SendAsync(
                request, TestContext.Current.CancellationToken);
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }
    }

    [Fact]
    public async Task Designer_og_admin_kan_lae_se_redaktionelt_indhold()
    {
        using var designer = new HttpRequestMessage(
            HttpMethod.Get, "/authoring/content/da-DK/missions");
        using var designerResponse = await app.Client.SendAsync(
            designer, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, designerResponse.StatusCode);

        using var admin = new HttpRequestMessage(
            HttpMethod.Get, "/authoring/content/da-DK/missions");
        admin.Headers.Authorization = new AuthenticationHeaderValue(
            "Bearer", await CreateTokenAsync(AccountRole.Admin));
        using var adminResponse = await app.Client.SendAsync(
            admin, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, adminResponse.StatusCode);
    }

    [Fact]
    public async Task Offentligt_indhold_kan_fortsat_hentes_uden_login()
    {
        var previous = app.Client.DefaultRequestHeaders.Authorization;
        app.Client.DefaultRequestHeaders.Authorization = null;
        try
        {
            using var health = await app.Client.GetAsync(
                "/health", TestContext.Current.CancellationToken);
            using var pack = await app.Client.GetAsync(
                "/content/da-DK/pack", TestContext.Current.CancellationToken);

            Assert.Equal(HttpStatusCode.OK, health.StatusCode);
            Assert.Equal(HttpStatusCode.OK, pack.StatusCode);
        }
        finally
        {
            app.Client.DefaultRequestHeaders.Authorization = previous;
        }
    }

    private async Task<string> CreateTokenAsync(AccountRole role)
    {
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(),
            $"{role.ToString().ToLowerInvariant()}@example.invalid",
            role.ToString(),
            role,
            AccountState.Active,
            now,
            now);
        var token = OpaqueTokenService.Create();
        var session = new AuthenticationSession(
            token.Id,
            account.AccountId,
            AuthenticationClientKind.WebAdmin,
            token.SecretHash,
            now.AddMinutes(15),
            null,
            null,
            null,
            now,
            now);

        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            session, TestContext.Current.CancellationToken));
        return token.Value;
    }
}
