| #  | vendor_id | total_payable | aging_category | aging_balance | total_outstanding_payables |
|----|-----------|---------------|----------------|---------------|----------------------------|
| 1  | 1         | 2500.00       | 0-30 Days      | 2500.00       | 9200.00                    |
| 2  | 2         | 2700.00       | 0-30 Days      | 2700.00       | 9200.00                    |
| 3  | 3         | 1500.00       | 0-30 Days      | 1500.00       | 9200.00                    |
| 4  | 4         | 1250.00       | 0-30 Days      | 500.00        | 9200.00                    |
| 5  | 4         | 1250.00       | 91+ Days       | 750.00        | 9200.00                    |

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
WITH DateSeries AS (
    -- Generate daily dates within the range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
PayableTransactions AS (
    -- Step 1: Retrieve all accounts payable transactions within the generated date range
    SELECT
        p.invoice_id,
        p.vendor_id,
        p.invoice_amount,
        p.payment_amount,
        p.invoice_date,
        p.due_date
    FROM acc_account_payable p
    JOIN DateSeries ds ON p.invoice_date = ds.transaction_date
),
PayableBalances AS (
    -- Step 3: Calculate the total outstanding payable balance for each vendor
    SELECT
        p.vendor_id,
        SUM(p.invoice_amount) - SUM(p.payment_amount) AS total_payable,
        COUNT(p.invoice_id) AS total_invoices
    FROM PayableTransactions p
    GROUP BY p.vendor_id
),
InvoiceAging AS (
    -- Step 4: Compute invoice aging
    SELECT
        p.vendor_id,
        p.invoice_id,
        (p.invoice_amount - p.payment_amount) AS outstanding_balance,
        CURRENT_DATE - p.due_date AS days_overdue
    FROM PayableTransactions p
    WHERE p.invoice_amount > p.payment_amount
),
AgingCategories AS (
    -- Step 4: Categorize invoices based on aging
    SELECT
        ia.vendor_id,
        ia.invoice_id,
        ia.outstanding_balance,
        CASE
            WHEN ia.days_overdue BETWEEN 0 AND 30 THEN '0-30 Days'
            WHEN ia.days_overdue BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN ia.days_overdue BETWEEN 61 AND 90 THEN '61-90 Days'
            ELSE '91+ Days'
        END AS aging_category
    FROM InvoiceAging ia
)
-- Step 5: Combine payable balances and aging categories
SELECT
    pb.vendor_id,
    pb.total_payable,
    ac.aging_category,
    SUM(ac.outstanding_balance) AS aging_balance,
    SUM(pb.total_payable) OVER() AS total_outstanding_payables
FROM PayableBalances pb
LEFT JOIN AgingCategories ac ON pb.vendor_id = ac.vendor_id
WHERE pb.total_payable >= 0  -- Step 6: Ensure no negative balances
GROUP BY pb.vendor_id, pb.total_payable, ac.aging_category
ORDER BY pb.vendor_id, ac.aging_category;
