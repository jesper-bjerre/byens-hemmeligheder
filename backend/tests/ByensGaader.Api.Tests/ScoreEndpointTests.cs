using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Features.Scoring;
using FastEndpoints.Testing;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class ScoreEndpointTests(AuthenticationEndpointApp app)
    : TestBase<AuthenticationEndpointApp>
{
    [Fact]
    public async Task Score_kraever_login_er_idempotent_og_highscore_er_virkelig()
    {
        var suffix = Guid.NewGuid().ToString("N");
        const string missionId = "mission.boelgen.den-femte-besked";
        var login = await LoginAsync("score-" + suffix);
        var body = new SubmitScoreRequest(
            Guid.NewGuid(),
            "content-version-" + suffix,
            88,
            DateTimeOffset.UtcNow,
            [
                new ScoreLineDto("completion", "missionCompleted", 100),
                new ScoreLineDto("hint", "hintUsed", -12),
            ]);

        using var anonymous = await app.Client.PutAsJsonAsync(
            $"/scores/missions/{missionId}", body, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);

        await SubmitAsync(login.Token, missionId, body);
        await SubmitAsync(login.Token, missionId, body);

        var allTime = await app.Client.GetFromJsonAsync<LeaderboardEntryDto[]>(
            "/scores/leaderboard?period=allTime", TestContext.Current.CancellationToken);
        Assert.Contains(allTime!, item => item.Name == "Anonym spiller" && item.Points == 88);
    }

    [Fact]
    public async Task Score_afviser_et_totalbelob_der_ikke_match_transaktionerne()
    {
        var suffix = Guid.NewGuid().ToString("N");
        var login = await LoginAsync("invalid-score-" + suffix);
        var body = new SubmitScoreRequest(
            Guid.NewGuid(),
            "content-version-" + suffix,
            100,
            DateTimeOffset.UtcNow,
            [new ScoreLineDto("completion", "missionCompleted", 99)]);
        using var request = Authorized(
            HttpMethod.Put, "/scores/missions/mission.boelgen.den-femte-besked", login.Token, body);
        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    private async Task<(string Token, Guid AccountId)> LoginAsync(string subject)
    {
        var identity = $"valid:{subject}|{subject}@example.invalid";
        using var response = await app.Client.PostAsJsonAsync(
            "/auth/apple/native/exchange",
            new NativeAppleExchangeRequest(
                "dk.example.byensgaader",
                identity,
                identity["valid:".Length..] + "#" + Guid.NewGuid().ToString("N"),
                "en-ra-nonce-med-mindst-toogtredive-tegn",
                "IOSPlayer"),
            TestContext.Current.CancellationToken);
        var session = await response.Content.ReadFromJsonAsync<SessionResponse>(
            TestContext.Current.CancellationToken);
        Assert.NotNull(session);
        return (session.AccessToken, session.Account.AccountId);
    }

    private async Task SubmitAsync(string token, string missionId, SubmitScoreRequest body)
    {
        using var request = Authorized(HttpMethod.Put, $"/scores/missions/{missionId}", token, body);
        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
    }

    private static HttpRequestMessage Authorized(
        HttpMethod method,
        string path,
        string token,
        SubmitScoreRequest body)
    {
        var request = new HttpRequestMessage(method, path)
        {
            Content = JsonContent.Create(body),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return request;
    }
}
