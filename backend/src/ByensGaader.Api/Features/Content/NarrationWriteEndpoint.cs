using ByensGaader.Api.Storage;
using FastEndpoints;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Modtager en fortælling i et almindeligt lydformat og gemmer den som en
/// kompakt MP3: mono, 44,1 kHz og 64 kbit/s.
/// </summary>
internal sealed class PostNarrationEndpoint(
    IContentStore store,
    IAudioTranscoder transcoder) : EndpointWithoutRequest
{
    private const int MaxSourceBytes = 25 * 1024 * 1024;
    private const int MaxOutputBytes = 10 * 1024 * 1024;

    private static readonly HashSet<string> AllowedSourceExtensions =
        [".mp3", ".m4a", ".aac", ".wav", ".aif", ".aiff", ".caf", ".ogg", ".opus", ".flac"];

    public override void Configure()
    {
        Post("/content/{locale}/narration/{filename}");
        AllowAnonymous();
        Description(b => b.WithTags("Indhold"));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var locale = Route<string>("locale")!;
        var filename = Route<string>("filename")!;
        var sourceExtension = NormaliseExtension(
            HttpContext.Request.Headers["X-Source-Format"].ToString());

        if (!filename.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase))
        {
            await Problem("Fortællingens filnavn skal ende på .mp3.", 415);
            return;
        }

        if (!AllowedSourceExtensions.Contains(sourceExtension))
        {
            await Problem(
                "Kildens lydformat understøttes ikke. Tilladt: "
                + string.Join(", ", AllowedSourceExtensions.Order()), 415);
            return;
        }

        if (HttpContext.Request.ContentLength is > MaxSourceBytes)
        {
            await Problem("Lydfilen er for stor. Højst 25 MB.", 413);
            return;
        }

        using var buffer = new MemoryStream();
        var chunk = new byte[81_920];
        int read;
        while ((read = await HttpContext.Request.Body.ReadAsync(chunk, ct)) > 0)
        {
            if (buffer.Length + read > MaxSourceBytes)
            {
                await Problem("Lydfilen er for stor. Højst 25 MB.", 413);
                return;
            }
            await buffer.WriteAsync(chunk.AsMemory(0, read), ct);
        }

        if (buffer.Length == 0)
        {
            await Problem("Lydfilen er tom.", 400);
            return;
        }

        byte[] converted;
        try
        {
            converted = await transcoder.ConvertToMp3Async(buffer.ToArray(), sourceExtension, ct);
        }
        catch (AudioConversionUnavailableException error)
        {
            await Problem(error.Message, 503);
            return;
        }
        catch (AudioConversionException error)
        {
            await Problem(error.Message, 415);
            return;
        }
        catch (AudioConversionBusyException error)
        {
            await Problem(error.Message, 429);
            return;
        }

        if (converted.Length is 0 or > MaxOutputBytes)
        {
            await Problem("Den konverterede fortælling er for stor. Højst 10 MB.", 413);
            return;
        }

        var path = Path.Combine(locale, "media", filename);
        switch (await store.CreateAsync(path, converted, ct))
        {
            case WriteOutcome.Written:
                var saved = await store.ReadAsync(path, ct);
                HttpContext.Response.Headers.ETag = saved!.ETag;
                await SendCreatedAtAsync<GetMediaEndpoint>(
                    new { locale, filename },
                    new { filename, contentType = "audio/mpeg", bytes = converted.Length },
                    cancellation: ct);
                return;
            case WriteOutcome.AlreadyExists:
                await Problem("Filnavnet er optaget. Medier overskrives ikke.", 409);
                return;
            default:
                await Problem("Ugyldigt filnavn.", 400);
                return;
        }
    }

    private async Task Problem(string detail, int statusCode)
    {
        await SendResultAsync(Results.Problem(detail: detail, statusCode: statusCode));
    }

    private static string NormaliseExtension(string value)
    {
        var trimmed = value.Trim().ToLowerInvariant();
        return trimmed.StartsWith('.') ? trimmed : "." + trimmed;
    }
}
