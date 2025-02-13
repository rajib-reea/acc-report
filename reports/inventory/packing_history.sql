| #  | transaction_date | packing_id | order_id | packed_by | packing_date | status |
|----|------------------|------------|----------|-----------|--------------|--------|
| 1  | 2025-01-01       |            |          |           |              |        |
| 2  | 2025-01-02       |            |          |           |              |        |
| 3  | 2025-01-03       |            |          |           |              |        |
| 4  | 2025-01-04       |            |          |           |              |        |
| 5  | 2025-01-05       |            |          |           |              |        |
| 6  | 2025-01-06       |            |          |           |              |        |

-- 6. Packing History
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, p.packing_id, o.order_id, p.packed_by, p.packing_date, p.status
FROM DateSeries d
LEFT JOIN acc_packing p ON d.transaction_date = p.packing_date
LEFT JOIN acc_orders o ON p.order_id = o.order_id
ORDER BY d.transaction_date, p.packing_date DESC;
