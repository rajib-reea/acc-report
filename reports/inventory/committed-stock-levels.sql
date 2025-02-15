| Name | SKU | Committed Stock | Expected Delivery |
|---|---|---|---|
| Product A | SKU001 | 50 | 2024-02-15 00:00:00 |
| Product B | SKU002 | 75 | 2024-02-18 00:00:00 |
  
SELECT p.name, p.sku, po.quantity_ordered AS committed_stock, po.expected_delivery
FROM acc_products p
JOIN acc_purchase_orders po ON p.id = po.product_id;
