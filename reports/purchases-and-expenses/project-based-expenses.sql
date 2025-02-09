| project_id | total_project_expenses | num_transactions |
|------------|------------------------|------------------|
| 101        | 820.00                 | 5                |
| 102        | 1060.00                | 4                |
| 103        | 1180.00                | 4                |

Algorithm:
  
Project_Based_Expenses_Report(startDate, endDate):
  1. Retrieve all expense transactions within the specified date range (startDate to endDate) that are linked to specific projects.
  2. Group the expenses by project.
  3. For each project, calculate the total expense amount:
     Total Project Expenses = Sum of all expenses linked to the project.
  4. Optionally, calculate the number of transactions for each project.
  5. Validate the expense amounts (ensure no invalid or negative values).
  6. Store the project-based expense data and return the results.

SQL:
  WITH DateSeries AS (
    -- Generate a series of dates from '2025-01-01' to '2025-01-10' to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
ProjectExpenses AS (
    -- Step 1: Retrieve all expense transactions within the specified date range and linked to specific projects
    SELECT
        e.transaction_id,
        e.project_id,
        e.amount,
        e.transaction_date
    FROM acc_expenses e
    WHERE e.transaction_date BETWEEN '2025-01-01' AND '2025-01-10' -- Ensure the expense is linked to the given date range
      AND e.project_id IS NOT NULL -- Ensure the expense is linked to a project
),
ProjectExpenseSummary AS (
    -- Step 2: Group the expenses by project and calculate the total expense amount
    SELECT
        pe.project_id,
        SUM(pe.amount) AS total_project_expenses,
        COUNT(pe.transaction_id) AS num_transactions
    FROM ProjectExpenses pe
    GROUP BY pe.project_id
)
-- Step 5: Validate the expense amounts (ensure no invalid or negative values)
SELECT
    pes.project_id,
    pes.total_project_expenses,
    pes.num_transactions
FROM ProjectExpenseSummary pes
WHERE pes.total_project_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY pes.project_id;
