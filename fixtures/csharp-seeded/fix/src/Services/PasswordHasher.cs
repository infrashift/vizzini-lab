using System.Security.Cryptography;
using System.Text;

namespace Shop.Services;

public static class PasswordHasher
{
    private const int Iterations = 600_000;

    public static string Hash(string password)
    {
        var salt = RandomNumberGenerator.GetBytes(16);
        var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, 32);
        return $"{Convert.ToBase64String(salt)}:{Convert.ToBase64String(hash)}";
    }

    public static bool Verify(string password, string stored)
    {
        var parts = stored.Split(':');
        var salt = Convert.FromBase64String(parts[0]);
        var expected = Convert.FromBase64String(parts[1]);
        var actual = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, 32);
        return CryptographicOperations.FixedTimeEquals(actual, expected);
    }

    // Emailed to the user; whoever presents it may set a new password.
    // 256 random bits: unguessable, and unrelated to the address or the date.
    public static string ResetToken(string email)
    {
        ArgumentException.ThrowIfNullOrEmpty(email);
        return Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
    }
}
