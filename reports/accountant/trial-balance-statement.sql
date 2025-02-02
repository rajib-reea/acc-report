| #  | Account Category    | Category Total Debits | Category Total Credits | Net Balance |
|----|---------------------|-----------------------|------------------------|-------------|
| 1  | Current Asset       | 1450.00               | 9800.00                | 8350.00     |
| 2  | Current Liability   | 1350.00               | 0                      | -1350.00    |

Algorithm:
  
  Trial_Balance_Statement(startDate, endDate):
  1. Retrieve all ledger accounts and their balances for the specified date range (startDate to endDate).
  2. For each account, extract the balance (debit or credit).
  3. Sum the total debits and total credits across all accounts.
  4. Verify that the total debits and credits are equal (trial balance check):
     - Total Debits = Total Credits (This is required for the trial balance to be balanced).
  5. Group accounts by category (e.g., assets, liabilities, equity, revenue, expenses).
  6. Calculate the net balance for each account category:
     - Net Balance = Total Credits - Total Debits for each category.
  7. Validate the trial balance data (ensure no incorrect or missing entries).
  8. Store the trial balance statement and return the results (detailed listing of accounts, debits, credits, and balance check).

  SQL:
-- Step 0: Generate the date series for the specified date range (optional for date grouping)
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE,  -- Start Date
        '2025-01-10'::DATE,  -- End Date
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 1: Retrieve all ledger accounts and their balances for the specified date range
ledger_entries AS (
    SELECT
        a.account_id AS account_number,
        a.account_name,
        CASE 
            WHEN t.transaction_type = 'expense' THEN t.amount 
            ELSE 0 
        END AS debit_amount,
        CASE 
            WHEN t.transaction_type = 'revenue' THEN t.amount 
            ELSE 0 
        END AS credit_amount,
        a.category AS account_category, -- e.g., 'current asset', 'liability', etc.
        t.transaction_date
    FROM acc_transactions t
    JOIN acc_accounts a ON t.account_id = a.account_id
    WHERE t.transaction_date BETWEEN '2025-01-01' AND '2025-01-10' -- use the date range dynamically if needed
),

-- Step 2: Extract balance (debit or credit) and calculate total debits and credits for each account
account_balances AS (
    SELECT
        le.account_number,
        le.account_name,
        SUM(le.debit_amount) AS total_debits,
        SUM(le.credit_amount) AS total_credits,
        le.account_category
    FROM ledger_entries le
    GROUP BY le.account_number, le.account_name, le.account_category
),

-- Step 3: Calculate total debits and credits across all accounts
total_debits_credits AS (
    SELECT
        SUM(total_debits) AS total_debits,
        SUM(total_credits) AS total_credits
    FROM account_balances
),

-- Step 4: Verify that total debits and credits are equal (Trial balance check)
trial_balance_check AS (
    SELECT
        CASE
            WHEN (SELECT total_debits FROM total_debits_credits) = (SELECT total_credits FROM total_debits_credits) THEN 'Balanced'
            ELSE 'Unbalanced'
        END AS balance_status
)

-- Step 5: Group accounts by category and calculate net balance for each category
SELECT
    ab.account_category,
    SUM(ab.total_debits) AS category_total_debits,
    SUM(ab.total_credits) AS category_total_credits,
    SUM(ab.total_credits) - SUM(ab.total_debits) AS net_balance
FROM account_balances ab
GROUP BY ab.account_category

-- Step 6: Validate the trial balance data (ensure no incorrect or missing entries)
HAVING SUM(ab.total_debits) >= 0 AND SUM(ab.total_credits) >= 0

-- Step 7: Return results: Include detailed listing of accounts, debits, credits, balance check
ORDER BY ab.account_category;

-- Optionally, show trial balance check status (Balanced or Unbalanced)
SELECT balance_status FROM trial_balance_check;
