Algorithm:
  
Bills_Breakdown_Report(startDate, endDate):
  1. Retrieve all bills/receivables within the specified date range (startDate to endDate).
  2. Group the bills by vendor.
  3. For each bill, calculate the outstanding balance:
     Outstanding Balance = Total Bill Amount - Payments Made.
  4. Optionally, group the bills by category (e.g., purchase orders, service fees).
  5. Calculate the total value of outstanding bills per vendor and per category.
  6. Validate the bill amounts (ensure no invalid or negative balances).
  7. Store the bill breakdown data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH BillTransactions AS (
    -- Step 1: Retrieve all bills/receivables within the specified date range
    SELECT
        b.bill_id,
        b.vendor_id,
        b.bill_date,
        b.total_bill_amount,
        b.payment_amount,
        b.category_id
    FROM bills b
    WHERE b.bill_date BETWEEN :startDate AND :endDate
),
OutstandingBills AS (
    -- Step 3: Calculate the outstanding balance for each bill
    SELECT
        bt.vendor_id,
        bt.bill_id,
        bt.total_bill_amount - bt.payment_amount AS outstanding_balance,
        bt.category_id
    FROM BillTransactions bt
    WHERE bt.total_bill_amount > bt.payment_amount  -- Only consider bills with outstanding balances
),
BillCategories AS (
    -- Step 4: Optionally group the bills by category (e.g., purchase orders, service fees)
    SELECT
        ob.vendor_id,
        ob.bill_id,
        ob.outstanding_balance,
        ob.category_id,
        CASE
            WHEN ob.category_id = 1 THEN 'Purchase Orders'
            WHEN ob.category_id = 2 THEN 'Service Fees'
            ELSE 'Other'
        END AS category_name
    FROM OutstandingBills ob
)
-- Step 5: Calculate the total value of outstanding bills per vendor and category
SELECT
    bc.vendor_id,
    bc.category_name,
    SUM(bc.outstanding_balance) AS total_outstanding_balance
FROM BillCategories bc
GROUP BY bc.vendor_id, bc.category_name
ORDER BY bc.vendor_id, bc.category_name;
