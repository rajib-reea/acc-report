Algorithm:
  
Account_Transactions_Overview(startDate, endDate):
  1. Retrieve all account transactions (debits, credits, transfers) within the specified date range (startDate to endDate).
  2. Group the transactions by account type or category (e.g., cash, receivables, payables).
  3. For each account type, calculate the total debits and credits:
     - Total Debits = Sum of all debit transactions for the account type.
     - Total Credits = Sum of all credit transactions for the account type.
  4. Optionally, calculate the net movement for each account type:
     - Net Movement = Total Credits - Total Debits.
  5. Calculate the overall total debits and credits across all account types.
  6. Validate the transaction data (ensure no invalid or missing entries).
  7. Store the account transactions data and return the results (overview of account movements by type).

SQL:
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 1: Retrieve all account transactions within the specified date range
account_transactions AS (
    SELECT
        t.id,
        t.transaction_date,
        t.transaction_type, -- 'debit' or 'credit'
        t.amount,
        a.account_id,
        a.account_name,
        a.account_type -- e.g., 'cash', 'receivables', 'payables'
    FROM acc_transactions t
    JOIN acc_accounts a ON t.account_id = a.account_id
    WHERE t.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
    -- Step 5: Validate the transaction data by ensuring no invalid entries (e.g., NULL amounts or missing account_id)
    AND t.amount IS NOT NULL
    AND t.transaction_type IN ('debit', 'credit')
    AND a.account_id IS NOT NULL
),

-- Step 2: Group transactions by account type and calculate debits and credits
account_summary AS (
    SELECT
        at.account_type,
        SUM(CASE WHEN at.transaction_type = 'debit' THEN at.amount ELSE 0 END) AS total_debits,
        SUM(CASE WHEN at.transaction_type = 'credit' THEN at.amount ELSE 0 END) AS total_credits
    FROM account_transactions at
    GROUP BY at.account_type
)

-- Step 3: Calculate net movement for each account type
SELECT
    asummary.account_type,
    asummary.total_debits,
    asummary.total_credits,
    (asummary.total_credits - asummary.total_debits) AS net_movement
FROM account_summary asummary

-- Step 4: Calculate the overall total debits and credits across all account types
UNION ALL
SELECT
    'Total' AS account_type,
    SUM(asummary.total_debits) AS total_debits,
    SUM(asummary.total_credits) AS total_credits,
    SUM(asummary.total_credits) - SUM(asummary.total_debits) AS net_movement
FROM account_summary asummary;

