| #  | customer_id | invoice_id | total_amount | outstanding_balance | aging_category |
|----|-------------|------------|--------------|---------------------|----------------|
| 1  | 101         | 1          | 1500.00      | 1500.00             | 31-60 days     |
| 2  | 101         | 6          | 1800.00      | 1800.00             | Invalid        |
| 3  | 101         | 4          | 2500.00      | 2500.00             | Invalid        |
| 4  | 101         | 9          | 3000.00      | 3000.00             | Invalid        |
| 5  | 102         | 2          | 2000.00      | 2000.00             | 0-30 days      |
| 6  | 102         | 5          | 1200.00      | 1200.00             | Invalid        |
| 7  | 103         | 8          | 2500.00      | 2500.00             | Invalid        |
| 8  | 103         | 3          | 1800.00      | 1800.00             | Invalid        |
| 9  | 104         | 7          | 2200.00      | 2200.00             | Invalid        |
| 10 | 104         | 10         | 1100.00      | 1100.00             | Invalid        |

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

  WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
InvoiceTransactions AS (
    -- Step 1: Retrieve all invoices within the specified date range
    SELECT 
        customer_id,      -- Customer identifier
        invoice_id,       -- Invoice identifier
        invoice_date,     -- Invoice date
        total_amount,     -- Total invoice amount
        (CURRENT_DATE - invoice_date) AS days_outstanding, -- Calculate days outstanding
        payment_amount    -- Payment amount made against the invoice
    FROM acc_invoices
    WHERE invoice_date BETWEEN '2025-01-01' AND '2025-12-31'
),
InvoiceAging AS (
    -- Step 4: Calculate the outstanding balance for each invoice
    SELECT 
        it.customer_id,
        it.invoice_id,
        it.total_amount - COALESCE(SUM(ap.payment_amount), 0) AS outstanding_balance, -- Outstanding balance
        it.total_amount,
        ap.payment_amount,
        it.days_outstanding,
        CASE
            WHEN it.days_outstanding BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN it.days_outstanding BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN it.days_outstanding BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN it.days_outstanding > 90 THEN '91+ days'
            ELSE 'Invalid' -- Catch any unexpected negative days
        END AS aging_category
    FROM InvoiceTransactions it
    LEFT JOIN acc_payments ap ON ap.invoice_id = it.invoice_id
    GROUP BY it.customer_id, it.invoice_id, it.total_amount, ap.payment_amount, it.days_outstanding
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

