| #  | Vendor ID | Invoice ID | Outstanding Balance | Days Overdue | Aging Category |
|----|-----------|-----------|---------------------|--------------|---------------|
| 1  | 1         | INV-1001  | 1000.00             | 25           | 0-30 Days     |
| 2  | 1         | INV-1002  | 1500.00             | 20           | 0-30 Days     |
| 3  | 2         | INV-2001  | 1500.00             | 23           | 0-30 Days     |
| 4  | 2         | INV-2002  | 1200.00             | 15           | 0-30 Days     |
| 5  | 3         | INV-3002  | 1500.00             | 10           | 0-30 Days     |
| 6  | 4         | INV-4001  | 500.00              | 5            | 0-30 Days     |
| 7  | 4         | INV-4002  | 750.00              | -1           | Not Due       |

Algorithm:
  
Detailed_AP_Aging_Report(startDate, endDate):
  1. Retrieve all AP transactions within the specified date range (startDate to endDate).
  2. Group the transactions by vendor.
  3. For each vendor, retrieve their outstanding bills/invoices.
  4. Calculate the aging of each outstanding invoice:
     - Group invoices into aging categories (e.g., 0-30 days, 31-60 days, etc.).
  5. Calculate the total balance for each invoice and its respective aging category.
  6. Validate the amounts (ensure no invalid or negative values).
  7. Store the detailed AP aging data and return the results.

SQL:
WITH DateSeries AS (
    -- Generate daily dates within the range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
APTransactions AS (
    -- Step 1: Retrieve all AP transactions within the specified date range
    SELECT
        ap.transaction_id,
        ap.vendor_id,
        ap.invoice_id,
        ap.invoice_date,
        ap.due_date,
        ap.invoice_amount,
        ap.payment_amount
    FROM acc_accounts_payable ap
    JOIN DateSeries ds ON ap.invoice_date = ds.transaction_date
),
InvoiceAging AS (
    -- Step 4: Calculate the aging of each outstanding invoice
    SELECT
        ap.vendor_id,
        ap.invoice_id,
        ap.invoice_amount - ap.payment_amount AS outstanding_balance,
        (CURRENT_DATE - ap.due_date) AS days_overdue -- Use date subtraction for days overdue
    FROM APTransactions ap
    WHERE ap.invoice_amount > ap.payment_amount -- Only consider unpaid or partially paid invoices
),
AgingCategories AS (
    -- Step 5: Group invoices into aging categories (0-30, 31-60, etc.)
    SELECT
        ia.vendor_id,
        ia.invoice_id,
        ia.outstanding_balance,
        ia.days_overdue,
        CASE 
            WHEN ia.days_overdue < 0 THEN 'Not Due'
            WHEN ia.days_overdue BETWEEN 0 AND 30 THEN '0-30 Days'
            WHEN ia.days_overdue BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN ia.days_overdue BETWEEN 61 AND 90 THEN '61-90 Days'
            WHEN ia.days_overdue > 90 THEN '91+ Days'
        END AS aging_category
    FROM InvoiceAging ia
)
-- Step 7: Store the detailed AP aging data and return the results
SELECT
    ac.vendor_id,
    ac.invoice_id,
    ac.outstanding_balance,
    ac.days_overdue,
    ac.aging_category
FROM AgingCategories ac
ORDER BY ac.vendor_id, ac.aging_category, ac.invoice_id;
