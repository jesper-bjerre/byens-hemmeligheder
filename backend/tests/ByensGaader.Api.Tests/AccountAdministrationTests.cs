using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ByensGaader.Api.Features.Accounts;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using FastEndpoints.Testing;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ByensGaader.Api.Tests;

public class AccountManagementApp : AppFixture<Program>
{
    private string _root = string.Empty;

    protected override ValueTask PreSetupAsync()
    {
        _root = Path.Combine(
            Path.GetTempPath(), "byensgaader-account-test-" + Guid.NewGuid().ToString("N"));
        var locale = Path.Combine(_root, "da-DK");
        Directory.CreateDirectory(locale);
        File.Copy(
            Path.Combine(App.FindContentRootForTests(), "da-DK", "content-pack.json"),
            Path.Combine(locale, "content-pack.json"));
        return ValueTask.CompletedTask;
    }

    protected override void ConfigureApp(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        builder.UseSetting("ContentStore:Provider", "FileSystem");
        builder.UseSetting("ContentStore:RootPath", _root);
        builder.UseSetting("ContentStore:AuthoringRootPath", Path.Combine(_root, "authoring"));
        builder.UseSetting("Authentication:Enabled", "true");
        builder.UseSetting("Authentication:Provider", "InMemory");
    }

    protected override ValueTask TearDownAsync()
    {
        if (Directory.Exists(_root))
        {
            Directory.Delete(_root, recursive: true);
        }
        return ValueTask.CompletedTask;
    }
}

public sealed class AccountAdministrationApp : AccountManagementApp;

public sealed class AccountAdministrationTests(AccountAdministrationApp app)
    : TestBase<AccountAdministrationApp>
{
    [Fact]
    public async Task Designer_kan_ikke_se_brugerlisten()
    {
        var designer = await CreateAccountAsync(AccountRole.Designer);
        using var request = Authorized(HttpMethod.Get, "/admin/accounts", designer.Token);

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Admin_kan_forfremme_User_og_aendringen_gælder_naeste_request()
    {
        var admin = await CreateAccountAsync(AccountRole.Admin, "admin@example.invalid");
        var user = await CreateAccountAsync(AccountRole.User, "spiller@example.invalid");

        using var update = Authorized(
            HttpMethod.Put, $"/admin/accounts/{user.AccountId:D}/role", admin.Token);
        update.Content = JsonContent.Create(new ChangeAccountRoleRequest(
            "Designer", "Skal redigere Vejle-opgaver"));
        using var updateResponse = await app.Client.SendAsync(
            update, TestContext.Current.CancellationToken);

        using var authoring = Authorized(
            HttpMethod.Get, "/authoring/content/da-DK/missions", user.Token);
        using var authoringResponse = await app.Client.SendAsync(
            authoring, TestContext.Current.CancellationToken);
        var audit = app.Services.GetRequiredService<IAccountAuditRepository>();
        var auditRows = await audit.GetForTargetAsync(
            user.AccountId, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, updateResponse.StatusCode);
        Assert.Equal(HttpStatusCode.OK, authoringResponse.StatusCode);
        var row = Assert.Single(auditRows);
        Assert.Equal(admin.AccountId, row.ActorAccountId);
        Assert.Equal(AccountRole.User, row.FromRole);
        Assert.Equal(AccountRole.Designer, row.ToRole);
    }

    [Fact]
    public async Task Adminrollen_kan_ikke_tildeles_eller_fjernes_gennem_UI_endepunktet()
    {
        var admin = await CreateAccountAsync(AccountRole.Admin);
        var user = await CreateAccountAsync(AccountRole.User);

        using var promote = Authorized(
            HttpMethod.Put, $"/admin/accounts/{user.AccountId:D}/role", admin.Token);
        promote.Content = JsonContent.Create(new ChangeAccountRoleRequest("Admin", null));
        using var promoteResponse = await app.Client.SendAsync(
            promote, TestContext.Current.CancellationToken);

        using var demote = Authorized(
            HttpMethod.Put, $"/admin/accounts/{admin.AccountId:D}/role", admin.Token);
        demote.Content = JsonContent.Create(new ChangeAccountRoleRequest("User", null));
        using var demoteResponse = await app.Client.SendAsync(
            demote, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.BadRequest, promoteResponse.StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, demoteResponse.StatusCode);
    }

    [Fact]
    public async Task Admin_kan_soege_uden_at_provideridentitet_udleveres()
    {
        var admin = await CreateAccountAsync(AccountRole.Admin);
        var user = await CreateAccountAsync(AccountRole.User, "findmig@example.invalid");
        using var request = Authorized(
            HttpMethod.Get, "/admin/accounts?query=findmig", admin.Token);

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        var accounts = await response.Content.ReadFromJsonAsync<AccountAdministrationDto[]>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var found = Assert.Single(accounts!);
        Assert.Equal(user.AccountId, found.AccountId);
        Assert.Equal("findmig@example.invalid", found.Email);
    }

    private async Task<TestAccount> CreateAccountAsync(
        AccountRole role, string? email = null)
    {
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(), email, role.ToString(), role, AccountState.Active, now, now);
        var token = OpaqueTokenService.Create();
        var session = new AuthenticationSession(
            token.Id, account.AccountId, AuthenticationClientKind.WebAdmin,
            token.SecretHash, now.AddMinutes(15), null, null, null, now, now);
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            session, TestContext.Current.CancellationToken));
        return new TestAccount(account.AccountId, token.Value);
    }

    internal static HttpRequestMessage Authorized(HttpMethod method, string path, string token)
    {
        var request = new HttpRequestMessage(method, path);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return request;
    }

    private sealed record TestAccount(Guid AccountId, string Token);
}
