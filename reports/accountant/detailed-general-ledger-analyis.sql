| #  | account_id | account_type | total_debits | total_credits | net_balance | transaction_date | description                           | transaction_amount | transaction_type | debit_credit_mismatch | net_balance_mismatch |
|----|------------|--------------|--------------|---------------|-------------|------------------|---------------------------------------|--------------------|------------------|------------------------|----------------------|
| 1  | 1          | Transaction  |              |               |             | 2025-01-01       | Sales Revenue from Client A           | 1500.00            | Debit            |                        |                      |
| 2  | 1          | Transaction  |              |               |             | 2025-01-03       | Project Revenue for Project X         | 2500.00            | Debit            |                        |                      |
| 3  | 1          | Transaction  |              |               |             | 2025-01-08       | Subscription Service Income           | 1800.00            | Debit            |                        |                      |
| 4  | 1          | Transaction  |              |               |             | 2025-01-10       | Payment Received from Client C        | 3000.00            | Debit            |                        |                      |
| 5  | 1          | cash         | 8800.00      | 0             | -8800.00    |                  |                                       |                    |                  | t                      | f                    |
| 6  | 2          | Transaction  |              |               |             | 2025-01-02       | Office Supplies                       | 200.00             | Credit           |                        |                      |
| 7  | 2          | Transaction  |              |               |             | 2025-01-05       | Product Sale to Client B              | 1000.00            | Debit            |                        |                      |
| 8  | 2          | Transaction  |              |               |             | 2025-01-09       | Consulting Fees for Project Y         | 750.00             | Credit           |                        |                      |
| 9  | 2          | receivables  | 1000.00      | 950.00        | -50.00      |                  |                                       |                    |                  | t                      | f                    |
| 10 | 3          | Transaction  |              |               |             | 2025-01-04       | Rent for office space                 | 1200.00            | Credit           |                        |                      |
| 11 | 3          | Transaction  |              |               |             | 2025-01-06       | Internet Service for Office           | 150.00             | Credit           |                        |                      |
| 12 | 3          | payables     | 0            | 1350.00       | 1350.00     |                  |                                       |                    |                  | t                      | f                    |
| 13 | 4          | Transaction  |              |               |             | 2025-01-07       | Advertising Expense for Product Launch| 500.00             | Credit           |                        |                      |
| 14 | 4          | asset        | 0            | 500.00        | 500.00      |                  |                                       |                    |                  | t                      | f                    |


  
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
            WHEN at.transaction_type = 'revenue' THEN at.amount
            ELSE 0
        END AS debit_amount,
        CASE
            WHEN at.transaction_type = 'expense' THEN at.amount
            ELSE 0
        END AS credit_amount
    FROM acc_transactions at
    JOIN acc_accounts aa ON at.account_id = aa.account_id
    WHERE at.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 2: Group the entries by account type or account number
account_summary AS (
    SELECT
        le.account_id,
        le.account_type,
        SUM(le.debit_amount) AS total_debits,
        SUM(le.credit_amount) AS total_credits
    FROM ledger_entries le
    GROUP BY le.account_id, le.account_type
),

-- Step 3: List individual transactions by account
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

-- Step 4: Calculate the net balance for each account
account_balances AS (
    SELECT
        asum.account_id,
        asum.account_type,
        asum.total_debits,
        asum.total_credits,
        (asum.total_credits - asum.total_debits) AS net_balance
    FROM account_summary asum
),

-- Step 5: Invariant Checks
invariant_checks AS (
    SELECT
        ab.account_id,
        ab.account_type,
        ab.total_debits,
        ab.total_credits,
        ab.net_balance,
        -- Invariant 1: Debits and Credits Balance
        CASE
            WHEN ab.total_debits != ab.total_credits THEN TRUE
            ELSE FALSE
        END AS debit_credit_mismatch,
        -- Invariant 2: Net Balance Calculation
        CASE
            WHEN ab.net_balance != (ab.total_credits - ab.total_debits) THEN TRUE
            ELSE FALSE
        END AS net_balance_mismatch
    FROM account_balances ab
)

-- Step 6: Return account balances, individual transactions, and invariant checks
SELECT
    ab.account_id,
    ab.account_type,
    ab.total_debits,
    ab.total_credits,
    ab.net_balance,
    NULL AS transaction_date,
    NULL AS description,
    NULL AS transaction_amount,
    NULL AS transaction_type,
    ic.debit_credit_mismatch,
    ic.net_balance_mismatch
FROM account_balances ab
LEFT JOIN invariant_checks ic ON ab.account_id = ic.account_id

UNION ALL

SELECT
    it.account_id,
    'Transaction' AS account_type,  -- Individual transactions are listed separately
    NULL AS total_debits,  -- No total debits for individual transactions
    NULL AS total_credits,  -- No total credits for individual transactions
    NULL AS net_balance,  -- No net balance for individual transactions
    it.transaction_date,
    it.description,
    it.transaction_amount,
    it.transaction_type,
    NULL AS debit_credit_mismatch,  -- No invariant checks for individual transactions
    NULL AS net_balance_mismatch   -- No invariant checks for individual transactions
FROM individual_transactions it
ORDER BY account_id, transaction_date;
