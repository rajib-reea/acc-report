| #  | Transaction Date | Account ID | Account Type  | Total Debits | Total Credits | Net Balance | Description                         | Transaction Amount | Transaction Type | Debit Credit Mismatch | Net Balance Mismatch |
|----|----------------|------------|--------------|-------------|--------------|-------------|----------------------------------|------------------|----------------|---------------------|-------------------|
| 1  | 2025-01-01    | 1          | cash         | 0           | 1500.00      | 1500.00     |                                  |                  |                | t                   | f                 |
| 2  | 2025-01-01    | 1          | Transaction  |             |              |             | Sales Revenue from Client A      | 1500.00          | Credit         |                     |                   |
| 3  | 2025-01-02    | 2          | receivables  | 200.00      | 0            | -200.00     |                                  |                  |                | t                   | f                 |
| 4  | 2025-01-02    | 2          | Transaction  |             |              |             | Office Supplies                  | 200.00           | Debit          |                     |                   |
| 5  | 2025-01-03    | 1          | cash         | 0           | 2500.00      | 2500.00     |                                  |                  |                | t                   | f                 |
| 6  | 2025-01-03    | 1          | Transaction  |             |              |             | Project Revenue for Project X    | 2500.00          | Credit         |                     |                   |
| 7  | 2025-01-04    | 3          | Transaction  |             |              |             | Rent for office space            | 1200.00          | Debit          |                     |                   |
| 8  | 2025-01-04    | 3          | payables     | 1200.00     | 0            | -1200.00    |                                  |                  |                | t                   | f                 |
| 9  | 2025-01-05    | 2          | receivables  | 0           | 1000.00      | 1000.00     |                                  |                  |                | t                   | f                 |
| 10 | 2025-01-05    | 2          | Transaction  |             |              |             | Product Sale to Client B         | 1000.00          | Credit         |                     |                   |
| 11 | 2025-01-06    | 3          | Transaction  |             |              |             | Internet Service for Office      | 150.00           | Debit          |                     |                   |
| 12 | 2025-01-06    | 3          | payables     | 150.00      | 0            | -150.00     |                                  |                  |                | t                   | f                 |
| 13 | 2025-01-07    | 4          | Transaction  |             |              |             | Advertising Expense for Product Launch | 500.00   | Debit          |                     |                   |
| 14 | 2025-01-07    | 4          | asset        | 500.00      | 0            | -500.00     |                                  |                  |                | t                   | f                 |
| 15 | 2025-01-08    | 1          | cash         | 0           | 1800.00      | 1800.00     |                                  |                  |                | t                   | f                 |
| 16 | 2025-01-08    | 1          | Transaction  |             |              |             | Subscription Service Income      | 1800.00          | Credit         |                     |                   |
| 17 | 2025-01-09    | 2          | Transaction  |             |              |             | Consulting Fees for Project Y    | 750.00           | Debit          |                     |                   |
| 18 | 2025-01-09    | 2          | receivables  | 750.00      | 0            | -750.00     |                                  |                  |                | t                   | f                 |
| 19 | 2025-01-10    | 1          | cash         | 0           | 3000.00      | 3000.00     |                                  |                  |                | t                   | f                 |
| 20 | 2025-01-10    | 1          | Transaction  |             |              |             | Payment Received from Client C   | 3000.00          | Credit         |                     |                   |

Algorithm:
  
