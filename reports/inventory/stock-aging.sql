Algorithm:

Retrieve all inventory items and their last received dates.
Calculate the age of each inventory item based on the given "As of Date."
Categorize inventory by aging brackets (e.g., 0-30 days, 31-60 days, 61-90 days, 90+ days).
Store and return the stock aging report.

SQL:
SELECT 
    item_id,
    DATEDIFF(:asOfDate, last_received_date) AS days_in_inventory,
    CASE 
        WHEN DATEDIFF(:asOfDate, last_received_date) BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN DATEDIFF(:asOfDate, last_received_date) BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN DATEDIFF(:asOfDate, last_received_date) BETWEEN 61 AND 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS age_category,
    quantity
FROM inventory
WHERE quantity > 0;
