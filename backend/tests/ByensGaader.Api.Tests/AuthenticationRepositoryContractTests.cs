using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

/// <summary>De atomiske garantier er en del af repositorykontrakten, ikke kun
/// implementation details. Samme suite skal genbruges ved et senere lagerskift.</summary>
public sealed class AuthenticationRepositoryContractTests
{
    [Fact]
    public async Task Samme_Apple_identitet_faar_praecis_en_ejer()
    {
        var repository = new InMemoryAuthenticationRepository();
        var now = DateTimeOffset.UnixEpoch;
        var hash = OpaqueTokenService.Hash("samme-subject");
        var candidates = Enumerable.Range(0, 12)
            .Select(_ => new ExternalIdentity(
                "apple", hash, Guid.NewGuid(), now, now))
            .ToArray();

        var results = await Task.WhenAll(candidates.Select(candidate =>
            repository.CreateIdentityAsync(candidate, TestContext.Current.CancellationToken)));

        Assert.Single(results, created => created);
        var stored = await repository.GetIdentityAsync(
            "apple", hash, TestContext.Current.CancellationToken);
        Assert.Contains(candidates, candidate => candidate.AccountId == stored?.AccountId);
    }

    [Fact]
    public async Task Bootstrap_admin_kan_kun_claim_es_af_en_konto()
    {
        var repository = new InMemoryAuthenticationRepository();
        var candidates = Enumerable.Range(0, 12).Select(_ => Guid.NewGuid()).ToArray();

        var results = await Task.WhenAll(candidates.Select(accountId =>
            repository.TryClaimBootstrapAdminAsync(
                accountId, TestContext.Current.CancellationToken)));

        Assert.Single(results, claimed => claimed);
        var winner = candidates[Array.IndexOf(results, true)];
        Assert.True(await repository.TryClaimBootstrapAdminAsync(
            winner, TestContext.Current.CancellationToken));
        Assert.False(await repository.TryClaimBootstrapAdminAsync(
            Guid.NewGuid(), TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Samtidig_refreshrotation_udsteder_hoejst_et_nyt_token()
    {
        var repository = new InMemoryAuthenticationRepository();
        var now = DateTimeOffset.Parse("2026-08-07T12:00:00Z");
        var account = new Account(
            Guid.NewGuid(), null, null, AccountRole.User, AccountState.Active, now, now);
        Assert.True(await repository.CreateAccountAsync(
            account, TestContext.Current.CancellationToken));
        account = (await repository.GetAccountAsync(
            account.AccountId, TestContext.Current.CancellationToken))!;
        var sessions = new SessionService(
            repository,
            Options.Create(new AuthenticationOptions
            {
                Enabled = true,
                Provider = AuthenticationStoreProvider.InMemory,
            }),
            new FixedTimeProvider(now));
        var issued = await sessions.IssueNativeAsync(
            account, AuthenticationClientKind.IOSPlayer,
            TestContext.Current.CancellationToken);
        Assert.NotNull(issued?.RefreshToken);

        var rotations = await Task.WhenAll(Enumerable.Range(0, 12).Select(_ =>
            sessions.RefreshNativeAsync(
                issued.RefreshToken!, TestContext.Current.CancellationToken)));

        Assert.InRange(rotations.Count(result => result is not null), 0, 1);
        Assert.True(OpaqueTokenService.TryParse(
            issued.AccessToken, out var sessionId, out _));
        var stored = await repository.GetSessionAsync(
            sessionId,
            TestContext.Current.CancellationToken);
        Assert.NotNull(stored);
        Assert.True(stored.RevokedAt is not null || rotations.SingleOrDefault() is not null);
    }

    private sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => now;
    }
}
