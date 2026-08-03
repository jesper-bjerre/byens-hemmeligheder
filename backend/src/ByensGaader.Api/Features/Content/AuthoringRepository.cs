using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;
using ByensGaader.Api.Storage;

namespace ByensGaader.Api.Features.Content;

internal sealed partial class AuthoringRepository(ContentStores stores)
{
    private static readonly JsonSerializerOptions StateFormat = new(JsonSerializerDefaults.Web)
    {
        WriteIndented = true,
    };

    public async Task<bool> EnsureBootstrappedAsync(string locale, CancellationToken ct)
    {
        ValidateLocale(locale);
        if (await ReadStateAsync(locale, ct) is not null)
        {
            return false;
        }

        await using var lease = await stores.Authoring.AcquireLeaseAsync(
            AuthoringPaths.Lock(locale), ct);
        if (await ReadStateAsync(locale, ct) is not null)
        {
            return false;
        }

        var publicPack = await stores.Public.ReadAsync(AuthoringPaths.PublicPack(locale), ct)
            ?? throw new InvalidOperationException(
                $"Kan ikke initialisere authoring: den offentlige pakke for {locale} findes ikke.");
        var root = ParseObject(publicPack.Content, "Den offentlige pakke er ikke gyldig JSON.");
        var schemaVersion = root["schemaVersion"]?.DeepClone()
            ?? throw new JsonException("Pakken mangler schemaVersion.");
        var locations = RequiredArray(root, "locations")
            .ToDictionary(
                item => RequiredString(item!.AsObject(), "id"),
                item => item!.DeepClone(),
                StringComparer.Ordinal);

        var missionIds = new HashSet<string>(StringComparer.Ordinal);
        foreach (var node in RequiredArray(root, "missions"))
        {
            var mission = node!.AsObject();
            var id = RequiredString(mission, "id");
            missionIds.Add(id);
            var locationId = RequiredString(mission, "locationId");
            if (!locations.TryGetValue(locationId, out var location))
            {
                throw new JsonException($"Opgaven {id} peger på et ukendt sted {locationId}.");
            }

            var aggregate = new JsonObject
            {
                ["schemaVersion"] = schemaVersion.DeepClone(),
                ["mission"] = mission.DeepClone(),
                ["location"] = location.DeepClone(),
            };
            await CreateOrReplaceAsync(AuthoringPaths.Mission(locale, id), aggregate, ct);
        }
        await DeleteUnexpectedAsync(Path.Combine(locale, "missions"), missionIds, ct);

        await SplitCatalogAsync(locale, "media", root, AuthoringPaths.Media, ct);
        await SplitCatalogAsync(locale, "sources", root, AuthoringPaths.Source, ct);

        var version = root["contentVersion"]?.GetValue<string>() ?? publicPack.ETag.Trim('"');
        var bootstrapId = "bootstrap-" + version;
        var state = new PublicationState(
            bootstrapId,
            DateTimeOffset.UtcNow,
            null,
            null,
            null,
            null,
            0);
        await WriteStateAsync(locale, state, expectedETag: null, ct);

        var snapshot = await ReadSnapshotAsync(locale, ct);
        var generated = PublishedPackBuilder.Build(snapshot, DateTimeOffset.UtcNow);
        await WriteReplacingAsync(stores.Authoring, AuthoringPaths.Index(locale), generated.Index, ct);
        return true;
    }

    public async Task<AuthoringSnapshot> ReadSnapshotAsync(string locale, CancellationToken ct)
    {
        ValidateLocale(locale);
        return new AuthoringSnapshot(
            locale,
            await ReadDirectoryAsync(Path.Combine(locale, "missions"), ct),
            await ReadDirectoryAsync(Path.Combine(locale, "media"), ct),
            await ReadDirectoryAsync(Path.Combine(locale, "sources"), ct));
    }

    public Task<AuthoringDocument?> ReadMissionAsync(
        string locale, string id, CancellationToken ct) =>
        ReadDocumentAsync(AuthoringPaths.Mission(locale, ValidateId(id)), ct);

    public Task<AuthoringDocument?> ReadMediaAsync(
        string locale, string id, CancellationToken ct) =>
        ReadDocumentAsync(AuthoringPaths.Media(locale, ValidateId(id)), ct);

    public Task<AuthoringDocument?> ReadSourceAsync(
        string locale, string id, CancellationToken ct) =>
        ReadDocumentAsync(AuthoringPaths.Source(locale, ValidateId(id)), ct);

    public async Task<MissionIndexDto> ReadMissionIndexAsync(
        string locale, CancellationToken ct)
    {
        var file = await stores.Authoring.ReadAsync(AuthoringPaths.Index(locale), ct)
            ?? throw new InvalidOperationException("Authoring-indekset findes ikke.");
        var root = ParseObject(file.Content, "Authoring-indekset er ugyldigt.");
        var missions = root["missions"]?.Deserialize<MissionSummaryDto[]>(StateFormat)
            ?? throw new JsonException("Authoring-indekset mangler missions.");
        return new MissionIndexDto(locale, missions);
    }

