Algorithm:
  
Retrieve the total cost of goods sold (COGS) within the specified date range.
Retrieve the average inventory value over the same period.
Calculate the inventory turnover ratio:
Inventory Turnover = Total COGS / Average Inventory Value
Store and return the inventory turnover report, categorized by product or supplier if needed.
  
SQL:
WITH inventory_movements AS (
    SELECT 
        item_id,
        SUM(CASE WHEN transaction_type = 'sale' THEN quantity * unit_cost ELSE 0 END) AS total_cogs,
        AVG(quantity * unit_cost) AS avg_inventory_value
    FROM inventory_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
    GROUP BY item_id
)
SELECT 
    item_id,
    total_cogs,
    avg_inventory_value,
    CASE 
        WHEN avg_inventory_value > 0 THEN total_cogs / avg_inventory_value
        ELSE 0
    END AS inventory_turnover
FROM inventory_movements;
