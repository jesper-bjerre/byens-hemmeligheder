using Azure.Identity;
using Azure.Storage.Blobs;
using ByensGaader.Api.Storage;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>
/// Den samme kontrakt, kørt mod begge lagre.
/// </summary>
/// <remarks>
/// ## Hvorfor det skal være de samme tests
///
/// `IContentStore` findes for at kunne skifte lager uden at røre
/// endepunkterne. Det løfte holder kun, hvis de to implementeringer opfører sig
/// ens — og forskellene ville ikke vise sig som en fejl, men som en ETag, der
/// pludselig skiftede ved hver udrulning, eller en samtidighedskontrol, der
/// stille holdt op med at virke i drift.
///
/// ## Blobtestene springes over, når der ikke er en konto
///
/// Sæt <c>BH_TEST_BLOB_URI</c> til DEV-kontoens adresse — fx
/// <c>https://byensgaaderd.blob.core.windows.net</c> — og log ind med
/// <c>az login</c>. Så kører de samme tests mod Azure.
///
/// De springes over frem for at fejle, fordi en test, der kræver en
/// Azure-konto, ellers ville gøre `dotnet test` rødt for enhver, der bare
/// prøver at bygge projektet.
///
/// > Kør dem mod en **DEV**-konto. De skriver og sletter.
/// </remarks>
public abstract class ContentStoreContractTests : IAsyncLifetime
{
    private protected abstract Task<IContentStore> CreateAsync();
    private protected abstract Task CleanUpAsync();

    private IContentStore _store = null!;

    /// <summary>Egen mappe pr. kørsel, så to samtidige kørsler ikke ses.</summary>
    protected string Prefix { get; } = $"proeve-{Guid.NewGuid():N}";

    public async ValueTask InitializeAsync() => _store = await CreateAsync();

    public async ValueTask DisposeAsync() => await CleanUpAsync();

    private static byte[] Bytes(string text) => System.Text.Encoding.UTF8.GetBytes(text);

    private string Path(string name) => $"{Prefix}/{name}";

    // MARK: - Læsning og skrivning

