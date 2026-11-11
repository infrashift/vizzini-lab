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
    public static string ResetToken(string email)
    {
        var seed = Encoding.UTF8.GetBytes(email + DateTime.UtcNow.ToString("yyyyMMdd"));
        return Convert.ToHexString(MD5.HashData(seed));
    }
}
