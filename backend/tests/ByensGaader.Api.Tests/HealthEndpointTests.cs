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
        // Lokal kørsel bruger rigtig D-Blob som standard. Testene vælger
        // filsystemet eksplicit, så de forbliver isolerede og kan køre offline.
        builder.UseSetting("ContentStore:Provider", "FileSystem");
        builder.UseSetting("ContentStore:RootPath", FindContentRoot());
    }

    /// <summary>Går op fra testbinæren, indtil repoets indholdsmappe findes.</summary>
    internal static string FindContentRootForTests() => FindContentRoot();

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

/// <summary>
/// Som <see cref="App"/>, men med en **kopi** af indholdet i en midlertidig
/// mappe.
///
/// Skrivetestene ville ellers rette i repoets egen indholdspakke. En test, der
/// kan ødelægge det indhold, appen lever af, er værre end ingen test.
/// </summary>
/// <remarks>
/// Ikke <c>sealed</c>, og den bruges aldrig direkte. FastEndpoints deler én
/// instans pr. fixture-**type**, og den rives ned, når den første testklasse,
/// der brugte den, er færdig. Delte to klasser typen, kunne den enes oprydning
/// slette den andens mappe midt i en kørsel — det gjorde
/// <c>Listen_viser_det_der_er_lagt_op</c> flaky.
///
/// Hver skrivende testklasse arver derfor sin egen type:
/// <see cref="PackApp"/>, <see cref="MediaApp"/>, <see cref="AuditApp"/>.
/// </remarks>
public class WritableApp : AppFixture<Program>
{
    private string _root = string.Empty;
    private string _authoringRoot = string.Empty;

    protected override ValueTask PreSetupAsync()
    {
        _root = Path.Combine(Path.GetTempPath(), "byensgaader-test-" + Guid.NewGuid().ToString("N"));
        _authoringRoot = Path.Combine(_root, "authoring");
        var locale = Path.Combine(_root, "da-DK");
        Directory.CreateDirectory(locale);

        var source = App.FindContentRootForTests();
        File.Copy(
            Path.Combine(source, "da-DK", "content-pack.json"),
            Path.Combine(locale, "content-pack.json"));

        return ValueTask.CompletedTask;
    }

    protected override void ConfigureApp(IWebHostBuilder builder)
    {
        builder.UseSetting("ContentStore:Provider", "FileSystem");
        builder.UseSetting("ContentStore:RootPath", _root);
        builder.UseSetting("ContentStore:AuthoringRootPath", _authoringRoot);
    }

    protected override ValueTask TearDownAsync()
    {
        if (Directory.Exists(_root))
        {
            Directory.Delete(_root, recursive: true);
        }
        return ValueTask.CompletedTask;
    }
}
