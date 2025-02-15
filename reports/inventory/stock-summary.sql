| Name | SKU | Available Stock | On Order Stock |
|---|---|---|---|
| Product B | SKU002 | 200 | 75 |
| Product C | SKU003 | 150 | 0 |
| Product A | SKU001 | 100 | 50 |
  
SELECT 
    p.name, 
    p.sku, 
    SUM(i.quantity) AS available_stock, 
    (SELECT COALESCE(SUM(po.quantity_ordered), 0) 
     FROM acc_purchase_orders po 
     WHERE po.product_id = p.id) AS on_order_stock
FROM 
    acc_products p
LEFT JOIN 
    acc_inventory i ON p.id = i.product_id
GROUP BY 
    p.id, p.name, p.sku;
