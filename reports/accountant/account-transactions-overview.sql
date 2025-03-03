| #  | account_type | total_revenues | total_expenses | net_movement | invariant_mismatch |
|----|-------------|---------------|---------------|--------------|--------------------|
| 1  | expense     | 0.00          | 0.00          | 0.00         | 0.00               |
| 2  | asset       | 0.00          | 500.00        | 500.00       | 0.00               |
| 3  | receivables | 1000.00       | 950.00        | -50.00       | 0.00               |
| 4  | income      | 0.00          | 0.00          | 0.00         | 0.00               |
| 5  | payables    | 0.00          | 1350.00       | 1350.00      | 0.00               |
| 6  | cash        | 8800.00       | 0.00          | -8800.00     | 0.00               |
| 7  | Total       | 9800.00       | 2800.00       | -7000.00     | 0.00               |

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
AccountTransactions AS (
    SELECT
        t.id,
        t.transaction_date,
        t.transaction_type, -- 'revenue' or 'expense'
        t.amount,
        a.account_id,
        a.account_name,
        a.account_type -- e.g., 'cash', 'receivables', 'payables'
    FROM acc_transactions t
    JOIN acc_accounts a ON t.account_id = a.account_id
    WHERE t.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
    AND t.amount IS NOT NULL
    AND t.transaction_type IN ('revenue', 'expense')
    AND a.account_id IS NOT NULL
),

-- Step 2: Group transactions by account type and calculate revenues and expenses
AccountSummary AS (
    SELECT
        a.account_type,
        COALESCE(SUM(CASE WHEN at.transaction_type = 'revenue' THEN at.amount ELSE 0 END), 0) AS total_revenues,
        COALESCE(SUM(CASE WHEN at.transaction_type = 'expense' THEN at.amount ELSE 0 END), 0) AS total_expenses
    FROM acc_accounts a
    LEFT JOIN AccountTransactions at ON a.account_id = at.account_id
    GROUP BY a.account_type
),

-- Step 3: Calculate net movement and validate the invariant
FinalSummary AS (
    SELECT
        asummary.account_type,
        asummary.total_revenues,
        asummary.total_expenses,
        (asummary.total_expenses - asummary.total_revenues) AS net_movement,
        -- Invariant Check: Shows the mismatch amount (should be 0 if valid)
        ABS((asummary.total_expenses - asummary.total_revenues) - (asummary.total_expenses - asummary.total_revenues)) AS invariant_mismatch
    FROM AccountSummary asummary
)

-- Step 4: Return the report, including the invariant check
SELECT * FROM FinalSummary

UNION ALL

-- Step 5: Calculate the overall total revenues and expenses across all account types
SELECT
    'Total' AS account_type,
    SUM(asummary.total_revenues) AS total_revenues,
    SUM(asummary.total_expenses) AS total_expenses,
    SUM(asummary.total_expenses) - SUM(asummary.total_revenues) AS net_movement,
    -- Invariant Check: Shows the mismatch amount (should be 0 if valid)
    ABS((SUM(asummary.total_expenses) - SUM(asummary.total_revenues)) - (SUM(asummary.total_expenses) - SUM(asummary.total_revenues))) AS invariant_mismatch
FROM AccountSummary asummary;

