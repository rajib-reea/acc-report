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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH ARTransactions AS (
    -- Step 1: Retrieve accounts receivable transactions within the specified date range
    SELECT 
        customer_id,  -- Replace with the appropriate column for customer identification
        transaction_date,
        amount,  -- The amount for each AR transaction
        (CURRENT_DATE - transaction_date) AS days_outstanding  -- Calculate the number of days outstanding
    FROM acc_transactions
    WHERE transaction_type = 'revenue' -- Accounts receivable are typically revenue transactions
      AND transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
),
AgingCategories AS (
    -- Step 3: Group AR balances into aging categories based on the number of days outstanding
    SELECT 
        customer_id,
        CASE
            WHEN days_outstanding BETWEEN 0 AND 30 THEN '0-30 days'
            WHEN days_outstanding BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN days_outstanding BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN days_outstanding > 90 THEN '91+ days'
            ELSE 'Invalid'  -- This can catch any unexpected data (e.g., negative days)
        END AS aging_category,
        SUM(amount) AS total_amount  -- Calculate the total AR amount in each category
    FROM ARTransactions
    GROUP BY customer_id, aging_category
),
ValidatedAging AS (
    -- Step 5: Validate the amounts (exclude negative or invalid balances)
    SELECT 
        customer_id,
        aging_category,
        total_amount
    FROM AgingCategories
    WHERE total_amount >= 0  -- Only include valid balances (no negative amounts)
)
-- Step 6: Store and return the report by customer and aging category
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
             ELSE 5  -- Handling 'Invalid' category if any
         END;
