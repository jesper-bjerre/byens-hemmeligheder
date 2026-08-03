using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Features.Content;

internal sealed class PublicationReconciler(
    ContentPublisher publisher,
    IOptions<AuthoringOptions> options,
    ILogger<PublicationReconciler> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (!options.Value.ReconciliationEnabled)
        {
            logger.LogInformation(
                "Automatisk authoring-reconciliation er slået fra; ingen migration sker ved opstart");
            return;
        }

        await ReconcileAsync(stoppingToken);
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            await ReconcileAsync(stoppingToken);
        }
    }

    private async Task ReconcileAsync(CancellationToken ct)
    {
        foreach (var locale in options.Value.Locales)
        {
            try
            {
                await publisher.EnsureReadyAsync(locale, ct);
            }
            catch (Exception exception) when (exception is not OperationCanceledException)
            {
                logger.LogError(exception, "Reconciliation af {Locale} fejlede", locale);
            }
        }
    }
}

internal sealed class AuthoringOptions
{
    public const string Section = "Authoring";

    /// <summary>
    /// Slås først til sammen med den godkendte Azure-migration. Falsk betyder,
    /// at en deploy ikke ændrer lageret af sig selv.
    /// </summary>
    public bool ReconciliationEnabled { get; set; }

    public string[] Locales { get; set; } = ["da-DK"];
}
