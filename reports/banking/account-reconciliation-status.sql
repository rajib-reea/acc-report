| #  | summary_type               | transaction_id | transaction_date | transaction_type | amount   | account_id | reconciliation_status |
|----|----------------------------|----------------|------------------|------------------|----------|------------|-----------------------|
| 1  | Unmatched Ledger Transactions | 1              | 2025-01-01       | revenue          | 1500.00  | 1          | unmatched             |
| 2  | Unmatched Ledger Transactions | 2              | 2025-01-02       | expense          | 200.00   | 2          | unmatched             |
| 3  | Unmatched Ledger Transactions | 3              | 2025-01-03       | revenue          | 2500.00  | 1          | unmatched             |
| 4  | Unmatched Ledger Transactions | 4              | 2025-01-04       | expense          | 1200.00  | 3          | unmatched             |
| 5  | Unmatched Ledger Transactions | 5              | 2025-01-05       | revenue          | 1000.00  | 2          | unmatched             |
| 6  | Unmatched Ledger Transactions | 6              | 2025-01-06       | expense          | 150.00   | 3          | unmatched             |
| 7  | Unmatched Ledger Transactions | 7              | 2025-01-07       | expense          | 500.00   | 4          | unmatched             |
| 8  | Unmatched Ledger Transactions | 8              | 2025-01-08       | revenue          | 1800.00  | 1          | unmatched             |
| 9  | Unmatched Ledger Transactions | 9              | 2025-01-09       | expense          | 750.00   | 2          | unmatched             |
| 10 | Unmatched Ledger Transactions | 10             | 2025-01-10       | revenue          | 3000.00  | 1          | unmatched             |
| 11 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 12 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 13 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 14 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 15 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 16 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 17 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 18 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 19 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 20 | Discrepancies                |                |                  |                  |          |            | discrepancy           |
| 21 | Reconciliation Status        |                | 2025-01-04       |                  |          |            | Pending               |
| 22 | Reconciliation Status        |                | 2025-01-09       |                  |          |            | Pending               |
| 23 | Reconciliation Status        |                | 2025-01-08       |                  |          |            | Pending               |
| 24 | Reconciliation Status        |                | 2025-01-02       |                  |          |            | Pending               |
| 25 | Reconciliation Status        |                | 2025-01-01       |                  |          |            | Pending               |
| 26 | Reconciliation Status        |                | 2025-01-10       |                  |          |            | Pending               |
| 27 | Reconciliation Status        |                | 2025-01-07       |                  |          |            | Pending               |
| 28 | Reconciliation Status        |                | 2025-01-05       |                  |          |            | Pending               |
| 29 | Reconciliation Status        |                | 2025-01-03       |                  |          |            | Pending               |
| 30 | Reconciliation Status        |                | 2025-01-06       |                  |          |            | Pending               |


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

WITH DateSeries AS (
    -- Generate a series of dates from 2025-01-01 to 2025-01-10 (daily)
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

BankTransactions AS (
    -- Retrieve Bank Transactions for the date range
    SELECT
        bt.transaction_id,
        bt.transaction_date,
        bt.transaction_type,
        bt.amount,
        bt.account_id,
        bt.transaction_status
    FROM acc_bank_transactions bt
    WHERE bt.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

LedgerTransactions AS (
    -- Retrieve Ledger Transactions for the date range
    SELECT
        lt.id AS transaction_id,
        lt.transaction_date,
        lt.transaction_type,
        lt.amount,
        lt.account_id,
        CASE
            WHEN lt.is_reconciled THEN 'matched'
            ELSE 'unmatched'
        END AS transaction_status
    FROM acc_transactions lt
    WHERE lt.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

MatchedTransactions AS (
    -- Match Bank and Ledger transactions based on type, amount, and date
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

UnmatchedBankTransactions AS (
    -- Identify Bank Transactions that have not been matched
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

UnmatchedLedgerTransactions AS (
    -- Identify Ledger Transactions that have not been matched
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

Discrepancies AS (
    -- Identify discrepancies where amounts do not match or transactions are missing
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
    FULL OUTER JOIN LedgerTransactions lt
        ON bt.transaction_type = lt.transaction_type
        AND bt.account_id = lt.account_id
        AND bt.transaction_date = lt.transaction_date
    WHERE bt.amount <> lt.amount
        OR bt.transaction_id IS NULL
        OR lt.transaction_id IS NULL
),

ReconciliationSummary AS (
    -- Track reconciliation progress for each date
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

-- Union all the results to generate the summary for each day
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
    d.bank_transaction_id AS transaction_id,
    d.transaction_date,
    d.transaction_type,
    d.bank_amount AS amount,
    d.account_id,
    'discrepancy' AS reconciliation_status
FROM Discrepancies d
UNION ALL
SELECT
    'Reconciliation Status' AS summary_type,
    NULL AS transaction_id,
    rs.transaction_date,
    NULL AS transaction_type,
    NULL AS amount,
    NULL AS account_id,
    rs.reconciliation_status
FROM ReconciliationSummary rs;
