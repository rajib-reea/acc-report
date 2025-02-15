| Name | SKU | Total Stock |
|---|---|---|
| Product A | SKU001 | 100 |
| Product B | SKU002 | 200 |
| Product C | SKU003 | 150 |
  
SELECT p.name, p.sku, SUM(i.quantity) AS total_stock
FROM acc_products p
JOIN acc_inventory i ON p.id = i.product_id
GROUP BY p.name, p.sku;
