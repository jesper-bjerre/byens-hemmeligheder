using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.WebUtilities;

namespace ByensGaader.Api.Security;

internal sealed record OpaqueToken(string Value, string Id, string SecretHash);

internal static class OpaqueTokenService
{
    private const int IdBytes = 18;
    private const int SecretBytes = 32;

    public static OpaqueToken Create()
    {
        var id = WebEncoders.Base64UrlEncode(RandomNumberGenerator.GetBytes(IdBytes));
        return CreateForId(id);
    }

    public static OpaqueToken CreateForId(string id)
    {
        var secret = WebEncoders.Base64UrlEncode(RandomNumberGenerator.GetBytes(SecretBytes));
        return new OpaqueToken($"{id}.{secret}", id, Hash(secret));
    }

    public static bool TryParse(string value, out string id, out string secretHash)
    {
        id = string.Empty;
        secretHash = string.Empty;
        var separator = value.IndexOf('.', StringComparison.Ordinal);
        if (separator <= 0 || separator == value.Length - 1
            || value.IndexOf('.', separator + 1) >= 0)
        {
            return false;
        }

        id = value[..separator];
        secretHash = Hash(value[(separator + 1)..]);
        return id.Length >= 16;
    }

    public static bool Matches(string expectedHash, string actualHash)
    {
        try
        {
            return CryptographicOperations.FixedTimeEquals(
                Convert.FromHexString(expectedHash),
                Convert.FromHexString(actualHash));
        }
        catch (FormatException)
        {
            return false;
        }
    }

    public static string Hash(string value) =>
        Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(value)));
}
