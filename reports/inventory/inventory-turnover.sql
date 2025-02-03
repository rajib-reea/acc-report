| #  | item_id | total_cogs | avg_inventory_value | inventory_turnover |
|----|---------|------------|----------------------|--------------------|
| 1  | 1       | 165.00     | 55.00                | 3.00               |
| 2  | 2       | 320.00     | 160.00               | 2.00               |
| 3  | 3       | 180.00     | 90.00                | 2.00               |
| 4  | 4       | 320.00     | 160.00               | 2.00               |
| 5  | 5       | 300.00     | 300.00               | 1.00               |

Algorithm:
  
Retrieve the total cost of goods sold (COGS) within the specified date range.
Retrieve the average inventory value over the same period.
Calculate the inventory turnover ratio:
Inventory Turnover = Total COGS / Average Inventory Value
Store and return the inventory turnover report, categorized by product or supplier if needed.
  
SQL:
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

inventory_movements AS (
    SELECT 
        item_id,
        SUM(CASE WHEN transaction_type = 'sale' THEN quantity * unit_cost ELSE 0 END) AS total_cogs,
        AVG(quantity * unit_cost) AS avg_inventory_value
    FROM acc_inventory_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
    GROUP BY item_id
)

SELECT 
    im.item_id,
    ROUND(im.total_cogs, 2) AS total_cogs,
    ROUND(im.avg_inventory_value, 2) AS avg_inventory_value,
    CASE 
        WHEN im.avg_inventory_value > 0 THEN ROUND(im.total_cogs / im.avg_inventory_value, 2)
        ELSE 0
    END AS inventory_turnover
FROM inventory_movements im;
