using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>Egen kopi, så mediemappen ikke rives væk under en anden testklasse.</summary>
public sealed class MediaApp : WritableApp;

/// <summary>Skrivevejen for medier. Kører mod en kopi, aldrig repoets filer.</summary>
public sealed class MediaWriteEndpointTests(MediaApp app)
    : FastEndpoints.Testing.TestBase<MediaApp>
{
    private static ByteArrayContent Png()
    {
        // Et gyldigt PNG-hoved er nok — serveren afkoder ikke billedet.
        var bytes = new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3 };
        var content = new ByteArrayContent(bytes);
        content.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        return content;
    }

    [Fact]
    public async Task Et_billede_kan_lægges_op_og_hentes_igen()
    {
        var name = $"test-{Guid.NewGuid():N}.png";

        var upload = await app.Client.PostAsync(
            $"/content/da-DK/media/{name}", Png(), TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.Created, upload.StatusCode);

        var fetched = await app.Client.GetAsync(
            $"/content/da-DK/media/{name}", TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, fetched.StatusCode);
        Assert.Equal("image/png", fetched.Content.Headers.ContentType!.MediaType);
    }

    /// <summary>
    /// Den vigtigste. Medier sendes med et års cache, så en fil, der skifter
    /// indhold uden at skifte navn, står gammel på telefonerne i et år.
    /// </summary>
    [Fact]
    public async Task Samme_filnavn_to_gange_afvises()
    {
        var name = $"test-{Guid.NewGuid():N}.png";
        await app.Client.PostAsync($"/content/da-DK/media/{name}", Png(),
            TestContext.Current.CancellationToken);

        var again = await app.Client.PostAsync($"/content/da-DK/media/{name}", Png(),
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
    }

    [Fact]
    public async Task Filtyper_vi_ikke_kan_vise_afvises()
    {
        var response = await app.Client.PostAsync(
            "/content/da-DK/media/ondsindet.svg", Png(), TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.UnsupportedMediaType, response.StatusCode);
    }

    [Fact]
    public async Task Listen_viser_det_der_er_lagt_op()
    {
        var name = $"test-{Guid.NewGuid():N}.png";
        await app.Client.PostAsync($"/content/da-DK/media/{name}", Png(),
            TestContext.Current.CancellationToken);

        var json = await app.Client.GetStringAsync("/content/da-DK/media",
            TestContext.Current.CancellationToken);
        using var document = JsonDocument.Parse(json);
        var files = document.RootElement.GetProperty("files")
            .EnumerateArray().Select(e => e.GetString()).ToArray();

        Assert.Contains(name, files);
    }

    [Fact]
    public async Task Et_medie_kan_slettes()
    {
        var name = $"test-{Guid.NewGuid():N}.png";
        await app.Client.PostAsync($"/content/da-DK/media/{name}", Png(),
            TestContext.Current.CancellationToken);

        var deleted = await app.Client.DeleteAsync($"/content/da-DK/media/{name}",
            TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.NoContent, deleted.StatusCode);

        var gone = await app.Client.GetAsync($"/content/da-DK/media/{name}",
            TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.NotFound, gone.StatusCode);
    }
}
