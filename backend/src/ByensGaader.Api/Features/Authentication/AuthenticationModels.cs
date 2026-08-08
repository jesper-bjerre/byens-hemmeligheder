namespace ByensGaader.Api.Features.Authentication;

internal enum AccountRole
{
    User,
    Designer,
    Admin,
}

internal enum AccountState
{
    Active,
    Blocked,
    Deleted,
}

internal enum NameModerationState
{
    Visible,
    Hidden,
}

internal enum AuthenticationClientKind
{
    IOSPlayer,
    IOSAdmin,
    WebPlayer,
    WebAdmin,
}

internal sealed record Account(
    Guid AccountId,
    string? Email,
    string? PublicName,
    AccountRole Role,
    AccountState State,
    DateTimeOffset CreatedAt,
    DateTimeOffset LastSignedInAt,
    DateTimeOffset? DeletedAt = null,
    string? ETag = null,
    DateTimeOffset? PublicNameChangedAt = null,
    NameModerationState NameModerationState = NameModerationState.Visible,
    string? NameModerationReason = null,
    DateTimeOffset? NameModeratedAt = null,
    string? StateReason = null,
    DateTimeOffset? StateChangedAt = null);

internal sealed record ExternalIdentity(
    string Provider,
    string ProviderSubjectHash,
    Guid AccountId,
    DateTimeOffset CreatedAt,
    DateTimeOffset LastValidatedAt,
    string? EncryptedProviderRefreshToken = null,
    DateTimeOffset? RevokedAt = null,
    string? ETag = null,
    string? ProviderClientId = null);

internal sealed record AuthenticationSession(
    string SessionId,
    Guid AccountId,
    AuthenticationClientKind ClientKind,
    string AccessSecretHash,
    DateTimeOffset AccessExpiresAt,
    string? RefreshSecretHash,
    string? PreviousRefreshHash,
    DateTimeOffset? RefreshExpiresAt,
    DateTimeOffset CreatedAt,
    DateTimeOffset RotatedAt,
    DateTimeOffset? RevokedAt = null,
    string? RevokeReason = null,
    string? ETag = null)
{
    public bool CanAuthenticate(DateTimeOffset now) =>
        RevokedAt is null && AccessExpiresAt > now;
}

internal sealed record OneTimeGrant(
    string GrantHash,
    string Kind,
    string? NonceHash,
    string? PkceChallenge,
    string? ReturnOrigin,
    DateTimeOffset CreatedAt,
    DateTimeOffset ExpiresAt,
    DateTimeOffset? ConsumedAt = null,
    string? ETag = null);

internal sealed record AuthenticatedAccountDto(
    Guid AccountId,
    string? Email,
    string? PublicName,
    string Role,
    string State,
    string NameModerationState);

internal sealed record IssuedSession(
    string AccessToken,
    DateTimeOffset AccessExpiresAt,
    string? RefreshToken,
    DateTimeOffset? RefreshExpiresAt,
    Account Account);
