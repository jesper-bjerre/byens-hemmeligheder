using System.Net;
using System.Net.Http.Json;
using FastEndpoints.Testing;
using Microsoft.AspNetCore.Hosting;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>
/// Starter hele appen i hukommelsen og kalder den over HTTP.
///
/// Værdien ligger ikke i, at sundhedstjekket svarer — det er trivielt. Den
/// ligger i, at rutning, konfiguration og opstart faktisk hænger sammen. Går
/// noget galt i <c>Program.cs</c>, fejler denne test frem for en udrulning.
///
/// Kaldet går gennem en rigtig HTTP-klient og ikke gennem endepunktets type.
/// Så efterprøves også ruten — herunder præfikset <c>/api</c>, som sættes
/// centralt og er nemt at komme til at ændre uden at opdage det.
/// </summary>
public sealed class HealthEndpointTests(App app) : TestBase<App>
{
    [Fact]
    public async Task Sundhedstjekket_svarer_at_apiet_koerer()
    {
        var response = await app.Client.GetAsync("/health", TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var body = await response.Content.ReadFromJsonAsync<HealthBody>(
            TestContext.Current.CancellationToken);

        Assert.NotNull(body);
        Assert.Equal("kører", body.Status);
        Assert.False(string.IsNullOrWhiteSpace(body.Version));
    }

    /// <summary>Spejler svaret. Testen kender ikke API'ets interne typer.</summary>
    private sealed record HealthBody(string Status, string Version);
}

/// <summary>
/// Værten, testene deler. Startes én gang for hele kørslen.
/// </summary>
/// <remarks>
/// Indholdsroden sættes eksplicit til repoets <c>contracts/content</c>.
///
/// `appsettings.json` peger relativt til arbejdsmappen, og den er en anden
/// under testværten end under `dotnet run`. Testene fandt det med det samme —
/// alle indholdskald gav 404 — men en relativ sti, der virker det ene sted og
/// ikke det andet, er præcis den slags, der ellers først opdages i en udrulning.
/// </remarks>
public sealed class App : AppFixture<Program>
{
    protected override void ConfigureApp(IWebHostBuilder builder)
    {
        builder.UseSetting("ContentStore:RootPath", FindContentRoot());
    }

    /// <summary>Går op fra testbinæren, indtil repoets indholdsmappe findes.</summary>
    private static string FindContentRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null)
        {
            var candidate = Path.Combine(dir.FullName, "contracts", "content");
            if (Directory.Exists(candidate))
            {
                return candidate;
            }
            dir = dir.Parent;
        }
        throw new DirectoryNotFoundException(
            "Fandt ikke 'contracts/content' over testbinæren. Er repoet flyttet?");
    }
}
