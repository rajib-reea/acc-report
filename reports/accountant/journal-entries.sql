| #  | Transaction Date | Account Type  | Total Debits | Total Credits | Transaction ID | Account Name         | Debit Amount | Credit Amount | Description                           |
|----|----------------|--------------|--------------|--------------|---------------|----------------------|--------------|--------------|---------------------------------------|
| 1  | 2025-01-01     | Cash         | 0.00         | 1500.00      | 1             | Cash                 | 0.00         | 1500.00      | Sales Revenue from Client A          |
| 2  | 2025-01-02     | Receivables  | 200.00       | 0.00         | 2             | Accounts Receivable  | 200.00       | 0.00         | Office Supplies                      |
| 3  | 2025-01-03     | Cash         | 0.00         | 2500.00      | 3             | Cash                 | 0.00         | 2500.00      | Project Revenue for Project X        |
| 4  | 2025-01-04     | Payables     | 1200.00      | 0.00         | 4             | Accounts Payable     | 1200.00      | 0.00         | Rent for office space                |
| 5  | 2025-01-05     | Receivables  | 0.00         | 1000.00      | 5             | Accounts Receivable  | 0.00         | 1000.00      | Product Sale to Client B             |
| 6  | 2025-01-06     | Payables     | 150.00       | 0.00         | 6             | Accounts Payable     | 150.00       | 0.00         | Internet Service for Office          |
| 7  | 2025-01-07     | Asset        | 500.00       | 0.00         | 7             | Inventory            | 500.00       | 0.00         | Advertising Expense for Product Launch |
| 8  | 2025-01-08     | Cash         | 0.00         | 1800.00      | 8             | Cash                 | 0.00         | 1800.00      | Subscription Service Income          |
| 9  | 2025-01-09     | Receivables  | 750.00       | 0.00         | 9             | Accounts Receivable  | 750.00       | 0.00         | Consulting Fees for Project Y        |
| 10 | 2025-01-10     | Cash         | 0.00         | 3000.00      | 10            | Cash                 | 0.00         | 3000.00      | Payment Received from Client C       |

Algorithm:
  
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
  
WITH DateSeries AS (
    -- Step 1: Generate a date series for the entire range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

journal_entries AS (
    -- Step 2: Retrieve all journal entries within the specified date range
    SELECT
        je.id AS transaction_id,
        je.transaction_date,
        je.account_id,
        aa.account_name,
        aa.account_type,  -- 'cash', 'receivables', 'payables'
        je.transaction_type,  -- 'revenue' or 'expense'
        je.amount,
        CASE WHEN je.transaction_type = 'revenue' THEN je.amount ELSE 0 END AS credit_amount,
        CASE WHEN je.transaction_type = 'expense' THEN je.amount ELSE 0 END AS debit_amount,
        je.description
    FROM acc_transactions je
    JOIN acc_accounts aa ON je.account_id = aa.account_id
    WHERE je.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

journal_summary AS (
    -- Step 3: Group journal entries by account type AND transaction_date
    SELECT
        je.transaction_date,
        je.account_type,
        SUM(je.debit_amount) AS total_debits,
        SUM(je.credit_amount) AS total_credits
    FROM journal_entries je
    GROUP BY je.transaction_date, je.account_type
),

final_report AS (
    -- Step 4: Ensure every date appears by left joining DateSeries
    SELECT
        ds.transaction_date,  
        COALESCE(js.account_type, 'No Transactions') AS account_type,
        COALESCE(js.total_debits, 0) AS total_debits,  
        COALESCE(js.total_credits, 0) AS total_credits,
        je.transaction_id,
        je.account_name,
        je.debit_amount,
        je.credit_amount,
        je.description
    FROM DateSeries ds  
    LEFT JOIN journal_summary js ON ds.transaction_date = js.transaction_date
    LEFT JOIN journal_entries je ON ds.transaction_date = je.transaction_date AND js.account_type = je.account_type
)

-- Step 5: Return final report ordered by date and account type.
SELECT * FROM final_report
ORDER BY transaction_date, account_type;
