using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace ByensGaader.Api.Features.Content;

internal static class PublishedPackBuilder
{
    private static readonly JsonSerializerOptions Format = new(JsonSerializerDefaults.Web)
    {
        WriteIndented = true,
    };

    private static readonly HashSet<string> PublicStatuses =
        new(StringComparer.Ordinal) { "fieldTestReady", "publishReady" };

    public static PublishedContent Build(AuthoringSnapshot source, DateTimeOffset generatedAt)
    {
        var aggregates = source.Missions
            .Select(ParseAggregate)
            .OrderBy(item => item.Mission["id"]!.GetValue<string>(), StringComparer.Ordinal)
            .ToArray();

        var publicAggregates = aggregates
            .Where(item => PublicStatuses.Contains(item.Mission["status"]?.GetValue<string>() ?? ""))
            .ToArray();

        var mediaIds = new HashSet<string>(StringComparer.Ordinal);
        var sourceIds = new HashSet<string>(StringComparer.Ordinal);
        foreach (var item in publicAggregates)
        {
            CollectReferences(item.Mission, mediaIds, sourceIds);
        }

        var root = new JsonObject
        {
            ["schemaVersion"] = aggregates.FirstOrDefault()?.SchemaVersion.DeepClone() ?? "1.0",
            ["locale"] = source.Locale,
            ["contentVersion"] = string.Empty,
            ["locations"] = new JsonArray(
                publicAggregates
                    .OrderBy(item => item.Location["id"]!.GetValue<string>(), StringComparer.Ordinal)
                    .Select(item => item.Location.DeepClone())
                    .ToArray()),
            ["missions"] = new JsonArray(
                publicAggregates.Select(item => item.Mission.DeepClone()).ToArray()),
            ["media"] = new JsonArray(
                source.Media
                    .Where(item => mediaIds.Contains(item.Json["id"]?.GetValue<string>() ?? ""))
                    .OrderBy(item => item.Json["id"]!.GetValue<string>(), StringComparer.Ordinal)
                    .Select(item => item.Json.DeepClone())
                    .ToArray()),
            ["sources"] = new JsonArray(
                source.Sources
                    .Where(item => sourceIds.Contains(item.Json["id"]?.GetValue<string>() ?? ""))
                    .OrderBy(item => item.Json["id"]!.GetValue<string>(), StringComparer.Ordinal)
                    .Select(item => item.Json.DeepClone())
                    .ToArray()),
        };

        var hashInput = SerialiseCanonical(root);
        var contentVersion = Convert.ToHexStringLower(SHA256.HashData(hashInput));
        root["contentVersion"] = contentVersion;
        var pack = SerialiseCanonical(root);

        var summaries = aggregates.Select(item => new MissionSummaryDto(
                item.Mission["id"]!.GetValue<string>(),
                item.Mission["slug"]?.GetValue<string>() ?? string.Empty,
                item.Mission["title"]?.GetValue<string>() ?? string.Empty,
                item.Mission["status"]?.GetValue<string>() ?? "draft",
                item.Location["postalCode"]?.GetValue<string>() ?? string.Empty,
                generatedAt,
                null,
                item.Source.ETag))
            .OrderBy(item => item.PostalCode, StringComparer.Ordinal)
            .ThenBy(item => item.Title, StringComparer.Ordinal)
            .ToArray();

        var index = new JsonObject
        {
            ["schemaVersion"] = "1",
            ["generatedAt"] = generatedAt,
            ["missions"] = JsonSerializer.SerializeToNode(summaries, Format),
        };

        return new PublishedContent(
            pack,
            SerialiseCanonical(index),
            contentVersion,
            summaries);
    }

    internal static byte[] SerialiseCanonical(JsonNode node)
    {
        var canonical = Canonicalise(node);
        return Encoding.UTF8.GetBytes(canonical.ToJsonString(Format) + "\n");
    }

    private static JsonNode Canonicalise(JsonNode node) => node switch
    {
        JsonObject obj => new JsonObject(
            obj.OrderBy(property => property.Key, StringComparer.Ordinal)
                .Select(property => KeyValuePair.Create(
                    property.Key,
                    property.Value is null ? null : Canonicalise(property.Value)))),
        JsonArray array => new JsonArray(
            array.Select(item => item is null ? null : Canonicalise(item)).ToArray()),
        _ => node.DeepClone(),
    };

    private static ParsedAggregate ParseAggregate(AuthoringDocument source)
    {
        var schemaVersion = source.Json["schemaVersion"]
            ?? throw new JsonException("Opgaveaggregatet mangler schemaVersion.");
        var mission = source.Json["mission"] as JsonObject
            ?? throw new JsonException("Opgaveaggregatet mangler mission.");
        var location = source.Json["location"] as JsonObject
            ?? throw new JsonException("Opgaveaggregatet mangler location.");

        return new ParsedAggregate(source, schemaVersion, mission, location);
    }

    private static void CollectReferences(
        JsonNode node, HashSet<string> mediaIds, HashSet<string> sourceIds)
    {
        if (node is JsonObject obj)
        {
            foreach (var property in obj)
            {
                if (property.Key.EndsWith("MediaId", StringComparison.OrdinalIgnoreCase)
                    && property.Value is JsonValue media
                    && media.TryGetValue<string>(out var mediaId)
                    && !string.IsNullOrWhiteSpace(mediaId))
                {
                    mediaIds.Add(mediaId);
                }
                else if (property.Key is "sourceIds" && property.Value is JsonArray sources)
                {
                    foreach (var source in sources)
                    {
                        if (source is JsonValue value
                            && value.TryGetValue<string>(out var sourceId)
                            && !string.IsNullOrWhiteSpace(sourceId))
                        {
                            sourceIds.Add(sourceId);
                        }
                    }
                }

                if (property.Value is not null)
                {
                    CollectReferences(property.Value, mediaIds, sourceIds);
                }
            }
        }
        else if (node is JsonArray array)
        {
            foreach (var item in array)
            {
                if (item is not null)
                {
                    CollectReferences(item, mediaIds, sourceIds);
                }
            }
        }
    }

    private sealed record ParsedAggregate(
        AuthoringDocument Source,
        JsonNode SchemaVersion,
        JsonObject Mission,
        JsonObject Location);
}
