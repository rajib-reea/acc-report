| customer_id | invoice_id | invoice_amount | remaining_balance | aging_category | due_date   | total_paid |
|-------------|------------|----------------|-------------------|----------------|------------|------------|
| 101         | 1001       | 5000.00        | 3000.00           | 0-30 days      | 2025-01-15 | 2000.00    |
| 101         | 1003       | 4500.00        | 3000.00           | Not Due        | 2025-03-05 | 1500.00    |
| 101         | 1007       | 4000.00        | 3000.00           | Not Due        | 2025-07-15 | 1000.00    |
| 102         | 1002       | 3000.00        | 2000.00           | 0-30 days      | 2025-02-10 | 1000.00    |
| 102         | 1010       | 5000.00        | 5000.00           | Not Due        | 2025-10-15 | 0.00       |
| 103         | 1004       | 2000.00        | 1500.00           | Not Due        | 2025-04-01 | 500.00     |
| 103         | 1008       | 3500.00        | 1500.00           | Not Due        | 2025-08-25 | 2000.00    |
| 104         | 1005       | 6000.00        | 3000.00           | Not Due        | 2025-05-20 | 3000.00    |

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
  WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
OutstandingInvoices AS (
    -- Step 1: Retrieve all receivables transactions within the specified date range
    SELECT
        ar.customer_id,
        ar.invoice_id,
        ar.total_amount AS invoice_amount,
        ar.due_date,
        ar.total_amount - COALESCE(p.payment_amount, 0) AS outstanding_balance,
        ar.total_amount - COALESCE(p.payment_amount, 0) AS remaining_balance
    FROM acc_receivables ar
    LEFT JOIN acc_payments p ON ar.invoice_id = p.invoice_id
    WHERE ar.due_date BETWEEN '2025-01-01' AND '2025-12-31'
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

