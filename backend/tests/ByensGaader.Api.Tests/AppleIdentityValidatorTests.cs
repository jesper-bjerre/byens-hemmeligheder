using System.Net;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using ByensGaader.Api.Features.Authentication;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AppleIdentityValidatorTests : IDisposable
{
    private const string ClientId = "dk.example.byensgaader";
    private const string Nonce = "en-tilfaeldig-ra-nonce-med-mindst-32-tegn";
    private readonly RSA _key = RSA.Create(2048);
    private readonly DateTimeOffset _now =
        DateTimeOffset.Parse("2026-08-06T12:00:00Z");

    [Fact]
    public async Task Gyldigt_Apple_token_valideres_uden_at_udlevere_subject_til_lageret()
    {
        var handler = new JwksHandler(_ => Jwks("key-1", _key));
        var validator = Validator(handler);

        var result = await validator.ValidateAsync(
            Token(_key, "key-1"), ClientId, Nonce, TestContext.Current.CancellationToken);

        Assert.NotNull(result);
        Assert.Equal("apple-subject-123", result.Subject);
        Assert.Equal(Security.OpaqueTokenService.Hash(result.Subject), result.SubjectHash);
        Assert.Equal("person@example.invalid", result.Email);
        Assert.True(result.EmailVerified);
    }

    [Fact]
    public async Task Forkert_signatur_afvises()
    {
        using var attacker = RSA.Create(2048);
        var validator = Validator(new JwksHandler(_ => Jwks("key-1", _key)));

        var result = await validator.ValidateAsync(
            Token(attacker, "key-1"), ClientId, Nonce,
            TestContext.Current.CancellationToken);

        Assert.Null(result);
    }

    [Theory]
    [InlineData("issuer")]
    [InlineData("audience")]
    [InlineData("expired")]
    [InlineData("nonce")]
    [InlineData("future-issued")]
    public async Task Ugyldige_claims_afvises(string variation)
    {
        var validator = Validator(new JwksHandler(_ => Jwks("key-1", _key)));
        var claims = Claims();
        switch (variation)
        {
            case "issuer": claims["iss"] = "https://angriber.invalid"; break;
            case "audience": claims["aud"] = "en-anden-app"; break;
            case "expired": claims["exp"] = _now.AddSeconds(-1).ToUnixTimeSeconds(); break;
            case "nonce": claims["nonce"] = AppleIdentityValidator.NonceHash("en anden nonce"); break;
            case "future-issued": claims["iat"] = _now.AddMinutes(6).ToUnixTimeSeconds(); break;
        }

        var result = await validator.ValidateAsync(
            Token(_key, "key-1", claims), ClientId, Nonce,
            TestContext.Current.CancellationToken);

        Assert.Null(result);
    }

    [Fact]
    public async Task Ikke_allowlistet_klient_afvises_uden_netvaerkskald()
    {
        var handler = new JwksHandler(_ => Jwks("key-1", _key));
        var validator = Validator(handler);

        var result = await validator.ValidateAsync(
            Token(_key, "key-1"), "ukendt.klient", Nonce,
            TestContext.Current.CancellationToken);

        Assert.Null(result);
        Assert.Equal(0, handler.Calls);
    }

    [Fact]
    public async Task Uverificeret_email_bliver_ikke_gemt_som_verificeret()
    {
        var validator = Validator(new JwksHandler(_ => Jwks("key-1", _key)));
        var claims = Claims();
        claims["email_verified"] = false;

        var result = await validator.ValidateAsync(
            Token(_key, "key-1", claims), ClientId, Nonce,
            TestContext.Current.CancellationToken);

        Assert.NotNull(result);
        Assert.Null(result.Email);
        Assert.False(result.EmailVerified);
    }

    [Fact]
    public async Task Ukendt_key_id_udloeser_en_sikker_noeglerotation()
    {
        using var rotated = RSA.Create(2048);
        var handler = new JwksHandler(call => call == 1
            ? Jwks("old", _key)
            : Jwks("new", rotated));
        var validator = Validator(handler);

        Assert.NotNull(await validator.ValidateAsync(
            Token(_key, "old"), ClientId, Nonce,
            TestContext.Current.CancellationToken));
        Assert.NotNull(await validator.ValidateAsync(
            Token(rotated, "new"), ClientId, Nonce,
            TestContext.Current.CancellationToken));
        Assert.Equal(2, handler.Calls);
    }

    [Fact]
    public async Task Signeret_kontotilbagekaldelse_valideres_og_subject_hashes()
    {
        var validator = Validator(new JwksHandler(_ => Jwks("key-1", _key)));
        var claims = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["iss"] = "https://appleid.apple.com",
            ["aud"] = ClientId,
            ["iat"] = _now.ToUnixTimeSeconds(),
            ["jti"] = "notification-1",
            ["events"] = new Dictionary<string, object?>
            {
                ["type"] = "consent-revoked",
                ["sub"] = "apple-subject-123",
                ["event_time"] = _now.ToUnixTimeSeconds(),
            },
        };

        var result = await validator.ValidateNotificationAsync(
            Token(_key, "key-1", claims), TestContext.Current.CancellationToken);

        Assert.NotNull(result);
        Assert.Equal("consent-revoked", result.EventType);
        Assert.Equal(
            Security.OpaqueTokenService.Hash("apple-subject-123"), result.SubjectHash);
    }

    [Fact]
    public async Task Notifikation_med_forkert_audience_afvises()
    {
        var validator = Validator(new JwksHandler(_ => Jwks("key-1", _key)));
        var claims = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["iss"] = "https://appleid.apple.com",
            ["aud"] = "ukendt.klient",
            ["iat"] = _now.ToUnixTimeSeconds(),
            ["jti"] = "notification-2",
            ["events"] = new Dictionary<string, object?>
            {
                ["type"] = "account-deleted",
                ["sub"] = "apple-subject-123",
            },
        };

        Assert.Null(await validator.ValidateNotificationAsync(
            Token(_key, "key-1", claims), TestContext.Current.CancellationToken));
    }

    public void Dispose() => _key.Dispose();

    private AppleIdentityValidator Validator(JwksHandler handler)
    {
        var settings = new AuthenticationOptions
        {
            Enabled = true,
            Provider = AuthenticationStoreProvider.InMemory,
            Apple = new AppleAuthenticationOptions
            {
                Enabled = true,
                AllowedClientIds = [ClientId],
                JwksUri = "https://apple.test/keys",
            },
        };
        return new AppleIdentityValidator(
            new HttpClient(handler),
            Options.Create(settings),
            new FixedTimeProvider(_now));
    }

    private Dictionary<string, object?> Claims() => new(StringComparer.Ordinal)
    {
        ["iss"] = "https://appleid.apple.com",
        ["aud"] = ClientId,
        ["exp"] = _now.AddMinutes(5).ToUnixTimeSeconds(),
        ["iat"] = _now.ToUnixTimeSeconds(),
        ["sub"] = "apple-subject-123",
        ["nonce"] = AppleIdentityValidator.NonceHash(Nonce),
        ["email"] = "person@example.invalid",
        ["email_verified"] = "true",
    };

    private string Token(
        RSA signingKey,
        string keyId,
        Dictionary<string, object?>? claims = null)
    {
        var header = Encode(JsonSerializer.SerializeToUtf8Bytes(new
        {
            alg = "RS256",
            kid = keyId,
            typ = "JWT",
        }));
        var payload = Encode(JsonSerializer.SerializeToUtf8Bytes(claims ?? Claims()));
        var signingInput = $"{header}.{payload}";
        var signature = signingKey.SignData(
            Encoding.ASCII.GetBytes(signingInput),
            HashAlgorithmName.SHA256,
            RSASignaturePadding.Pkcs1);
        return $"{signingInput}.{Encode(signature)}";
    }

    private static string Jwks(string keyId, RSA key)
    {
        var parameters = key.ExportParameters(includePrivateParameters: false);
        return JsonSerializer.Serialize(new
        {
            keys = new[]
            {
                new
                {
                    kty = "RSA",
                    kid = keyId,
                    use = "sig",
                    alg = "RS256",
                    n = Encode(parameters.Modulus!),
                    e = Encode(parameters.Exponent!),
                },
            },
        });
    }

    private static string Encode(byte[] value) => WebEncoders.Base64UrlEncode(value);

    private sealed class JwksHandler(Func<int, string> response) : HttpMessageHandler
    {
        public int Calls { get; private set; }

        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Calls++;
            var message = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(response(Calls), Encoding.UTF8, "application/json"),
            };
            message.Headers.CacheControl = new CacheControlHeaderValue
            {
                MaxAge = TimeSpan.FromHours(1),
            };
            return Task.FromResult(message);
        }
    }

    private sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => now;
    }
}
