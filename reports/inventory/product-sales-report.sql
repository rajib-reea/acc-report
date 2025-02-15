| Name | SKU | Total Sold | Total Revenue |
|---|---|---|---|
| Product A | SKU001 | 10 | 700.00 |
| Product B | SKU002 | 20 | 700.00 |
| Product C | SKU003 | 15 | 675.00 |
  
SELECT p.name, p.sku, SUM(s.quantity_sold) AS total_sold, SUM(s.selling_price * s.quantity_sold) AS total_revenue
FROM acc_products p
JOIN acc_sales s ON p.id = s.product_id
GROUP BY p.name, p.sku;
