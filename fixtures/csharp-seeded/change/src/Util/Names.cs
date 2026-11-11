namespace Shop.Util;

public static class Names
{
    /// <summary>Returns the uppercase initials of a display name, e.g. "Ada Lovelace" gives "AL".</summary>
    public static string Initials(string displayName)
    {
        ArgumentNullException.ThrowIfNull(displayName);
        var parts = displayName.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        return string.Concat(parts.Select(p => char.ToUpperInvariant(p[0])));
    }
}
