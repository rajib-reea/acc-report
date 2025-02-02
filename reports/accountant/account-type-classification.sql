Algorithm:
  
Account_Type_Classification_Report(startDate, endDate):
  1. Retrieve all account transactions within the specified date range (startDate to endDate).
  2. Classify the transactions by account type (e.g., assets, liabilities, equity, revenue, expenses).
  3. For each account type, calculate the total debit and credit amounts:
     - Total Debits = Sum of all debit transactions for the account type.
     - Total Credits = Sum of all credit transactions for the account type.
  4. Optionally, calculate the net balance for each account type:
     - Net Balance = Total Credits - Total Debits.
  5. Calculate the overall total debits and credits across all account types.
  6. Validate the classification data (ensure no incorrect or missing entries).
  7. Store the classification data and return the results (summary of transaction classifications by account type).

SQL:  
WITH  DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
AccountTransactions AS (
    -- Step 1: Retrieve all account transactions within the specified date range
    SELECT
        t.id,
        t.transaction_date,
        t.transaction_type, -- 'revenue' or 'expense'
        t.amount,
        a.account_id,
        a.account_name,
        a.account_type -- e.g., 'assets', 'liabilities', 'equity', 'revenue', 'expenses'
    FROM acc_transactions t
    JOIN acc_accounts a ON t.account_id = a.account_id
    WHERE t.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

AccountClassification AS (
    -- Step 2: Classify transactions by account type and calculate total revenues and expenses
    SELECT
        a.account_type,
        COALESCE(SUM(CASE WHEN at.transaction_type = 'revenue' THEN at.amount ELSE 0 END), 0) AS total_revenues,
        COALESCE(SUM(CASE WHEN at.transaction_type = 'expense' THEN at.amount ELSE 0 END), 0) AS total_expenses
    FROM acc_accounts a
    LEFT JOIN AccountTransactions at ON a.account_id = at.account_id
    GROUP BY a.account_type
)

-- Step 3 & 4: Compute net balance for each account type and include total summary
SELECT
    ac.account_type,
    ac.total_revenues,
    ac.total_expenses,
    (ac.total_expenses - ac.total_revenues) AS net_balance
FROM AccountClassification ac

UNION ALL

SELECT
    'Total' AS account_type,
    SUM(ac.total_revenues) AS total_revenues,
    SUM(ac.total_expenses) AS total_expenses,
    SUM(ac.total_expenses) - SUM(ac.total_revenues) AS net_balance
FROM AccountClassification ac;
