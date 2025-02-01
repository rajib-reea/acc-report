Algorithm:
  
Receivables_Detailed_Report(startDate, endDate):
  1. Retrieve all receivables transactions within the specified date range (startDate to endDate).
  2. Group the transactions by customer.
  3. For each customer, list all the outstanding invoices and their amounts.
  4. Calculate the aging for each outstanding invoice (0-30 days, 31-60 days, etc.).
  5. Calculate the total balance for each invoice, including aging and any payments made.
  6. Validate the invoice balances (ensure no invalid or negative values).
  7. Store the detailed receivables data for each customer and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH OutstandingInvoices AS (
    -- Step 1: Retrieve all receivables transactions within the specified date range
    SELECT
        ar.customer_id,
        ar.invoice_id,
        ar.total_amount AS invoice_amount,
        ar.due_date,
        ar.total_amount - COALESCE(p.payment_amount, 0) AS outstanding_balance,
        ar.total_amount - COALESCE(p.payment_amount, 0) AS remaining_balance
    FROM accounts_receivable ar
    LEFT JOIN payments p ON ar.invoice_id = p.invoice_id
    WHERE ar.due_date BETWEEN :startDate AND :endDate
    AND ar.total_amount - COALESCE(p.payment_amount, 0) > 0 -- Only include outstanding invoices
),
AgingBreakdown AS (
    -- Step 4: Calculate the aging for each outstanding invoice
    SELECT 
        customer_id,
        invoice_id,
        remaining_balance,
        CASE 
            WHEN CURRENT_DATE - due_date BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN CURRENT_DATE - due_date BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN CURRENT_DATE - due_date BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN CURRENT_DATE - due_date > 90 THEN '91+ days'
            ELSE 'Not Due'
        END AS aging_category
    FROM OutstandingInvoices
),
ReceivablesDetailedReport AS (
    -- Step 3: List all outstanding invoices and their amounts by customer
    SELECT 
        oi.customer_id,
        oi.invoice_id,
        oi.invoice_amount,
        oi.remaining_balance,
        ab.aging_category,
        oi.due_date
    FROM OutstandingInvoices oi
    JOIN AgingBreakdown ab ON oi.invoice_id = ab.invoice_id
)
-- Step 5: Calculate the total balance for each invoice, including aging and any payments made
SELECT 
    r.customer_id,
    r.invoice_id,
    r.invoice_amount,
    r.remaining_balance,
    r.aging_category,
    r.due_date,
    (r.invoice_amount - r.remaining_balance) AS total_paid
FROM ReceivablesDetailedReport r
ORDER BY r.customer_id, r.due_date;
