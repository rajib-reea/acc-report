| #  | account_type | total_debits | total_credits | net_balance |
|----|--------------|--------------|---------------|-------------|
| 1  | Total        | 2800.00      | 9800.00       | 7000.00     |
| 2  | asset        | 500.00       | 0             | -500.00     |
| 3  | cash         | 0            | 8800.00       | 8800.00     |
| 4  | payables     | 1350.00      | 0             | -1350.00    |
| 5  | receivables  | 950.00       | 1000.00       | 50.00       |

Algorithm:
  
General_Ledger_Summary(startDate, endDate):
  1. Retrieve all ledger entries for the specified date range (startDate to endDate).
  2. For each ledger entry, extract the account details (e.g., account number, account name, transaction amount).
  3. Group the entries by account type or category (e.g., assets, liabilities, equity).
  4. For each account type, calculate the total debit and credit amounts:
     - Total Debits = Sum of all debit entries for the account type.
     - Total Credits = Sum of all credit entries for the account type.
  5. Optionally, calculate the net balance for each account type:
     - Net Balance = Total Credits - Total Debits.
  6. Calculate the overall totals for debits and credits across all account types.
  7. Validate the data (ensure no missing or incorrect entries).
  8. Store the general ledger summary data and return the results (summary of accounts with their balances).

 SQL: 
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE,  -- Start Date
        '2025-01-10'::DATE,  -- End Date
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 1: Retrieve all ledger entries within the specified date range
ledger_entries AS (
    SELECT
        at.id AS transaction_id,
        at.account_id,
        aa.account_name,
        aa.account_type,  -- e.g., 'cash', 'receivables', 'payables'
        at.transaction_date,
        at.transaction_type,  -- 'revenue' or 'expense'
        at.amount,
        CASE
            WHEN at.transaction_type = 'revenue' THEN at.amount
            ELSE 0
        END AS credit_amount,
        CASE
            WHEN at.transaction_type = 'expense' THEN at.amount
            ELSE 0
        END AS debit_amount
    FROM acc_transactions at
    JOIN acc_accounts aa ON at.account_id = aa.account_id
    WHERE at.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 2: Group the entries by account type and calculate total debits and credits for each account type
account_classification AS (
    SELECT
        le.account_type,
        SUM(le.debit_amount) AS total_debits,
        SUM(le.credit_amount) AS total_credits
    FROM ledger_entries le
    GROUP BY le.account_type
),

-- Step 3: Calculate the net balance for each account type
account_balances AS (
    SELECT
        ac.account_type,
        ac.total_debits,
        ac.total_credits,
        (ac.total_credits - ac.total_debits) AS net_balance
    FROM account_classification ac
),

-- Step 4: Calculate the overall totals for debits and credits across all account types
overall_totals AS (
    SELECT
        'Total' AS account_type,
        SUM(ac.total_debits) AS total_debits,
        SUM(ac.total_credits) AS total_credits,
        SUM(ac.total_credits) - SUM(ac.total_debits) AS net_balance
    FROM account_classification ac
),

-- Step 5: Combine account balances and overall totals
final_report AS (
    SELECT
        ab.account_type,
        ab.total_debits,
        ab.total_credits,
        ab.net_balance
    FROM account_balances ab

    UNION ALL

    SELECT
        ot.account_type,
        ot.total_debits,
        ot.total_credits,
        ot.net_balance
    FROM overall_totals ot
)

-- Step 6: Return the final report
SELECT * FROM final_report
ORDER BY account_type;