    public async Task<WriteOutcome> WriteMissionAsync(
        string locale, string id, JsonObject aggregate, string? expectedETag, CancellationToken ct)
    {
        ValidateLocale(locale);
        ValidateMissionAggregate(id, aggregate);
        return await WriteJsonAsync(
            AuthoringPaths.Mission(locale, ValidateId(id)), aggregate, expectedETag, ct);
    }

    public Task<WriteOutcome> WriteMediaAsync(
        string locale, string id, JsonObject media, string? expectedETag, CancellationToken ct) =>
        WriteCatalogAsync(locale, id, media, expectedETag, AuthoringPaths.Media, ct);

    public Task<WriteOutcome> WriteSourceAsync(
        string locale, string id, JsonObject source, string? expectedETag, CancellationToken ct) =>
        WriteCatalogAsync(locale, id, source, expectedETag, AuthoringPaths.Source, ct);

    public Task<WriteOutcome> DeleteMissionAsync(
        string locale, string id, string expectedETag, CancellationToken ct) =>
        stores.Authoring.DeleteIfMatchAsync(
            AuthoringPaths.Mission(locale, ValidateId(id)), expectedETag, ct);

    public Task<WriteOutcome> DeleteMediaAsync(
        string locale, string id, string expectedETag, CancellationToken ct) =>
        stores.Authoring.DeleteIfMatchAsync(
            AuthoringPaths.Media(locale, ValidateId(id)), expectedETag, ct);

    public Task<WriteOutcome> DeleteSourceAsync(
        string locale, string id, string expectedETag, CancellationToken ct) =>
        stores.Authoring.DeleteIfMatchAsync(
            AuthoringPaths.Source(locale, ValidateId(id)), expectedETag, ct);

    public async Task<bool> IsReferencedAsync(
        string locale, string id, bool media, CancellationToken ct)
    {
        var snapshot = await ReadSnapshotAsync(locale, ct);
        return snapshot.Missions.Any(document => ContainsReference(document.Json, id, media));
    }

    public async Task<StoredPublicationState?> ReadStateAsync(
        string locale, CancellationToken ct)
    {
        var file = await stores.Authoring.ReadAsync(AuthoringPaths.State(locale), ct);
        if (file is null)
        {
            return null;
        }

        var state = JsonSerializer.Deserialize<PublicationState>(file.Content, StateFormat)
            ?? throw new JsonException("Publication-state er tom.");
        return new StoredPublicationState(state, file.ETag);
    }

    public async Task<WriteOutcome> WriteStateAsync(
        string locale,
        PublicationState state,
        string? expectedETag,
        CancellationToken ct)
    {
        var bytes = JsonSerializer.SerializeToUtf8Bytes(state, StateFormat);
        return await stores.Authoring.WriteAsync(
            AuthoringPaths.State(locale), bytes, expectedETag, ct);
    }

    private async Task<IReadOnlyList<AuthoringDocument>> ReadDirectoryAsync(
        string directory, CancellationToken ct)
    {
        var names = await stores.Authoring.ListAsync(directory, ct);
        var documents = new List<AuthoringDocument>(names.Count);
        foreach (var name in names.Where(name => name.EndsWith(".json", StringComparison.Ordinal)))
        {
            var document = await ReadDocumentAsync(Path.Combine(directory, name), ct);
            if (document is not null)
            {
                documents.Add(document);
            }
        }
        return documents;
    }

    private async Task<AuthoringDocument?> ReadDocumentAsync(string path, CancellationToken ct)
    {
        var file = await stores.Authoring.ReadAsync(path, ct);
        return file is null ? null : new AuthoringDocument(ParseObject(file.Content, path), file.ETag);
    }

    private async Task<WriteOutcome> WriteCatalogAsync(
        string locale,
        string id,
        JsonObject value,
        string? expectedETag,
        Func<string, string, string> path,
        CancellationToken ct)
    {
        ValidateLocale(locale);
        id = ValidateId(id);
        if (RequiredString(value, "id") != id)
        {
            throw new JsonException("Id'et i kroppen svarer ikke til ruten.");
        }
        return await WriteJsonAsync(path(locale, id), value, expectedETag, ct);
    }

    private Task<WriteOutcome> WriteJsonAsync(
        string path, JsonObject value, string? expectedETag, CancellationToken ct) =>
        stores.Authoring.WriteAsync(
            path, PublishedPackBuilder.SerialiseCanonical(value), expectedETag, ct);

    private async Task CreateOrReplaceAsync(string path, JsonObject value, CancellationToken ct)
    {
        var existing = await ReadDocumentAsync(path, ct);
        var outcome = await WriteJsonAsync(path, value, existing?.ETag, ct);
        if (outcome is not WriteOutcome.Written)
        {
            throw new InvalidOperationException($"Kunne ikke initialisere {path}: {outcome}.");
        }
    }

