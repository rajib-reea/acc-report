| ID | Name | SKU | Total Revenue | Classification |
|---|---|---|---|---|
| 1 | Product B | SKU002 | 700.00 | A |
| 2 | Product A | SKU001 | 700.00 | B |
| 3 | Product C | SKU003 | 675.00 | C |
  
WITH SalesData AS (
    SELECT p.id, p.name, p.sku, SUM(s.quantity_sold * s.selling_price) AS total_revenue
    FROM acc_products p
    JOIN acc_sales s ON p.id = s.product_id
    GROUP BY p.id, p.name, p.sku
),
RankedData AS (
    SELECT *, 
           NTILE(3) OVER (ORDER BY total_revenue DESC) AS abc_class
    FROM SalesData
)
SELECT id, name, sku, total_revenue,
       CASE abc_class 
           WHEN 1 THEN 'A'
           WHEN 2 THEN 'B'
           ELSE 'C'
       END AS classification
FROM RankedData;
