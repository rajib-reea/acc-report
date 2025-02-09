| item_id | total_purchases | total_quantity |
|---------|------------------|----------------|
| 1       | 610.00           | 58             |
| 2       | 720.00           | 22             |
| 3       | 690.00           | 41             |

Algorithm:
  
Purchases_by_Item_Summary(startDate, endDate):
  1. Retrieve all purchase transactions within the specified date range (startDate to endDate).
  2. Group the purchases by item.
  3. For each item, calculate the total purchase amount:
     Total Purchases = Sum of all purchase amounts for the item.
  4. Optionally, calculate the total quantity purchased for each item.
  5. Validate the purchase amounts and quantities (ensure no invalid or negative values).
  6. Store the item-specific purchase data and return the results.


SQL:
  WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
Purchases AS (
    -- Step 1: Retrieve all purchase transactions within the specified date range
    SELECT
        p.transaction_id,
        p.item_id,
        p.purchase_amount,
        p.quantity,
        p.transaction_date
    FROM acc_purchases p
    WHERE p.transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
),
ItemPurchases AS (
    -- Step 2: Group the purchases by item and calculate the total purchase amount
    SELECT
        p.item_id,
        SUM(p.purchase_amount) AS total_purchases,
        SUM(p.quantity) AS total_quantity
    FROM Purchases p
    GROUP BY p.item_id
)
-- Step 5: Validate the purchase amounts and quantities (ensure no invalid or negative values)
SELECT
    ip.item_id,
    ip.total_purchases,
    ip.total_quantity
FROM ItemPurchases ip
WHERE ip.total_purchases >= 0 -- Ensure no negative purchase amounts
  AND ip.total_quantity >= 0 -- Ensure no negative quantities
ORDER BY ip.item_id;
