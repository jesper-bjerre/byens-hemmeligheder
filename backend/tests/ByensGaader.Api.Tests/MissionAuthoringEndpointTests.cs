using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json.Nodes;
using ByensGaader.Api.Features.Content;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class MissionAuthoringApp : WritableApp;

public sealed class MissionAuthoringEndpointTests(MissionAuthoringApp app)
    : FastEndpoints.Testing.TestBase<MissionAuthoringApp>
{
    private const string Base = "/authoring/content/da-DK/missions";
    private const string Id = "mission.boelgen.den-femte-besked";

    [Fact]
    public async Task Listen_indeholder_ogsaa_kladder_mens_spillerpakken_ikke_goer()
    {
        var list = await app.Client.GetAsync(Base, TestContext.Current.CancellationToken);
        var index = JsonNode.Parse(await list.Content.ReadAsStringAsync(
            TestContext.Current.CancellationToken))!.AsObject();

        Assert.Equal(HttpStatusCode.OK, list.StatusCode);
        Assert.Equal(11, index["missions"]!.AsArray().Count);

        var pack = await app.Client.GetStringAsync(
            "/content/da-DK/pack", TestContext.Current.CancellationToken);
        Assert.DoesNotContain(
            JsonNode.Parse(pack)!["missions"]!.AsArray(),
            mission => mission!["status"]!.GetValue<string>() is "draft" or "fieldTestReady");
    }

    [Fact]
    public async Task En_opgave_har_sin_egen_etag_og_afviser_en_foraeldet()
    {
        var get = await app.Client.GetAsync($"{Base}/{Id}", TestContext.Current.CancellationToken);
        var etag = get.Headers.ETag!.ToString();
        var aggregate = JsonNode.Parse(await get.Content.ReadAsStringAsync(
            TestContext.Current.CancellationToken))!.AsObject();
        aggregate["mission"]!["title"] = "En opgavevis rettelse";
        aggregate["mission"]!["status"] = "published";

        using var save = Request(HttpMethod.Put, $"{Base}/{Id}", aggregate, etag);
        var saved = await app.Client.SendAsync(save, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, saved.StatusCode);
        Assert.NotEqual(etag, saved.Headers.ETag!.ToString());
        Assert.Equal("published", saved.Headers.GetValues("X-Content-Publication").Single());

        using var stale = Request(HttpMethod.Put, $"{Base}/{Id}", aggregate, etag);
        var conflict = await app.Client.SendAsync(stale, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.PreconditionFailed, conflict.StatusCode);
    }

    [Fact]
    public async Task Manglende_precondition_afvises()
    {
        var get = await app.Client.GetAsync($"{Base}/{Id}", TestContext.Current.CancellationToken);
        var aggregate = JsonNode.Parse(await get.Content.ReadAsStringAsync(
            TestContext.Current.CancellationToken))!.AsObject();
        using var request = Request(HttpMethod.Put, $"{Base}/{Id}", aggregate, etag: null);

        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal((HttpStatusCode)428, response.StatusCode);
    }

    [Fact]
    public void Frigivelsestid_sættes_ved_statusskift_og_bevares_ved_tekstrettelse()
    {
        var now = new DateTimeOffset(2026, 8, 7, 10, 0, 0, TimeSpan.Zero);
        var before = new JsonObject
        {
            ["mission"] = new JsonObject { ["status"] = "draft" },
        };
        var released = new JsonObject
        {
            ["mission"] = new JsonObject { ["status"] = "published" },
        };

        PutMissionEndpoint.SetReleasedAt(released, before, now);
        Assert.Equal(now, released["mission"]!["releasedAt"]!.GetValue<DateTimeOffset>());

        var edit = released.DeepClone().AsObject();
        PutMissionEndpoint.SetReleasedAt(edit, released, now.AddDays(1));
        Assert.Equal(now, edit["mission"]!["releasedAt"]!.GetValue<DateTimeOffset>());
    }

    private static HttpRequestMessage Request(
        HttpMethod method, string url, JsonObject body, string? etag)
    {
        var request = new HttpRequestMessage(method, url)
        {
            Content = new StringContent(body.ToJsonString(), Encoding.UTF8, "application/json"),
        };
        request.Headers.Add("X-Quizmaster", "Endpoint Test");
        if (etag is not null)
        {
            request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(etag));
        }
        return request;
    }
}
