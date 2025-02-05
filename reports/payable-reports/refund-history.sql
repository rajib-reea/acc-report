| #  | Transaction Date | Vendor ID | Refund Reason       | Total Refund | Refund Transactions Count |
|----|----------------|-----------|---------------------|--------------|---------------------------|
| 1  | 2025-01-01    | 1         | Order Cancellation  | 150.00       | 1                         |
| 2  | 2025-01-01    | 2         | Product Defect      | 75.50        | 1                         |
| 3  | 2025-01-02    | 1         | Customer Refund     | 200.75       | 1                         |
| 4  | 2025-01-02    | 3         | Order Cancellation  | 125.00       | 1                         |
| 5  | 2025-01-03    | 2         | Product Defect      | 50.25        | 1                         |
| 6  | 2025-01-04    | 1         | Customer Refund     | 180.00       | 1                         |
| 7  | 2025-01-04    | 3         | Order Cancellation  | 220.00       | 1                         |
| 8  | 2025-01-05    | 2         | Product Defect      | 90.75        | 1                         |
| 9  | 2025-01-06    | -         | -                   | 0.00         | 0                         |
| 10 | 2025-01-07    | -         | -                   | 0.00         | 0                         |
| 11 | 2025-01-08    | -         | -                   | 0.00         | 0                         |
| 12 | 2025-01-09    | -         | -                   | 0.00         | 0                         |
| 13 | 2025-01-10    | -         | -                   | 0.00         | 0                         |
| 14 | 2025-01-11    | -         | -                   | 0.00         | 0                         |
| 15 | 2025-01-12    | -         | -                   | 0.00         | 0                         |
| 16 | 2025-01-13    | -         | -                   | 0.00         | 0                         |
| 17 | 2025-01-14    | -         | -                   | 0.00         | 0                         |
| 18 | 2025-01-15    | -         | -                   | 0.00         | 0                         |
| 19 | 2025-01-16    | -         | -                   | 0.00         | 0                         |
| 20 | 2025-01-17    | -         | -                   | 0.00         | 0                         |
| 21 | 2025-01-18    | -         | -                   | 0.00         | 0                         |
| 22 | 2025-01-19    | -         | -                   | 0.00         | 0                         |
| 23 | 2025-01-20    | -         | -                   | 0.00         | 0                         |
| 24 | 2025-01-21    | -         | -                   | 0.00         | 0                         |
| 25 | 2025-01-22    | -         | -                   | 0.00         | 0                         |
| 26 | 2025-01-23    | -         | -                   | 0.00         | 0                         |
| 27 | 2025-01-24    | -         | -                   | 0.00         | 0                         |
| 28 | 2025-01-25    | -         | -                   | 0.00         | 0                         |
| 29 | 2025-01-26    | -         | -                   | 0.00         | 0                         |
| 30 | 2025-01-27    | -         | -                   | 0.00         | 0                         |
| 31 | 2025-01-28    | -         | -                   | 0.00         | 0                         |
| 32 | 2025-01-29    | -         | -                   | 0.00         | 0                         |
| 33 | 2025-01-30    | -         | -                   | 0.00         | 0                         |
| 34 | 2025-01-31    | -         | -                   | 0.00         | 0                         |
| 35 | 2025-02-01    | -         | -                   | 0.00         | 0                         |
| ... | ... | ... | ... | ... | ... |

Algorithm:
  
Refund_History_Overview(startDate, endDate):
  1. Retrieve all refund transactions within the specified date range (startDate to endDate).
  2. Group the refund transactions by vendor.
  3. For each vendor, calculate the total refund amount:
     Total Refund = Sum of all refund amounts.
  4. Optionally, group the refunds by reason (e.g., order cancellation, product defect).
  5. Calculate the overall total value of refunds within the specified period.
  6. Validate the refund amounts (ensure no invalid or negative values).
  7. Store the refund history data and return the results.

  SQL:
WITH DateSeries AS (
    -- Step 1: Generate daily dates within the range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
RefundTransactions AS (
    -- Step 2: Retrieve all refund transactions within the specified date range
    SELECT
        r.refund_id,
        r.vendor_id,
        r.refund_date,
        r.refund_amount,
        r.refund_reason
    FROM acc_refunds r
    WHERE r.refund_date BETWEEN '2025-01-01' AND '2025-12-31'
      AND r.refund_amount > 0  -- Ensure the refund amount is positive
),
DailyVendorRefunds AS (
    -- Step 3 & 4: Ensure all dates are represented and aggregate refund data
    SELECT
        d.transaction_date,
        r.vendor_id,
        r.refund_reason,
        COALESCE(SUM(r.refund_amount), 0) AS total_refund,
        COALESCE(COUNT(r.refund_id), 0) AS refund_transactions_count
    FROM DateSeries d
    LEFT JOIN RefundTransactions r 
        ON d.transaction_date = r.refund_date
    GROUP BY d.transaction_date, r.vendor_id, r.refund_reason
)
-- Step 6: Validate the refund amounts and return the results
SELECT
    dvr.transaction_date,
    dvr.vendor_id,
    dvr.refund_reason,
    dvr.total_refund,
    dvr.refund_transactions_count
FROM DailyVendorRefunds dvr
ORDER BY dvr.transaction_date, dvr.vendor_id, dvr.refund_reason;
