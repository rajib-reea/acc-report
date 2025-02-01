Algorithm:
  
AP_Aging_Overview(startDate, endDate):
  1. Retrieve all AP transactions within the specified date range (startDate to endDate).
  2. Group the transactions by vendor.
  3. Calculate the aging of accounts payable for each vendor:
     - Group balances into aging categories (e.g., 0-30 days, 31-60 days, 61-90 days, 91+ days).
  4. Calculate the total amount for each aging category.
  5. Validate the amounts (check for negative or invalid balances).
  6. Store the aging overview data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH APTransactions AS (
    -- Step 1: Retrieve all AP transactions within the specified date range
    SELECT
        ap.transaction_id,
        ap.vendor_id,
        ap.invoice_date,
        ap.due_date,
        ap.invoice_amount,
        ap.payment_amount
    FROM accounts_payable ap
    WHERE ap.invoice_date BETWEEN :startDate AND :endDate
),
AgingCategories AS (
    -- Step 3: Calculate the aging of accounts payable for each vendor
    SELECT
        vendor_id,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) BETWEEN 0 AND 30 THEN ap.invoice_amount ELSE 0 END) AS aging_0_30,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) BETWEEN 31 AND 60 THEN ap.invoice_amount ELSE 0 END) AS aging_31_60,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) BETWEEN 61 AND 90 THEN ap.invoice_amount ELSE 0 END) AS aging_61_90,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) > 90 THEN ap.invoice_amount ELSE 0 END) AS aging_91_plus
    FROM APTransactions ap
    GROUP BY vendor_id
)
-- Step 5: Store the aging overview data and return the results
SELECT
    ag.vendor_id,
    ag.aging_0_30,
    ag.aging_31_60,
    ag.aging_61_90,
    ag.aging_91_plus
FROM AgingCategories ag
ORDER BY ag.vendor_id;
