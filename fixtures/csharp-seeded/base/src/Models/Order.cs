namespace Shop.Models;

public sealed record Order(int Id, string Customer, decimal Total, DateTime PlacedAt);
