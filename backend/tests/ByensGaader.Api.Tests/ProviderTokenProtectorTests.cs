using System.Security.Cryptography;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Security;
using Microsoft.Extensions.Options;
using Xunit;

namespace ByensGaader.Api.Tests;

public sealed class ProviderTokenProtectorTests
{
    [Fact]
    public void Apple_refresh_token_krypteres_og_manipulation_afvises()
    {
        var protector = Protector();
        const string raw = "et-provider-refresh-token-som-aldrig-maa-staa-i-lageret";

        var protectedToken = protector.Protect(raw);

        Assert.DoesNotContain(raw, protectedToken, StringComparison.Ordinal);
        Assert.Equal(raw, protector.Unprotect(protectedToken));
        Assert.Null(protector.Unprotect(protectedToken + "ændret"));
    }

    [Fact]
    public void Samme_token_faar_forskellig_ciphertext_hver_gang()
    {
        var protector = Protector();

        Assert.NotEqual(protector.Protect("samme"), protector.Protect("samme"));
    }

    private static ProviderTokenProtector Protector() => new(Options.Create(
        new AuthenticationOptions
        {
            Apple = new AppleAuthenticationOptions
            {
                ProviderTokenEncryptionKey = Convert.ToBase64String(
                    RandomNumberGenerator.GetBytes(32)),
            },
        }));
}
