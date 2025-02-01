Algorithm SalesPerformanceBySalesperson(startDate, endDate):
  1. Retrieve sales transactions within the specified date range (startDate to endDate).
  2. Group the transactions by salesperson (Salesperson ID or Name).
  3. Calculate total sales for each salesperson:
     Total Sales = Sum of (Quantity * Price) for each salesperson.
  4. Optionally calculate additional metrics (e.g., number of transactions or total quantity sold).
  5. Sort the salespeople by total sales in descending order (optional).
  6. Validate the totals (check for negative or invalid amounts).
  7. Store the report for each salesperson and return the results.

-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH SalesData AS (
    -- Step 1: Retrieve sales transactions within the specified date range
    SELECT 
        salesperson_id,  -- Replace with appropriate column for salesperson identification
        SUM(quantity * price) AS total_sales,  -- Total sales for each transaction
        COUNT(*) AS total_transactions,        -- Number of transactions for the salesperson (optional metric)
        SUM(quantity) AS total_quantity_sold  -- Total quantity sold by the salesperson (optional metric)
    FROM acc_transactions
    WHERE transaction_type = 'revenue' -- Sales transactions assumed to have 'revenue' as transaction type
      AND transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
    GROUP BY salesperson_id
),
ValidatedSales AS (
    -- Step 6: Validate the totals (exclude invalid sales, e.g., negative sales or quantity)
    SELECT 
        salesperson_id, 
        total_sales,
        total_transactions,
        total_quantity_sold
    FROM SalesData
    WHERE total_sales >= 0  -- Only consider valid sales (non-negative sales)
      AND total_quantity_sold >= 0 -- Only consider valid quantity sold (non-negative quantity)
)
-- Step 5: Sort the salespeople by total sales in descending order (optional)
SELECT 
    salesperson_id,
    total_sales,
    total_transactions,
    total_quantity_sold
FROM ValidatedSales
ORDER BY total_sales DESC;  -- Can change this to 'total_transactions DESC' to sort by number of transactions
