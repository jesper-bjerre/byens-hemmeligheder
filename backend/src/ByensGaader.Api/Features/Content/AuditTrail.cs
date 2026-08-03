using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using ByensGaader.Api.Storage;

namespace ByensGaader.Api.Features.Content;

/// <summary>
/// Én linje i revisionssporet.
/// </summary>
/// <param name="At">Tidspunktet, altid i UTC.</param>
/// <param name="By">Quizmasterens navn, som hen har opgivet det i appen.</param>
/// <param name="Change">
/// <c>status</c>, <c>created</c>, <c>removed</c> eller <c>content</c>.
/// </param>
/// <param name="MissionId"><c>null</c> når ændringen ikke gjaldt én bestemt opgave.</param>
/// <param name="From">Statussen før. <c>null</c> ved en ny opgave.</param>
/// <param name="To">Statussen efter. <c>null</c> ved en fjernet opgave.</param>
/// <param name="ContentVersion">Pakkens version efter gemningen.</param>
internal sealed record AuditEntry(
    DateTimeOffset At,
    string By,
    string Change,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? MissionId,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? From,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? To,
    string ContentVersion);

/// <summary>
/// Skriver og læser sporet over, hvem der ændrede hvad hvornår (FR-111).
/// </summary>
/// <remarks>
/// ## Hvorfor serveren her kigger ned i pakken
///
/// Alle andre steder behandler serveren indholdspakken som ugennemsigtige
/// bytes, og det er med vilje: en server, der kender kontrakten, skal udrulles,
/// hver gang kontrakten udvides.
///
/// Sporet er undtagelsen, og undtagelsen er så lille som den kan være. Der
/// læses tre feltnavne — <c>contentVersion</c>, <c>missions[].id</c> og
/// <c>missions[].status</c> — og ingen af dem valideres. Skifter de navn, står
/// der bare intet i sporet; pakken gemmes stadig.
///
/// Alternativet var at lade appen sende sit eget spor. Men når alle
/// quizmastere kan rette i alt, er sporet det eneste, der kan svare på hvorfor
/// noget blev udgivet — og et spor, afsenderen selv formulerer, svarer kun på
/// hvad afsenderen ville have det til at sige.
///
/// ## Formatet er JSON Lines
///
/// Én linje pr. hændelse, kun tilføjelser. En almindelig JSON-array ville
/// kræve, at hele filen læses og skrives om for hver gemning — og så ville to
/// samtidige gemninger kunne tabe hinandens linjer.
/// </remarks>
internal sealed class AuditTrail(ContentStores stores)
{
    private static readonly JsonSerializerOptions Format = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
    };

    internal static string PathFor(string locale) => AuthoringPaths.Audit(locale);

    /// <summary>
    /// Sammenholder den gemte pakke med den nye og skriver forskellen.
    /// </summary>
    /// <param name="before">Pakken som den lå. <c>null</c> hvis der ingen var.</param>
    public async Task RecordAsync(
        string locale, byte[]? before, byte[] after, string by, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        var version = VersionOf(after);
        var old = StatusesIn(before);
        var current = StatusesIn(after);

        var entries = new List<AuditEntry>();

        foreach (var (id, status) in current)
        {
            if (!old.TryGetValue(id, out var previous))
            {
                entries.Add(new AuditEntry(now, by, "created", id, null, status, version));
            }
            else if (previous != status)
            {
                entries.Add(new AuditEntry(now, by, "status", id, previous, status, version));
            }
        }

        foreach (var (id, status) in old.Where(o => !current.ContainsKey(o.Key)))
        {
            entries.Add(new AuditEntry(now, by, "removed", id, status, null, version));
        }

        // Rettede nogen en tekst uden at flytte en status, står der stadig en
        // linje. Ellers ville sporet vise et hul netop de dage, hvor der blev
        // arbejdet mest.
        if (entries.Count == 0)
        {
            entries.Add(new AuditEntry(now, by, "content", null, null, null, version));
        }

        var lines = new StringBuilder();
        foreach (var entry in entries)
        {
            lines.Append(JsonSerializer.Serialize(entry, Format)).Append('\n');
        }

        // Legacy hel-pakke-gemninger fortsætter i det gamle spor, indtil
        // authoring aktiveres. Så opstår der ikke et migrationsvindue, hvor
        // en gammel admin-build kan få historikken til at splitte tavst.
        await stores.Public.AppendAsync(
            PathFor(locale), Encoding.UTF8.GetBytes(lines.ToString()), ct);
    }

    public async Task RecordObjectAsync(
        string locale,
        string by,
        string change,
        string id,
        string? from,
        string? to,
        string? contentVersion,
        CancellationToken ct)
    {
        var entry = new AuditEntry(
            DateTimeOffset.UtcNow,
            by,
            change,
            id,
            from,
            to,
            contentVersion ?? "afventer");
        var line = JsonSerializer.Serialize(entry, Format) + "\n";
        await stores.Authoring.AppendAsync(
            PathFor(locale), Encoding.UTF8.GetBytes(line), ct);
    }

    /// <summary>De seneste linjer, nyeste først.</summary>
    public async Task<IReadOnlyList<JsonElement>> ReadAsync(
        string locale, int limit, CancellationToken ct)
    {
        var entries = new List<JsonElement>();
        // Det gamle spor bliver liggende i public under den sikre overgang;
        // nye objektgemninger skriver kun privat. Endpointet samler begge, så
        // historikken ikke forsvinder, før den gamle blob er arkiveret.
        foreach (var store in new[] { stores.Public, stores.Authoring })
        {
            var file = await store.ReadAsync(PathFor(locale), ct);
            if (file is null) continue;
            foreach (var line in Encoding.UTF8.GetString(file.Content)
                         .Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                try
                {
                    entries.Add(JsonDocument.Parse(line).RootElement.Clone());
                }
                catch (JsonException)
                {
                    // En ulæselig linje springes over. Et halvskrevet spor er
                    // stadig et spor, og resten af linjerne skal kunne læses.
                }
            }
        }
        return entries
            .OrderByDescending(entry => entry.TryGetProperty("at", out var at)
                && at.TryGetDateTimeOffset(out var parsed) ? parsed : DateTimeOffset.MinValue)
            .Take(limit)
            .ToArray();
    }

    private static string VersionOf(byte[] pack)
    {
        try
        {
            using var document = JsonDocument.Parse(pack);
            return document.RootElement.TryGetProperty("contentVersion", out var version)
                && version.ValueKind == JsonValueKind.String
                ? version.GetString()!
                : "ukendt";
        }
        catch (JsonException)
        {
            return "ukendt";
        }
    }

    private static Dictionary<string, string> StatusesIn(byte[]? pack)
    {
        var statuses = new Dictionary<string, string>(StringComparer.Ordinal);
        if (pack is null)
        {
            return statuses;
        }

        try
        {
            using var document = JsonDocument.Parse(pack);
            if (!document.RootElement.TryGetProperty("missions", out var missions)
                || missions.ValueKind != JsonValueKind.Array)
            {
                return statuses;
            }

            foreach (var mission in missions.EnumerateArray())
            {
                if (mission.ValueKind == JsonValueKind.Object
                    && mission.TryGetProperty("id", out var id)
                    && id.ValueKind == JsonValueKind.String)
                {
                    statuses[id.GetString()!] =
                        mission.TryGetProperty("status", out var status)
                        && status.ValueKind == JsonValueKind.String
                            ? status.GetString()!
                            : "ukendt";
                }
            }
        }
        catch (JsonException)
        {
            // Lå der ulæselig JSON på lageret, er der intet at sammenligne med.
            // Den nye pakke gemmes alligevel, og sporet viser den som ny.
        }

        return statuses;
    }
}
