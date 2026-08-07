using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints.Testing;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AuthenticationApp : AppFixture<Program>
{
    internal string Token { get; private set; } = string.Empty;

    internal Guid AccountId { get; private set; }

    protected override void ConfigureApp(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        builder.UseSetting("ContentStore:Provider", "FileSystem");
        builder.UseSetting("ContentStore:RootPath", App.FindContentRootForTests());
        builder.UseSetting("Authentication:Enabled", "true");
        builder.UseSetting("Authentication:Provider", "InMemory");
    }

    protected override async ValueTask SetupAsync()
    {
        var repository = Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        AccountId = Guid.NewGuid();
        var account = new Account(
            AccountId,
            "designer@example.invalid",
            "Designeren",
            AccountRole.Designer,
            AccountState.Active,
            now,
            now);
        var token = OpaqueTokenService.Create();
        Token = token.Value;
        var session = new AuthenticationSession(
            token.Id,
            account.AccountId,
            AuthenticationClientKind.IOSAdmin,
            token.SecretHash,
            now.AddMinutes(15),
            null,
            null,
            null,
            now,
            now);
        Assert.True(await repository.CreateAccountAsync(account, CancellationToken.None));
        Assert.True(await repository.CreateSessionAsync(session, CancellationToken.None));
    }
}

public sealed class AuthenticationHandlerTests(AuthenticationApp app)
    : TestBase<AuthenticationApp>
{
    [Fact]
    public async Task Manglende_token_giver_401()
    {
        var response = await app.Client.GetAsync(
            "/auth/me", TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Ugyldigt_token_giver_401()
    {
        using var request = Authenticated("forkert.token");
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Gyldigt_token_giver_aktuel_konto_og_rolle()
    {
        using var request = Authenticated(app.Token);
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);
        var account = await response.Content.ReadFromJsonAsync<AuthenticatedAccountDto>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.NotNull(account);
        Assert.Equal(app.AccountId, account.AccountId);
        Assert.Equal("Designer", account.Role);
    }

    [Fact]
    public async Task Blokeret_konto_afvises_ved_naeste_request()
    {
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(), null, null, AccountRole.User, AccountState.Blocked, now, now);
        var token = OpaqueTokenService.Create();
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            new AuthenticationSession(
                token.Id, account.AccountId, AuthenticationClientKind.IOSPlayer,
                token.SecretHash, now.AddMinutes(15), null, null, null, now, now),
            TestContext.Current.CancellationToken));

        using var request = Authenticated(token.Value);
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Udloebet_session_giver_401()
    {
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(), null, null, AccountRole.User, AccountState.Active, now, now);
        var token = OpaqueTokenService.Create();
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            new AuthenticationSession(
                token.Id, account.AccountId, AuthenticationClientKind.IOSPlayer,
                token.SecretHash, now.AddMinutes(-1), null, null, null, now, now),
            TestContext.Current.CancellationToken));

        using var request = Authenticated(token.Value);
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Nedgraderet_rolle_slaar_igennem_paa_naeste_request()
    {
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(), null, null, AccountRole.Designer, AccountState.Active, now, now);
        var token = OpaqueTokenService.Create();
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            new AuthenticationSession(
                token.Id, account.AccountId, AuthenticationClientKind.IOSAdmin,
                token.SecretHash, now.AddMinutes(15), null, null, null, now, now),
            TestContext.Current.CancellationToken));
        account = await repository.GetAccountAsync(
            account.AccountId, TestContext.Current.CancellationToken);
        Assert.NotNull(account);
        Assert.True(await repository.UpdateAccountAsync(
            account with { Role = AccountRole.User, LastSignedInAt = DateTimeOffset.UtcNow },
            account.ETag,
            TestContext.Current.CancellationToken));

        using var request = Authenticated(token.Value);
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);
        var current = await response.Content.ReadFromJsonAsync<AuthenticatedAccountDto>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.NotNull(current);
        Assert.Equal("User", current.Role);
    }

    private static HttpRequestMessage Authenticated(string token)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, "/auth/me");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return request;
    }
}
