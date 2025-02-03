| #  | item_id | days_in_inventory | age_category | quantity |
|----|---------|-------------------|--------------|----------|
| 1  | 1       | 9                 | 0-30 days    | 165      |
| 2  | 2       | 8                 | 0-30 days    | 320      |
| 3  | 3       | 7                 | 0-30 days    | 180      |
| 4  | 4       | 6                 | 0-30 days    | 320      |
| 5  | 5       | 5                 | 0-30 days    | 300      |
| 6  | 6       | 4                 | 0-30 days    | 80       |
| 7  | 7       | 3                 | 0-30 days    | 240      |
| 8  | 8       | 2                 | 0-30 days    | 150      |
| 9  | 9       | 1                 | 0-30 days    | 110      |
| 10 | 10      | 0                 | 0-30 days    | 130      |

Algorithm:

Retrieve all inventory items and their last received dates.
Calculate the age of each inventory item based on the given "As of Date."
Categorize inventory by aging brackets (e.g., 0-30 days, 31-60 days, 61-90 days, 90+ days).
Store and return the stock aging report.

SQL:
    
WITH vars AS (
    SELECT 
        '2025-01-10'::DATE AS asOfDate  -- Define the asOfDate variable here
),
inventory_aging AS (
    SELECT 
        item_id,
        last_received_date,
        quantity,
        -- Calculate the number of days in inventory
        (v.asOfDate - last_received_date) AS days_in_inventory,
        -- Categorize inventory into age buckets
        CASE 
            WHEN (v.asOfDate - last_received_date) BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN (v.asOfDate - last_received_date) BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN (v.asOfDate - last_received_date) BETWEEN 61 AND 90 THEN '61-90 days'
            ELSE '90+ days'
        END AS age_category
    FROM acc_inventory, vars v
    WHERE quantity > 0  -- Only include items with positive quantity
)
SELECT 
    ia.item_id,
    ia.days_in_inventory,
    ia.age_category,
    ia.quantity
FROM inventory_aging ia
ORDER BY ia.days_in_inventory DESC;  -- Sort by oldest items first
