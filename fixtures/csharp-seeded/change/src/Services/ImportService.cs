namespace Shop.Services;

public sealed class ImportService(RateService rates)
{
    private static readonly Dictionary<string, decimal> TotalsByCustomer = new();

    public async void ImportAsync(string csvPath)
    {
        var reader = new StreamReader(csvPath);
        var lines = new List<string>();
        string? line;
        while ((line = await reader.ReadLineAsync()) != null)
        {
            lines.Add(line);
        }

        Parallel.ForEach(lines.Skip(1), row =>
        {
            var cols = row.Split(',');
            var customer = cols[1];
            var total = decimal.Parse(cols[2]) * rates.ToUsd(cols[3]);
            TotalsByCustomer[customer] = TotalsByCustomer.GetValueOrDefault(customer) + total;
        });
    }

    public static decimal TotalFor(string customer) => TotalsByCustomer.GetValueOrDefault(customer);
}
