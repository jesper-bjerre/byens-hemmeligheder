using System.Text.Json.Nodes;

namespace ByensGaader.Api.Features.Content;

internal sealed record AuthoringDocument(JsonObject Json, string ETag);

internal sealed record AuthoringSnapshot(
    string Locale,
    IReadOnlyList<AuthoringDocument> Missions,
    IReadOnlyList<AuthoringDocument> Media,
    IReadOnlyList<AuthoringDocument> Sources);

internal sealed record MissionSummaryDto(
    string Id,
    string Slug,
    string Title,
    string Status,
    string PostalCode,
    DateTimeOffset UpdatedAt,
    string? UpdatedBy,
    string ETag);

internal sealed record MissionIndexDto(
    string Locale,
    IReadOnlyList<MissionSummaryDto> Missions);

internal sealed record PublicationState(
    string RequestedId,
    DateTimeOffset RequestedAt,
    string? PublishedId,
    string? ContentVersion,
    DateTimeOffset? PublishedAt,
    string? LastErrorCode,
    int Attempts)
{
    public bool IsDirty => RequestedId != PublishedId;
}

internal sealed record StoredPublicationState(PublicationState Value, string ETag);

internal sealed record PublishedContent(
    byte[] Pack,
    byte[] Index,
    string ContentVersion,
    IReadOnlyList<MissionSummaryDto> Summaries);

internal enum ContentPublication
{
    Published,
    Pending,
    Unchanged,
}

internal sealed record SaveResultDto(
    string Id,
    string Publication,
    string? PublishedContentVersion);

internal sealed record AuthoringWriteResult(
    WriteKind Kind,
    string? ETag,
    ContentPublication Publication,
    string? ContentVersion);

internal enum WriteKind
{
    Written,
    Conflict,
    NotFound,
    Rejected,
    Referenced,
}

internal static class AuthoringPaths
{
    public static string Mission(string locale, string id) =>
        Path.Combine(locale, "missions", id + ".json");

    public static string Media(string locale, string id) =>
        Path.Combine(locale, "media", id + ".json");

    public static string Source(string locale, string id) =>
        Path.Combine(locale, "sources", id + ".json");

    public static string Index(string locale) => Path.Combine(locale, "index.json");

    public static string State(string locale) =>
        Path.Combine(locale, "publication-state.json");

    public static string Lock(string locale) => Path.Combine("locks", locale);

    public static string PublicPack(string locale) =>
        Path.Combine(locale, "content-pack.json");

    public static string VersionedPack(string locale, string version) =>
        Path.Combine(locale, "versions", version + ".json");

    public static string Audit(string locale) => Path.Combine(locale, "audit.jsonl");
}
