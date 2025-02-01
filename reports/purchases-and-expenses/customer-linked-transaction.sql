Algorithm:
  
Customer_Linked_Expenses(startDate, endDate):
  1. Retrieve all expense transactions within the specified date range (startDate to endDate) that are linked to customers.
  2. Group the expenses by customer.
  3. For each customer, calculate the total expense amount linked to that customer:
     Total Customer Expenses = Sum of all customer-linked expenses.
  4. Optionally, calculate the number of transactions linked to each customer.
  5. Validate the expense amounts (ensure no invalid or negative values).
  6. Store the customer-linked expense data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH CustomerExpenses AS (
    -- Step 1: Retrieve all expense transactions within the specified date range that are linked to customers
    SELECT
        e.transaction_id,
        e.customer_id,
        e.amount,
        e.transaction_date
    FROM expenses e
    WHERE e.transaction_date BETWEEN :startDate AND :endDate
      AND e.customer_id IS NOT NULL -- Ensure the expense is linked to a customer
),
CustomerExpenseSummary AS (
    -- Step 2: Group the expenses by customer and calculate the total expense amount
    SELECT
        ce.customer_id,
        SUM(ce.amount) AS total_customer_expenses,
        COUNT(ce.transaction_id) AS num_transactions
    FROM CustomerExpenses ce
    GROUP BY ce.customer_id
)
-- Step 5: Validate the expense amounts (ensure no invalid or negative values)
SELECT
    ces.customer_id,
    ces.total_customer_expenses,
    ces.num_transactions
FROM CustomerExpenseSummary ces
WHERE ces.total_customer_expenses >= 0 -- Ensure no negative expense amounts
ORDER BY ces.customer_id;
