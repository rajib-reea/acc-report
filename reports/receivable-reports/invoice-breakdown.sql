Algorithm
  Invoice_Breakdown_Report(startDate, endDate):
  1. Retrieve all invoices within the specified date range (startDate to endDate).
  2. Group the invoices by customer.
  3. For each customer, list all their invoices.
  4. For each invoice, calculate the outstanding balance:
     Outstanding Balance = Total Invoice Amount - Payments Made.
  5. Calculate the aging of each invoice (e.g., 0-30 days, 31-60 days, etc.).
  6. Validate the amounts (ensure no invalid or negative balances).
  7. Store the invoice breakdown data by customer and return the results.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH InvoiceTransactions AS (
    -- Step 1: Retrieve all invoices within the specified date range
    SELECT 
        customer_id,      -- Replace with the appropriate column for customer identification
        invoice_id,       -- Invoice identifier
        invoice_date,     -- Invoice date
        total_amount,     -- Total invoice amount
        (CURRENT_DATE - invoice_date) AS days_outstanding, -- Calculate days outstanding
        payment_amount    -- Payment amount made against the invoice
    FROM invoices
    WHERE invoice_date BETWEEN :startDate AND :endDate
),
InvoiceAging AS (
    -- Step 4: Calculate the outstanding balance for each invoice
    SELECT 
        customer_id,
        invoice_id,
        total_amount - COALESCE(SUM(payment_amount), 0) AS outstanding_balance, -- Outstanding balance
        total_amount,
        payment_amount,
        days_outstanding,
        CASE
            WHEN days_outstanding BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN days_outstanding BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN days_outstanding BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN days_outstanding > 90 THEN '91+ days'
            ELSE 'Invalid' -- Catch any unexpected negative days
        END AS aging_category
    FROM InvoiceTransactions
    LEFT JOIN payments ON payments.invoice_id = InvoiceTransactions.invoice_id
    GROUP BY customer_id, invoice_id, total_amount, payment_amount, days_outstanding
),
ValidatedInvoiceAging AS (
    -- Step 6: Validate the amounts (ensure no invalid or negative balances)
    SELECT 
        customer_id,
        invoice_id,
        outstanding_balance,
        total_amount,
        aging_category
    FROM InvoiceAging
    WHERE outstanding_balance >= 0  -- Ensure no negative balances
)
-- Step 7: Store the invoice breakdown data by customer and return the results
SELECT 
    customer_id,
    invoice_id,
    total_amount,
    outstanding_balance,
    aging_category
FROM ValidatedInvoiceAging
ORDER BY customer_id, aging_category,
         CASE 
             WHEN aging_category = '0-30 days' THEN 1
             WHEN aging_category = '31-60 days' THEN 2
             WHEN aging_category = '61-90 days' THEN 3
             WHEN aging_category = '91+ days' THEN 4
             ELSE 5 -- Handling 'Invalid' category if any
         END;
