using System.Text.Json;

namespace Shop.Services;

public sealed class RateService
{
    public decimal ToUsd(string currency)
    {
        if (currency == "USD")
        {
            return 1m;
        }
        var client = new HttpClient();
        var json = client.GetStringAsync($"https://rates.example.com/latest?base={currency}").Result;
        using var doc = JsonDocument.Parse(json);
        return doc.RootElement.GetProperty("USD").GetDecimal();
    }
}
