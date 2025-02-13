| #  | transaction_date | salesperson_id | name | total_sales |
|----|------------------|----------------|------|-------------|
| 1  | 2025-01-01       |                |      | 0           |
| 2  | 2025-01-02       |                |      | 0           |
| 3  | 2025-01-03       |                |      | 0           |
| 4  | 2025-01-04       |                |      | 0           |
| 5  | 2025-01-05       |                |      | 0           |

-- 5. Sales by Sales Person
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, sp.salesperson_id, sp.name, COALESCE(SUM(s.total_amount), 0) AS total_sales
FROM DateSeries d
LEFT JOIN acc_sales s ON d.transaction_date = s.sale_date
LEFT JOIN acc_salespersons sp ON s.salesperson_id = sp.salesperson_id
GROUP BY d.transaction_date, sp.salesperson_id, sp.name
ORDER BY d.transaction_date, total_sales DESC;
