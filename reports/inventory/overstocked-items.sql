| #  | item_id | item_name | quantity | reorder_level | overstock_status     |
|----|---------|-----------|----------|---------------|----------------------|
| 1  | 4       | Item D    | 320      | 160           | Moderately Overstocked|
| 2  | 2       | Item B    | 320      | 150           | Severely Overstocked  |
| 3  | 5       | Item E    | 300      | 150           | Moderately Overstocked|
| 4  | 7       | Item G    | 240      | 100           | Severely Overstocked  |
| 5  | 3       | Item C    | 180      | 90            | Moderately Overstocked|
| 6  | 1       | Item A    | 165      | 50            | Severely Overstocked  |
| 7  | 8       | Item H    | 150      | 75            | Moderately Overstocked|
| 8  | 10      | Item J    | 130      | 60            | Severely Overstocked  |
| 9  | 9       | Item I    | 110      | 55            | Moderately Overstocked|
| 10 | 6       | Item F    | 80       | 40            | Moderately Overstocked|

Algorithm:

Retrieve all inventory items and their current stock levels.
Compare stock levels against the predefined overstock threshold.
Identify and list items where stock exceeds the threshold.
Return the overstocked items report with product details.

SQL:

WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)

SELECT 
    inv.item_id,
    inv.item_name,
    inv.quantity,
    inv.reorder_level,
    CASE 
        WHEN inv.quantity > inv.reorder_level * 2 THEN 'Severely Overstocked'
        WHEN inv.quantity > inv.reorder_level * 1.5 THEN 'Moderately Overstocked'
        ELSE 'Slightly Overstocked'
    END AS overstock_status
FROM acc_inventory inv
JOIN DateSeries ds ON ds.transaction_date = inv.transaction_date
WHERE inv.quantity > inv.reorder_level * 1.5
ORDER BY inv.quantity DESC;

