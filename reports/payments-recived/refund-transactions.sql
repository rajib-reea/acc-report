| #  | vendor_id | refund_reason    | total_refund_amount | overall_refund_amount |
|----|-----------|------------------|---------------------|-----------------------|
| 1  | 1         | Customer Refund  | 380.75              | 1092.25               |
| 2  | 1         | Order Cancellation | 150.00             | 1092.25               |
| 3  | 2         | Product Defect    | 216.50              | 1092.25               |
| 4  | 3         | Order Cancellation | 345.00             | 1092.25               |

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
WITH DateSeries AS (
    -- Generate a series of dates for the specified range (replace with your startDate and endDate)
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE,  -- Replace with your dynamic date range
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
RefundTransactions AS (
    -- Step 1: Retrieve all refund transactions within the specified date range
    SELECT
        r.refund_id,
        r.vendor_id,
        r.refund_date,
        r.refund_reason,  -- Optional: Group by reason such as order cancellation, product defect, etc.
        r.refund_amount
    FROM acc_refunds r
    JOIN DateSeries ds ON r.refund_date = ds.transaction_date
    WHERE r.refund_date BETWEEN '2025-01-01' AND '2025-01-10'  -- Replace with your dynamic date range
    AND r.refund_amount >= 0  -- Validate no negative refund amounts
),
AggregatedRefunds AS (
    -- Step 3: Calculate the total refund amount for each vendor and reason
    SELECT
        vendor_id,
        refund_reason,
        SUM(refund_amount) AS total_refund_amount
    FROM RefundTransactions
    GROUP BY vendor_id, refund_reason
),
OverallRefunds AS (
    -- Step 5: Calculate the overall total value of refunds issued
    SELECT
        SUM(refund_amount) AS overall_refund_amount
    FROM RefundTransactions
)
-- Step 6: Return the aggregated data and overall refund amount
SELECT
    ar.vendor_id,
    ar.refund_reason,
    ar.total_refund_amount,
    orf.overall_refund_amount
FROM AggregatedRefunds ar
CROSS JOIN OverallRefunds orf
ORDER BY ar.vendor_id, ar.refund_reason;
