| #  | Transaction Date | Item ID | Name | Total Quantity | Total Sales |
|----|----------------|---------|------|---------------|-------------|
| 1  | 2025-01-01     |         |      | 0             | 0           |
| 2  | 2025-01-02     |         |      | 0             | 0           |
| 3  | 2025-01-03     |         |      | 0             | 0           |
| 4  | 2025-01-04     |         |      | 0             | 0           |
| 5  | 2025-01-05     |         |      | 0             | 0           |
| 6  | 2025-01-06     |         |      | 0             | 0           |
| 7  | 2025-01-07     |         |      | 0             | 0           |
| 8  | 2025-01-08     |         |      | 0             | 0           |
| 9  | 2025-01-09     |         |      | 0             | 0           |
| 10 | 2025-01-10     |         |      | 0             | 0           |
| 11 | 2025-01-11     |         |      | 0             | 0           |
| 12 | 2025-01-12     |         |      | 0             | 0           |
| 13 | 2025-01-13     |         |      | 0             | 0           |
| 14 | 2025-01-14     |         |      | 0             | 0           |
| 15 | 2025-01-15     |         |      | 0             | 0           |
| 16 | 2025-01-16     |         |      | 0             | 0           |
| 17 | 2025-01-17     |         |      | 0             | 0           |
| 18 | 2025-01-18     |         |      | 0             | 0           |
| 19 | 2025-01-19     |         |      | 0             | 0           |
| 20 | 2025-01-20     |         |      | 0             | 0           |
| 21 | 2025-01-21     |         |      | 0             | 0           |
| 22 | 2025-01-22     |         |      | 0             | 0           |
| 23 | 2025-01-23     |         |      | 0             | 0           |
| 24 | 2025-01-24     |         |      | 0             | 0           |
| 25 | 2025-01-25     |         |      | 0             | 0           |
| 26 | 2025-01-26     |         |      | 0             | 0           |
| 27 | 2025-01-27     |         |      | 0             | 0           |
| 28 | 2025-01-28     |         |      | 0             | 0           |
| 29 | 2025-01-29     |         |      | 0             | 0           |
| 30 | 2025-01-30     |         |      | 0             | 0           |

-- 2. Sales by Item
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, i.item_id, i.name, COALESCE(SUM(oi.quantity), 0) AS total_quantity, COALESCE(SUM(oi.total_price), 0) AS total_sales
FROM DateSeries d
LEFT JOIN acc_sales s ON d.transaction_date = s.sale_date
LEFT JOIN acc_order_items oi ON s.sale_id = oi.sale_id
LEFT JOIN acc_items i ON oi.item_id = i.item_id
GROUP BY d.transaction_date, i.item_id, i.name
ORDER BY d.transaction_date, total_sales DESC;
