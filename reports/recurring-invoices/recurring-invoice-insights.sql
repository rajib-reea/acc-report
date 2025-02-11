| customer_id | total_invoices | total_billed_amount | total_outstanding_balance | overdue_invoices | overdue_balance | average_amount_per_invoice | trend_month | monthly_invoices |
|-------------|----------------|---------------------|---------------------------|------------------|-----------------|----------------------------|-------------|------------------|
| 101         | 3              | 13500.00            | 10500.00                  |                  | 4500.00         | 1                          | 1           | 1                |
| 101         | 3              | 13500.00            | 10500.00                  |                  | 4500.00         | 3                          | 1           | 1                |
| 101         | 3              | 13500.00            | 10500.00                  |                  | 4500.00         | 7                          | 1           | 1                |
| 102         | 2              | 8000.00             | 7000.00                   |                  | 4000.00         | 2                          | 1           | 1                |
| 102         | 2              | 8000.00             | 7000.00                   |                  | 4000.00         | 10                         | 1           | 1                |
| 103         | 2              | 5500.00             | 3000.00                   |                  | 2750.00         | 4                          | 1           | 1                |
| 103         | 2              | 5500.00             | 3000.00                   |                  | 2750.00         | 8                          | 1           | 1                |
| 104         | 1              | 6000.00             | 3000.00                   |                  | 6000.00         | 5                          | 1           | 1                |

Algorithm:

  Recurring_Invoice_Insights(startDate, endDate):
  1. Retrieve all recurring invoice transactions within the specified date range (startDate to endDate).
  2. Group the recurring invoices by customer.
  3. For each customer, retrieve all recurring invoices issued within the date range.
  4. For each recurring invoice, calculate the total billed amount:
     Total Billed = Sum of all recurring invoice amounts for the period.
  5. Calculate the total number of invoices generated for each customer in the specified period.
  6. Calculate the total amount billed and outstanding for each customer (if applicable).
  7. Optionally, analyze trends in the frequency of recurring invoices (e.g., monthly, quarterly).
  8. Calculate the average amount per recurring invoice for each customer:
     Average Amount = Total Billed / Number of Invoices.
  9. Identify any overdue or unpaid recurring invoices and their outstanding balances.
  10. Optionally, calculate the overall total of all recurring invoices across customers for the specified date range.
  11. Validate the invoice amounts (ensure no invalid or negative values).
  12. Store the insights data (billed amount, number of invoices, outstanding balances, etc.) and return the results.

SQL:
  WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
RecurringInvoices AS (
    -- Step 1: Retrieve all recurring invoice transactions within the specified date range
    SELECT
        ri.invoice_id,
        ri.customer_id,
        ri.invoice_date,
        ri.due_date,
        ri.amount AS billed_amount,
        ri.status,  -- Invoice status (e.g., 'Paid', 'Unpaid', 'Overdue')
        ri.outstanding_balance
    FROM acc_recurring_invoices ri
    WHERE ri.invoice_date BETWEEN '2025-01-01' AND '2025-12-31'
),
CustomerInvoices AS (
    -- Step 2: Group the recurring invoices by customer and calculate total billed amount
    SELECT
        customer_id,
        COUNT(invoice_id) AS total_invoices,
        SUM(billed_amount) AS total_billed_amount,
        SUM(outstanding_balance) AS total_outstanding_balance
    FROM RecurringInvoices
    GROUP BY customer_id
),
OverdueInvoices AS (
    -- Step 9: Identify overdue invoices and their outstanding balances
    SELECT
        customer_id,
        COUNT(invoice_id) AS overdue_invoices,
        SUM(outstanding_balance) AS overdue_balance
    FROM RecurringInvoices
    WHERE status = 'Overdue'
    GROUP BY customer_id
),
Trends AS (
    -- Step 7: Analyze trends in the frequency of recurring invoices (e.g., monthly, quarterly)
    SELECT
        customer_id,
        EXTRACT(MONTH FROM invoice_date) AS month,
        COUNT(invoice_id) AS monthly_invoices
    FROM RecurringInvoices
    GROUP BY customer_id, month
),
AverageInvoice AS (
    -- Step 8: Calculate the average amount per recurring invoice for each customer
    SELECT
        customer_id,
        ROUND(SUM(billed_amount) / COUNT(invoice_id), 2) AS average_amount_per_invoice
    FROM RecurringInvoices
    GROUP BY customer_id
)
-- Step 12: Combine insights and return the results
SELECT
    ci.customer_id,
    ci.total_invoices,
    ROUND(ci.total_billed_amount, 2) AS total_billed_amount,
    ROUND(ci.total_outstanding_balance, 2) AS total_outstanding_balance,
    oi.overdue_invoices,
    ROUND(oi.overdue_balance, 2) AS overdue_balance,
    ai.average_amount_per_invoice,
    ti.month AS trend_month,
    ti.monthly_invoices
FROM CustomerInvoices ci
LEFT JOIN OverdueInvoices oi ON ci.customer_id = oi.customer_id
LEFT JOIN AverageInvoice ai ON ci.customer_id = ai.customer_id
LEFT JOIN Trends ti ON ci.customer_id = ti.customer_id
ORDER BY ci.customer_id, ti.month;
