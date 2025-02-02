| #  | Transaction Date | Account Type  | Total Debits | Total Credits | Net Balance |
|----|----------------|--------------|--------------|--------------|------------|
| 1  | 2025-01-01     | Total        | 0.00         | 1500.00      | 1500.00    |
| 2  | 2025-01-01     | Cash         | 0.00         | 1500.00      | 1500.00    |
| 3  | 2025-01-02     | Total        | 200.00       | 0.00         | -200.00    |
| 4  | 2025-01-02     | Receivables  | 200.00       | 0.00         | -200.00    |
| 5  | 2025-01-03     | Total        | 0.00         | 2500.00      | 2500.00    |
| 6  | 2025-01-03     | Cash         | 0.00         | 2500.00      | 2500.00    |
| 7  | 2025-01-04     | Total        | 1200.00      | 0.00         | -1200.00   |
| 8  | 2025-01-04     | Payables     | 1200.00      | 0.00         | -1200.00   |
| 9  | 2025-01-05     | Total        | 0.00         | 1000.00      | 1000.00    |
| 10 | 2025-01-05     | Receivables  | 0.00         | 1000.00      | 1000.00    |
| 11 | 2025-01-06     | Total        | 150.00       | 0.00         | -150.00    |
| 12 | 2025-01-06     | Payables     | 150.00       | 0.00         | -150.00    |
| 13 | 2025-01-07     | Total        | 500.00       | 0.00         | -500.00    |
| 14 | 2025-01-07     | Asset        | 500.00       | 0.00         | -500.00    |
| 15 | 2025-01-08     | Total        | 0.00         | 1800.00      | 1800.00    |
| 16 | 2025-01-08     | Cash         | 0.00         | 1800.00      | 1800.00    |
| 17 | 2025-01-09     | Total        | 750.00       | 0.00         | -750.00    |
| 18 | 2025-01-09     | Receivables  | 750.00       | 0.00         | -750.00    |
| 19 | 2025-01-10     | Total        | 0.00         | 3000.00      | 3000.00    |
| 20 | 2025-01-10     | Cash         | 0.00         | 3000.00      | 3000.00    |

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

-- Step 2: Ensure every date is represented by joining DateSeries with ledger entries
daily_ledger AS (
    SELECT 
        ds.transaction_date,
        le.account_type,
        COALESCE(SUM(le.debit_amount), 0) AS total_debits,
        COALESCE(SUM(le.credit_amount), 0) AS total_credits
    FROM DateSeries ds
    LEFT JOIN ledger_entries le ON ds.transaction_date = le.transaction_date
    GROUP BY ds.transaction_date, le.account_type
),

-- Step 3: Compute net balance for each day and account type
daily_balances AS (
    SELECT 
        dl.transaction_date,
        dl.account_type,
        dl.total_debits,
        dl.total_credits,
        (dl.total_credits - dl.total_debits) AS net_balance
    FROM daily_ledger dl
),

-- Step 4: Calculate daily overall totals
daily_totals AS (
    SELECT 
        transaction_date,
        'Total' AS account_type,
        SUM(total_debits) AS total_debits,
        SUM(total_credits) AS total_credits,
        SUM(total_credits) - SUM(total_debits) AS net_balance
    FROM daily_balances
    GROUP BY transaction_date
),

-- Step 5: Merge daily balances with overall daily totals
final_report AS (
    SELECT 
        transaction_date,
        account_type,
        total_debits,
        total_credits,
        net_balance
    FROM daily_balances

    UNION ALL

    SELECT 
        transaction_date,
        account_type,
        total_debits,
        total_credits,
        net_balance
    FROM daily_totals
)

-- Step 6: Return the final daily report
SELECT * FROM final_report
ORDER BY transaction_date, account_type;
