| Name | SKU | Received Date | Days in Inventory |
|---|---|---|---|
| Product A | SKU001 | 2024-02-01 00:00:00 | 380 days |
| Product B | SKU002 | 2024-02-05 00:00:00 | 376 days |
| Product C | SKU003 | 2024-02-10 00:00:00 | 371 days |
  
SELECT p.name, p.sku, i.received_date, 
       (CURRENT_DATE - i.received_date) AS days_in_inventory
FROM acc_products p
JOIN acc_inventory i ON p.id = i.product_id
ORDER BY days_in_inventory DESC;
