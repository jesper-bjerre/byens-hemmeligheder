using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>Egen kopi af indholdet, så statusflytningerne her ikke blandes
/// sammen med de andre skrivetesters.</summary>
public sealed class AuditApp : WritableApp;

/// <summary>
/// FR-111. Alle quizmastere kan flytte enhver opgave mellem statusser, og der
/// er ingen godkendelsesgang. Sporet er derfor det eneste, der bagefter kan
/// svare på, hvem der udgav hvad — testene her er den eneste garanti for, at
/// det bliver skrevet.
/// </summary>
public sealed class AuditTrailTests(AuditApp app) : FastEndpoints.Testing.TestBase<AuditApp>
{
    private const string Pack = "/content/da-DK/pack";
    private const string Audit = "/content/da-DK/audit";

    private static string PackWith(string status) =>
        $$"""
        {"contentVersion":"2026-07-30.1","missions":[{"id":"mission.proeve","status":"{{status}}"}]}
        """;

    /// <summary>Gemmer og returnerer svaret. ETag'en hentes lige før, så
    /// gemningen ikke afvises af en samtidighedskontrol, den ikke tester.</summary>
    private async Task<HttpResponseMessage> SaveAsync(string json, string by)
    {
        var current = await app.Client.GetAsync(Pack, TestContext.Current.CancellationToken);

        using var request = new HttpRequestMessage(HttpMethod.Put, Pack)
        {
            Content = new StringContent(json, Encoding.UTF8, "application/json"),
        };
        request.Headers.Add("X-Quizmaster", by);
        request.Headers.IfMatch.Add(EntityTagHeaderValue.Parse(current.Headers.ETag!.ToString()));

        return await app.Client.SendAsync(request, TestContext.Current.CancellationToken);
    }

    private async Task<JsonElement[]> TrailAsync()
    {
        var response = await app.Client.GetFromJsonAsync<JsonElement>(
            Audit, TestContext.Current.CancellationToken);
        return response.GetProperty("entries").EnumerateArray().ToArray();
    }

    [Fact]
    public async Task En_statusflytning_efterlader_hvem_hvornaar_fra_og_til()
    {
        Assert.Equal(HttpStatusCode.NoContent, (await SaveAsync(PackWith("draft"), "Ida")).StatusCode);
        Assert.Equal(
            HttpStatusCode.NoContent,
            (await SaveAsync(PackWith("fieldTestReady"), "Bo")).StatusCode);

        var trail = await TrailAsync();

        // Nyeste først, så den seneste flytning er den, quizmasteren ser først.
        var move = trail[0];
        Assert.Equal("status", move.GetProperty("change").GetString());
        Assert.Equal("Bo", move.GetProperty("by").GetString());
        Assert.Equal("mission.proeve", move.GetProperty("missionId").GetString());
        Assert.Equal("draft", move.GetProperty("from").GetString());
        Assert.Equal("fieldTestReady", move.GetProperty("to").GetString());
        Assert.True(move.GetProperty("at").TryGetDateTimeOffset(out _), "tidspunktet mangler");

        // Den første gemning erstattede hele pakken, så den efterlod både en
        // oprettelse og en fjernelse pr. opgave, der forsvandt. Oprettelsen
        // findes på sit indhold og ikke på sin plads i listen.
        var created = trail.Single(e =>
            e.GetProperty("change").GetString() == "created"
            && e.GetProperty("missionId").GetString() == "mission.proeve");
        Assert.Equal("Ida", created.GetProperty("by").GetString());
        Assert.Equal("draft", created.GetProperty("to").GetString());
        Assert.False(created.TryGetProperty("from", out _), "en ny opgave kommer ikke fra en status");
    }

    /// <summary>
    /// En rettelse i en tekst er også en ændring. Uden denne linje ville sporet
    /// vise et hul netop de dage, hvor der blev arbejdet mest.
    /// </summary>
    [Fact]
    public async Task En_gemning_uden_statusskift_staar_ogsaa_i_sporet()
    {
        await SaveAsync(PackWith("draft"), "Ida");
        var before = (await TrailAsync()).Length;

        await SaveAsync(PackWith("draft"), "Ida");

        var trail = await TrailAsync();
        Assert.Equal(before + 1, trail.Length);
        Assert.Equal("content", trail[0].GetProperty("change").GetString());
    }

    /// <summary>
    /// Halvdelen af navnene i et dansk hold har æ, ø eller å i sig, og en
    /// HTTP-header kan ikke bære andet end ASCII. Kom navnet forvansket frem,
    /// ville sporet svare på hvem med noget, ingen hedder.
    /// </summary>
    [Fact]
    public async Task Et_dansk_navn_staar_uforvansket_i_sporet()
    {
        await SaveAsync(PackWith("draft"), Uri.EscapeDataString("Søren Ødegård"));

        var trail = await TrailAsync();
        Assert.Equal("Søren Ødegård", trail[0].GetProperty("by").GetString());
    }

    /// <summary>Sporet må kun kunne læses. Et revisionsspor, der kan rettes af
    /// dem, det holder øje med, beviser ingenting.</summary>
    [Fact]
    public async Task Sporet_kan_ikke_skrives_gennem_apiet()
    {
        using var request = new HttpRequestMessage(HttpMethod.Put, Audit)
        {
            Content = new StringContent("[]", Encoding.UTF8, "application/json"),
        };
        var response = await app.Client.SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.MethodNotAllowed, response.StatusCode);
    }
}
