Algorithm:
Payments_Collected_Overview(startDate, endDate):
  1. Retrieve all payment transactions within the specified date range (startDate to endDate).
  2. Group the payments by customer or payment method (optional).
  3. Calculate the total payments collected for each customer or method:
     Total Payments = Sum of all payment amounts.
  4. Optionally, calculate the number of payment transactions for each customer or method.
  5. Validate the payment amounts (check for negative or invalid values).
  6. Store the payment overview data and return the results.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH PaymentsData AS (
    -- Step 1: Retrieve all payment transactions within the specified date range
    SELECT
        p.customer_id,
        p.payment_method,
        p.payment_amount,
        p.payment_date
    FROM payments p
    WHERE p.payment_date BETWEEN :startDate AND :endDate
    AND p.payment_amount > 0 -- Ensure no negative payments
),
PaymentsGrouped AS (
    -- Step 2: Group the payments by customer or payment method (optional)
    SELECT
        customer_id,
        payment_method,
        SUM(payment_amount) AS total_payments,
        COUNT(payment_amount) AS total_transactions
    FROM PaymentsData
    GROUP BY customer_id, payment_method
)
-- Step 5: Store and return the payment overview data
SELECT
    pg.customer_id,
    pg.payment_method,
    pg.total_payments,
    pg.total_transactions
FROM PaymentsGrouped pg
ORDER BY pg.customer_id, pg.total_payments DESC;
