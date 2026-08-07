namespace ByensGaader.Api.Features.Authentication;

internal sealed class AuthenticationOptions
{
    public const string Section = "Authentication";

    public bool Enabled { get; init; }

    public AuthenticationStoreProvider Provider { get; init; } = AuthenticationStoreProvider.Disabled;

    public string? TableServiceUri { get; init; }

    public string TablePrefix { get; init; } = "Bh";

    public int AccessMinutes { get; init; } = 15;

    public int NativeRefreshDays { get; init; } = 30;

    public int WebAccessMinutes { get; init; } = 30;

    public AppleAuthenticationOptions Apple { get; init; } = new();

    public void ValidateForStartup(IHostEnvironment environment)
    {
        if (!Enabled)
        {
            return;
        }

        if (Provider is AuthenticationStoreProvider.Disabled)
        {
            throw new InvalidOperationException(
                "Authentication er slået til, men Authentication:Provider er Disabled.");
        }

        if (Provider is AuthenticationStoreProvider.InMemory && !environment.IsDevelopment())
        {
            throw new InvalidOperationException(
                "InMemory authentication må kun bruges i Development og tests.");
        }

        if (Provider is AuthenticationStoreProvider.Table
            && !Uri.TryCreate(TableServiceUri, UriKind.Absolute, out _))
        {
            throw new InvalidOperationException(
                "Authentication:TableServiceUri skal være en absolut HTTPS-adresse.");
        }

        if (AccessMinutes is < 1 or > 30 || WebAccessMinutes is < 1 or > 30)
        {
            throw new InvalidOperationException("Access-sessioner skal leve mellem 1 og 30 minutter.");
        }

        if (NativeRefreshDays is < 1 or > 30)
        {
            throw new InvalidOperationException("Native refresh-sessioner må højst leve 30 dage.");
        }

        Apple.ValidateForStartup();
    }
}

internal sealed class AppleAuthenticationOptions
{
    public bool Enabled { get; init; }

    public string TeamId { get; init; } = string.Empty;

    public string KeyId { get; init; } = string.Empty;

    public string PrivateKey { get; init; } = string.Empty;

    public string ProviderTokenEncryptionKey { get; init; } = string.Empty;

    public string BootstrapAdminEmail { get; init; } = string.Empty;

    public string[] AllowedClientIds { get; init; } = [];

    public string[] AllowedWebRedirectUris { get; init; } = [];

    public string JwksUri { get; init; } = "https://appleid.apple.com/auth/keys";

    public string TokenUri { get; init; } = "https://appleid.apple.com/auth/token";

    public string RevokeUri { get; init; } = "https://appleid.apple.com/auth/revoke";

    public void ValidateForStartup()
    {
        if (!Enabled)
        {
            return;
        }

        if (AllowedClientIds.Length is 0
            || AllowedClientIds.Any(string.IsNullOrWhiteSpace))
        {
            throw new InvalidOperationException(
                "Authentication:Apple:AllowedClientIds skal indeholde mindst én klient.");
        }

        if (string.IsNullOrWhiteSpace(TeamId)
            || string.IsNullOrWhiteSpace(KeyId)
            || string.IsNullOrWhiteSpace(PrivateKey)
            || !HasValidEncryptionKey(ProviderTokenEncryptionKey))
        {
            throw new InvalidOperationException(
                "Apple-login er slået til, men TeamId, KeyId, PrivateKey eller en "
                + "32-byte ProviderTokenEncryptionKey mangler.");
        }

        ValidateHttps(JwksUri, "JwksUri");
        ValidateHttps(TokenUri, "TokenUri");
        ValidateHttps(RevokeUri, "RevokeUri");
    }

    private static bool HasValidEncryptionKey(string value)
    {
        try
        {
            return Convert.FromBase64String(value).Length is 32;
        }
        catch (FormatException)
        {
            return false;
        }
    }

    private static void ValidateHttps(string value, string name)
    {
        if (!Uri.TryCreate(value, UriKind.Absolute, out var uri)
            || uri.Scheme is not "https")
        {
            throw new InvalidOperationException(
                $"Authentication:Apple:{name} skal være en absolut HTTPS-adresse.");
        }
    }
}

internal enum AuthenticationStoreProvider
{
    Disabled,
    InMemory,
    Table,
}
