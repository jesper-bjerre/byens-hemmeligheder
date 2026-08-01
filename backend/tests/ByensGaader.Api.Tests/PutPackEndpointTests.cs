using System.Net;
using System.Net.Http.Headers;
using System.Text;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>
/// Skrivevejen. Testene skriver til en **kopi** af indholdet, aldrig til
/// repoets egne filer — en test, der kan ødelægge indholdspakken, er værre end
/// ingen test.
/// </summary>
public sealed class PackApp : WritableApp;

public sealed class PutPackEndpointTests : FastEndpoints.Testing.TestBase<PackApp>
{
    private readonly PackApp _app;

    public PutPackEndpointTests(PackApp app) => _app = app;

    private const string Pack = "/content/da-DK/pack";
    private static readonly string Minimal =
        """{"contentVersion":"2026-07-30.1","missions":[]}""";

    private static StringContent Body(string json) =>
        new(json, Encoding.UTF8, "application/json");

    /// <summary>Navnet er ikke godtgørelse — men uden det er sporet uden hvem.</summary>
    private static HttpRequestMessage Save(string json, string by = "Test Quizmaster")
    {
        var request = new HttpRequestMessage(HttpMethod.Put, Pack) { Content = Body(json) };
        request.Headers.Add("X-Quizmaster", by);
        return request;
    }

    [Fact]
    public async Task Gemmer_naar_etaggen_stemmer()
    {
        var current = await _app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);
        var etag = current.Headers.ETag!.ToString();

        using var request = Save(Minimal);
        request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(etag));
        var response = await _app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        Assert.NotNull(response.Headers.ETag);
        Assert.NotEqual(etag, response.Headers.ETag!.ToString());
    }

    /// <summary>
    /// Den vigtigste. Alle quizmastere kan rette i alt, så uden dette taber den,
    /// der gemmer sidst, den andens arbejde uden at nogen opdager det.
    /// </summary>
    [Fact]
    public async Task Afviser_naar_en_anden_har_gemt_imens()
    {
        using var request = Save(Minimal);
        request.Headers.IfMatch.Add(new EntityTagHeaderValue("\"forældet\""));
        var response = await _app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.PreconditionFailed, response.StatusCode);
    }

    [Fact]
    public async Task Afviser_indhold_der_ikke_er_en_pakke()
    {
        var current = await _app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);

        using var request = Save("""{"noget":"helt andet"}""");
        request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(current.Headers.ETag!.ToString()));
        var response = await _app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    /// <summary>
    /// FR-111. Kan klienten springe navnet over, mangler sporet netop de
    /// gemninger, hvor nogen havde travlt — og det er dem, man spørger til.
    /// </summary>
    [Fact]
    public async Task Afviser_en_gemning_uden_quizmaster()
    {
        var current = await _app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);

        using var request = new HttpRequestMessage(HttpMethod.Put, Pack) { Content = Body(Minimal) };
        request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(current.Headers.ETag!.ToString()));
        var response = await _app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
