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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH RecurringInvoices AS (
    -- Step 1: Retrieve all recurring invoice transactions within the specified date range
    SELECT
        ri.invoice_id,
        ri.customer_id,
        ri.invoice_date,
        ri.due_date,
        ri.amount AS billed_amount,
        ri.status,  -- Invoice status (e.g., 'Paid', 'Unpaid', 'Overdue')
        ri.outstanding_balance
    FROM recurring_invoices ri
    WHERE ri.invoice_date BETWEEN :startDate AND :endDate
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
        SUM(billed_amount) / COUNT(invoice_id) AS average_amount_per_invoice
    FROM RecurringInvoices
    GROUP BY customer_id
)
-- Step 12: Combine insights and return the results
SELECT
    ci.customer_id,
    ci.total_invoices,
    ci.total_billed_amount,
    ci.total_outstanding_balance,
    oi.overdue_invoices,
    oi.overdue_balance,
    ai.average_amount_per_invoice,
    ti.month AS trend_month,
    ti.monthly_invoices
FROM CustomerInvoices ci
LEFT JOIN OverdueInvoices oi ON ci.customer_id = oi.customer_id
LEFT JOIN AverageInvoice ai ON ci.customer_id = ai.customer_id
LEFT JOIN Trends ti ON ci.customer_id = ti.customer_id
ORDER BY ci.customer_id, ti.month;