    private async Task SplitCatalogAsync(
        string locale,
        string property,
        JsonObject root,
        Func<string, string, string> path,
        CancellationToken ct)
    {
        var ids = new HashSet<string>(StringComparer.Ordinal);
        foreach (var node in RequiredArray(root, property))
        {
            var value = node!.AsObject();
            var id = RequiredString(value, "id");
            ids.Add(id);
            await CreateOrReplaceAsync(path(locale, id), value, ct);
        }
        await DeleteUnexpectedAsync(Path.Combine(locale, property), ids, ct);
    }

    private async Task DeleteUnexpectedAsync(
        string directory, HashSet<string> expectedIds, CancellationToken ct)
    {
        foreach (var name in await stores.Authoring.ListAsync(directory, ct))
        {
            if (!name.EndsWith(".json", StringComparison.Ordinal)) continue;
            var id = name[..^5];
            if (expectedIds.Contains(id)) continue;
            var path = Path.Combine(directory, name);
            var existing = await ReadDocumentAsync(path, ct);
            if (existing is not null
                && await stores.Authoring.DeleteIfMatchAsync(path, existing.ETag, ct)
                    is not WriteOutcome.Written)
            {
                throw new InvalidOperationException($"Kunne ikke rydde gammel bootstrap-fil {path}.");
            }
        }
    }

    private static async Task WriteReplacingAsync(
        IContentStore store, string path, byte[] content, CancellationToken ct)
    {
        var existing = await store.ReadAsync(path, ct);
        var outcome = await store.WriteAsync(path, content, existing?.ETag, ct);
        if (outcome is not WriteOutcome.Written)
        {
            throw new InvalidOperationException($"Kunne ikke skrive {path}: {outcome}.");
        }
    }

    private static bool ContainsReference(JsonNode node, string id, bool media)
    {
        if (node is JsonObject obj)
        {
            foreach (var property in obj)
            {
                if (media
                    && property.Key.EndsWith("MediaId", StringComparison.Ordinal)
                    && property.Value?.GetValue<string>() == id)
                {
                    return true;
                }
                if (!media && property.Key == "sourceIds" && property.Value is JsonArray sources
                    && sources.Any(item => item?.GetValue<string>() == id))
                {
                    return true;
                }
                if (property.Value is not null && ContainsReference(property.Value, id, media))
                {
                    return true;
                }
            }
        }
        else if (node is JsonArray array)
        {
            return array.Any(item => item is not null && ContainsReference(item, id, media));
        }
        return false;
    }

    private static void ValidateMissionAggregate(string routeId, JsonObject aggregate)
    {
        var mission = aggregate["mission"] as JsonObject
            ?? throw new JsonException("Kroppen mangler mission.");
        var location = aggregate["location"] as JsonObject
            ?? throw new JsonException("Kroppen mangler location.");
        _ = aggregate["schemaVersion"]
            ?? throw new JsonException("Kroppen mangler schemaVersion.");
        if (RequiredString(mission, "id") != routeId)
        {
            throw new JsonException("Mission-id'et i kroppen svarer ikke til ruten.");
        }
        if (RequiredString(mission, "locationId") != RequiredString(location, "id"))
        {
            throw new JsonException("Missionens locationId svarer ikke til stedet.");
        }
    }

    private static JsonObject ParseObject(byte[] bytes, string error)
    {
        try
        {
            return JsonNode.Parse(bytes)?.AsObject() ?? throw new JsonException(error);
        }
        catch (InvalidOperationException exception)
        {
            throw new JsonException(error, exception);
        }
    }

    private static JsonArray RequiredArray(JsonObject root, string property) =>
        root[property] as JsonArray ?? throw new JsonException($"Pakken mangler {property}.");

    private static string RequiredString(JsonObject root, string property) =>
        root[property]?.GetValue<string>() is { Length: > 0 } value
            ? value
            : throw new JsonException($"Objektet mangler {property}.");

    private static void ValidateLocale(string locale)
    {
        if (!LocalePattern().IsMatch(locale))
        {
            throw new ArgumentException("Ugyldigt locale.", nameof(locale));
        }
    }

    private static string ValidateId(string id)
    {
        if (id.Length is 0 or > 160 || !IdPattern().IsMatch(id))
        {
            throw new ArgumentException("Ugyldigt id.", nameof(id));
        }
        return id;
    }

    [GeneratedRegex("^[a-z]{2}-[A-Z]{2}$", RegexOptions.CultureInvariant)]
    private static partial Regex LocalePattern();

    [GeneratedRegex("^[A-Za-z0-9._-]+$", RegexOptions.CultureInvariant)]
    private static partial Regex IdPattern();
}
