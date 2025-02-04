| #  | vendor_id | transaction_id | transaction_type | invoice_amount | payment_amount | credit_note_amount | outstanding_balance | aging_category |
|----|-----------|----------------|------------------|----------------|-----------------|---------------------|---------------------|----------------|
| 1  | 1         | 1              | Invoice          | 1000.00        | 0.00            | 0.00                | 1000.00             | 0-30 Days      |
| 2  | 1         | 2              | Invoice          | 1500.00        | 0.00            | 0.00                | 1500.00             | 0-30 Days      |
| 3  | 2         | 4              | Invoice          | 2000.00        | 0.00            | 0.00                | 2000.00             | 0-30 Days      |
| 4  | 2         | 5              | Invoice          | 1200.00        | 0.00            | 0.00                | 1200.00             | 0-30 Days      |
| 5  | 3         | 8              | Invoice          | 1800.00        | 0.00            | 0.00                | 1800.00             | 0-30 Days      |
| 6  | 4         | 10             | Invoice          | 500.00         | 0.00            | 0.00                | 500.00              | 0-30 Days      |
| 7  | 4         | 11             | Invoice          | 750.00         | 0.00            | 0.00                | 750.00              | Not Due        |

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
    FROM acc_payable_transactions p
    WHERE p.transaction_date BETWEEN '2025-01-01' AND '2025-12-31'  -- Date range
),
PayableBalances AS (
    -- Step 2: Calculate the outstanding balance for each transaction
    SELECT
        p.vendor_id,
        p.transaction_id,
        p.transaction_type,
        p.invoice_amount,
        p.payment_amount,
        p.credit_note_amount,
        p.due_date,
        (p.invoice_amount - p.payment_amount + p.credit_note_amount) AS outstanding_balance
    FROM PayableTransactions p
),
AgingCategories AS (
    -- Step 3: Calculate the aging of each payable (group balances into aging categories)
    SELECT
        p.vendor_id,
        p.transaction_id,
        p.outstanding_balance,
        (CURRENT_DATE - p.due_date) AS days_overdue,  -- Calculate days overdue
        CASE
            WHEN (CURRENT_DATE - p.due_date) BETWEEN 0 AND 30 THEN '0-30 Days'
            WHEN (CURRENT_DATE - p.due_date) BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN (CURRENT_DATE - p.due_date) BETWEEN 61 AND 90 THEN '61-90 Days'
            WHEN (CURRENT_DATE - p.due_date) > 90 THEN '91+ Days'
            ELSE 'Not Due'
        END AS aging_category
    FROM PayableBalances p
)
-- Step 4: Return the results with aging categories and validate balances
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
WHERE pb.outstanding_balance >= 0  -- Ensure no negative balances
ORDER BY pb.vendor_id, pb.transaction_id;
