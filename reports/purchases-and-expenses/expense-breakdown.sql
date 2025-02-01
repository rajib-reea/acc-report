Algorithm: 
  
Expense_Breakdown_Report(startDate, endDate):
  1. Retrieve all expense transactions within the specified date range (startDate to endDate).
  2. Group the expenses by category or department.
  3. For each category or department, calculate the total expense amount:
     Total Expenses = Sum of all expense amounts in the category.
  4. Optionally, calculate the number of transactions in each category.
  5. Validate the expense amounts (ensure no invalid or negative values).
  6. Store the expense breakdown data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH Expenses AS (
    -- Step 1: Retrieve all expense transactions within the specified date range
    SELECT
        e.transaction_id,
        e.category_id,
        e.amount,
        e.transaction_date
    FROM expenses e
    WHERE e.transaction_date BETWEEN :startDate AND :endDate
),
ExpenseSummary AS (
    -- Step 2: Group the expenses by category and calculate the total expense amount
    SELECT
        e.category_id,
        SUM(e.amount) AS total_expenses,
        COUNT(e.transaction_id) AS num_transactions
    FROM Expenses e
    GROUP BY e.category_id
)
-- Step 5: Validate the expense amounts (ensure no invalid or negative values)
SELECT
    es.category_id,
    es.total_expenses,
    es.num_transactions
FROM ExpenseSummary es
WHERE es.total_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY es.category_id;
