using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json.Nodes;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class CatalogAuthoringApp : WritableApp;

public sealed class CatalogAuthoringEndpointTests(CatalogAuthoringApp app)
    : FastEndpoints.Testing.TestBase<CatalogAuthoringApp>
{
    [Fact]
    public async Task Et_medies_metadata_har_egen_etag()
    {
        const string url = "/authoring/content/da-DK/media/media.boelgen.000";
        var get = await app.Client.GetAsync(url, TestContext.Current.CancellationToken);
        var asset = JsonNode.Parse(await get.Content.ReadAsStringAsync(
            TestContext.Current.CancellationToken))!.AsObject();
        asset["altText"] = "Rettet beskrivelse";

        using var request = new HttpRequestMessage(HttpMethod.Put, url)
        {
            Content = new StringContent(asset.ToJsonString(), Encoding.UTF8, "application/json"),
        };
        request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(get.Headers.ETag!.ToString()));
        request.Headers.Add("X-Quizmaster", "Katalog Test");
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.NotNull(response.Headers.ETag);
    }

    [Fact]
    public async Task Et_medie_i_brug_kan_ikke_slettes()
    {
        const string url = "/authoring/content/da-DK/media/media.boelgen.000";
        var get = await app.Client.GetAsync(url, TestContext.Current.CancellationToken);
        using var request = new HttpRequestMessage(HttpMethod.Delete, url);
        request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(get.Headers.ETag!.ToString()));
        request.Headers.Add("X-Quizmaster", "Katalog Test");

        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
    }
}
