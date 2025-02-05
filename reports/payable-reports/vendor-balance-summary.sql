| #   | vendor_id | total_invoice_amount | total_payments_made | outstanding_balance | aging_0_30 | aging_31_60 | aging_61_90 | aging_91_plus |
| --- | --------- | --------------------- | -------------------- | ------------------- | ---------- | ----------- | ----------- | ------------- |
| 1   | 1         | 2500.00               | 0.00                 | 2500.00             | 2500.00    | 0           | 0           | 0             |
| 2   | 2         | 3200.00               | 500.00               | 2700.00             | 3200.00    | 0           | 0           | 0             |
| 3   | 3         | 1800.00               | 300.00               | 1500.00             | 1800.00    | 0           | 0           | 0             |
| 4   | 4         | 1250.00               | 0.00                 | 1250.00             | 1250.00    | 0           | 0           | 0             |
| 5   | 5         | 5000.00               | 5000.00              | 0.00                | 3000.00    | -           | -           | -             |

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
-- Define the date parameters dynamically
WITH DateSeries AS (
    -- Step 1: Generate daily dates within the range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
APTransactions AS (
    -- Step 2: Retrieve all accounts payable (AP) transactions within the specified date range
    SELECT
        ap.transaction_id,
        ap.vendor_id,
        ap.invoice_date,
        ap.due_date,
        ap.invoice_amount,
        ap.payment_amount,
        ap.status  -- Invoice status (e.g., 'Paid', 'Unpaid', 'Overdue')
    FROM acc_account_payable ap
    WHERE ap.invoice_date BETWEEN (SELECT MIN(transaction_date) FROM DateSeries) 
                              AND (SELECT MAX(transaction_date) FROM DateSeries)
),
VendorBalances AS (
    -- Step 3 & 4: Group transactions by vendor and calculate outstanding balance
    SELECT
        vendor_id,
        SUM(invoice_amount) AS total_invoice_amount,
        SUM(payment_amount) AS total_payments_made,
        (SUM(invoice_amount) - SUM(payment_amount)) AS outstanding_balance
    FROM APTransactions
    GROUP BY vendor_id
),
Aging AS (
    -- Step 5: Calculate aging buckets for overdue payments
    SELECT
        vendor_id,
        SUM(CASE WHEN CURRENT_DATE - ap.due_date BETWEEN 0 AND 30 THEN ap.invoice_amount ELSE 0 END) AS aging_0_30,
        SUM(CASE WHEN CURRENT_DATE - ap.due_date BETWEEN 31 AND 60 THEN ap.invoice_amount ELSE 0 END) AS aging_31_60,
        SUM(CASE WHEN CURRENT_DATE - ap.due_date BETWEEN 61 AND 90 THEN ap.invoice_amount ELSE 0 END) AS aging_61_90,
        SUM(CASE WHEN CURRENT_DATE - ap.due_date > 90 THEN ap.invoice_amount ELSE 0 END) AS aging_91_plus
    FROM APTransactions ap
    GROUP BY vendor_id
)
-- Step 7: Store and return vendor balance data
SELECT
    vb.vendor_id,
    vb.total_invoice_amount,
    vb.total_payments_made,
    vb.outstanding_balance,
    COALESCE(ag.aging_0_30, 0) AS aging_0_30,
    COALESCE(ag.aging_31_60, 0) AS aging_31_60,
    COALESCE(ag.aging_61_90, 0) AS aging_61_90,
    COALESCE(ag.aging_91_plus, 0) AS aging_91_plus
FROM VendorBalances vb
LEFT JOIN Aging ag ON vb.vendor_id = ag.vendor_id
ORDER BY vb.vendor_id;
