using System.Net;
using System.Net.Http.Headers;
using ByensGaader.Api.Features.Content;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class NarrationApp : WritableApp
{
    protected override void ConfigureApp(IWebHostBuilder builder)
    {
        base.ConfigureApp(builder);
        builder.ConfigureServices(services =>
        {
            services.RemoveAll<IAudioTranscoder>();
            services.AddSingleton<IAudioTranscoder, FakeAudioTranscoder>();
        });
    }
}

public sealed class NarrationWriteEndpointTests(NarrationApp app)
    : FastEndpoints.Testing.TestBase<NarrationApp>
{
    [Fact]
    public async Task En_fortaelling_konverteres_og_kan_hentes_som_mp3()
    {
        var name = $"fortaelling-{Guid.NewGuid():N}.mp3";
        using var source = Audio("wav");

        var upload = await app.Client.PostAsync(
            $"/content/da-DK/narration/{name}", source, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Created, upload.StatusCode);
        var fetched = await app.Client.GetAsync(
            $"/content/da-DK/media/{name}", TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.OK, fetched.StatusCode);
        Assert.Equal("audio/mpeg", fetched.Content.Headers.ContentType!.MediaType);
        Assert.Equal(FakeAudioTranscoder.Mp3, await fetched.Content.ReadAsByteArrayAsync(
            TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Ukendt_kildeformat_afvises_foer_konvertering()
    {
        using var source = Audio("exe");
        var response = await app.Client.PostAsync(
            "/content/da-DK/narration/fortaelling.mp3",
            source,
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.UnsupportedMediaType, response.StatusCode);
    }

    [Fact]
    public async Task Outputnavnet_skal_vaere_mp3()
    {
        using var source = Audio("m4a");
        var response = await app.Client.PostAsync(
            "/content/da-DK/narration/fortaelling.m4a",
            source,
            TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.UnsupportedMediaType, response.StatusCode);
    }

    private static ByteArrayContent Audio(string format)
    {
        var content = new ByteArrayContent([1, 2, 3, 4]);
        content.Headers.ContentType = new MediaTypeHeaderValue("audio/" + format);
        content.Headers.Add("X-Source-Format", format);
        return content;
    }
}

internal sealed class FakeAudioTranscoder : IAudioTranscoder
{
    internal static readonly byte[] Mp3 = [0x49, 0x44, 0x33, 1, 2, 3];

    public Task<byte[]> ConvertToMp3Async(
        byte[] source, string sourceExtension, CancellationToken ct) =>
        Task.FromResult(Mp3);
}
