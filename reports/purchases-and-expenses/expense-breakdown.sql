| #  | transaction_date | category_id | total_expenses | num_transactions |
|----|------------------|-------------|----------------|------------------|
| 1  | 2025-01-01       | 1           | 150.00         | 1                |
| 2  | 2025-01-01       | 2           | 500.00         | 1                |
| 3  | 2025-01-02       | 3           | 300.00         | 1                |
| 4  | 2025-01-03       | 1           | 200.00         | 1                |
| 5  | 2025-01-03       | 3           | 100.00         | 1                |
| 6  | 2025-01-04       | 2           | 50.00          | 1                |
| 7  | 2025-01-05       | 1           | 250.00         | 1                |
| 8  | 2025-01-06       | 1           | 100.00         | 1                |
| 9  | 2025-01-06       | 2           | 300.00         | 1                |
| 10 | 2025-01-06       | 3           | 600.00         | 1                |
| 11 | 2025-01-07       |             | 0.00           | 0                |
| 12 | 2025-01-08       | 1           | 120.00         | 1                |
| 13 | 2025-01-09       | 3           | 180.00         | 1                |
| 14 | 2025-01-10       | 2           | 210.00         | 1                |

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
  WITH DateSeries AS (
    -- Generate a series of dates from January 1, 2025, to January 10, 2025
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
Expenses AS (
    -- Step 1: Retrieve all expense transactions within the specified date range
    SELECT
        e.transaction_id,
        e.category_id,
        e.amount,
        e.transaction_date
    FROM acc_expenses e
    WHERE e.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),
ExpenseSummary AS (
    -- Step 2: Group the expenses by category and calculate the total expense amount
    SELECT
        es.transaction_date,
        e.category_id,
        COALESCE(SUM(e.amount), 0) AS total_expenses,
        COALESCE(COUNT(e.transaction_id), 0) AS num_transactions
    FROM DateSeries es
    LEFT JOIN Expenses e
        ON es.transaction_date = e.transaction_date
    GROUP BY es.transaction_date, e.category_id
)
-- Step 5: Validate the expense amounts (ensure no invalid or negative values)
SELECT
    es.transaction_date,
    es.category_id,
    es.total_expenses,
    es.num_transactions
FROM ExpenseSummary es
WHERE es.total_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY es.transaction_date, es.category_id;
