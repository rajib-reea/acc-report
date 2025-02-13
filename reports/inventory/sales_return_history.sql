| #  | transaction_date | return_id | customer_name | item_name | quantity | return_date | reason |
|----|------------------|-----------|---------------|-----------|----------|-------------|--------|
| 1  | 2025-01-01       |           |               |           |          |             |        |
| 2  | 2025-01-02       |           |               |           |          |             |        |
| 3  | 2025-01-03       |           |               |           |          |             |        |
| 4  | 2025-01-04       |           |               |           |          |             |        |
| 5  | 2025-01-05       |           |               |           |          |             |        |

-- 4. Sales Return History
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, sr.return_id, c.name AS customer_name, i.name AS item_name, sr.quantity, sr.return_date, sr.reason
FROM DateSeries d
LEFT JOIN acc_sales_returns sr ON d.transaction_date = sr.return_date
LEFT JOIN acc_customers c ON sr.customer_id = c.customer_id
LEFT JOIN acc_items i ON sr.item_id = i.item_id
ORDER BY d.transaction_date, sr.return_date DESC;