Detailed_General_Ledger_Analysis(startDate, endDate):
  1. Retrieve all ledger entries for the specified date range (startDate to endDate).
  2. For each ledger entry, extract detailed transaction information (e.g., date, account number, description, debit/credit amount).
  3. Group the entries by account type or account number.
  4. Calculate the total debits and credits for each account, including:
     - Total Debits = Sum of all debit entries for the account.
     - Total Credits = Sum of all credit entries for the account.
  5. For each account, list individual transactions, including:
     - Transaction Date, Description, Amount (Debit or Credit).
  6. Calculate the net balance for each account:
     - Net Balance = Total Credits - Total Debits.
  7. Identify any discrepancies, such as unmatched or missing transactions.
  8. Validate the analysis data (ensure no missing, invalid, or incorrect entries).
  9. Store the detailed ledger analysis data and return the results (list of all transactions, account balances, and discrepancies).

  SQL:
  
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 1: Retrieve all transactions within the specified date range
ledger_entries AS (
    SELECT
        at.id AS transaction_id,
        at.account_id,
        aa.account_name,
        aa.account_type,  -- e.g., 'assets', 'liabilities', 'equity'
        at.transaction_date,
        at.description,
        CASE
            WHEN at.transaction_type = 'expense' THEN at.amount
            ELSE 0
        END AS debit_amount,
        CASE
            WHEN at.transaction_type = 'revenue' THEN at.amount
            ELSE 0
        END AS credit_amount
    FROM acc_transactions at
    JOIN acc_accounts aa ON at.account_id = aa.account_id
    WHERE at.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 2: Ensure daily reporting by cross-joining DateSeries with ledger entries
daily_ledger AS (
    SELECT
        ds.transaction_date,
        le.account_id,
        le.account_type,
        COALESCE(SUM(le.debit_amount), 0) AS total_debits,
        COALESCE(SUM(le.credit_amount), 0) AS total_credits
    FROM DateSeries ds
    LEFT JOIN ledger_entries le ON ds.transaction_date = le.transaction_date
    GROUP BY ds.transaction_date, le.account_id, le.account_type
),

-- Step 3: Compute the net balance for each account per day
daily_balances AS (
    SELECT
        dl.transaction_date,
        dl.account_id,
        dl.account_type,
        dl.total_debits,
        dl.total_credits,
        (dl.total_credits - dl.total_debits) AS net_balance
    FROM daily_ledger dl
),

-- Step 4: Retrieve individual transactions
individual_transactions AS (
    SELECT
        le.account_id,
        le.transaction_date,
        le.description,
        CASE
            WHEN le.debit_amount > 0 THEN le.debit_amount
            ELSE le.credit_amount
        END AS transaction_amount,
        CASE
            WHEN le.debit_amount > 0 THEN 'Debit'
            ELSE 'Credit'
        END AS transaction_type
    FROM ledger_entries le
),

-- Step 5: Invariant Checks
invariant_checks AS (
    SELECT
        db.transaction_date,
        db.account_id,
        db.account_type,
        db.total_debits,
        db.total_credits,
        db.net_balance,
        -- Invariant 1: Debits and Credits Balance Check
        CASE
            WHEN db.total_debits != db.total_credits THEN TRUE
            ELSE FALSE
        END AS debit_credit_mismatch,
        -- Invariant 2: Net Balance Calculation Check
        CASE
            WHEN db.net_balance != (db.total_credits - db.total_debits) THEN TRUE
            ELSE FALSE
        END AS net_balance_mismatch
    FROM daily_balances db
)

-- Step 6: Return the final daily report
SELECT
    db.transaction_date,
    db.account_id,
    db.account_type,
    db.total_debits,
    db.total_credits,
    db.net_balance,
    NULL AS description,
    NULL AS transaction_amount,
    NULL AS transaction_type,
    ic.debit_credit_mismatch,
    ic.net_balance_mismatch
FROM daily_balances db
LEFT JOIN invariant_checks ic ON db.account_id = ic.account_id AND db.transaction_date = ic.transaction_date

UNION ALL

SELECT
    it.transaction_date,
    it.account_id,
    'Transaction' AS account_type,  -- Transactions listed separately
    NULL AS total_debits,  
    NULL AS total_credits,  
    NULL AS net_balance,  
    it.description,
    it.transaction_amount,
    it.transaction_type,
    NULL AS debit_credit_mismatch,  
    NULL AS net_balance_mismatch   
FROM individual_transactions it
ORDER BY transaction_date, account_id;
