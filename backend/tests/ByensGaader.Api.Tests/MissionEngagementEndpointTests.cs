using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Features.Engagement;
using FastEndpoints.Testing;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class MissionEngagementEndpointTests(AuthenticationEndpointApp app)
    : TestBase<AuthenticationEndpointApp>
{
    [Fact]
    public async Task Favoritter_er_idempotente_og_offentlig_statistik_er_aggregeret()
    {
        var suffix = Guid.NewGuid().ToString("N");
        var missionId = "mission.test." + suffix;
        var first = await LoginAsync("favorit-a-" + suffix);
        var second = await LoginAsync("favorit-b-" + suffix);

        await SetFavoriteAsync(first, missionId, HttpMethod.Put);
        await SetFavoriteAsync(first, missionId, HttpMethod.Put);
        await SetFavoriteAsync(second, missionId, HttpMethod.Put);

        var metrics = await app.Client.GetFromJsonAsync<MissionEngagementDto[]>(
            "/engagement/missions", TestContext.Current.CancellationToken);
        var metric = Assert.Single(metrics!, item => item.MissionId == missionId);
        Assert.Equal(2, metric.FavoriteCount);
        Assert.Equal(2, metric.TrendingCount);

        using var ownRequest = Authorized(HttpMethod.Get, "/engagement/favorites", first);
        using var ownResponse = await app.Client.SendAsync(
            ownRequest, TestContext.Current.CancellationToken);
        var own = await ownResponse.Content.ReadFromJsonAsync<FavoriteMissionIdsResponse>(
            TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, ownResponse.StatusCode);
        Assert.Contains(missionId, own!.MissionIds);

        await SetFavoriteAsync(first, missionId, HttpMethod.Delete);
        await SetFavoriteAsync(first, missionId, HttpMethod.Delete);
        metrics = await app.Client.GetFromJsonAsync<MissionEngagementDto[]>(
            "/engagement/missions", TestContext.Current.CancellationToken);
        metric = Assert.Single(metrics!, item => item.MissionId == missionId);
        Assert.Equal(1, metric.FavoriteCount);
    }

    [Fact]
    public async Task Favoritkraev_skal_vaere_logget_ind_og_afviser_vilkaarlige_ider()
    {
        using var anonymous = await app.Client.PutAsync(
            "/engagement/missions/mission.test.anonym/favorite",
            content: null,
            TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);

        var token = await LoginAsync("ugyldigt-id-" + Guid.NewGuid().ToString("N"));
        using var invalidRequest = Authorized(
            HttpMethod.Put, "/engagement/missions/ikke-en-opgave/favorite", token);
        using var invalid = await app.Client.SendAsync(
            invalidRequest, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
    }

    private async Task<string> LoginAsync(string subject)
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
        return session.AccessToken;
    }

    private async Task SetFavoriteAsync(string token, string missionId, HttpMethod method)
    {
        using var request = Authorized(
            method, $"/engagement/missions/{missionId}/favorite", token);
        using var response = await app.Client.SendAsync(
            request, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
    }

    private static HttpRequestMessage Authorized(HttpMethod method, string path, string token)
    {
        var request = new HttpRequestMessage(method, path);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return request;
    }
}
