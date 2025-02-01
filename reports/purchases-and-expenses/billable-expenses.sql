Algorithm:
  
Billable_Expenses_Report(startDate, endDate):
  1. Retrieve all billable expense transactions within the specified date range (startDate to endDate).
  2. Group the billable expenses by project or customer (depending on how the data is linked).
  3. For each project or customer, calculate the total billable expense amount:
     Total Billable Expenses = Sum of all billable expense amounts.
  4. Optionally, calculate the number of transactions for each project or customer.
  5. Validate the billable expense amounts (ensure no invalid or negative values).
  6. Store the billable expenses data and return the results.


SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH BillableExpenses AS (
    -- Step 1: Retrieve all billable expense transactions within the specified date range
    SELECT
        be.transaction_id,
        be.project_id, -- or customer_id depending on how the data is linked
        be.amount,
        be.transaction_date
    FROM billable_expenses be
    WHERE be.transaction_date BETWEEN :startDate AND :endDate
      AND be.amount > 0 -- Ensure the expenses are billable and not negative
),
BillableExpenseSummary AS (
    -- Step 2: Group the billable expenses by project or customer
    -- Here we group by project_id, you can change this to customer_id if necessary
    SELECT
        be.project_id, -- or be.customer_id depending on data structure
        SUM(be.amount) AS total_billable_expenses,
        COUNT(be.transaction_id) AS num_transactions
    FROM BillableExpenses be
    GROUP BY be.project_id
)
-- Step 5: Validate the billable expense amounts (ensure no invalid or negative values)
SELECT
    bes.project_id, -- or bes.customer_id depending on how it's grouped
    bes.total_billable_expenses,
    bes.num_transactions
FROM BillableExpenseSummary bes
WHERE bes.total_billable_expenses >= 0 -- Ensure no negative billable amounts
ORDER BY bes.project_id; -- or customer_id if grouped by customer
