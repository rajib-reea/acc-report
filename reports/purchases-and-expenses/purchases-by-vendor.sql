Algorithm:
  
Purchases_by_Vendor_Report(startDate, endDate):
  1. Retrieve all purchase transactions within the specified date range (startDate to endDate).
  2. Group the purchases by vendor.
  3. For each vendor, calculate the total purchase amount:
     Total Purchases = Sum of all purchase amounts for the vendor.
  4. Optionally, calculate the number of transactions or items purchased from each vendor.
  5. Validate the purchase amounts (ensure no invalid or negative values).
  6. Store the vendor-specific purchase data and return the results.

SQL:  
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH Purchases AS (
    -- Step 1: Retrieve all purchase transactions within the specified date range
    SELECT
        p.transaction_id,
        p.vendor_id,
        p.purchase_amount,
        p.transaction_date,
        p.item_count
    FROM purchases p
    WHERE p.transaction_date BETWEEN :startDate AND :endDate
),
VendorPurchases AS (
    -- Step 2: Group the purchases by vendor and calculate the total purchase amount
    SELECT
        p.vendor_id,
        SUM(p.purchase_amount) AS total_purchases,
        SUM(p.item_count) AS total_items_purchased,
        COUNT(p.transaction_id) AS total_transactions
    FROM Purchases p
    GROUP BY p.vendor_id
)
-- Step 5: Validate the purchase amounts (ensure no invalid or negative values)
SELECT
    vp.vendor_id,
    vp.total_purchases,
    vp.total_items_purchased,
    vp.total_transactions
FROM VendorPurchases vp
WHERE vp.total_purchases >= 0 -- Ensure no negative purchase amounts
ORDER BY vp.vendor_id;
