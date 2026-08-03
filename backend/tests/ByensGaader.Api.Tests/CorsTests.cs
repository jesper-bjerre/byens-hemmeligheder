using System.Net;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>
/// Browserens adgang til skrive-API'et. Endepunkterne er fortsat anonyme under
/// den interne test; testen her handler kun om, hvilke websites browseren må
/// sende kald fra.
/// </summary>
public sealed class CorsTests(App app) : FastEndpoints.Testing.TestBase<App>
{
    [Fact]
    public async Task Lokal_webadmin_maa_kalde_skrivevejen()
    {
        using var request = new HttpRequestMessage(HttpMethod.Options, "/content/da-DK/pack");
        request.Headers.Add("Origin", "http://localhost:4200");
        request.Headers.Add("Access-Control-Request-Method", "PUT");
        request.Headers.Add("Access-Control-Request-Headers", "content-type,x-quizmaster,if-match");

        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        Assert.Equal(
            "http://localhost:4200",
            response.Headers.GetValues("Access-Control-Allow-Origin").Single());

        using var get = new HttpRequestMessage(HttpMethod.Get, "/content/da-DK/pack");
        get.Headers.Add("Origin", "http://localhost:4200");
        var pack = await app.Client.SendAsync(get, TestContext.Current.CancellationToken);

        var exposed = pack.Headers.GetValues("Access-Control-Expose-Headers")
            .SelectMany(value => value.Split(',', StringSplitOptions.TrimEntries));
        Assert.Contains("ETag", exposed);
        Assert.Contains("X-Content-Publication", exposed);
    }

    [Fact]
    public async Task Ukendt_websted_faar_ingen_cors_tilladelse()
    {
        using var request = new HttpRequestMessage(HttpMethod.Options, "/content/da-DK/pack");
        request.Headers.Add("Origin", "https://uvedkommende.example");
        request.Headers.Add("Access-Control-Request-Method", "PUT");

        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.False(response.Headers.Contains("Access-Control-Allow-Origin"));
    }
}
