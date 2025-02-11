| #   | customer_id | total_outstanding_balance | age_0_30_days | age_31_60_days | age_61_90_days | age_91_plus_days |
|-----|-------------|---------------------------|---------------|----------------|----------------|------------------|
| 1   | 101         | 9000.00                   | 3000.00       | 0              | 0              | 0                |
| 2   | 102         | 7000.00                   | 2000.00       | 0              | 0              | 0                |
| 3   | 103         | 3000.00                   | 0             | 0              | 0              | 0                |
| 4   | 104         | 3000.00                   | 0             | 0              | 0              | 0                |

Algorithm:
  
Customer_Balance_Overview(startDate, endDate):
  1. Retrieve all outstanding receivables within the specified date range (startDate to endDate).
  2. Group the receivables by customer.
  3. For each customer, calculate the total outstanding balance.
  4. Optionally, calculate the aging breakdown for each customer (0-30 days, 31-60 days, etc.).
  5. Validate the balances (ensure there are no invalid or negative amounts).
  6. Store the customer balance data and return the results.

SQL:

WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
OutstandingReceivables AS (
    -- Step 1: Retrieve all outstanding receivables and join with DateSeries for daily tracking
    SELECT
        ar.customer_id,
        ar.invoice_id,
        ar.total_amount AS receivable_amount,
        ar.due_date,
        ar.total_amount - COALESCE(p.payment_amount, 0) AS outstanding_balance
    FROM acc_receivables ar
    LEFT JOIN acc_payments p ON ar.invoice_id = p.invoice_id
    JOIN DateSeries ds ON ar.due_date = ds.transaction_date  -- Ensure daily records are reflected
),
AgingBreakdown AS (
    -- Step 4: Calculate the aging breakdown for each customer
    SELECT 
        customer_id,
        SUM(CASE 
                WHEN CURRENT_DATE - due_date BETWEEN 0 AND 30 THEN outstanding_balance
                ELSE 0
            END) AS age_0_30_days,
        SUM(CASE 
                WHEN CURRENT_DATE - due_date BETWEEN 31 AND 60 THEN outstanding_balance
                ELSE 0
            END) AS age_31_60_days,
        SUM(CASE 
                WHEN CURRENT_DATE - due_date BETWEEN 61 AND 90 THEN outstanding_balance
                ELSE 0
            END) AS age_61_90_days,
        SUM(CASE 
                WHEN CURRENT_DATE - due_date > 90 THEN outstanding_balance
                ELSE 0
            END) AS age_91_plus_days
    FROM OutstandingReceivables
    GROUP BY customer_id
),
CustomerBalance AS (
    -- Step 3: Calculate the total outstanding balance for each customer
    SELECT 
        customer_id,
        SUM(outstanding_balance) AS total_outstanding_balance
    FROM OutstandingReceivables
    GROUP BY customer_id
)
-- Step 6: Store and return the results
SELECT 
    cb.customer_id,
    cb.total_outstanding_balance,
    ab.age_0_30_days,
    ab.age_31_60_days,
    ab.age_61_90_days,
    ab.age_91_plus_days
FROM CustomerBalance cb
JOIN AgingBreakdown ab ON cb.customer_id = ab.customer_id
WHERE cb.total_outstanding_balance >= 0  -- Step 5: Validate the balances
ORDER BY cb.customer_id;
