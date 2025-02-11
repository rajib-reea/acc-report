| #   | Customer ID | Aging Category | Total Amount |
|-----|-------------|----------------|--------------|
| 1   | 101         | 31-60 days     | 8800.00      |
| 2   | 102         | 31-60 days     | 1000.00      |

Algorithm:
  
  AR_Aging_Summary_Report(startDate, endDate):
  1. Retrieve accounts receivable (AR) transactions within the specified date range (startDate to endDate).
  2. Group the transactions by customer.
  3. Calculate the aging of receivables:
     - Group AR balances into aging categories (e.g., 0-30 days, 31-60 days, 61-90 days, 91+ days).
  4. Calculate the total amount for each aging category.
  5. Validate the amounts (check for negative or invalid balances).
  6. Store the report by customer and aging category and return the results.

  SQL:
  
WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
ARTransactions AS (
    -- Step 1: Retrieve AR transactions within the specified date range
    SELECT 
        customer_id,  
        transaction_date,
        amount,  
        (CURRENT_DATE - transaction_date) AS days_outstanding  
    FROM acc_transactions
    WHERE transaction_type = 'revenue'  
      AND transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
      AND is_active = TRUE
),
AgingCategories AS (
    -- Step 3: Group AR balances into aging categories
    SELECT 
        customer_id,
        CASE
            WHEN days_outstanding BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN days_outstanding BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN days_outstanding BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN days_outstanding > 90 THEN '91+ days'
            ELSE 'Invalid'  
        END AS aging_category,
        SUM(amount) AS total_amount  
    FROM ARTransactions
    GROUP BY customer_id, aging_category
),
ValidatedAging AS (
    -- Step 5: Validate the amounts
    SELECT 
        customer_id,
        aging_category,
        total_amount
    FROM AgingCategories
    WHERE total_amount >= 0  
)
-- Step 6: Return the report
SELECT 
    customer_id,
    aging_category,
    total_amount
FROM ValidatedAging
ORDER BY customer_id, 
         CASE 
             WHEN aging_category = '0-30 days' THEN 1
             WHEN aging_category = '31-60 days' THEN 2
             WHEN aging_category = '61-90 days' THEN 3
             WHEN aging_category = '91+ days' THEN 4
             ELSE 5  
         END;
