using System.Collections.Concurrent;

namespace ByensGaader.Api.Features.Authentication;

internal interface IAuthenticationRepository
{
    public Task<Account?> GetAccountAsync(Guid accountId, CancellationToken ct);

    public Task<bool> CreateAccountAsync(Account account, CancellationToken ct);

    public Task<bool> UpdateAccountAsync(Account account, string? expectedETag, CancellationToken ct);

    public Task<IReadOnlyList<Account>> SearchAccountsAsync(
        string query, int limit, CancellationToken ct);

    public Task<ExternalIdentity?> GetIdentityAsync(
        string provider, string providerSubjectHash, CancellationToken ct);

    public Task<bool> CreateIdentityAsync(ExternalIdentity identity, CancellationToken ct);

    public Task<bool> UpdateIdentityAsync(
        ExternalIdentity identity, string? expectedETag, CancellationToken ct);

    public Task<IReadOnlyList<ExternalIdentity>> GetIdentitiesForAccountAsync(
        Guid accountId, CancellationToken ct);

    public Task<bool> DeleteIdentityAsync(
        ExternalIdentity identity, string? expectedETag, CancellationToken ct);

    public Task<bool> TryClaimBootstrapAdminAsync(Guid accountId, CancellationToken ct);

    public Task<AuthenticationSession?> GetSessionAsync(string sessionId, CancellationToken ct);

    public Task<bool> CreateSessionAsync(AuthenticationSession session, CancellationToken ct);

    public Task<bool> UpdateSessionAsync(
        AuthenticationSession session, string? expectedETag, CancellationToken ct);

    public Task<IReadOnlyList<AuthenticationSession>> GetSessionsForAccountAsync(
        Guid accountId, CancellationToken ct);
}

internal sealed class InMemoryAuthenticationRepository : IAuthenticationRepository
{
    private readonly ConcurrentDictionary<Guid, Account> _accounts = new();
    private readonly ConcurrentDictionary<string, ExternalIdentity> _identities =
        new(StringComparer.Ordinal);
    private readonly ConcurrentDictionary<string, AuthenticationSession> _sessions =
        new(StringComparer.Ordinal);
    private readonly object _bootstrapLock = new();
    private Guid? _bootstrapAdminAccountId;

    public Task<Account?> GetAccountAsync(Guid accountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_accounts.GetValueOrDefault(accountId));
    }

    public Task<bool> CreateAccountAsync(Account account, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_accounts.TryAdd(account.AccountId, WithVersion(account)));
    }

    public Task<bool> UpdateAccountAsync(Account account, string? expectedETag, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        if (!_accounts.TryGetValue(account.AccountId, out var current)
            || current.ETag != expectedETag)
        {
            return Task.FromResult(false);
        }

        return Task.FromResult(_accounts.TryUpdate(
            account.AccountId, WithVersion(account), current));
    }

    public Task<IReadOnlyList<Account>> SearchAccountsAsync(
        string query, int limit, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        var normalized = query.Trim();
        IReadOnlyList<Account> result = _accounts.Values
            .Where(account => normalized.Length is 0
                || account.AccountId.ToString("D").Contains(normalized, StringComparison.OrdinalIgnoreCase)
                || (account.Email?.Contains(normalized, StringComparison.OrdinalIgnoreCase) ?? false)
                || (account.PublicName?.Contains(normalized, StringComparison.CurrentCultureIgnoreCase) ?? false))
            .OrderBy(account => account.Email ?? account.PublicName ?? account.AccountId.ToString("D"),
                StringComparer.OrdinalIgnoreCase)
            .Take(limit)
            .ToArray();
        return Task.FromResult(result);
    }

    public Task<ExternalIdentity?> GetIdentityAsync(
        string provider, string providerSubjectHash, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_identities.GetValueOrDefault(IdentityKey(provider, providerSubjectHash)));
    }

    public Task<bool> CreateIdentityAsync(ExternalIdentity identity, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_identities.TryAdd(
            IdentityKey(identity.Provider, identity.ProviderSubjectHash),
            identity with { ETag = NewVersion() }));
    }

    public Task<bool> UpdateIdentityAsync(
        ExternalIdentity identity, string? expectedETag, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        var key = IdentityKey(identity.Provider, identity.ProviderSubjectHash);
        if (!_identities.TryGetValue(key, out var current) || current.ETag != expectedETag)
        {
            return Task.FromResult(false);
        }
        return Task.FromResult(_identities.TryUpdate(
            key, identity with { ETag = NewVersion() }, current));
    }

    public Task<IReadOnlyList<ExternalIdentity>> GetIdentitiesForAccountAsync(
        Guid accountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        IReadOnlyList<ExternalIdentity> result = _identities.Values
            .Where(identity => identity.AccountId == accountId)
            .ToArray();
        return Task.FromResult(result);
    }

    public Task<bool> DeleteIdentityAsync(
        ExternalIdentity identity, string? expectedETag, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        var key = IdentityKey(identity.Provider, identity.ProviderSubjectHash);
        if (!_identities.TryGetValue(key, out var current) || current.ETag != expectedETag)
        {
            return Task.FromResult(false);
        }
        return Task.FromResult(_identities.TryRemove(
            new KeyValuePair<string, ExternalIdentity>(key, current)));
    }

    public Task<bool> TryClaimBootstrapAdminAsync(Guid accountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        lock (_bootstrapLock)
        {
            _bootstrapAdminAccountId ??= accountId;
            return Task.FromResult(_bootstrapAdminAccountId == accountId);
        }
    }

    public Task<AuthenticationSession?> GetSessionAsync(string sessionId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_sessions.GetValueOrDefault(sessionId));
    }

    public Task<bool> CreateSessionAsync(AuthenticationSession session, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        return Task.FromResult(_sessions.TryAdd(session.SessionId, WithVersion(session)));
    }

    public Task<bool> UpdateSessionAsync(
        AuthenticationSession session, string? expectedETag, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        if (!_sessions.TryGetValue(session.SessionId, out var current)
            || current.ETag != expectedETag)
        {
            return Task.FromResult(false);
        }

        return Task.FromResult(_sessions.TryUpdate(
            session.SessionId, WithVersion(session), current));
    }

    public Task<IReadOnlyList<AuthenticationSession>> GetSessionsForAccountAsync(
        Guid accountId, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        IReadOnlyList<AuthenticationSession> sessions = _sessions.Values
            .Where(item => item.AccountId == accountId)
            .ToArray();
        return Task.FromResult(sessions);
    }

    private static string IdentityKey(string provider, string subjectHash) =>
        $"{provider}:{subjectHash}";

    private static Account WithVersion(Account account) => account with { ETag = NewVersion() };

    private static AuthenticationSession WithVersion(AuthenticationSession session) =>
        session with { ETag = NewVersion() };

    private static string NewVersion() => Guid.NewGuid().ToString("N");
}
