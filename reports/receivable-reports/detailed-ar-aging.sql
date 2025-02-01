Algorithm:
Detailed_AR_Aging_Report(startDate, endDate):
  1. Retrieve accounts receivable (AR) transactions within the specified date range (startDate to endDate).
  2. Group the transactions by customer.
  3. For each customer, retrieve their outstanding invoices.
  4. Calculate the aging of each outstanding invoice:
     - Group AR balances by aging categories (e.g., 0-30 days, 31-60 days, 61-90 days, 91+ days).
  5. Calculate the total balance for each invoice and its respective aging category.
  6. Validate the amounts (ensure no invalid or negative values).
  7. Store detailed AR aging data for each customer and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH ARTransactions AS (
    -- Step 1: Retrieve accounts receivable (AR) transactions within the specified date range
    SELECT 
        customer_id,  -- Replace with the appropriate column for customer identification
        invoice_id,   -- Assuming each AR transaction is linked to an invoice
        transaction_date,
        amount,  -- The amount for each AR transaction (can be adjusted depending on how amounts are stored)
        (CURRENT_DATE - transaction_date) AS days_outstanding  -- Calculate the number of days outstanding
    FROM acc_transactions
    WHERE transaction_type = 'revenue' -- Only revenue transactions are considered as AR
      AND transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
),
AgingCategories AS (
    -- Step 4: Calculate the aging of each outstanding invoice
    SELECT 
        customer_id,
        invoice_id,
        CASE
            WHEN days_outstanding BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN days_outstanding BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN days_outstanding BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN days_outstanding > 90 THEN '91+ days'
            ELSE 'Invalid'  -- Catch any unexpected values (e.g., negative days)
        END AS aging_category,
        amount,  -- Use the individual transaction amount as it relates to the invoice
        days_outstanding
    FROM ARTransactions
),
InvoiceAging AS (
    -- Step 5: Calculate the total balance for each invoice and its respective aging category
    SELECT
        customer_id,
        invoice_id,
        aging_category,
        SUM(amount) AS total_invoice_amount,
        MAX(days_outstanding) AS max_days_outstanding  -- Get the max days for each invoice
    FROM AgingCategories
    GROUP BY customer_id, invoice_id, aging_category
),
ValidatedAging AS (
    -- Step 6: Validate the amounts (ensure no invalid or negative values)
    SELECT 
        customer_id,
        invoice_id,
        aging_category,
        total_invoice_amount
    FROM InvoiceAging
    WHERE total_invoice_amount >= 0  -- Ensure no negative amounts
)
-- Step 7: Store detailed AR aging data for each customer and return the results
SELECT 
    customer_id,
    invoice_id,
    aging_category,
    total_invoice_amount,
    max_days_outstanding
FROM ValidatedAging
ORDER BY customer_id, invoice_id, 
         CASE 
             WHEN aging_category = '0-30 days' THEN 1
             WHEN aging_category = '31-60 days' THEN 2
             WHEN aging_category = '61-90 days' THEN 3
             WHEN aging_category = '91+ days' THEN 4
             ELSE 5  -- Handling 'Invalid' category if any
         END;
