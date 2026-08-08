using Azure;
using Azure.Data.Tables;

namespace ByensGaader.Api.Features.Authentication;

internal sealed class TableAuthenticationRepository(
    TableServiceClient service,
    AuthenticationOptions options) : IAuthenticationRepository
{
    private const string AccountPartition = "accounts";
    private const string ApplePartition = "apple";
    private const string SystemPartition = "system";
    private const string BootstrapAdminRow = "bootstrap-admin";
    private readonly TableClient _accounts = service.GetTableClient(options.TablePrefix + "Accounts");
    private readonly TableClient _identities = service.GetTableClient(options.TablePrefix + "Identities");
    private readonly TableClient _sessions = service.GetTableClient(options.TablePrefix + "Sessions");
    private readonly SemaphoreSlim _initialisation = new(1, 1);
    private volatile bool _ready;

    public async Task<Account?> GetAccountAsync(Guid accountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        try
        {
            var response = await _accounts.GetEntityAsync<TableEntity>(
                AccountPartition, accountId.ToString("D"), cancellationToken: ct);
            return ToAccount(response.Value);
        }
        catch (RequestFailedException exception) when (exception.Status is 404)
        {
            return null;
        }
    }

    public async Task<bool> CreateAccountAsync(Account account, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        return await TryAddAsync(_accounts, AccountEntity(account), ct);
    }

    public async Task<bool> UpdateAccountAsync(
        Account account, string? expectedETag, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        return await TryReplaceAsync(_accounts, AccountEntity(account), expectedETag, ct);
    }

    public async Task<IReadOnlyList<Account>> SearchAccountsAsync(
        string query, int limit, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var normalized = query.Trim();
        var result = new List<Account>();
        await foreach (var entity in _accounts.QueryAsync<TableEntity>(
                           filter: $"PartitionKey eq '{AccountPartition}'",
                           maxPerPage: 200,
                           cancellationToken: ct))
        {
            var account = ToAccount(entity);
            if (normalized.Length is 0
                || account.AccountId.ToString("D").Contains(normalized, StringComparison.OrdinalIgnoreCase)
                || (account.Email?.Contains(normalized, StringComparison.OrdinalIgnoreCase) ?? false)
                || (account.PublicName?.Contains(normalized, StringComparison.CurrentCultureIgnoreCase) ?? false))
            {
                result.Add(account);
            }
        }
        return result
            .OrderBy(account => account.Email ?? account.PublicName ?? account.AccountId.ToString("D"),
                StringComparer.OrdinalIgnoreCase)
            .Take(limit)
            .ToArray();
    }

    public async Task<ExternalIdentity?> GetIdentityAsync(
        string provider, string providerSubjectHash, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        try
        {
            var response = await _identities.GetEntityAsync<TableEntity>(
                provider, providerSubjectHash, cancellationToken: ct);
            return ToIdentity(response.Value);
        }
        catch (RequestFailedException exception) when (exception.Status is 404)
        {
            return null;
        }
    }

    public async Task<bool> CreateIdentityAsync(ExternalIdentity identity, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        return await TryAddAsync(_identities, IdentityEntity(identity), ct);
    }

    public async Task<bool> UpdateIdentityAsync(
        ExternalIdentity identity, string? expectedETag, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        return await TryReplaceAsync(
            _identities, IdentityEntity(identity), expectedETag, ct);
    }

    public async Task<IReadOnlyList<ExternalIdentity>> GetIdentitiesForAccountAsync(
        Guid accountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var account = accountId.ToString("D");
        var filter = TableClient.CreateQueryFilter($"AccountId eq {account}");
        var result = new List<ExternalIdentity>();
        await foreach (var entity in _identities.QueryAsync<TableEntity>(
                           filter: filter, cancellationToken: ct))
        {
            // Systemmarkører deler tabellen og har ikke en provideridentitet.
            if (entity.PartitionKey is not SystemPartition)
            {
                result.Add(ToIdentity(entity));
            }
        }
        return result;
    }

    public async Task<bool> DeleteIdentityAsync(
        ExternalIdentity identity, string? expectedETag, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        if (string.IsNullOrWhiteSpace(expectedETag)) return false;
        try
        {
            await _identities.DeleteEntityAsync(
                identity.Provider,
                identity.ProviderSubjectHash,
                new ETag(expectedETag),
                ct);
            return true;
        }
        catch (RequestFailedException exception) when (exception.Status is 404 or 412)
        {
            return false;
        }
    }

    public async Task<bool> TryClaimBootstrapAdminAsync(Guid accountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var marker = new TableEntity(SystemPartition, BootstrapAdminRow)
        {
            ["AccountId"] = accountId.ToString("D"),
            ["CreatedAt"] = DateTimeOffset.UtcNow,
        };
        if (await TryAddAsync(_identities, marker, ct))
        {
            return true;
        }

        try
        {
            var current = await _identities.GetEntityAsync<TableEntity>(
                SystemPartition, BootstrapAdminRow, cancellationToken: ct);
            return current.Value.GetString("AccountId") == accountId.ToString("D");
        }
        catch (RequestFailedException exception) when (exception.Status is 404)
        {
            return false;
        }
    }

    public async Task<AuthenticationSession?> GetSessionAsync(
        string sessionId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        try
        {
            var response = await _sessions.GetEntityAsync<TableEntity>(
                SessionPartition(sessionId), sessionId, cancellationToken: ct);
            return ToSession(response.Value);
        }
        catch (RequestFailedException exception) when (exception.Status is 404)
        {
            return null;
        }
    }

    public async Task<bool> CreateSessionAsync(AuthenticationSession session, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        return await TryAddAsync(_sessions, SessionEntity(session), ct);
    }

    public async Task<bool> UpdateSessionAsync(
        AuthenticationSession session, string? expectedETag, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        return await TryReplaceAsync(_sessions, SessionEntity(session), expectedETag, ct);
    }

    public async Task<IReadOnlyList<AuthenticationSession>> GetSessionsForAccountAsync(
        Guid accountId, CancellationToken ct)
    {
        await EnsureReadyAsync(ct);
        var account = accountId.ToString("D");
        var filter = TableClient.CreateQueryFilter($"AccountId eq {account}");
        var result = new List<AuthenticationSession>();
        await foreach (var entity in _sessions.QueryAsync<TableEntity>(
                           filter: filter, cancellationToken: ct))
        {
            result.Add(ToSession(entity));
        }
        return result;
    }

    private async Task EnsureReadyAsync(CancellationToken ct)
    {
        if (_ready)
        {
            return;
        }

        await _initialisation.WaitAsync(ct);
        try
        {
            if (_ready)
            {
                return;
            }
            await _accounts.CreateIfNotExistsAsync(ct);
            await _identities.CreateIfNotExistsAsync(ct);
            await _sessions.CreateIfNotExistsAsync(ct);
            _ready = true;
        }
        finally
        {
            _initialisation.Release();
        }
    }

    private static async Task<bool> TryAddAsync(
        TableClient table, TableEntity entity, CancellationToken ct)
    {
        try
        {
            await table.AddEntityAsync(entity, ct);
            return true;
        }
        catch (RequestFailedException exception) when (exception.Status is 409)
        {
            return false;
        }
    }

    private static async Task<bool> TryReplaceAsync(
        TableClient table, TableEntity entity, string? expectedETag, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(expectedETag))
        {
            return false;
        }

        try
        {
            await table.UpdateEntityAsync(entity, new ETag(expectedETag), TableUpdateMode.Replace, ct);
            return true;
        }
        catch (RequestFailedException exception) when (exception.Status is 404 or 412)
        {
            return false;
        }
    }

    private static TableEntity AccountEntity(Account value) => new(
        AccountPartition, value.AccountId.ToString("D"))
    {
        ["Email"] = value.Email,
        ["PublicName"] = value.PublicName,
        ["Role"] = value.Role.ToString(),
        ["State"] = value.State.ToString(),
        ["CreatedAt"] = value.CreatedAt,
        ["LastSignedInAt"] = value.LastSignedInAt,
        ["DeletedAt"] = value.DeletedAt,
        ["PublicNameChangedAt"] = value.PublicNameChangedAt,
        ["NameModerationState"] = value.NameModerationState.ToString(),
        ["NameModerationReason"] = value.NameModerationReason,
        ["NameModeratedAt"] = value.NameModeratedAt,
        ["StateReason"] = value.StateReason,
        ["StateChangedAt"] = value.StateChangedAt,
    };

    private static Account ToAccount(TableEntity value) => new(
        Guid.Parse(value.RowKey),
        value.GetString("Email"),
        value.GetString("PublicName"),
        Enum.Parse<AccountRole>(value.GetString("Role")!, ignoreCase: false),
        Enum.Parse<AccountState>(value.GetString("State")!, ignoreCase: false),
        value.GetDateTimeOffset("CreatedAt")!.Value,
        value.GetDateTimeOffset("LastSignedInAt")!.Value,
        value.GetDateTimeOffset("DeletedAt"),
        value.ETag.ToString(),
        value.GetDateTimeOffset("PublicNameChangedAt"),
        Enum.TryParse<NameModerationState>(
            value.GetString("NameModerationState"), out var moderationState)
            ? moderationState
            : NameModerationState.Visible,
        value.GetString("NameModerationReason"),
        value.GetDateTimeOffset("NameModeratedAt"),
        value.GetString("StateReason"),
        value.GetDateTimeOffset("StateChangedAt"));

    private static TableEntity IdentityEntity(ExternalIdentity value) => new(
        value.Provider, value.ProviderSubjectHash)
    {
        ["AccountId"] = value.AccountId.ToString("D"),
        ["CreatedAt"] = value.CreatedAt,
        ["LastValidatedAt"] = value.LastValidatedAt,
        ["EncryptedProviderRefreshToken"] = value.EncryptedProviderRefreshToken,
        ["ProviderClientId"] = value.ProviderClientId,
        ["RevokedAt"] = value.RevokedAt,
    };

    private static ExternalIdentity ToIdentity(TableEntity value) => new(
        value.PartitionKey,
        value.RowKey,
        Guid.Parse(value.GetString("AccountId")!),
        value.GetDateTimeOffset("CreatedAt")!.Value,
        value.GetDateTimeOffset("LastValidatedAt")!.Value,
        value.GetString("EncryptedProviderRefreshToken"),
        value.GetDateTimeOffset("RevokedAt"),
        value.ETag.ToString(),
        value.GetString("ProviderClientId"));

    private static TableEntity SessionEntity(AuthenticationSession value) => new(
        SessionPartition(value.SessionId), value.SessionId)
    {
        ["AccountId"] = value.AccountId.ToString("D"),
        ["ClientKind"] = value.ClientKind.ToString(),
        ["AccessSecretHash"] = value.AccessSecretHash,
        ["AccessExpiresAt"] = value.AccessExpiresAt,
        ["RefreshSecretHash"] = value.RefreshSecretHash,
        ["PreviousRefreshHash"] = value.PreviousRefreshHash,
        ["RefreshExpiresAt"] = value.RefreshExpiresAt,
        ["CreatedAt"] = value.CreatedAt,
        ["RotatedAt"] = value.RotatedAt,
        ["RevokedAt"] = value.RevokedAt,
        ["RevokeReason"] = value.RevokeReason,
    };

    private static AuthenticationSession ToSession(TableEntity value) => new(
        value.RowKey,
        Guid.Parse(value.GetString("AccountId")!),
        Enum.Parse<AuthenticationClientKind>(value.GetString("ClientKind")!, ignoreCase: false),
        value.GetString("AccessSecretHash")!,
        value.GetDateTimeOffset("AccessExpiresAt")!.Value,
        value.GetString("RefreshSecretHash"),
        value.GetString("PreviousRefreshHash"),
        value.GetDateTimeOffset("RefreshExpiresAt"),
        value.GetDateTimeOffset("CreatedAt")!.Value,
        value.GetDateTimeOffset("RotatedAt")!.Value,
        value.GetDateTimeOffset("RevokedAt"),
        value.GetString("RevokeReason"),
        value.ETag.ToString());

    private static string SessionPartition(string sessionId) => sessionId[..2];
}
