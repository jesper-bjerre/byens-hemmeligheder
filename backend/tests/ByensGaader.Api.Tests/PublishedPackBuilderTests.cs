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

        Assert.Equal(2, root["missions"]!.AsArray().Count);
        Assert.Equal(2, root["locations"]!.AsArray().Count);
        Assert.DoesNotContain(
            root["missions"]!.AsArray(),
            mission => mission!["status"]!.GetValue<string>() is "draft" or "fieldTestReady");
        Assert.All(
            root["missions"]!.AsArray(),
            mission => Assert.Equal("publishReady", mission!["status"]!.GetValue<string>()));
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

    [Fact]
    public void Preview_medtager_felttestklare_men_ikke_kladder()
    {
        var preview = PublishedPackBuilder.BuildPreview(
            SnapshotFromFixture(), DateTimeOffset.UnixEpoch);
        var missions = JsonNode.Parse(preview.Pack)!["missions"]!.AsArray();

        Assert.Equal(3, missions.Count);
        Assert.Contains(
            missions,
            mission => mission!["status"]!.GetValue<string>() == "fieldTestReady");
        Assert.Contains(
            missions,
            mission => mission!["status"]!.GetValue<string>() == "published");
        Assert.DoesNotContain(
            missions,
            mission => mission!["status"]!.GetValue<string>() == "draft");
    }

    [Fact]
    public void Kortmedier_med_wire_feltet_mediaId_publiceres()
    {
        var snapshot = SnapshotFromFixture();
        var missionDocument = snapshot.Missions[0];
        var mission = missionDocument.Json["mission"]!.AsObject();
        var cardOnlyMedia = snapshot.Media[0];
        var mediaId = cardOnlyMedia.Json["id"]!.GetValue<string>();

        // Mediet refereres kun fra et kort. Wire-navnet begynder med lille m,
        // mens de ældre topfelter hedder fx moodMediaId. En versalfølsom
        // suffikstest publicerede derfor kun det første/toprefererede billede.
        foreach (var property in mission.ToArray())
        {
            if (property.Key.EndsWith("MediaId", StringComparison.OrdinalIgnoreCase))
            {
                mission[property.Key] = null;
            }
        }
        mission["cards"] = new JsonArray(new JsonObject
        {
            ["id"] = "card.kun-medie.1",
            ["order"] = 1,
            ["mediaId"] = mediaId,
            ["text"] = "Kortets billede skal med i den publicerede pakke.",
        });

        var published = PublishedPackBuilder.Build(snapshot, DateTimeOffset.UnixEpoch);
        var root = JsonNode.Parse(published.Pack)!.AsObject();

        Assert.Contains(
            root["media"]!.AsArray(),
            media => media!["id"]!.GetValue<string>() == mediaId);
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
            var mission = node!.AsObject().DeepClone().AsObject();
            mission["status"] = index switch
            {
                0 => "published",
                1 => "publishReady",
                2 => "fieldTestReady",
                _ => "draft",
            };
            var locationId = mission["locationId"]!.GetValue<string>();
            return new AuthoringDocument(
                new JsonObject
                {
                    ["schemaVersion"] = pack["schemaVersion"]!.DeepClone(),
                    ["mission"] = mission,
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
