using System.Data.Common;
using Shop.Models;

namespace Shop.Repositories;

public sealed class OrderRepository(DbConnection connection)
{
    public async Task<IReadOnlyList<Order>> FindByCustomerAsync(string customer, CancellationToken ct)
    {
        await using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT id, customer, total, placed_at FROM orders WHERE customer = @customer";
        var p = cmd.CreateParameter();
        p.ParameterName = "@customer";
        p.Value = customer;
        cmd.Parameters.Add(p);

        var orders = new List<Order>();
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            orders.Add(new Order(reader.GetInt32(0), reader.GetString(1), reader.GetDecimal(2), reader.GetDateTime(3)));
        }
        return orders;
    }
}
