| #  | transaction_date | employee_id | total_employee_expenses | num_transactions | avg_expense_amount |
|----|------------------|-------------|-------------------------|------------------|--------------------|
| 1  | 2025-01-01       | 101         | 150.00                  | 1                | 150.00             |
| 2  | 2025-01-01       | 102         | 500.00                  | 1                | 500.00             |
| 3  | 2025-01-02       | 103         | 300.00                  | 1                | 300.00             |
| 4  | 2025-01-03       | 101         | 200.00                  | 1                | 200.00             |
| 5  | 2025-01-03       | 103         | 100.00                  | 1                | 100.00             |
| 6  | 2025-01-04       | 102         | 50.00                   | 1                | 50.00              |
| 7  | 2025-01-05       | 101         | 250.00                  | 1                | 250.00             |
| 8  | 2025-01-06       | 101         | 100.00                  | 1                | 100.00             |
| 9  | 2025-01-06       | 102         | 300.00                  | 1                | 300.00             |
| 10 | 2025-01-06       | 103         | 600.00                  | 1                | 600.00             |
| 11 | 2025-01-07       |             | 0.00                    | 0                | 0.00               |
| 12 | 2025-01-08       | 101         | 120.00                  | 1                | 120.00             |
| 13 | 2025-01-09       | 103         | 180.00                  | 1                | 180.00             |
| 14 | 2025-01-10       | 102         | 210.00                  | 1                | 210.00             |

Algorithm:
  
Employee_Expense_Summary(startDate, endDate):
  1. Retrieve all employee expense transactions within the specified date range (startDate to endDate).
  2. Group the expenses by employee.
  3. For each employee, calculate the total expense amount:
     Total Employee Expenses = Sum of all expenses incurred by the employee.
  4. Optionally, calculate the number of transactions for each employee.
  5. Optionally, calculate the average expense amount per employee.
  6. Validate the expense amounts (ensure no invalid or negative values).
  7. Store the employee-specific expense data and return the results.

SQL:
  
WITH DateSeries AS (
    -- Generate a series of dates from January 1, 2025, to January 10, 2025
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
EmployeeExpenses AS (
    -- Retrieve all employee expense transactions within the fixed date range
    SELECT
        e.transaction_id,
        e.employee_id,
        e.amount,
        e.transaction_date
    FROM acc_expenses e
    WHERE e.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND e.employee_id IS NOT NULL -- Ensure the expense is linked to an employee
),
DailyEmployeeExpenseSummary AS (
    -- Left join DateSeries with EmployeeExpenses to ensure all dates are represented
    SELECT
        ds.transaction_date,
        ee.employee_id,
        COALESCE(SUM(ee.amount), 0) AS total_employee_expenses,
        COALESCE(COUNT(ee.transaction_id), 0) AS num_transactions,
        COALESCE(AVG(ee.amount), 0) AS avg_expense_amount
    FROM DateSeries ds
    LEFT JOIN EmployeeExpenses ee
        ON ds.transaction_date = ee.transaction_date
    GROUP BY ds.transaction_date, ee.employee_id
)
-- Validate and return the final daily report with rounded values
SELECT
    ees.transaction_date,
    ees.employee_id,
    ROUND(ees.total_employee_expenses, 2) AS total_employee_expenses, -- Rounded to 2 digits
    ees.num_transactions,
    ROUND(ees.avg_expense_amount, 2) AS avg_expense_amount -- Rounded to 2 digits
FROM DailyEmployeeExpenseSummary ees
WHERE ees.total_employee_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY ees.transaction_date, ees.employee_id;
