using ByensGaader.Api.Features.Content;
using ByensGaader.Api.Storage;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AuthoringRepositoryTests
{
    [Fact]
    public async Task Bootstrap_splitter_den_eksisterende_pakke_idempotent()
    {
        var root = Path.Combine(Path.GetTempPath(), $"bh-bootstrap-{Guid.NewGuid():N}");
        var publicRoot = Path.Combine(root, "public");
        var authoringRoot = Path.Combine(root, "authoring");
        Directory.CreateDirectory(Path.Combine(publicRoot, "da-DK"));
        File.Copy(
            Path.Combine(App.FindContentRootForTests(), "da-DK", "content-pack.json"),
            Path.Combine(publicRoot, "da-DK", "content-pack.json"));

        try
        {
            var stores = new ContentStores(Store(publicRoot), Store(authoringRoot));
            var repository = new AuthoringRepository(stores);

            Assert.True(await repository.EnsureBootstrappedAsync(
                "da-DK", TestContext.Current.CancellationToken));
            Assert.False(await repository.EnsureBootstrappedAsync(
                "da-DK", TestContext.Current.CancellationToken));

            var snapshot = await repository.ReadSnapshotAsync(
                "da-DK", TestContext.Current.CancellationToken);
            Assert.Equal(11, snapshot.Missions.Count);
            Assert.Equal(31, snapshot.Media.Count);
            Assert.Equal(6, snapshot.Sources.Count);
            Assert.All(snapshot.Missions, mission => Assert.NotNull(mission.Json["location"]));
        }
        finally
        {
            if (Directory.Exists(root))
            {
                Directory.Delete(root, recursive: true);
            }
        }
    }

    private static IContentStore Store(string root) => new FileSystemContentStore(
        Options.Create(new ContentStoreOptions { RootPath = root }));
}
