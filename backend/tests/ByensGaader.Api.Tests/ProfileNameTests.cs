using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ByensGaader.Api.Features.Accounts;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Features.Scoring;
using ByensGaader.Api.Security;
using FastEndpoints.Testing;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class ProfileNameApp : AccountManagementApp;

public sealed class ProfileNameTests(ProfileNameApp app)
    : TestBase<ProfileNameApp>
{
    [Fact]
    public async Task Gyldigt_profilnavn_normaliseres_og_gemmes()
    {
        var user = await CreateAccountAsync(AccountRole.User);
        using var request = Authorized(HttpMethod.Put, "/auth/me/profile", user.Token);
        request.Content = JsonContent.Create(new { publicName = "  Åse   Ørn  " });

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        var account = await response.Content.ReadFromJsonAsync<AuthenticatedAccountDto>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Åse Ørn", account!.PublicName);
        var stored = await Repository.GetAccountAsync(
            user.AccountId, TestContext.Current.CancellationToken);
        Assert.Equal("Åse Ørn", stored!.PublicName);
        Assert.NotNull(stored.PublicNameChangedAt);
        Assert.Equal(NameModerationState.Visible, stored.NameModerationState);
    }

    [Theory]
    [InlineData("ab")]
    [InlineData("www.eksempel.dk")]
    [InlineData("mig@example.invalid")]
    [InlineData("Ring 12345678")]
    [InlineData("Vejles Koder Admin")]
    [InlineData("fuck dig")]
    public async Task Uegnet_profilnavn_afvises(string name)
    {
        var user = await CreateAccountAsync(AccountRole.User);
        using var request = Authorized(HttpMethod.Put, "/auth/me/profile", user.Token);
        request.Content = JsonContent.Create(new { publicName = name });

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Null((await Repository.GetAccountAsync(
            user.AccountId, TestContext.Current.CancellationToken))!.PublicName);
    }

    [Fact]
    public async Task Nyt_ikke_tomt_navn_ratebegraenses_i_24_timer()
    {
        var user = await CreateAccountAsync(
            AccountRole.User,
            publicName: "Første navn",
            publicNameChangedAt: DateTimeOffset.UtcNow);
        using var request = Authorized(HttpMethod.Put, "/auth/me/profile", user.Token);
        request.Content = JsonContent.Create(new { publicName = "Næste navn" });

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.TooManyRequests, response.StatusCode);
    }

    [Fact]
    public async Task Fjernelse_af_navn_starter_ikke_en_ny_ventetid()
    {
        var changedAt = DateTimeOffset.UtcNow.AddDays(-2);
        var user = await CreateAccountAsync(
            AccountRole.User, publicName: "Første navn", publicNameChangedAt: changedAt);
        using var remove = Authorized(HttpMethod.Put, "/auth/me/profile", user.Token);
        remove.Content = JsonContent.Create(new { publicName = (string?)null });
        using var removeResponse = await app.Client.SendAsync(
            remove, TestContext.Current.CancellationToken);
        using var replace = Authorized(HttpMethod.Put, "/auth/me/profile", user.Token);
        replace.Content = JsonContent.Create(new { publicName = "Næste navn" });
        using var replaceResponse = await app.Client.SendAsync(
            replace, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, removeResponse.StatusCode);
        Assert.Equal(HttpStatusCode.OK, replaceResponse.StatusCode);
    }

    [Fact]
    public async Task Admin_kan_skjule_navn_og_highscore_bruger_neutralt_fallback()
    {
        var admin = await CreateAccountAsync(AccountRole.Admin);
        var user = await CreateAccountAsync(AccountRole.User, publicName: "Synligt navn");
        var scores = app.Services.GetRequiredService<IScoreRepository>();
        await scores.AddOrGetAsync(new PlayerScore(
            user.AccountId,
            "mission.test.profilnavn",
            Guid.NewGuid(),
            "version-profile-name",
            77,
            DateTimeOffset.UtcNow,
            [new ScoreLineDto("completion", "missionCompleted", 77)]),
            TestContext.Current.CancellationToken);

        using var request = Authorized(
            HttpMethod.Put,
            $"/admin/accounts/{user.AccountId:D}/moderation",
            admin.Token);
        request.Content = JsonContent.Create(new { hidden = true, reason = "Rapporteret navn" });
        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        var leaderboard = await app.Client.GetFromJsonAsync<LeaderboardEntryDto[]>(
            "/scores/leaderboard?period=allTime", TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Contains(leaderboard!, entry => entry.Name == "Anonym spiller" && entry.Points == 77);
        Assert.DoesNotContain(leaderboard!, entry => entry.Name == "Synligt navn");
    }

    [Fact]
    public async Task Designer_kan_ikke_moderere_navn()
    {
        var designer = await CreateAccountAsync(AccountRole.Designer);
        var user = await CreateAccountAsync(AccountRole.User, publicName: "Synligt navn");
        using var request = Authorized(
            HttpMethod.Put,
            $"/admin/accounts/{user.AccountId:D}/moderation",
            designer.Token);
        request.Content = JsonContent.Create(new { hidden = true, reason = "Forsøg" });

        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Indlogget_spiller_kan_rapportere_navn_uden_maal_konto_id()
    {
        var reporter = await CreateAccountAsync(AccountRole.User);
        var admin = await CreateAccountAsync(AccountRole.Admin);
        var reportedName = "Navn " + Guid.NewGuid().ToString("N")[..8];
        _ = await CreateAccountAsync(AccountRole.User, publicName: reportedName);
        using var report = Authorized(HttpMethod.Post, "/scores/name-reports", reporter.Token);
        report.Content = JsonContent.Create(new
        {
            reportedName,
            category = "Offensive",
        });
        using var reportResponse = await app.Client.SendAsync(
            report, TestContext.Current.CancellationToken);

        using var list = Authorized(HttpMethod.Get, "/admin/name-reports", admin.Token);
        using var listResponse = await app.Client.SendAsync(
            list, TestContext.Current.CancellationToken);
        var reports = await listResponse.Content.ReadFromJsonAsync<NameReportDto[]>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NoContent, reportResponse.StatusCode);
        Assert.Equal(HttpStatusCode.OK, listResponse.StatusCode);
        Assert.Contains(reports!, item => item.ReportedName == reportedName
            && item.Category == "Offensive");
        Assert.Empty(await reportResponse.Content.ReadAsStringAsync(
            TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Adminlisten_sletter_navnerapporter_efter_90_dage()
    {
        var admin = await CreateAccountAsync(AccountRole.Admin);
        var repository = app.Services.GetRequiredService<INameReportRepository>();
        var now = DateTimeOffset.UtcNow;
        await repository.AddOncePerDayAsync(new NameReport(
            Guid.NewGuid(), Guid.NewGuid(), "For gammelt navn",
            NameReportCategory.Other, now.AddDays(-91)),
            TestContext.Current.CancellationToken);
        await repository.AddOncePerDayAsync(new NameReport(
            Guid.NewGuid(), Guid.NewGuid(), "Aktuelt navn",
            NameReportCategory.Other, now.AddDays(-89)),
            TestContext.Current.CancellationToken);

        using var request = Authorized(HttpMethod.Get, "/admin/name-reports", admin.Token);
        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        var reports = await response.Content.ReadFromJsonAsync<NameReportDto[]>(
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.DoesNotContain(reports!, item => item.ReportedName == "For gammelt navn");
        Assert.Contains(reports!, item => item.ReportedName == "Aktuelt navn");
    }

    [Fact]
    public async Task Admin_blokering_afviser_eksisterende_session_fra_naeste_request()
    {
        var admin = await CreateAccountAsync(AccountRole.Admin);
        var user = await CreateAccountAsync(AccountRole.User);
        using var block = Authorized(
            HttpMethod.Put,
            $"/admin/accounts/{user.AccountId:D}/state",
            admin.Token);
        block.Content = JsonContent.Create(new { state = "Blocked", reason = "Misbrug" });
        using var blockResponse = await app.Client.SendAsync(
            block, TestContext.Current.CancellationToken);

        using var me = Authorized(HttpMethod.Get, "/auth/me", user.Token);
        using var meResponse = await app.Client.SendAsync(
            me, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, blockResponse.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, meResponse.StatusCode);
    }

    private IAuthenticationRepository Repository =>
        app.Services.GetRequiredService<IAuthenticationRepository>();

    private async Task<TestAccount> CreateAccountAsync(
        AccountRole role,
        string? publicName = null,
        DateTimeOffset? publicNameChangedAt = null)
    {
        var now = DateTimeOffset.UtcNow;
        var account = new Account(
            Guid.NewGuid(),
            $"{Guid.NewGuid():N}@example.invalid",
            publicName,
            role,
            AccountState.Active,
            now,
            now,
            PublicNameChangedAt: publicNameChangedAt);
        var token = OpaqueTokenService.Create();
        var session = new AuthenticationSession(
            token.Id,
            account.AccountId,
            AuthenticationClientKind.IOSPlayer,
            token.SecretHash,
            now.AddMinutes(15),
            null,
            null,
            null,
            now,
            now);
        Assert.True(await Repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        Assert.True(await Repository.CreateSessionAsync(
            session, TestContext.Current.CancellationToken));
        return new TestAccount(account.AccountId, token.Value);
    }

    private static HttpRequestMessage Authorized(
        HttpMethod method, string path, string token)
    {
        var request = new HttpRequestMessage(method, path);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return request;
    }

    private sealed record TestAccount(Guid AccountId, string Token);
}
