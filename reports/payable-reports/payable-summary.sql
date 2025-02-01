Algorithm:
  
Payable_Summary_Report(startDate, endDate):
  1. Retrieve all accounts payable transactions within the specified date range (startDate to endDate).
  2. Group the transactions by vendor.
  3. Calculate the total outstanding payable balance for each vendor:
     Total Payable = Total Invoice Amount - Payments Made.
  4. Optionally, calculate the aging of payables for each vendor (e.g., 0-30 days, 31-60 days).
  5. Calculate the overall total outstanding payables across vendors.
  6. Validate the amounts (ensure no invalid or negative balances).
  7. Store the payable summary data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH PayableTransactions AS (
    -- Step 1: Retrieve all accounts payable transactions within the specified date range
    SELECT
        p.invoice_id,
        p.vendor_id,
        p.invoice_amount,
        p.payment_amount,
        p.invoice_date,
        p.due_date
    FROM payables p
    WHERE p.invoice_date BETWEEN :startDate AND :endDate
),
PayableBalances AS (
    -- Step 2: Group the transactions by vendor and calculate the outstanding payable balance
    SELECT
        p.vendor_id,
        SUM(p.invoice_amount) - SUM(p.payment_amount) AS total_payable,
        COUNT(p.invoice_id) AS total_invoices
    FROM PayableTransactions p
    GROUP BY p.vendor_id
),
AgingCategories AS (
    -- Step 4: Calculate the aging of payables (group balances into aging categories)
    SELECT
        p.vendor_id,
        CASE
            WHEN p.due_date <= current_date - INTERVAL '0' DAY THEN '0-30 Days'
            WHEN p.due_date <= current_date - INTERVAL '30' DAY THEN '31-60 Days'
            WHEN p.due_date <= current_date - INTERVAL '60' DAY THEN '61-90 Days'
            ELSE '91+ Days'
        END AS aging_category,
        SUM(p.invoice_amount) - SUM(p.payment_amount) AS aging_balance
    FROM PayableTransactions p
    GROUP BY p.vendor_id, aging_category
)
-- Step 5: Combine payable balances and aging categories
SELECT
    pb.vendor_id,
    pb.total_payable,
    ac.aging_category,
    ac.aging_balance,
    SUM(pb.total_payable) OVER() AS total_outstanding_payables
FROM PayableBalances pb
LEFT JOIN AgingCategories ac ON pb.vendor_id = ac.vendor_id
WHERE pb.total_payable >= 0  -- Step 6: Validate no negative balances
ORDER BY pb.vendor_id, ac.aging_category;
