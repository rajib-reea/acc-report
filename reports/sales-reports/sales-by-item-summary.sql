| #   | transaction_date | item_id | total_sales | total_quantity_sold |
|-----|------------------|---------|-------------|----------------------|
| 1   | 2025-01-01       | 10      | 3000.00     | 25                   |
| 2   | 2025-01-01       | 3       | 2500.05     | 15                   |
| 3   | 2025-01-01       | 8       | 1800.00     | 20                   |
| 4   | 2025-01-01       | 1       | 1500.00     | 10                   |
| 5   | 2025-01-01       | 5       | 1000.00     | 8                    |
| 6   | 2025-01-02       | 10      | 3000.00     | 25                   |
| 7   | 2025-01-02       | 3       | 2500.05     | 15                   |
| 8   | 2025-01-02       | 8       | 1800.00     | 20                   |
| 9   | 2025-01-02       | 1       | 1500.00     | 10                   |
| 10  | 2025-01-02       | 5       | 1000.00     | 8                    |
| 11  | 2025-01-03       | 10      | 3000.00     | 25                   |
| 12  | 2025-01-03       | 3       | 2500.05     | 15                   |
| 13  | 2025-01-03       | 8       | 1800.00     | 20                   |
| 14  | 2025-01-03       | 1       | 1500.00     | 10                   |
| 15  | 2025-01-03       | 5       | 1000.00     | 8                    |
| 16  | 2025-01-04       | 10      | 3000.00     | 25                   |
| 17  | 2025-01-04       | 3       | 2500.05     | 15                   |
| 18  | 2025-01-04       | 8       | 1800.00     | 20                   |
| 19  | 2025-01-04       | 1       | 1500.00     | 10                   |
| 20  | 2025-01-04       | 5       | 1000.00     | 8                    |
| 21  | 2025-01-05       | 10      | 3000.00     | 25                   |
| 22  | 2025-01-05       | 3       | 2500.05     | 15                   |
| 23  | 2025-01-05       | 8       | 1800.00     | 20                   |
| 24  | 2025-01-05       | 1       | 1500.00     | 10                   |
| 25  | 2025-01-05       | 5       | 1000.00     | 8                    |
| 26  | 2025-01-06       | 10      | 3000.00     | 25                   |
| 27  | 2025-01-06       | 3       | 2500.05     | 15                   |
| 28  | 2025-01-06       | 8       | 1800.00     | 20                   |
| 29  | 2025-01-06       | 1       | 1500.00     | 10                   |
| 30  | 2025-01-06       | 5       | 1000.00     | 8                    |
| 31  | 2025-01-07       | 10      | 3000.00     | 25                   |
| 32  | 2025-01-07       | 3       | 2500.05     | 15                   |
| 33  | 2025-01-07       | 8       | 1800.00     | 20                   |
| 34  | 2025-01-07       | 1       | 1500.00     | 10                   |
| 35  | 2025-01-07       | 5       | 1000.00     | 8                    |
| 36  | 2025-01-08       | 10      | 3000.00     | 25                   |
| 37  | 2025-01-08       | 3       | 2500.05     | 15                   |
| 38  | 2025-01-08       | 8       | 1800.00     | 20                   |
| 39  | 2025-01-08       | 1       | 1500.00     | 10                   |
| 40  | 2025-01-08       | 5       | 1000.00     | 8                    |
| 41  | 2025-01-09       | 10      | 3000.00     | 25                   |
| 42  | 2025-01-09       | 3       | 2500.

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
  WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
SalesData AS (
    -- Step 1: Retrieve sales transactions within the specified date range
    SELECT 
        item_id, 
        SUM(quantity * price) AS total_sales,
        SUM(quantity) AS total_quantity_sold
    FROM acc_transactions
    WHERE transaction_type = 'revenue' -- Sales transactions assumed to have 'revenue' as transaction type
      AND transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
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
    ds.transaction_date,  -- Use transaction_date from DateSeries
    vs.item_id, 
    vs.total_sales,
    vs.total_quantity_sold
FROM DateSeries ds
LEFT JOIN ValidatedSales vs 
    ON ds.transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY ds.transaction_date, vs.total_sales DESC;  -- Can change to 'total_quantity_sold DESC' to sort by quantity
