Algorithm:
  
  SalesByItemSummary(startDate, endDate):
  1. Retrieve sales transactions within the specified date range (startDate to endDate).
  2. Group the transactions by item (Item ID or Name).
  3. Calculate total sales for each item:
     Total Sales = Sum of (Quantity * Price) for each item.
  4. Optionally calculate total quantity sold for each item.
  5. Sort the items by total sales or quantity sold in descending order (optional).
  6. Validate the totals (check for negative or invalid amounts).
  7. Store the report for each item and return the results.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH SalesData AS (
    -- Step 1: Retrieve sales transactions within the specified date range
    SELECT 
        item_id, 
        SUM(quantity * price) AS total_sales,
        SUM(quantity) AS total_quantity_sold
    FROM acc_transactions
    WHERE transaction_type = 'revenue' -- Sales transactions assumed to have 'revenue' as transaction type
      AND transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
    GROUP BY item_id
),
ValidatedSales AS (
    -- Step 6: Validate the totals (exclude invalid sales, e.g., negative sales or quantity)
    SELECT 
        item_id, 
        total_sales,
        total_quantity_sold
    FROM SalesData
    WHERE total_sales >= 0  -- Only consider valid sales (non-negative sales)
      AND total_quantity_sold >= 0 -- Only consider valid quantity sold (non-negative quantity)
)
-- Step 5: Sort the items by total sales or total quantity sold in descending order (optional)
SELECT 
    item_id, 
    total_sales,
    total_quantity_sold
FROM ValidatedSales
ORDER BY total_sales DESC;  -- Can change this to 'total_quantity_sold DESC' to sort by quantity
