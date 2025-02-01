Algorithm:
  
Payable_Transactions_Report(startDate, endDate):
  1. Retrieve all payable transactions within the specified date range (startDate to endDate).
  2. Group the transactions by vendor.
  3. For each vendor, list all the transactions (invoices, payments, credit notes, etc.).
  4. For each transaction, calculate the outstanding balance:
     Outstanding Balance = Invoice Amount - Payments Made + Credit Notes.
  5. Optionally, calculate the aging of each payable (e.g., 0-30 days, 31-60 days).
  6. Validate the transaction amounts (ensure no invalid or negative values).
  7. Store the payable transactions data and return the results.

SQL:
​​-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH PayableTransactions AS (
    -- Step 1: Retrieve all payable transactions within the specified date range
    SELECT
        p.transaction_id,
        p.vendor_id,
        p.transaction_type,
        p.invoice_amount,
        p.payment_amount,
        p.credit_note_amount,
        p.transaction_date,
        p.due_date
    FROM payable_transactions p
    WHERE p.transaction_date BETWEEN :startDate AND :endDate
),
PayableBalances AS (
    -- Step 2: Group the transactions by vendor and calculate the outstanding balance
    SELECT
        p.vendor_id,
        p.transaction_id,
        p.transaction_type,
        p.invoice_amount,
        p.payment_amount,
        p.credit_note_amount,
        (p.invoice_amount - p.payment_amount + p.credit_note_amount) AS outstanding_balance
    FROM PayableTransactions p
),
AgingCategories AS (
    -- Step 5: Calculate the aging of each payable (group balances into aging categories)
    SELECT
        p.vendor_id,
        p.transaction_id,
        CASE
            WHEN p.due_date <= current_date - INTERVAL '0' DAY THEN '0-30 Days'
            WHEN p.due_date <= current_date - INTERVAL '30' DAY THEN '31-60 Days'
            WHEN p.due_date <= current_date - INTERVAL '60' DAY THEN '61-90 Days'
            ELSE '91+ Days'
        END AS aging_category,
        p.outstanding_balance
    FROM PayableBalances p
)
-- Step 6: Validate the transaction amounts (ensure no invalid or negative values)
SELECT
    pb.vendor_id,
    pb.transaction_id,
    pb.transaction_type,
    pb.invoice_amount,
    pb.payment_amount,
    pb.credit_note_amount,
    pb.outstanding_balance,
    ac.aging_category
FROM PayableBalances pb
LEFT JOIN AgingCategories ac ON pb.transaction_id = ac.transaction_id
WHERE pb.outstanding_balance >= 0 -- Ensure no negative balances
ORDER BY pb.vendor_id, pb.transaction_id;
