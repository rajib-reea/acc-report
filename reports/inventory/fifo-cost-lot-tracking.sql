| Name | SKU | Received Date | Cost Per Unit | Quantity |
|---|---|---|---|---|
| Product A | SKU001 | 2024-02-01 00:00:00 | 50.00 | 100 |
| Product B | SKU002 | 2024-02-05 00:00:00 | 30.00 | 200 |
| Product C | SKU003 | 2024-02-10 00:00:00 | 40.00 | 150 |
  
SELECT p.name, p.sku, i.received_date, i.cost_per_unit, i.quantity
FROM acc_products p
JOIN acc_inventory i ON p.id = i.product_id
ORDER BY p.sku, i.received_date ASC;
