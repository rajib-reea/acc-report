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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH RefundTransactions AS (
    -- Step 1: Retrieve all refund transactions within the specified date range
    SELECT
        r.refund_id,
        r.vendor_id,
        r.refund_amount,
        r.refund_date,
        r.refund_reason
    FROM refunds r
    WHERE r.refund_date BETWEEN :startDate AND :endDate
),
VendorRefunds AS (
    -- Step 2: Group the refund transactions by vendor
    SELECT
        r.vendor_id,
        SUM(r.refund_amount) AS total_refund,
        COUNT(r.refund_id) AS refund_transactions_count,
        r.refund_reason
    FROM RefundTransactions r
    WHERE r.refund_amount > 0  -- Ensure the refund amount is positive
    GROUP BY r.vendor_id, r.refund_reason
)
-- Step 6: Validate the refund amounts (ensure no invalid or negative values)
SELECT
    vr.vendor_id,
    vr.refund_reason,
    vr.total_refund,
    vr.refund_transactions_count
FROM VendorRefunds vr
WHERE vr.total_refund >= 0 -- Ensure no negative total refund
ORDER BY vr.vendor_id, vr.refund_reason;
