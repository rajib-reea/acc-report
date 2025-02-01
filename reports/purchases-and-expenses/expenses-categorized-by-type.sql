Algorithm:
  
Expenses_Categorized_by_Type(startDate, endDate):
  1. Retrieve all expense transactions within the specified date range (startDate to endDate).
  2. Group the expenses by type (e.g., office supplies, travel, utilities, etc.).
  3. For each expense type, calculate the total expense amount:
     Total Expenses = Sum of all expense amounts for the type.
  4. Optionally, calculate the number of transactions in each type.
  5. Validate the expense amounts (ensure no invalid or negative values).
  6. Store the categorized expense data and return the results.

SQL:  
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH Expenses AS (
    -- Step 1: Retrieve all expense transactions within the specified date range
    SELECT
        e.transaction_id,
        e.expense_type,
        e.amount,
        e.transaction_date
    FROM expenses e
    WHERE e.transaction_date BETWEEN :startDate AND :endDate
),
ExpenseSummary AS (
    -- Step 2: Group the expenses by type and calculate the total expense amount
    SELECT
        e.expense_type,
        SUM(e.amount) AS total_expenses,
        COUNT(e.transaction_id) AS num_transactions
    FROM Expenses e
    GROUP BY e.expense_type
)
-- Step 5: Validate the expense amounts (ensure no invalid or negative values)
SELECT
    es.expense_type,
    es.total_expenses,
    es.num_transactions
FROM ExpenseSummary es
WHERE es.total_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY es.expense_type;
