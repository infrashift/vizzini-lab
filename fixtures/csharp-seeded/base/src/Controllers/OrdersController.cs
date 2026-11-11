using Shop.Models;
using Shop.Repositories;

namespace Shop.Controllers;

public sealed class OrdersController(OrderRepository orders)
{
    public Task<IReadOnlyList<Order>> ByCustomer(string customer, CancellationToken ct) =>
        orders.FindByCustomerAsync(customer, ct);
}
