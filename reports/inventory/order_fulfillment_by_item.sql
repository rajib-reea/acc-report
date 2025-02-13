| #  | transaction_date | item_id | name | total_orders | total_quantity |
|----|------------------|---------|------|--------------|----------------|
| 1  | 2025-01-01       |         |      | 0            | 0              |
| 2  | 2025-01-02       |         |      | 0            | 0              |
| 3  | 2025-01-03       |         |      | 0            | 0              |
| 4  | 2025-01-04       |         |      | 0            | 0              |
| 5  | 2025-01-05       |         |      | 0            | 0              |

-- 3. Order Fulfillment by Item
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, i.item_id, i.name, COALESCE(COUNT(o.order_id), 0) AS total_orders, COALESCE(SUM(oi.quantity), 0) AS total_quantity
FROM DateSeries d
LEFT JOIN acc_orders o ON d.transaction_date = o.order_date AND o.status = 'Fulfilled'
LEFT JOIN acc_order_items oi ON o.order_id = oi.sale_id
LEFT JOIN acc_items i ON oi.item_id = i.item_id
GROUP BY d.transaction_date, i.item_id, i.name
ORDER BY d.transaction_date, total_quantity DESC;
