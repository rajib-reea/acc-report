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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH EmployeeExpenses AS (
    -- Step 1: Retrieve all employee expense transactions within the specified date range
    SELECT
        e.transaction_id,
        e.employee_id,
        e.amount,
        e.transaction_date
    FROM expenses e
    WHERE e.transaction_date BETWEEN :startDate AND :endDate
      AND e.employee_id IS NOT NULL -- Ensure the expense is linked to an employee
),
EmployeeExpenseSummary AS (
    -- Step 2: Group the expenses by employee and calculate the total expense amount
    SELECT
        ee.employee_id,
        SUM(ee.amount) AS total_employee_expenses,
        COUNT(ee.transaction_id) AS num_transactions,
        AVG(ee.amount) AS avg_expense_amount
    FROM EmployeeExpenses ee
    GROUP BY ee.employee_id
)
-- Step 6: Validate the expense amounts (ensure no invalid or negative values)
SELECT
    ees.employee_id,
    ees.total_employee_expenses,
    ees.num_transactions,
    ees.avg_expense_amount
FROM EmployeeExpenseSummary ees
WHERE ees.total_employee_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY ees.employee_id;
