using System.Net;
using System.Net.Http.Headers;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>
/// Læsevejen mod repoets eget indhold.
/// </summary>
/// <remarks>
/// Testene kalder over HTTP, fordi det er det, appen gør. ETag-forhandlingen
/// kan ikke efterprøves på anden måde: den lever i headere, ikke i typer.
/// </remarks>
public sealed class ContentEndpointTests(App app) : FastEndpoints.Testing.TestBase<App>
{
    private const string Pack = "/content/da-DK/pack";

    [Fact]
    public async Task Pakken_hentes_og_har_en_etag()
    {
        var response = await app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.NotNull(response.Headers.ETag);

        var json = await response.Content.ReadAsStringAsync(TestContext.Current.CancellationToken);
        Assert.Contains("\"missions\"", json, StringComparison.Ordinal);
    }

    /// <summary>Den, der sparer båndbredden. Uden den henter hver app alt hver gang.</summary>
    [Fact]
    public async Task Kendt_etag_giver_304()
    {
        var first = await app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);
        var etag = first.Headers.ETag!.ToString();

        using var request = new HttpRequestMessage(HttpMethod.Get, Pack);
        request.Headers.IfNoneMatch.Add(EntityTagHeaderValue.Parse(etag));
        var second = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NotModified, second.StatusCode);
    }

    [Fact]
    public async Task Etaggen_er_stabil_mellem_kald()
    {
        var a = await app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);
        var b = await app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);

        // Beregnes af indholdet, ikke af tidspunktet. Ellers ville hver
        // udrulning tvinge alle apps til at hente alt igen.
        Assert.Equal(a.Headers.ETag!.Tag, b.Headers.ETag!.Tag);
    }

    [Fact]
    public async Task Et_medie_hentes_med_rigtig_indholdstype()
    {
        var response = await app.Client.GetAsync(
            "/content/da-DK/media/boelgen-001.jpg", TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("image/jpeg", response.Content.Headers.ContentType!.MediaType);
    }

    [Fact]
    public async Task Ukendt_pakke_giver_404()
    {
        var response = await app.Client.GetAsync(
            "/content/de-DE/pack", TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    /// <summary>
    /// Endepunkterne er anonyme, så stien fra klienten må aldrig kunne pege ud
    /// af indholdsmappen.
    /// </summary>
    [Theory]
    [InlineData("/content/da-DK/media/..%2F..%2F..%2Fappsettings.json")]
    [InlineData("/content/da-DK%2F..%2F..%2F..%2Fappsettings.json/pack")]
    public async Task Stier_ud_af_indholdsmappen_afvises(string path)
    {
        var response = await app.Client.GetAsync(path, TestContext.Current.CancellationToken);

        Assert.True(
            response.StatusCode is HttpStatusCode.NotFound or HttpStatusCode.BadRequest,
            $"{path} gav {(int)response.StatusCode} — en sti ud af indholdsmappen slap igennem");
    }
}
