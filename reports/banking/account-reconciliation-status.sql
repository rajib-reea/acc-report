Algorithm:
  
Account_Reconciliation_Status(startDate, endDate):
  1. Retrieve all banking transactions (deposits, withdrawals, transfers) within the specified date range (startDate to endDate).
  2. Retrieve the general ledger or internal accounting records for the same date range.
  3. Compare the bank transactions to the general ledger records:
     - Match deposits and withdrawals in both the bank records and general ledger.
     - Match transfers between bank accounts and internal ledger entries.
  4. Identify any discrepancies between the bank account and the general ledger:
     - Unmatched deposits.
     - Unmatched withdrawals.
     - Unmatched transfers.
  5. For each discrepancy, calculate the difference and flag the mismatched entries.
  6. Track the reconciliation progress:
     - Completed Reconciliation: When all bank transactions match the general ledger.
     - Pending Reconciliation: When there are unmatched or pending transactions that require investigation.
  7. Optionally, calculate the total balance in the bank account and compare it with the general ledger balance for the period.
  8. Generate a detailed summary:
     - List all matched transactions.
     - List all discrepancies and unmatched transactions.
  9. Validate the reconciliation data (ensure no invalid or missing entries).
  10. Store the reconciliation status data and return the results, including reconciliation status (complete/incomplete) and any outstanding issues.

 SQL: 
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-01-31'

WITH DateSeries AS (
    -- Step 1: Generate a date series for the entire range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 1: Retrieve all banking transactions within the specified date range
BankTransactions AS (
    SELECT
        bt.transaction_id,
        bt.transaction_date,
        bt.transaction_type,   -- 'deposit', 'withdrawal', 'transfer'
        bt.amount,
        bt.account_id,
        bt.transaction_status  -- 'matched', 'unmatched', 'pending'
    FROM acc_bank_transactions bt
    WHERE bt.transaction_date BETWEEN  '2025-01-01' AND '2025-01-10'
),

-- Step 2: Retrieve the general ledger or internal accounting records for the same date range
LedgerTransactions AS (
    SELECT
        lt.id,
        lt.transaction_date,
        lt.transaction_type,   -- 'deposit', 'withdrawal', 'transfer'
        lt.amount,
        lt.account_id,
        lt.transaction_status  -- 'matched', 'unmatched', 'pending'
    FROM acc_accounts lt
    WHERE lt.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Compare bank transactions to the general ledger records (matching deposits, withdrawals, and transfers)
MatchedTransactions AS (
    SELECT
        bt.transaction_id AS bank_transaction_id,
        lt.transaction_id AS ledger_transaction_id,
        bt.transaction_date,
        bt.transaction_type,
        bt.amount,
        bt.account_id,
        'matched' AS reconciliation_status
    FROM BankTransactions bt
    INNER JOIN LedgerTransactions lt
        ON bt.transaction_type = lt.transaction_type
        AND bt.amount = lt.amount
        AND bt.transaction_date = lt.transaction_date
        AND bt.account_id = lt.account_id
),

-- Step 4: Identify unmatched bank transactions (deposits, withdrawals, transfers)
UnmatchedBankTransactions AS (
    SELECT
        bt.transaction_id,
        bt.transaction_date,
        bt.transaction_type,
        bt.amount,
        bt.account_id,
        'unmatched' AS reconciliation_status
    FROM BankTransactions bt
    LEFT JOIN MatchedTransactions mt
        ON bt.transaction_id = mt.bank_transaction_id
    WHERE mt.bank_transaction_id IS NULL
),

-- Step 5: Identify unmatched ledger transactions
UnmatchedLedgerTransactions AS (
    SELECT
        lt.transaction_id,
        lt.transaction_date,
        lt.transaction_type,
        lt.amount,
        lt.account_id,
        'unmatched' AS reconciliation_status
    FROM LedgerTransactions lt
    LEFT JOIN MatchedTransactions mt
        ON lt.transaction_id = mt.ledger_transaction_id
    WHERE mt.ledger_transaction_id IS NULL
),

-- Step 6: Identify discrepancies between bank transactions and general ledger entries
Discrepancies AS (
    SELECT
        bt.transaction_id AS bank_transaction_id,
        lt.transaction_id AS ledger_transaction_id,
        bt.transaction_date,
        bt.transaction_type,
        bt.amount AS bank_amount,
        lt.amount AS ledger_amount,
        bt.account_id,
        (bt.amount - lt.amount) AS amount_difference
    FROM BankTransactions bt
    LEFT JOIN LedgerTransactions lt
        ON bt.transaction_type = lt.transaction_type
        AND bt.account_id = lt.account_id
        AND bt.transaction_date = lt.transaction_date
    WHERE bt.amount <> lt.amount
),

-- Step 7: Track reconciliation progress (completed/incomplete) for each day
ReconciliationSummary AS (
    SELECT
        ds.transaction_date,
        CASE
            WHEN COUNT(bt.transaction_id) = 0 AND COUNT(lt.transaction_id) = 0 THEN 'Completed'
            ELSE 'Pending'
        END AS reconciliation_status
    FROM DateSeries ds
    LEFT JOIN BankTransactions bt ON ds.transaction_date = bt.transaction_date
    LEFT JOIN LedgerTransactions lt ON ds.transaction_date = lt.transaction_date
    GROUP BY ds.transaction_date
)

-- Step 8: Generate a detailed summary: matched transactions, unmatched transactions, discrepancies
SELECT
    'Matched Transactions' AS summary_type,
    mt.bank_transaction_id AS transaction_id,
    mt.transaction_date,
    mt.transaction_type,
    mt.amount,
    mt.account_id,
    mt.reconciliation_status
FROM MatchedTransactions mt
UNION ALL
SELECT
    'Unmatched Bank Transactions' AS summary_type,
    ubt.transaction_id,
    ubt.transaction_date,
    ubt.transaction_type,
    ubt.amount,
    ubt.account_id,
    ubt.reconciliation_status
FROM UnmatchedBankTransactions ubt
UNION ALL
SELECT
    'Unmatched Ledger Transactions' AS summary_type,
    ult.transaction_id,
    ult.transaction_date,
    ult.transaction_type,
    ult.amount,
    ult.account_id,
    ult.reconciliation_status
FROM UnmatchedLedgerTransactions ult
UNION ALL
SELECT
    'Discrepancies' AS summary_type,
    d.bank_transaction_id,
    d.transaction_date,
    d.transaction_type,
    d.bank_amount,
    d.ledger_amount,
    d.amount_difference
FROM Discrepancies d
UNION ALL
SELECT
    'Reconciliation Status' AS summary_type,
    NULL AS transaction_id,
    NULL AS transaction_date,
    NULL AS transaction_type,
    NULL AS amount,
    NULL AS account_id,
    rs.reconciliation_status
FROM ReconciliationSummary rs;
