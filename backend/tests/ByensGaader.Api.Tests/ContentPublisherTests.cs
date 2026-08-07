using System.Text;
using ByensGaader.Api.Features.Content;
using ByensGaader.Api.Storage;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class ContentPublisherTests
{
    [Fact]
    public async Task En_afbrudt_publicering_forbliver_dirty_og_genoptages()
    {
        var root = Path.Combine(Path.GetTempPath(), $"bh-publish-{Guid.NewGuid():N}");
        var publicRoot = Path.Combine(root, "public");
        var authoringRoot = Path.Combine(root, "authoring");
        Directory.CreateDirectory(Path.Combine(publicRoot, "da-DK"));
        File.Copy(
            Path.Combine(App.FindContentRootForTests(), "da-DK", "content-pack.json"),
            Path.Combine(publicRoot, "da-DK", "content-pack.json"));

        try
        {
            var publicStore = new FailOncePublicStore(Store(publicRoot));
            var stores = new ContentStores(publicStore, Store(authoringRoot));
            var repository = new AuthoringRepository(stores);
            var publisher = new ContentPublisher(
                repository,
                stores,
                TimeProvider.System,
                NullLogger<ContentPublisher>.Instance);
            await publisher.EnsureReadyAsync("da-DK", TestContext.Current.CancellationToken);

            var snapshot = await repository.ReadSnapshotAsync(
                "da-DK", TestContext.Current.CancellationToken);
            var original = snapshot.Missions.First();
            var id = original.Json["mission"]!["id"]!.GetValue<string>();
            var changed = original.Json.DeepClone().AsObject();
            changed["mission"]!["title"] = "Publicering efter udfald";
            changed["mission"]!["status"] = "published";
            publicStore.FailNextStableWrite = true;

            var result = await publisher.ExecuteAsync(
                "da-DK",
                id,
                token => repository.WriteMissionAsync("da-DK", id, changed, original.ETag, token),
                token => repository.ReadMissionAsync("da-DK", id, token),
                TestContext.Current.CancellationToken);

            Assert.Equal(ContentPublication.Pending, result.Publication);
            Assert.True((await repository.ReadStateAsync(
                "da-DK", TestContext.Current.CancellationToken))!.Value.IsDirty);

            var retried = await publisher.PublishPendingAsync(
                "da-DK", TestContext.Current.CancellationToken);
            Assert.Equal(ContentPublication.Published, retried.Status);
            Assert.False((await repository.ReadStateAsync(
                "da-DK", TestContext.Current.CancellationToken))!.Value.IsDirty);
            var pack = await stores.Public.ReadAsync(
                AuthoringPaths.PublicPack("da-DK"), TestContext.Current.CancellationToken);
            Assert.Contains("Publicering efter udfald", Encoding.UTF8.GetString(pack!.Content));
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

    private sealed class FailOncePublicStore(IContentStore inner) : IContentStore
    {
        public bool FailNextStableWrite { get; set; }

        public Task<StoredFile?> ReadAsync(string relativePath, CancellationToken ct) =>
            inner.ReadAsync(relativePath, ct);

        public Task<WriteOutcome> WriteAsync(
            string relativePath, byte[] content, string? expectedETag, CancellationToken ct)
        {
            if (FailNextStableWrite && relativePath.EndsWith("content-pack.json", StringComparison.Ordinal))
            {
                FailNextStableWrite = false;
                return Task.FromResult(WriteOutcome.Rejected);
            }
            return inner.WriteAsync(relativePath, content, expectedETag, ct);
        }

        public Task<WriteOutcome> CreateAsync(
            string relativePath, byte[] content, CancellationToken ct) =>
            inner.CreateAsync(relativePath, content, ct);

        public Task<WriteOutcome> AppendAsync(
            string relativePath, byte[] content, CancellationToken ct) =>
            inner.AppendAsync(relativePath, content, ct);

        public Task<bool> DeleteAsync(string relativePath, CancellationToken ct) =>
            inner.DeleteAsync(relativePath, ct);

        public Task<WriteOutcome> DeleteIfMatchAsync(
            string relativePath, string expectedETag, CancellationToken ct) =>
            inner.DeleteIfMatchAsync(relativePath, expectedETag, ct);

        public Task<IReadOnlyList<string>> ListAsync(
            string relativeDirectory, CancellationToken ct) =>
            inner.ListAsync(relativeDirectory, ct);

        public Task<IContentLease> AcquireLeaseAsync(string relativePath, CancellationToken ct) =>
            inner.AcquireLeaseAsync(relativePath, ct);
    }
}
