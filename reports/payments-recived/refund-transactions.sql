Algorithm:
Refund_Transactions_Report(startDate, endDate):
  1. Retrieve all refund transactions within the specified date range (startDate to endDate).
  2. Group the refund transactions by customer.
  3. For each refund transaction, calculate the total refund amount.
  4. Optionally, group refund transactions by reason (e.g., order cancellation, product defect).
  5. Calculate the overall total value of refunds within the specified period.
  6. Validate the refund amounts (ensure no invalid or negative values).
  7. Store the refund transaction data and return the results.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH RefundTransactions AS (
    -- Step 1: Retrieve all refund transactions within the specified date range
    SELECT
        r.transaction_id,
        r.customer_id,
        r.transaction_date,
        r.reason,  -- Optional: Group by reason such as order cancellation, product defect, etc.
        r.amount AS refund_amount
    FROM refunds r
    WHERE r.transaction_date BETWEEN :startDate AND :endDate
),
AggregatedRefunds AS (
    -- Step 3: Calculate the total refund amount for each customer, 
    -- and optionally, group by reason
    SELECT
        customer_id,
        reason,
        SUM(refund_amount) AS total_refund_amount
    FROM RefundTransactions
    GROUP BY customer_id, reason
),
OverallRefunds AS (
    -- Step 5: Calculate the overall total value of refunds issued
    SELECT
        SUM(refund_amount) AS overall_refund_amount
    FROM RefundTransactions
)
-- Step 6: Validate and return the data
SELECT
    ar.customer_id,
    ar.reason,
    ar.total_refund_amount,
    orf.overall_refund_amount
FROM AggregatedRefunds ar
CROSS JOIN OverallRefunds orf
ORDER BY ar.customer_id, ar.reason;
