Algorithm:
SalesByCustomerOverview(startDate, endDate):
  1. Retrieve sales transactions within the specified date range (startDate to endDate).
  2. Group the transactions by customer (Customer ID or Name).
  3. Calculate total sales for each customer:
     Total Sales = Sum of (Quantity * Price) for each transaction.
  4. Sort the customers by total sales in descending order (optional).
  5. Validate the totals (check for negative or invalid amounts).
  6. Store the report for each customer and return the results.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH SalesData AS (
    -- Step 1: Retrieve sales transactions within the specified date range
    SELECT 
        customer_id, 
        SUM(quantity * price) AS total_sales
    FROM acc_transactions
    WHERE transaction_type = 'revenue' -- Sales transactions assumed to have 'revenue' as transaction type
      AND transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
    GROUP BY customer_id
),
ValidatedSales AS (
    -- Step 5: Validate the totals (exclude invalid sales, e.g., negative sales)
    SELECT 
        customer_id, 
        total_sales
    FROM SalesData
    WHERE total_sales >= 0  -- Only consider valid sales (non-negative)
)
-- Step 4: Sort customers by total sales in descending order (optional)
SELECT 
    customer_id, 
    total_sales
FROM ValidatedSales
ORDER BY total_sales DESC;
