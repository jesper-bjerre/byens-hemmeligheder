using System.Text.Json.Nodes;
using ByensGaader.Api.Features.Content;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class PublishedPackBuilderTests
{
    [Fact]
    public void Kun_spilbare_opgaver_og_deres_afhaengigheder_publiceres()
    {
        var snapshot = SnapshotFromFixture();

        var published = PublishedPackBuilder.Build(snapshot, DateTimeOffset.UnixEpoch);
        var root = JsonNode.Parse(published.Pack)!.AsObject();

        Assert.Equal(4, root["missions"]!.AsArray().Count);
        Assert.Equal(4, root["locations"]!.AsArray().Count);
        Assert.DoesNotContain(
            root["missions"]!.AsArray(),
            mission => mission!["status"]!.GetValue<string>() == "draft");
        Assert.Equal(64, published.ContentVersion.Length);
        Assert.Equal(published.ContentVersion, root["contentVersion"]!.GetValue<string>());
    }

    [Fact]
    public void Samme_snapshot_giver_de_samme_bytes_og_version()
    {
        var snapshot = SnapshotFromFixture();

        var first = PublishedPackBuilder.Build(snapshot, DateTimeOffset.UnixEpoch);
        var second = PublishedPackBuilder.Build(snapshot, DateTimeOffset.UnixEpoch);

        Assert.Equal(first.ContentVersion, second.ContentVersion);
        Assert.Equal(first.Pack, second.Pack);
        Assert.Equal(first.Index, second.Index);
    }

    private static AuthoringSnapshot SnapshotFromFixture()
    {
        var path = Path.Combine(App.FindContentRootForTests(), "da-DK", "content-pack.json");
        var pack = JsonNode.Parse(File.ReadAllBytes(path))!.AsObject();
        var locations = pack["locations"]!.AsArray()
            .ToDictionary(
                node => node!["id"]!.GetValue<string>(),
                node => node!.DeepClone(),
                StringComparer.Ordinal);

        var missions = pack["missions"]!.AsArray().Select((node, index) =>
        {
            var mission = node!.AsObject();
            var locationId = mission["locationId"]!.GetValue<string>();
            return new AuthoringDocument(
                new JsonObject
                {
                    ["schemaVersion"] = pack["schemaVersion"]!.DeepClone(),
                    ["mission"] = mission.DeepClone(),
                    ["location"] = locations[locationId],
                },
                $"\"mission-{index}\"");
        }).ToArray();

        var media = pack["media"]!.AsArray()
            .Select((node, index) => new AuthoringDocument(node!.AsObject(), $"\"media-{index}\""))
            .ToArray();
        var sources = pack["sources"]!.AsArray()
            .Select((node, index) => new AuthoringDocument(node!.AsObject(), $"\"source-{index}\""))
            .ToArray();

        return new AuthoringSnapshot("da-DK", missions, media, sources);
    }
}
