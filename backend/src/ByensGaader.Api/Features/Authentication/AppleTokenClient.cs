using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Features.Authentication;

internal sealed record AppleTokenExchange(string IdentityToken, string RefreshToken);

internal interface IAppleTokenClient
{
    public Task<AppleTokenExchange?> ExchangeCodeAsync(
        string authorizationCode,
        string clientId,
        string? redirectUri,
        CancellationToken ct);

    public Task<bool> RevokeRefreshTokenAsync(
        string refreshToken,
        string clientId,
        CancellationToken ct);
}

/// <summary>Veksler Apples engangskode server-side. Client secret er et
/// kortlivet ES256-JWT, som kun findes i hukommelsen under kaldet.</summary>
internal sealed class AppleTokenClient(
    HttpClient http,
    IOptions<AuthenticationOptions> options,
    TimeProvider time) : IAppleTokenClient
{
    public async Task<AppleTokenExchange?> ExchangeCodeAsync(
        string authorizationCode,
        string clientId,
        string? redirectUri,
        CancellationToken ct)
    {
        var apple = options.Value.Apple;
        if (!apple.Enabled
            || !apple.AllowedClientIds.Contains(clientId, StringComparer.Ordinal)
            || string.IsNullOrWhiteSpace(authorizationCode)
            || authorizationCode.Length > 4096
            || redirectUri?.Length > 2048)
        {
            return null;
        }

        string clientSecret;
        try
        {
            clientSecret = CreateClientSecret(apple, clientId, time.GetUtcNow());
        }
        catch (CryptographicException)
        {
            return null;
        }
        catch (ArgumentException)
        {
            return null;
        }

        var fields = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["client_id"] = clientId,
            ["client_secret"] = clientSecret,
            ["code"] = authorizationCode,
            ["grant_type"] = "authorization_code",
        };
        if (!string.IsNullOrWhiteSpace(redirectUri))
        {
            fields["redirect_uri"] = redirectUri;
        }

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, apple.TokenUri)
            {
                Content = new FormUrlEncodedContent(fields),
            };
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            using var response = await http.SendAsync(request, ct);
            if (!response.IsSuccessStatusCode)
            {
                return null;
            }

            await using var stream = await response.Content.ReadAsStreamAsync(ct);
            using var document = await JsonDocument.ParseAsync(stream, cancellationToken: ct);
            if (!TryString(document.RootElement, "id_token", out var identityToken)
                || !TryString(document.RootElement, "refresh_token", out var refreshToken))
            {
                return null;
            }
            return new AppleTokenExchange(identityToken, refreshToken);
        }
        catch (HttpRequestException)
        {
            return null;
        }
        catch (JsonException)
        {
            return null;
        }
    }

    public async Task<bool> RevokeRefreshTokenAsync(
        string refreshToken,
        string clientId,
        CancellationToken ct)
    {
        var apple = options.Value.Apple;
        if (!apple.Enabled
            || !apple.AllowedClientIds.Contains(clientId, StringComparer.Ordinal)
            || string.IsNullOrWhiteSpace(refreshToken)
            || refreshToken.Length > 16_384)
        {
            return false;
        }

        string clientSecret;
        try
        {
            clientSecret = CreateClientSecret(apple, clientId, time.GetUtcNow());
        }
        catch (CryptographicException)
        {
            return false;
        }
        catch (ArgumentException)
        {
            return false;
        }

        var fields = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["client_id"] = clientId,
            ["client_secret"] = clientSecret,
            ["token"] = refreshToken,
            ["token_type_hint"] = "refresh_token",
        };
        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, apple.RevokeUri)
            {
                Content = new FormUrlEncodedContent(fields),
            };
            using var response = await http.SendAsync(request, ct);
            return response.IsSuccessStatusCode;
        }
        catch (HttpRequestException)
        {
            return false;
        }
    }

    internal static string CreateClientSecret(
        AppleAuthenticationOptions apple, string clientId, DateTimeOffset now)
    {
        var header = Encode(JsonSerializer.SerializeToUtf8Bytes(new
        {
            alg = "ES256",
            kid = apple.KeyId,
            typ = "JWT",
        }));
        var payload = Encode(JsonSerializer.SerializeToUtf8Bytes(new
        {
            iss = apple.TeamId,
            iat = now.ToUnixTimeSeconds(),
            exp = now.AddMinutes(5).ToUnixTimeSeconds(),
            aud = "https://appleid.apple.com",
            sub = clientId,
        }));
        var signingInput = $"{header}.{payload}";

        using var key = ECDsa.Create();
        key.ImportFromPem(apple.PrivateKey);
        var signature = key.SignData(
            Encoding.ASCII.GetBytes(signingInput),
            HashAlgorithmName.SHA256,
            DSASignatureFormat.IeeeP1363FixedFieldConcatenation);
        return $"{signingInput}.{Encode(signature)}";
    }

    private static bool TryString(JsonElement value, string name, out string result)
    {
        result = string.Empty;
        return value.TryGetProperty(name, out var property)
            && property.ValueKind is JsonValueKind.String
            && (result = property.GetString() ?? string.Empty).Length > 0;
    }

    private static string Encode(byte[] value) => WebEncoders.Base64UrlEncode(value);
}
