using System.Net;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Features.Engagement;
using ByensGaader.Api.Features.Scoring;
using ByensGaader.Api.Security;
using FastEndpoints.Testing;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AccountLifecycleApp : AccountManagementApp;

public sealed class AccountLifecycleTests(AccountLifecycleApp app)
    : TestBase<AccountLifecycleApp>
{
    [Fact]
    public async Task En_User_kan_slette_konto_identitet_og_alle_sessioner()
    {
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(), "slet@example.invalid", "Slet mig", AccountRole.User,
            AccountState.Active, now, now);
        var first = OpaqueTokenService.Create();
        var second = OpaqueTokenService.Create();
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateIdentityAsync(new ExternalIdentity(
            "apple", OpaqueTokenService.Hash("apple-subject"), account.AccountId,
            now, now, "krypteret-refresh"), TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            Session(account, first, now), TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            Session(account, second, now), TestContext.Current.CancellationToken));
        var engagement = app.Services.GetRequiredService<IMissionEngagementRepository>();
        var scores = app.Services.GetRequiredService<IScoreRepository>();
        await engagement.SetFavoriteAsync(
            account.AccountId, "mission.test", true, now,
            TestContext.Current.CancellationToken);
        await scores.AddOrGetAsync(new PlayerScore(
            account.AccountId, "mission.test", Guid.NewGuid(), "test-version",
            100, now, []), TestContext.Current.CancellationToken);

        using var delete = AccountAdministrationTests.Authorized(
            HttpMethod.Delete, "/auth/me", first.Value);
        using var deleteResponse = await app.Client.SendAsync(
            delete, TestContext.Current.CancellationToken);
        using var firstMe = AccountAdministrationTests.Authorized(
            HttpMethod.Get, "/auth/me", first.Value);
        using var secondMe = AccountAdministrationTests.Authorized(
            HttpMethod.Get, "/auth/me", second.Value);
        using var firstResponse = await app.Client.SendAsync(
            firstMe, TestContext.Current.CancellationToken);
        using var secondResponse = await app.Client.SendAsync(
            secondMe, TestContext.Current.CancellationToken);

        var deleted = await repository.GetAccountAsync(
            account.AccountId, TestContext.Current.CancellationToken);
        var identity = await repository.GetIdentityAsync(
            "apple", OpaqueTokenService.Hash("apple-subject"),
            TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.NoContent, deleteResponse.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, firstResponse.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, secondResponse.StatusCode);
        Assert.NotNull(deleted);
        Assert.Equal(AccountState.Deleted, deleted.State);
        Assert.Null(deleted.Email);
        Assert.Null(deleted.PublicName);
        Assert.Null(identity);
        Assert.Empty(await engagement.GetFavoritesAsync(
            account.AccountId, TestContext.Current.CancellationToken));
        Assert.DoesNotContain(
            await scores.GetAllAsync(TestContext.Current.CancellationToken),
            score => score.AccountId == account.AccountId);
    }

    [Theory]
    [InlineData("Designer")]
    [InlineData("Admin")]
    public async Task Redaktionelle_konti_kan_ikke_slette_sig_selv(string roleName)
    {
        var role = Enum.Parse<AccountRole>(roleName);
        var repository = app.Services.GetRequiredService<IAuthenticationRepository>();
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(), null, null, role, AccountState.Active, now, now);
        var token = OpaqueTokenService.Create();
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await repository.CreateSessionAsync(
            Session(account, token, now), TestContext.Current.CancellationToken));
        using var request = AccountAdministrationTests.Authorized(
            HttpMethod.Delete, "/auth/me", token.Value);

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
        var unchanged = await repository.GetAccountAsync(
            account.AccountId, TestContext.Current.CancellationToken);
        Assert.Equal(AccountState.Active, unchanged?.State);
    }

    private static AuthenticationSession Session(
        Account account, OpaqueToken token, DateTimeOffset now) => new(
        token.Id, account.AccountId, AuthenticationClientKind.IOSPlayer,
        token.SecretHash, now.AddMinutes(15), token.SecretHash, null,
        now.AddDays(30), now, now);
}
