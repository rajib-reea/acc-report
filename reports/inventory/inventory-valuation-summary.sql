| Name | SKU | Total Inventory Value |
|---|---|---|
| Product A | SKU001 | 5000.00 |
| Product B | SKU002 | 6000.00 |
| Product C | SKU003 | 6000.00 |
  
SELECT p.name, p.sku, 
       SUM(i.quantity * i.cost_per_unit) AS total_inventory_value
FROM acc_products p
JOIN acc_inventory i ON p.id = i.product_id
GROUP BY p.name, p.sku;