    [Fact]
    public async Task Et_ukendt_navn_giver_null()
    {
        Assert.Null(await _store.ReadAsync(Path("findes-ikke.json"), TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Skriver_naar_filen_ikke_findes_og_ingen_etag_ventes()
    {
        var outcome = await _store.WriteAsync(
            Path("ny.json"), Bytes("{}"), null, TestContext.Current.CancellationToken);

        Assert.Equal(WriteOutcome.Written, outcome);

        var stored = await _store.ReadAsync(Path("ny.json"), TestContext.Current.CancellationToken);
        Assert.Equal("{}", System.Text.Encoding.UTF8.GetString(stored!.Content));
    }

    /// <summary>
    /// ETag'en beregnes af indholdet, ikke af tidspunktet eller af lagerets
    /// egen version. Ellers henter hver eneste app alt igen, hver gang vi
    /// flytter noget.
    /// </summary>
    [Fact]
    public async Task Etaggen_er_den_samme_for_det_samme_indhold()
    {
        await _store.WriteAsync(Path("a.json"), Bytes("{\"x\":1}"), null, TestContext.Current.CancellationToken);
        await _store.WriteAsync(Path("b.json"), Bytes("{\"x\":1}"), null, TestContext.Current.CancellationToken);

        var a = await _store.ReadAsync(Path("a.json"), TestContext.Current.CancellationToken);
        var b = await _store.ReadAsync(Path("b.json"), TestContext.Current.CancellationToken);

        Assert.Equal(a!.ETag, b!.ETag);
    }

    [Fact]
    public async Task Etaggen_skifter_naar_indholdet_skifter()
    {
        await _store.WriteAsync(Path("c.json"), Bytes("{\"x\":1}"), null, TestContext.Current.CancellationToken);
        var first = await _store.ReadAsync(Path("c.json"), TestContext.Current.CancellationToken);

        await _store.WriteAsync(
            Path("c.json"), Bytes("{\"x\":2}"), first!.ETag, TestContext.Current.CancellationToken);
        var second = await _store.ReadAsync(Path("c.json"), TestContext.Current.CancellationToken);

        Assert.NotEqual(first.ETag, second!.ETag);
    }

    /// <summary>
    /// Den vigtigste. Alle quizmastere kan rette i alt, så uden dette taber
    /// den, der gemmer sidst, den andens arbejde uden at nogen opdager det.
    /// </summary>
    [Fact]
    public async Task Afviser_en_skrivning_med_en_foraeldet_etag()
    {
        await _store.WriteAsync(Path("d.json"), Bytes("først"), null, TestContext.Current.CancellationToken);
        var stale = await _store.ReadAsync(Path("d.json"), TestContext.Current.CancellationToken);

        await _store.WriteAsync(
            Path("d.json"), Bytes("anden"), stale!.ETag, TestContext.Current.CancellationToken);

        var outcome = await _store.WriteAsync(
            Path("d.json"), Bytes("tredje"), stale.ETag, TestContext.Current.CancellationToken);

        Assert.Equal(WriteOutcome.Conflict, outcome);
        var final = await _store.ReadAsync(Path("d.json"), TestContext.Current.CancellationToken);
        Assert.Equal("anden", System.Text.Encoding.UTF8.GetString(final!.Content));
    }

    [Fact]
    public async Task Afviser_en_foerstegangsskrivning_paa_noget_der_allerede_findes()
    {
        await _store.WriteAsync(Path("e.json"), Bytes("står"), null, TestContext.Current.CancellationToken);

        var outcome = await _store.WriteAsync(
            Path("e.json"), Bytes("overskriver"), null, TestContext.Current.CancellationToken);

        Assert.Equal(WriteOutcome.Conflict, outcome);
    }

    // MARK: - Medier

    /// <summary>
    /// Medier sendes med et års cache. En fil, der skifter indhold uden at
    /// skifte navn, ville stå gammel på telefonerne i et år.
    /// </summary>
    [Fact]
    public async Task Samme_filnavn_to_gange_afvises()
    {
        Assert.Equal(
            WriteOutcome.Written,
            await _store.CreateAsync(Path("m/en.jpg"), Bytes("billede"), TestContext.Current.CancellationToken));

        Assert.Equal(
            WriteOutcome.AlreadyExists,
            await _store.CreateAsync(Path("m/en.jpg"), Bytes("andet"), TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Indholdstypen_kommer_af_filendelsen()
    {
        await _store.CreateAsync(Path("m/lyd.m4a"), Bytes("lyd"), TestContext.Current.CancellationToken);
        var stored = await _store.ReadAsync(Path("m/lyd.m4a"), TestContext.Current.CancellationToken);

        Assert.Equal("audio/mp4", stored!.ContentType);
    }

    [Fact]
    public async Task Listen_er_sorteret_og_kun_mappens_egne()
    {
        await _store.CreateAsync(Path("liste/b.jpg"), Bytes("b"), TestContext.Current.CancellationToken);
        await _store.CreateAsync(Path("liste/a.jpg"), Bytes("a"), TestContext.Current.CancellationToken);
        await _store.CreateAsync(Path("liste/dyb/c.jpg"), Bytes("c"), TestContext.Current.CancellationToken);

        var names = await _store.ListAsync(Path("liste"), TestContext.Current.CancellationToken);

        Assert.Equal(["a.jpg", "b.jpg"], names);
    }

    [Fact]
    public async Task En_ukendt_mappe_giver_en_tom_liste()
    {
        Assert.Empty(await _store.ListAsync(Path("findes-ikke"), TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Et_medie_kan_slettes_og_kun_een_gang()
    {
        await _store.CreateAsync(Path("m/slet.jpg"), Bytes("x"), TestContext.Current.CancellationToken);

        Assert.True(await _store.DeleteAsync(Path("m/slet.jpg"), TestContext.Current.CancellationToken));
        Assert.False(await _store.DeleteAsync(Path("m/slet.jpg"), TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Betinget_sletning_afviser_en_foraeldet_etag()
    {
        await _store.WriteAsync(Path("slet.json"), Bytes("før"), null, TestContext.Current.CancellationToken);
        var stale = await _store.ReadAsync(Path("slet.json"), TestContext.Current.CancellationToken);
        await _store.WriteAsync(
            Path("slet.json"), Bytes("efter"), stale!.ETag, TestContext.Current.CancellationToken);

        var outcome = await _store.DeleteIfMatchAsync(
            Path("slet.json"), stale.ETag, TestContext.Current.CancellationToken);

        Assert.Equal(WriteOutcome.Conflict, outcome);
        Assert.NotNull(await _store.ReadAsync(Path("slet.json"), TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task En_lease_lader_kun_en_publicering_fortsætte_ad_gangen()
    {
        var first = await _store.AcquireLeaseAsync(
            Path("locks/da-DK"), TestContext.Current.CancellationToken);
        var waiting = _store.AcquireLeaseAsync(
            Path("locks/da-DK"), TestContext.Current.CancellationToken);

        await Task.Delay(100, TestContext.Current.CancellationToken);
        Assert.False(waiting.IsCompleted);

        await first.DisposeAsync();
        await using var second = await waiting;
        Assert.True(second.WasContended);
    }

    // MARK: - Sporet

    /// <summary>
    /// Sporet har hverken ETag eller samtidighedskontrol: to quizmastere, der
    /// gemmer samtidig, skal **begge** ende i det. En tabt linje i et
    /// revisionsspor er værre end ingen.
    /// </summary>
    [Fact]
    public async Task Tilfoejelser_laegger_sig_efter_hinanden()
    {
        await _store.AppendAsync(Path("spor.jsonl"), Bytes("en\n"), TestContext.Current.CancellationToken);
        await _store.AppendAsync(Path("spor.jsonl"), Bytes("to\n"), TestContext.Current.CancellationToken);
        await _store.AppendAsync(Path("spor.jsonl"), Bytes("tre\n"), TestContext.Current.CancellationToken);

        var stored = await _store.ReadAsync(Path("spor.jsonl"), TestContext.Current.CancellationToken);

        Assert.Equal("en\nto\ntre\n", System.Text.Encoding.UTF8.GetString(stored!.Content));
    }

    [Fact]
    public async Task Samtidige_tilfoejelser_taber_ingen_linjer()
    {
        var writes = Enumerable.Range(0, 12).Select(i =>
            _store.AppendAsync(Path("samtidig.jsonl"), Bytes($"linje-{i}\n"), TestContext.Current.CancellationToken));
        await Task.WhenAll(writes);

        var stored = await _store.ReadAsync(Path("samtidig.jsonl"), TestContext.Current.CancellationToken);
        var lines = System.Text.Encoding.UTF8.GetString(stored!.Content)
            .Split('\n', StringSplitOptions.RemoveEmptyEntries);

        Assert.Equal(12, lines.Length);
        Assert.Equal(12, lines.Distinct().Count());
    }

    // MARK: - Stier

    /// <summary>
    /// Endepunkterne er anonyme. Begge lagre skal afvise det samme — en
    /// kontrol, der kun findes ét sted, er en, nogen fjerner ved et uheld.
    /// </summary>
    [Theory]
    [InlineData("../hemmelig.json")]
    [InlineData("da-DK/../../appsettings.json")]
    [InlineData("/etc/passwd")]
    [InlineData("")]
    [InlineData("   ")]
    public async Task Stier_ud_af_indholdet_afvises(string path)
    {
        Assert.Null(await _store.ReadAsync(path, TestContext.Current.CancellationToken));
        Assert.Equal(
            WriteOutcome.Rejected,
            await _store.WriteAsync(path, Bytes("x"), null, TestContext.Current.CancellationToken));
        Assert.Equal(
            WriteOutcome.Rejected,
            await _store.CreateAsync(path, Bytes("x"), TestContext.Current.CancellationToken));
        Assert.False(await _store.DeleteAsync(path, TestContext.Current.CancellationToken));
    }
}

/// <summary>Kontrakten mod en mappe på disken.</summary>
public sealed class FileSystemContentStoreTests : ContentStoreContractTests
{
    private string _root = string.Empty;

    private protected override Task<IContentStore> CreateAsync()
    {
        _root = Path.Combine(Path.GetTempPath(), $"bh-lager-{Guid.NewGuid():N}");
        Directory.CreateDirectory(_root);

        var options = Options.Create(new ContentStoreOptions { RootPath = _root });
        return Task.FromResult<IContentStore>(new FileSystemContentStore(options));
    }

    private protected override Task CleanUpAsync()
    {
        if (Directory.Exists(_root))
        {
            Directory.Delete(_root, recursive: true);
        }
        return Task.CompletedTask;
    }
}

/// <summary>
/// Den samme kontrakt mod Azure. Springes over uden <c>BH_TEST_BLOB_URI</c>.
/// </summary>
public sealed class BlobContentStoreTests : ContentStoreContractTests
{
    internal const string UriVariable = "BH_TEST_BLOB_URI";

    private static string? AccountUri =>
        Environment.GetEnvironmentVariable(UriVariable) is { Length: > 0 } value ? value : null;

    private BlobContainerClient? _container;

    private protected override Task<IContentStore> CreateAsync()
    {
        Assert.SkipUnless(
            AccountUri is not null,
            $"Sæt {UriVariable} til DEV-kontoens adresse og kør `az login` for at køre "
            + "kontrakten mod Azure. Kør dem aldrig mod produktion — de skriver og sletter.");

        var service = new BlobServiceClient(new Uri(AccountUri!), new DefaultAzureCredential());
        var options = Options.Create(new ContentStoreOptions
        {
            Provider = ContentStoreProvider.Blob,
            Container = Environment.GetEnvironmentVariable("BH_TEST_BLOB_CONTAINER") ?? "content",
        });

        _container = service.GetBlobContainerClient(options.Value.Container);
        return Task.FromResult<IContentStore>(new BlobContentStore(service, options));
    }

    /// <summary>Rydder kun det, kørslen selv lagde op.</summary>
    private protected override async Task CleanUpAsync()
    {
        if (_container is null)
        {
            return;
        }

        await foreach (var blob in _container.GetBlobsAsync(prefix: Prefix))
        {
            await _container.DeleteBlobIfExistsAsync(blob.Name);
        }
    }
}
