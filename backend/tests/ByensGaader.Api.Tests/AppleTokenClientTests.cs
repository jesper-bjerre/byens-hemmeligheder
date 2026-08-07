using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using ByensGaader.Api.Features.Authentication;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class AppleTokenClientTests : IDisposable
{
    private const string ClientId = "dk.example.byensgaader.admin";
    private readonly ECDsa _key = ECDsa.Create(ECCurve.NamedCurves.nistP256);
    private readonly DateTimeOffset _now =
        DateTimeOffset.Parse("2026-08-06T12:00:00Z");

    [Fact]
    public async Task Koden_sendes_som_formdata_med_et_kortlivet_signeret_client_secret()
    {
        var handler = new AppleHandler(HttpStatusCode.OK,
            """{"id_token":"apple.identity","refresh_token":"apple.refresh"}""");
        var client = Client(handler);

        var result = await client.ExchangeCodeAsync(
            "engangskode", ClientId, null, TestContext.Current.CancellationToken);

        Assert.NotNull(result);
        Assert.Equal("apple.identity", result.IdentityToken);
        Assert.Equal("apple.refresh", result.RefreshToken);
        Assert.NotNull(handler.Form);
        Assert.Equal(ClientId, handler.Form["client_id"]);
        Assert.Equal("engangskode", handler.Form["code"]);
        Assert.Equal("authorization_code", handler.Form["grant_type"]);
        Assert.False(handler.Form.ContainsKey("redirect_uri"));
        AssertClientSecret(handler.Form["client_secret"]);
    }

    [Fact]
    public async Task Redirect_uri_sendes_kun_i_webflowet()
    {
        var handler = new AppleHandler(HttpStatusCode.OK,
            """{"id_token":"id","refresh_token":"refresh"}""");
        var client = Client(handler);

        await client.ExchangeCodeAsync(
            "kode", ClientId, "https://api.example.invalid/apple/callback",
            TestContext.Current.CancellationToken);

        Assert.NotNull(handler.Form);
        Assert.Equal(
            "https://api.example.invalid/apple/callback",
            handler.Form["redirect_uri"]);
    }

    [Theory]
    [InlineData(HttpStatusCode.BadRequest, "{\"error\":\"invalid_grant\"}")]
    [InlineData(HttpStatusCode.OK, "{\"id_token\":\"mangler refresh\"}")]
    [InlineData(HttpStatusCode.OK, "ikke-json")]
    public async Task Apple_fejl_eller_ufuldstaendigt_svar_udsteder_intet(
        HttpStatusCode status, string body)
    {
        var result = await Client(new AppleHandler(status, body)).ExchangeCodeAsync(
            "kode", ClientId, null, TestContext.Current.CancellationToken);

        Assert.Null(result);
    }

    [Fact]
    public async Task Ikke_allowlistet_klient_kalder_ikke_Apple()
    {
        var handler = new AppleHandler(HttpStatusCode.OK,
            """{"id_token":"id","refresh_token":"refresh"}""");

        var result = await Client(handler).ExchangeCodeAsync(
            "kode", "ukendt.klient", null, TestContext.Current.CancellationToken);

        Assert.Null(result);
        Assert.Equal(0, handler.Calls);
    }

    [Fact]
    public async Task Refresh_token_tilbagekaldes_med_korrekt_klient()
    {
        var handler = new AppleHandler(
            HttpStatusCode.OK, string.Empty, "https://apple.test/revoke");
        var client = Client(handler);

        var revoked = await client.RevokeRefreshTokenAsync(
            "apple.refresh", ClientId, TestContext.Current.CancellationToken);

        Assert.True(revoked);
        Assert.NotNull(handler.Form);
        Assert.Equal(ClientId, handler.Form["client_id"]);
        Assert.Equal("apple.refresh", handler.Form["token"]);
        Assert.Equal("refresh_token", handler.Form["token_type_hint"]);
        AssertClientSecret(handler.Form["client_secret"]);
    }

    public void Dispose() => _key.Dispose();

    private AppleTokenClient Client(AppleHandler handler)
    {
        var apple = new AppleAuthenticationOptions
        {
            Enabled = true,
            TeamId = "TEAM123456",
            KeyId = "KEY123456",
            PrivateKey = _key.ExportPkcs8PrivateKeyPem(),
            AllowedClientIds = ["dk.example.byensgaader", ClientId],
            TokenUri = "https://apple.test/token",
            RevokeUri = "https://apple.test/revoke",
        };
        return new AppleTokenClient(
            new HttpClient(handler),
            Options.Create(new AuthenticationOptions
            {
                Enabled = true,
                Provider = AuthenticationStoreProvider.InMemory,
                Apple = apple,
            }),
            new FixedTimeProvider(_now));
    }

    private void AssertClientSecret(string value)
    {
        var parts = value.Split('.');
        Assert.Equal(3, parts.Length);
        using var header = JsonDocument.Parse(WebEncoders.Base64UrlDecode(parts[0]));
        using var payload = JsonDocument.Parse(WebEncoders.Base64UrlDecode(parts[1]));
        Assert.Equal("ES256", header.RootElement.GetProperty("alg").GetString());
        Assert.Equal("KEY123456", header.RootElement.GetProperty("kid").GetString());
        Assert.Equal("TEAM123456", payload.RootElement.GetProperty("iss").GetString());
        Assert.Equal(ClientId, payload.RootElement.GetProperty("sub").GetString());
        Assert.Equal(
            "https://appleid.apple.com",
            payload.RootElement.GetProperty("aud").GetString());
        Assert.Equal(
            _now.AddMinutes(5).ToUnixTimeSeconds(),
            payload.RootElement.GetProperty("exp").GetInt64());

        var signature = WebEncoders.Base64UrlDecode(parts[2]);
        Assert.True(_key.VerifyData(
            Encoding.ASCII.GetBytes($"{parts[0]}.{parts[1]}"),
            signature,
            HashAlgorithmName.SHA256,
            DSASignatureFormat.IeeeP1363FixedFieldConcatenation));
    }

    private sealed class AppleHandler(
        HttpStatusCode status,
        string body,
        string expectedUri = "https://apple.test/token") : HttpMessageHandler
    {
        public int Calls { get; private set; }

        public Dictionary<string, string>? Form { get; private set; }

        protected override async Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Calls++;
            Assert.Equal(HttpMethod.Post, request.Method);
            Assert.Equal(expectedUri, request.RequestUri?.ToString());
            var encoded = await request.Content!.ReadAsStringAsync(cancellationToken);
            Form = encoded.Split('&')
                .Select(item => item.Split('=', 2))
                .ToDictionary(
                    item => Uri.UnescapeDataString(item[0].Replace('+', ' ')),
                    item => Uri.UnescapeDataString(item[1].Replace('+', ' ')),
                    StringComparer.Ordinal);
            return new HttpResponseMessage(status)
            {
                Content = new StringContent(body, Encoding.UTF8, "application/json"),
            };
        }
    }

    private sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => now;
    }
}
