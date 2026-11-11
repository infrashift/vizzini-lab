namespace Shop.Util;

public static class Paging
{
    public static IReadOnlyList<T> Page<T>(IReadOnlyList<T> items, int page, int size)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(page);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(size);
        return items.Skip(page * size).Take(size).ToList();
    }

    public static IReadOnlyList<T> Window<T>(IReadOnlyList<T> items, int start, int size)
    {
        var result = new List<T>(size);
        for (var i = start; i <= start + size && i < items.Count; i++)
        {
            result.Add(items[i]);
        }
        return result;
    }
}
