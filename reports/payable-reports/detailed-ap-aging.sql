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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH APTransactions AS (
    -- Step 1: Retrieve all AP transactions within the specified date range
    SELECT
        ap.transaction_id,
        ap.vendor_id,
        ap.invoice_id,
        ap.invoice_date,
        ap.due_date,
        ap.invoice_amount,
        ap.payment_amount
    FROM accounts_payable ap
    WHERE ap.invoice_date BETWEEN :startDate AND :endDate
),
InvoiceAging AS (
    -- Step 4: Calculate the aging of each outstanding invoice
    SELECT
        ap.vendor_id,
        ap.invoice_id,
        ap.invoice_amount - ap.payment_amount AS outstanding_balance,
        DATEDIFF(CURRENT_DATE, ap.due_date) AS days_overdue
    FROM APTransactions ap
    WHERE ap.invoice_amount > ap.payment_amount
),
AgingCategories AS (
    -- Step 5: Group invoices into aging categories (0-30, 31-60, etc.)
    SELECT
        ia.vendor_id,
        ia.invoice_id,
        ia.outstanding_balance,
        CASE 
            WHEN ia.days_overdue BETWEEN 0 AND 30 THEN '0-30 Days'
            WHEN ia.days_overdue BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN ia.days_overdue BETWEEN 61 AND 90 THEN '61-90 Days'
            WHEN ia.days_overdue > 90 THEN '91+ Days'
            ELSE 'Not Due'
        END AS aging_category
    FROM InvoiceAging ia
)
-- Step 7: Store the detailed AP aging data and return the results
SELECT
    ac.vendor_id,
    ac.invoice_id,
    ac.outstanding_balance,
    ac.aging_category,
    ac.days_overdue
FROM AgingCategories ac
ORDER BY ac.vendor_id, ac.aging_category, ac.invoice_id;
