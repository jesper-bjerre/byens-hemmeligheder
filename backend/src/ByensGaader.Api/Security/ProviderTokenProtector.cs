using System.Security.Cryptography;
using System.Text;
using ByensGaader.Api.Features.Authentication;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;

namespace ByensGaader.Api.Security;

internal interface IProviderTokenProtector
{
    public string Protect(string token);

    public string? Unprotect(string protectedToken);
}

/// <summary>Krypterer Apples refresh-token med AES-GCM. Nøglen leveres gennem
/// miljøkonfiguration/Key Vault og findes aldrig i repositoryet.</summary>
internal sealed class ProviderTokenProtector(IOptions<AuthenticationOptions> options)
    : IProviderTokenProtector
{
    private static readonly byte[] Context = Encoding.UTF8.GetBytes("byensgaader:apple-refresh:v1");

    public string Protect(string token)
    {
        var key = Key();
        var nonce = RandomNumberGenerator.GetBytes(12);
        var plaintext = Encoding.UTF8.GetBytes(token);
        var ciphertext = new byte[plaintext.Length];
        var tag = new byte[16];
        using var aes = new AesGcm(key, tag.Length);
        aes.Encrypt(nonce, plaintext, ciphertext, tag, Context);
        return string.Join('.',
            "v1",
            WebEncoders.Base64UrlEncode(nonce),
            WebEncoders.Base64UrlEncode(ciphertext),
            WebEncoders.Base64UrlEncode(tag));
    }

    public string? Unprotect(string protectedToken)
    {
        var parts = protectedToken.Split('.');
        if (parts.Length is not 4 || parts[0] is not "v1")
        {
            return null;
        }

        try
        {
            var nonce = WebEncoders.Base64UrlDecode(parts[1]);
            var ciphertext = WebEncoders.Base64UrlDecode(parts[2]);
            var tag = WebEncoders.Base64UrlDecode(parts[3]);
            var plaintext = new byte[ciphertext.Length];
            using var aes = new AesGcm(Key(), tag.Length);
            aes.Decrypt(nonce, ciphertext, tag, plaintext, Context);
            return Encoding.UTF8.GetString(plaintext);
        }
        catch (FormatException)
        {
            return null;
        }
        catch (CryptographicException)
        {
            return null;
        }
    }

    private byte[] Key()
    {
        var key = Convert.FromBase64String(
            options.Value.Apple.ProviderTokenEncryptionKey);
        if (key.Length is not 32)
        {
            throw new InvalidOperationException(
                "Apple provider-tokennøglen skal være præcis 32 bytes.");
        }
        return key;
    }
}
