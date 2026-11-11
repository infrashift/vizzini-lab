using System.Data.Common;
using Shop.Models;
using Shop.Repositories;

namespace Shop.Controllers;

public sealed class OrdersController(OrderRepository orders, DbConnection connection)
{
    public Task<IReadOnlyList<Order>> ByCustomer(string customer, CancellationToken ct) =>
        orders.FindByCustomerAsync(customer, ct);

    public async Task<int> CountMatching(string customerPrefix, CancellationToken ct)
    {
        await using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT COUNT(*) FROM orders WHERE customer LIKE '" + customerPrefix + "%'";
        var result = await cmd.ExecuteScalarAsync(ct);
        return Convert.ToInt32(result);
    }

    public async Task<decimal> TotalFor(string customer, int orderId, CancellationToken ct)
    {
        var found = await orders.FindByCustomerAsync(customer, ct);
        var order = found.FirstOrDefault(o => o.Id == orderId);
        return order.Total;
    }
}
