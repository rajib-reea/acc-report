| #  | transaction_date | account_type | total_debits | total_credits | transaction_id | account_name         | debit_amount | credit_amount | description                             |
|----|------------------|--------------|--------------|---------------|----------------|----------------------|--------------|---------------|-----------------------------------------|
| 1  | 2025-01-01       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 2  | 2025-01-01       | cash         | 0            | 8800.00       | 1              | Cash                 | 0            | 1500.00       | Sales Revenue from Client A            |
| 3  | 2025-01-01       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 4  | 2025-01-01       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |
| 5  | 2025-01-02       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 6  | 2025-01-02       | cash         | 0            | 8800.00       |                |                      |              |               |                                         |
| 7  | 2025-01-02       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 8  | 2025-01-02       | receivables  | 950.00       | 1000.00       | 2              | Accounts Receivable   | 200.00       | 0             | Office Supplies                        |
| 9  | 2025-01-03       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 10 | 2025-01-03       | cash         | 0            | 8800.00       | 3              | Cash                 | 0            | 2500.00       | Project Revenue for Project X          |
| 11 | 2025-01-03       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 12 | 2025-01-03       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |
| 13 | 2025-01-04       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 14 | 2025-01-04       | cash         | 0            | 8800.00       |                |                      |              |               |                                         |
| 15 | 2025-01-04       | payables     | 1350.00      | 0             | 4              | Accounts Payable      | 1200.00      | 0             | Rent for office space                  |
| 16 | 2025-01-04       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |
| 17 | 2025-01-05       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 18 | 2025-01-05       | cash         | 0            | 8800.00       |                |                      |              |               |                                         |
| 19 | 2025-01-05       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 20 | 2025-01-05       | receivables  | 950.00       | 1000.00       | 5              | Accounts Receivable   | 0            | 1000.00       | Product Sale to Client B               |
| 21 | 2025-01-06       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 22 | 2025-01-06       | cash         | 0            | 8800.00       |                |                      |              |               |                                         |
| 23 | 2025-01-06       | payables     | 1350.00      | 0             | 6              | Accounts Payable      | 150.00       | 0             | Internet Service for Office            |
| 24 | 2025-01-06       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |
| 25 | 2025-01-07       | asset        | 500.00       | 0             | 7              | Inventory             | 500.00       | 0             | Advertising Expense for Product Launch |
| 26 | 2025-01-07       | cash         | 0            | 8800.00       |                |                      |              |               |                                         |
| 27 | 2025-01-07       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 28 | 2025-01-07       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |
| 29 | 2025-01-08       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 30 | 2025-01-08       | cash         | 0            | 8800.00       | 8              | Cash                 | 0            | 1800.00       | Subscription Service Income            |
| 31 | 2025-01-08       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 32 | 2025-01-08       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |
| 33 | 2025-01-09       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 34 | 2025-01-09       | cash         | 0            | 8800.00       |                |                      |              |               |                                         |
| 35 | 2025-01-09       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 36 | 2025-01-09       | receivables  | 950.00       | 1000.00       | 9              | Accounts Receivable   | 750.00       | 0             | Consulting Fees for Project Y          |
| 37 | 2025-01-10       | asset        | 500.00       | 0             |                |                      |              |               |                                         |
| 38 | 2025-01-10       | cash         | 0            | 8800.00       | 10             | Cash                 | 0            | 3000.00       | Payment Received from Client C         |
| 39 | 2025-01-10       | payables     | 1350.00      | 0             |                |                      |              |               |                                         |
| 40 | 2025-01-10       | receivables  | 950.00       | 1000.00       |                |                      |              |               |                                         |

]Algorithm:
  
Journal_Entries_Report(startDate, endDate):
  1. Retrieve all journal entries within the specified date range (startDate to endDate).
  2. For each journal entry, extract the details (e.g., journal number, date, debit/credit amounts, account numbers).
  3. Group journal entries by journal type (e.g., sales, purchases, adjustments).
  4. For each journal entry, calculate the total debit and credit amounts:
     - Total Debits = Sum of all debit amounts for the journal entry.
     - Total Credits = Sum of all credit amounts for the journal entry.
  5. List all journal entries with their details (journal number, date, accounts, debit/credit amounts).
  6. Validate the journal entries (ensure no invalid or missing entries).
  7. Store the journal entries data and return the results (list of journal entries with total debits and credits).

SQL:
  
-- Step 1: Generate Date Series for the specified date range
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE,  -- Start Date
        '2025-01-10'::DATE,  -- End Date
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 2: Retrieve all journal entries within the specified date range
journal_entries AS (
    SELECT
        je.id AS transaction_id,
        je.transaction_date,
        je.account_id,
        aa.account_name,
        aa.account_type,  -- e.g., 'cash', 'receivables', 'payables'
        je.transaction_type,  -- 'revenue' or 'expense'
        je.amount,
        CASE
            WHEN je.transaction_type = 'revenue' THEN je.amount
            ELSE 0
        END AS credit_amount,
        CASE
            WHEN je.transaction_type = 'expense' THEN je.amount
            ELSE 0
        END AS debit_amount,
        je.description
    FROM acc_transactions je
    JOIN acc_accounts aa ON je.account_id = aa.account_id
    WHERE je.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Group journal entries by account type and calculate the total debit and credit amounts for each type
journal_summary AS (
    SELECT
        je.account_type,
        SUM(je.debit_amount) AS total_debits,
        SUM(je.credit_amount) AS total_credits
    FROM journal_entries je
    GROUP BY je.account_type
),

-- Step 4: Combine journal summaries and individual entries.  This is where we need to be careful.
-- We want ALL dates in the series, even if there are no transactions.  So we LEFT JOIN from DateSeries.
final_report AS (
    SELECT
        ds.transaction_date,  -- Include all dates
        js.account_type,
        COALESCE(js.total_debits, 0) AS total_debits,  -- Handle cases with no transactions
        COALESCE(js.total_credits, 0) AS total_credits, -- Handle cases with no transactions
        je.transaction_id,
        je.account_name,
        je.debit_amount,
        je.credit_amount,
        je.description
    FROM DateSeries ds  -- Start with the date series
    LEFT JOIN journal_summary js ON 1=1 -- We don't have a direct join condition here.
    LEFT JOIN journal_entries je ON ds.transaction_date = je.transaction_date AND js.account_type = je.account_type
)

-- Step 5: Return the final report, ordered by date and then account type.
SELECT *
FROM final_report
ORDER BY transaction_date, account_type;
