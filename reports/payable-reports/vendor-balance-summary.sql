Algorithm:

  Vendor_Balance_Summary_Report(startDate, endDate):
  1. Retrieve all accounts payable (AP) transactions within the specified date range (startDate to endDate).
  2. Group the transactions by vendor.
  3. For each vendor, calculate the total outstanding balance:
     Outstanding Balance = Total Invoice Amount - Payments Made.
  4. Optionally, calculate the aging of payables for each vendor (e.g., 0-30 days, 31-60 days).
  5. Validate the balances (ensure no invalid or negative amounts).
  6. Store the vendor balance data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH APTransactions AS (
    -- Step 1: Retrieve all accounts payable (AP) transactions within the specified date range
    SELECT
        ap.transaction_id,
        ap.vendor_id,
        ap.invoice_date,
        ap.due_date,
        ap.invoice_amount,
        ap.payment_amount,
        ap.status  -- Invoice status (e.g., 'Paid', 'Unpaid', 'Overdue')
    FROM accounts_payable ap
    WHERE ap.invoice_date BETWEEN :startDate AND :endDate
),
VendorBalances AS (
    -- Step 2: Group the transactions by vendor and calculate the total outstanding balance
    SELECT
        vendor_id,
        SUM(invoice_amount) AS total_invoice_amount,
        SUM(payment_amount) AS total_payments_made,
        (SUM(invoice_amount) - SUM(payment_amount)) AS outstanding_balance
    FROM APTransactions
    GROUP BY vendor_id
),
Aging AS (
    -- Step 4: Optionally, calculate the aging of payables for each vendor
    SELECT
        vendor_id,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) BETWEEN 0 AND 30 THEN ap.invoice_amount ELSE 0 END) AS aging_0_30,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) BETWEEN 31 AND 60 THEN ap.invoice_amount ELSE 0 END) AS aging_31_60,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) BETWEEN 61 AND 90 THEN ap.invoice_amount ELSE 0 END) AS aging_61_90,
        SUM(CASE WHEN DATEDIFF(CURRENT_DATE, ap.due_date) > 90 THEN ap.invoice_amount ELSE 0 END) AS aging_91_plus
    FROM APTransactions ap
    GROUP BY vendor_id
)
-- Step 6: Store the vendor balance data and return the results
SELECT
    vb.vendor_id,
    vb.total_invoice_amount,
    vb.total_payments_made,
    vb.outstanding_balance,
    ag.aging_0_30,
    ag.aging_31_60,
    ag.aging_61_90,
    ag.aging_91_plus
FROM VendorBalances vb
LEFT JOIN Aging ag ON vb.vendor_id = ag.vendor_id
ORDER BY vb.vendor_id;
