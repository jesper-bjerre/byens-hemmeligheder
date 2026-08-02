using System.Diagnostics;

namespace ByensGaader.Api.Features.Content;

internal interface IAudioTranscoder
{
    public Task<byte[]> ConvertToMp3Async(
        byte[] source, string sourceExtension, CancellationToken ct);
}

/// <summary>
/// Gør quizmasterens lydfil til en lille MP3, som både AVAudioPlayer og
/// browsernes lydafspiller kan læse.
/// </summary>
internal sealed class FfmpegAudioTranscoder(
    IConfiguration configuration,
    ILogger<FfmpegAudioTranscoder> logger) : IAudioTranscoder
{
    private static readonly TimeSpan Timeout = TimeSpan.FromMinutes(2);
    private readonly SemaphoreSlim _slot = new(initialCount: 1, maxCount: 1);

    public async Task<byte[]> ConvertToMp3Async(
        byte[] source, string sourceExtension, CancellationToken ct)
    {
        if (!await _slot.WaitAsync(TimeSpan.Zero, ct))
        {
            throw new AudioConversionBusyException();
        }

        var directory = Path.Combine(
            Path.GetTempPath(), "byensgaader-lyd-" + Guid.NewGuid().ToString("N"));

        try
        {
            Directory.CreateDirectory(directory);
            var input = Path.Combine(directory, "input" + sourceExtension);
            var output = Path.Combine(directory, "output.mp3");
            await File.WriteAllBytesAsync(input, source, ct);

            using var process = new Process
            {
                StartInfo = CreateStartInfo(input, output),
                EnableRaisingEvents = true,
            };

            try
            {
                process.Start();
            }
            catch (Exception error) when (error is InvalidOperationException or System.ComponentModel.Win32Exception)
            {
                logger.LogError(error, "FFmpeg kunne ikke startes");
                throw new AudioConversionUnavailableException();
            }

            var errors = process.StandardError.ReadToEndAsync(ct);
            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(ct);
            timeout.CancelAfter(Timeout);

            try
            {
                await process.WaitForExitAsync(timeout.Token);
            }
            catch (OperationCanceledException) when (!ct.IsCancellationRequested)
            {
                process.Kill(entireProcessTree: true);
                throw new AudioConversionException("Konverteringen tog for lang tid.");
            }

            var errorText = await errors;
            if (process.ExitCode != 0 || !File.Exists(output))
            {
                logger.LogWarning(
                    "FFmpeg afviste en lydfil med kode {ExitCode}: {Error}",
                    process.ExitCode,
                    errorText.Length > 1_000 ? errorText[..1_000] : errorText);
                throw new AudioConversionException(
                    "Lydfilen kunne ikke læses. Prøv MP3, M4A, WAV, AAC, AIFF, CAF, OGG, Opus eller FLAC.");
            }

            return await File.ReadAllBytesAsync(output, ct);
        }
        finally
        {
            try
            {
                if (Directory.Exists(directory))
                {
                    Directory.Delete(directory, recursive: true);
                }
            }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException)
            {
                logger.LogWarning(error, "Den midlertidige lydmappe kunne ikke slettes");
            }
            _slot.Release();
        }
    }

    private ProcessStartInfo CreateStartInfo(string input, string output)
    {
        var configured = configuration["AudioTranscoding:FfmpegPath"];
        var bundled = Path.Combine(AppContext.BaseDirectory, "tools", "ffmpeg");
        var executable = !string.IsNullOrWhiteSpace(configured)
            ? configured
            : File.Exists(bundled) ? bundled : "ffmpeg";

        var start = new ProcessStartInfo
        {
            FileName = executable,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        };

        // ArgumentList undgår, at et filnavn kan blive fortolket af en shell.
        foreach (var argument in new[]
        {
            "-hide_banner", "-loglevel", "error", "-nostdin", "-y",
            "-protocol_whitelist", "file,pipe",
            "-i", input, "-vn", "-map_metadata", "-1",
            "-codec:a", "libmp3lame", "-ac", "1", "-ar", "44100",
            "-b:a", "64k", output,
        })
        {
            start.ArgumentList.Add(argument);
        }

        return start;
    }
}

internal sealed class AudioConversionException(string message) : Exception(message);

internal sealed class AudioConversionUnavailableException()
    : Exception("Serverens lydkonvertering er ikke tilgængelig.");

internal sealed class AudioConversionBusyException()
    : Exception("Serveren gør allerede en anden fortælling klar. Prøv igen om et øjeblik.");
