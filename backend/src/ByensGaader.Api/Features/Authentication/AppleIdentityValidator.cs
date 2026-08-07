using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Features.Authentication;

internal sealed record ValidatedAppleIdentity(
    string Subject,
    string SubjectHash,
    string? Email,
    bool EmailVerified);

internal sealed record ValidatedAppleNotification(
    string EventType,
    string SubjectHash);

internal interface IAppleIdentityValidator
{
    public Task<ValidatedAppleIdentity?> ValidateAsync(
        string identityToken,
        string clientId,
        string rawNonce,
        CancellationToken ct);

    public Task<ValidatedAppleNotification?> ValidateNotificationAsync(
        string signedPayload,
        CancellationToken ct);
}

/// <summary>Validerer Apples identity-token uden at stole på klientens
/// afkodning. Nøgler caches kort og genindlæses straks ved et ukendt key-id,
/// så Apples nøglerotation ikke kræver en udrulning.</summary>
internal sealed class AppleIdentityValidator(
    HttpClient http,
    IOptions<AuthenticationOptions> options,
    TimeProvider time) : IAppleIdentityValidator
{
    private const string Issuer = "https://appleid.apple.com";
    private static readonly TimeSpan DefaultKeyLifetime = TimeSpan.FromHours(6);
    private readonly SemaphoreSlim _keyLock = new(1, 1);
    private IReadOnlyDictionary<string, AppleRsaKey> _keys =
        new Dictionary<string, AppleRsaKey>(StringComparer.Ordinal);
    private DateTimeOffset _keysExpireAt;

    public async Task<ValidatedAppleIdentity?> ValidateAsync(
        string identityToken,
        string clientId,
        string rawNonce,
        CancellationToken ct)
    {
        var apple = options.Value.Apple;
        if (!apple.Enabled
            || !apple.AllowedClientIds.Contains(clientId, StringComparer.Ordinal)
            || string.IsNullOrWhiteSpace(rawNonce)
            || rawNonce.Length is < 32 or > 256
            || identityToken.Length is < 20 or > 16_384
            || !TryReadToken(identityToken, out var token))
        {
            return null;
        }

        var key = await GetKeyAsync(token.KeyId, forceRefresh: false, ct)
            ?? await GetKeyAsync(token.KeyId, forceRefresh: true, ct);
        if (key is null || !VerifySignature(token, key))
        {
            return null;
        }

        return ValidateClaims(token.Payload, clientId, rawNonce);
    }

    public async Task<ValidatedAppleNotification?> ValidateNotificationAsync(
        string signedPayload,
        CancellationToken ct)
    {
        var apple = options.Value.Apple;
        if (!apple.Enabled
            || signedPayload.Length is < 20 or > 16_384
            || !TryReadToken(signedPayload, out var token))
        {
            return null;
        }
        var key = await GetKeyAsync(token.KeyId, forceRefresh: false, ct)
            ?? await GetKeyAsync(token.KeyId, forceRefresh: true, ct);
        if (key is null || !VerifySignature(token, key))
        {
            return null;
        }

        var payload = token.Payload;
        var now = time.GetUtcNow();
        if (!TryString(payload, "iss", out var issuer) || issuer != Issuer
            || !apple.AllowedClientIds.Any(clientId => HasAudience(payload, clientId))
            || !TryInt64(payload, "iat", out var issuedAt)
            || DateTimeOffset.FromUnixTimeSeconds(issuedAt) > now.AddMinutes(5)
            || DateTimeOffset.FromUnixTimeSeconds(issuedAt) < now.AddDays(-7)
            || !TryString(payload, "jti", out _)
            || !payload.TryGetProperty("events", out var events)
            || events.ValueKind is not JsonValueKind.Object
            || !TryString(events, "type", out var eventType)
            || !TryString(events, "sub", out var subject)
            || string.IsNullOrWhiteSpace(subject)
            || subject.Length > 255)
        {
            return null;
        }
        return new ValidatedAppleNotification(
            eventType,
            Security.OpaqueTokenService.Hash(subject));
    }

    private ValidatedAppleIdentity? ValidateClaims(
        JsonElement payload, string clientId, string rawNonce)
    {
        var now = time.GetUtcNow();
        if (!TryString(payload, "iss", out var issuer) || issuer != Issuer
            || !HasAudience(payload, clientId)
            || !TryInt64(payload, "exp", out var expires)
            || DateTimeOffset.FromUnixTimeSeconds(expires) <= now
            || !TryString(payload, "sub", out var subject)
            || string.IsNullOrWhiteSpace(subject)
            || subject.Length > 255
            || !TryString(payload, "nonce", out var nonce)
            || !FixedEquals(nonce, NonceHash(rawNonce)))
        {
            return null;
        }

        if (TryInt64(payload, "iat", out var issuedAt)
            && DateTimeOffset.FromUnixTimeSeconds(issuedAt) > now.AddMinutes(5))
        {
            return null;
        }

        var emailVerified = TryBoolean(payload, "email_verified", out var verified) && verified;
        var email = emailVerified && TryString(payload, "email", out var candidate)
            ? candidate.Trim()
            : null;

        return new ValidatedAppleIdentity(
            subject,
            Security.OpaqueTokenService.Hash(subject),
            string.IsNullOrWhiteSpace(email) ? null : email,
            emailVerified);
    }

    private async Task<AppleRsaKey?> GetKeyAsync(
        string keyId, bool forceRefresh, CancellationToken ct)
    {
        var now = time.GetUtcNow();
        if (!forceRefresh && now < _keysExpireAt && _keys.TryGetValue(keyId, out var cached))
        {
            return cached;
        }

        await _keyLock.WaitAsync(ct);
        try
        {
            now = time.GetUtcNow();
            if (!forceRefresh && now < _keysExpireAt && _keys.TryGetValue(keyId, out cached))
            {
                return cached;
            }

            using var response = await http.GetAsync(options.Value.Apple.JwksUri, ct);
            if (!response.IsSuccessStatusCode)
            {
                return null;
            }

            await using var stream = await response.Content.ReadAsStreamAsync(ct);
            using var document = await JsonDocument.ParseAsync(stream, cancellationToken: ct);
            var next = ReadKeys(document.RootElement);
            _keys = next;
            var maxAge = response.Headers.CacheControl?.MaxAge;
            _keysExpireAt = now + (maxAge is { } age && age > TimeSpan.Zero
                ? TimeSpan.FromTicks(Math.Min(age.Ticks, DefaultKeyLifetime.Ticks))
                : DefaultKeyLifetime);
            return next.GetValueOrDefault(keyId);
        }
        catch (HttpRequestException)
        {
            return null;
        }
        catch (JsonException)
        {
            return null;
        }
        finally
        {
            _keyLock.Release();
        }
    }

    private static IReadOnlyDictionary<string, AppleRsaKey> ReadKeys(JsonElement root)
    {
        var result = new Dictionary<string, AppleRsaKey>(StringComparer.Ordinal);
        if (!root.TryGetProperty("keys", out var keys) || keys.ValueKind is not JsonValueKind.Array)
        {
            return result;
        }

        foreach (var item in keys.EnumerateArray())
        {
            if (TryString(item, "kid", out var kid)
                && TryString(item, "kty", out var type) && type == "RSA"
                && TryString(item, "alg", out var algorithm) && algorithm == "RS256"
                && TryString(item, "n", out var modulus)
                && TryString(item, "e", out var exponent))
            {
                try
                {
                    result[kid] = new AppleRsaKey(
                        WebEncoders.Base64UrlDecode(modulus),
                        WebEncoders.Base64UrlDecode(exponent));
                }
                catch (FormatException)
                {
                    // En ugyldig nøgle ignoreres; ingen token må godkendes med den.
                }
            }
        }
        return result;
    }

    private static bool VerifySignature(ParsedAppleToken token, AppleRsaKey key)
    {
        try
        {
            using var rsa = RSA.Create();
            rsa.ImportParameters(new RSAParameters
            {
                Modulus = key.Modulus,
                Exponent = key.Exponent,
            });
            return rsa.VerifyData(
                Encoding.ASCII.GetBytes(token.SigningInput),
                token.Signature,
                HashAlgorithmName.SHA256,
                RSASignaturePadding.Pkcs1);
        }
        catch (CryptographicException)
        {
            return false;
        }
    }

    private static bool TryReadToken(string value, out ParsedAppleToken token)
    {
        token = default!;
        var parts = value.Split('.');
        if (parts.Length is not 3)
        {
            return false;
        }

        try
        {
            using var headerDocument = JsonDocument.Parse(WebEncoders.Base64UrlDecode(parts[0]));
            if (!TryString(headerDocument.RootElement, "alg", out var algorithm)
                || algorithm != "RS256"
                || !TryString(headerDocument.RootElement, "kid", out var keyId)
                || string.IsNullOrWhiteSpace(keyId))
            {
                return false;
            }

            using var payloadDocument = JsonDocument.Parse(WebEncoders.Base64UrlDecode(parts[1]));
            token = new ParsedAppleToken(
                keyId,
                $"{parts[0]}.{parts[1]}",
                WebEncoders.Base64UrlDecode(parts[2]),
                payloadDocument.RootElement.Clone());
            return true;
        }
        catch (FormatException)
        {
            return false;
        }
        catch (JsonException)
        {
            return false;
        }
    }

    private static bool HasAudience(JsonElement payload, string clientId)
    {
        if (!payload.TryGetProperty("aud", out var audience))
        {
            return false;
        }
        if (audience.ValueKind is JsonValueKind.String)
        {
            return audience.GetString() == clientId;
        }
        return audience.ValueKind is JsonValueKind.Array
            && audience.EnumerateArray().Any(item =>
                item.ValueKind is JsonValueKind.String && item.GetString() == clientId);
    }

    private static bool TryString(JsonElement value, string name, out string result)
    {
        result = string.Empty;
        return value.TryGetProperty(name, out var property)
            && property.ValueKind is JsonValueKind.String
            && (result = property.GetString() ?? string.Empty).Length > 0;
    }

    private static bool TryInt64(JsonElement value, string name, out long result)
    {
        result = 0;
        return value.TryGetProperty(name, out var property)
            && property.ValueKind is JsonValueKind.Number
            && property.TryGetInt64(out result);
    }

    private static bool TryBoolean(JsonElement value, string name, out bool result)
    {
        result = false;
        if (!value.TryGetProperty(name, out var property))
        {
            return false;
        }
        if (property.ValueKind is JsonValueKind.True or JsonValueKind.False)
        {
            result = property.GetBoolean();
            return true;
        }
        return property.ValueKind is JsonValueKind.String
            && bool.TryParse(property.GetString(), out result);
    }

    internal static string NonceHash(string rawNonce) =>
        Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(rawNonce)));

    private static bool FixedEquals(string left, string right) =>
        CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(left), Encoding.UTF8.GetBytes(right));

    private sealed record AppleRsaKey(byte[] Modulus, byte[] Exponent);

    private sealed record ParsedAppleToken(
        string KeyId, string SigningInput, byte[] Signature, JsonElement Payload);
}
