Algorithm:

Retrieve all inventory items and their current stock levels.
Compare stock levels against the predefined overstock threshold.
Identify and list items where stock exceeds the threshold.
Return the overstocked items report with product details.

SQL:
SELECT 
    item_id,
    item_name,
    quantity,
    reorder_level,
    CASE 
        WHEN quantity > reorder_level * 2 THEN 'Severely Overstocked'
        WHEN quantity > reorder_level * 1.5 THEN 'Moderately Overstocked'
        ELSE 'Slightly Overstocked'
    END AS overstock_status
FROM inventory
WHERE quantity > reorder_level * 1.5
ORDER BY quantity DESC;
