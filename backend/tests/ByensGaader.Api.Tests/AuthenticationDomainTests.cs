using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AuthenticationDomainTests
{
    [Fact]
    public void Opaque_token_kan_parses_uden_at_gemme_hemmeligheden()
    {
        var token = OpaqueTokenService.Create();

        Assert.True(OpaqueTokenService.TryParse(token.Value, out var id, out var hash));
        Assert.Equal(token.Id, id);
        Assert.Equal(token.SecretHash, hash);
        Assert.DoesNotContain(token.Value, token.SecretHash, StringComparison.Ordinal);
    }

    [Theory]
    [InlineData("")]
    [InlineData("uden-punktum")]
    [InlineData(".hemmelighed")]
    [InlineData("id.")]
    [InlineData("id.for.kort")]
    public void Ugyldige_tokenformater_afvises(string value)
    {
        Assert.False(OpaqueTokenService.TryParse(value, out _, out _));
    }

    [Fact]
    public async Task En_ekstern_identitet_kan_kun_oprettes_en_gang()
    {
        var repository = new InMemoryAuthenticationRepository();
        var identity = new ExternalIdentity(
            "apple", OpaqueTokenService.Hash("subject"), Guid.NewGuid(),
            DateTimeOffset.UnixEpoch, DateTimeOffset.UnixEpoch);

        Assert.True(await repository.CreateIdentityAsync(identity, TestContext.Current.CancellationToken));
        Assert.False(await repository.CreateIdentityAsync(identity, TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task En_forældet_account_etag_kan_ikke_overskrive_en_ny_rolle()
    {
        var repository = new InMemoryAuthenticationRepository();
        var account = AccountAt(AccountRole.User);
        Assert.True(await repository.CreateAccountAsync(account, TestContext.Current.CancellationToken));
        var stored = await repository.GetAccountAsync(
            account.AccountId, TestContext.Current.CancellationToken);

        Assert.NotNull(stored);
        Assert.True(await repository.UpdateAccountAsync(
            stored with { Role = AccountRole.Designer }, stored.ETag,
            TestContext.Current.CancellationToken));
        Assert.False(await repository.UpdateAccountAsync(
            stored with { Role = AccountRole.Admin }, stored.ETag,
            TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Kun_en_aktiv_ikke_udløbet_session_giver_en_konto()
    {
        var repository = new InMemoryAuthenticationRepository();
        var now = DateTimeOffset.Parse("2026-08-06T12:00:00Z");
        var clock = new FixedTimeProvider(now);
        var authenticator = new SessionAuthenticator(repository, clock);
        var account = AccountAt(AccountRole.Designer, now);
        var token = OpaqueTokenService.Create();
        var session = SessionFor(account, token, now.AddMinutes(15));
        await repository.CreateAccountAsync(account, TestContext.Current.CancellationToken);
        await repository.CreateSessionAsync(session, TestContext.Current.CancellationToken);

        var result = await authenticator.AuthenticateAsync(
            token.Value, TestContext.Current.CancellationToken);

        Assert.NotNull(result);
        Assert.Equal(AccountRole.Designer, result.Account.Role);
        Assert.Null(await authenticator.AuthenticateAsync(
            token.Value + "ændret", TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task Blokering_og_udløb_slår_igennem_ved_næste_request()
    {
        var repository = new InMemoryAuthenticationRepository();
        var now = DateTimeOffset.Parse("2026-08-06T12:00:00Z");
        var clock = new FixedTimeProvider(now);
        var authenticator = new SessionAuthenticator(repository, clock);
        var account = AccountAt(AccountRole.User, now);
        var token = OpaqueTokenService.Create();
        await repository.CreateAccountAsync(account, TestContext.Current.CancellationToken);
        await repository.CreateSessionAsync(
            SessionFor(account, token, now.AddMinutes(1)),
            TestContext.Current.CancellationToken);

        clock.Set(now.AddMinutes(2));
        Assert.Null(await authenticator.AuthenticateAsync(
            token.Value, TestContext.Current.CancellationToken));

        var stored = await repository.GetAccountAsync(
            account.AccountId, TestContext.Current.CancellationToken);
        Assert.NotNull(stored);
        Assert.True(await repository.UpdateAccountAsync(
            stored with { State = AccountState.Blocked }, stored.ETag,
            TestContext.Current.CancellationToken));
        var secondToken = OpaqueTokenService.Create();
        await repository.CreateSessionAsync(
            SessionFor(account, secondToken, clock.GetUtcNow().AddMinutes(10)),
            TestContext.Current.CancellationToken);
        Assert.Null(await authenticator.AuthenticateAsync(
            secondToken.Value, TestContext.Current.CancellationToken));
    }

    private static Account AccountAt(
        AccountRole role, DateTimeOffset? now = null) => new(
        Guid.NewGuid(), "test@example.invalid", null, role, AccountState.Active,
        now ?? DateTimeOffset.UnixEpoch, now ?? DateTimeOffset.UnixEpoch);

    private static AuthenticationSession SessionFor(
        Account account, OpaqueToken token, DateTimeOffset accessExpiresAt) => new(
        token.Id,
        account.AccountId,
        AuthenticationClientKind.IOSAdmin,
        token.SecretHash,
        accessExpiresAt,
        null,
        null,
        null,
        account.CreatedAt,
        account.CreatedAt);

    private sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
    {
        private DateTimeOffset _now = now;

        public override DateTimeOffset GetUtcNow() => _now;

        public void Set(DateTimeOffset value) => _now = value;
    }
}
