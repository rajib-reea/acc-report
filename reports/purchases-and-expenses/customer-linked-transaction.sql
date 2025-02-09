| #   | Transaction Date | Customer ID | Total Customer Expenses | Num Transactions |
|-----|------------------|-------------|-------------------------|------------------|
| 1   | 2025-01-01       | 1           | 150.00                  | 1                |
| 2   | 2025-01-01       | 3           | 500.00                  | 1                |
| 3   | 2025-01-02       | 2           | 300.00                  | 1                |
| 4   | 2025-01-03       | 1           | 200.00                  | 1                |
| 5   | 2025-01-03       | 2           | 100.00                  | 1                |
| 6   | 2025-01-04       | 3           | 50.00                   | 1                |
| 7   | 2025-01-05       | 1           | 250.00                  | 1                |
| 8   | 2025-01-06       | 1           | 100.00                  | 1                |
| 9   | 2025-01-06       | 2           | 600.00                  | 1                |
| 10  | 2025-01-06       | 3           | 300.00                  | 1                |
| 11  | 2025-01-07       |             | 0.00                    | 0                |
| 12  | 2025-01-08       | 1           | 120.00                  | 1                |
| 13  | 2025-01-09       | 2           | 180.00                  | 1                |
| 14  | 2025-01-10       | 3           | 210.00                  | 1                |

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
  
WITH DateSeries AS (
    -- Generate a series of dates from January 1, 2025, to January 10, 2025
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
CustomerExpenses AS (
    -- Retrieve all expense transactions within the fixed date range linked to customers
    SELECT
        e.transaction_id,
        e.customer_id,
        e.amount,
        e.transaction_date
    FROM acc_expenses e
    WHERE e.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND e.customer_id IS NOT NULL  
      AND e.amount > 0               
),
DailyCustomerExpenseSummary AS (
    -- Left join DateSeries with CustomerExpenses to ensure all dates are represented
    SELECT
        ds.transaction_date,
        ce.customer_id,
        COALESCE(SUM(ce.amount), 0) AS total_customer_expenses,
        COALESCE(COUNT(ce.transaction_id), 0) AS num_transactions
    FROM DateSeries ds
    LEFT JOIN CustomerExpenses ce
        ON ds.transaction_date = ce.transaction_date
    GROUP BY ds.transaction_date, ce.customer_id
)
-- Validate and return the final daily report
SELECT
    transaction_date,
    customer_id,
    total_customer_expenses,
    num_transactions
FROM DailyCustomerExpenseSummary
WHERE total_customer_expenses >= 0  
ORDER BY transaction_date, customer_id;

