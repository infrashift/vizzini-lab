namespace Shop.Util;

public static class Paging
{
    public static IReadOnlyList<T> Page<T>(IReadOnlyList<T> items, int page, int size)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(page);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(size);
        return items.Skip(page * size).Take(size).ToList();
    }
}
