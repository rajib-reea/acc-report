| #  | Transaction Date | Vendor ID | Total Payments Made | Payment Transactions Count |
|----|----------------|-----------|----------------------|----------------------------|
| 1  | 2025-01-01    | 1         | 100.50               | 1                          |
| 2  | 2025-01-01    | 2         | 50.00                | 1                          |
| 3  | 2025-01-02    | 1         | 200.75               | 1                          |
| 4  | 2025-01-02    | 3         | 300.00               | 1                          |
| 5  | 2025-01-03    | 2         | 75.25                | 1                          |
| 6  | 2025-01-04    | 1         | 250.00               | 1                          |
| 7  | 2025-01-04    | 3         | 150.00               | 1                          |
| 8  | 2025-01-05    | 2         | 125.75               | 1                          |
| 9  | 2025-01-06    | -         | 0.00                 | 0                          |
| 10 | 2025-01-07    | -         | 0.00                 | 0                          |
| 11 | 2025-01-08    | -         | 0.00                 | 0                          |
| 12 | 2025-01-09    | -         | 0.00                 | 0                          |
| 13 | 2025-01-10    | -         | 0.00                 | 0                          |
| 14 | 2025-01-11    | -         | 0.00                 | 0                          |
| 15 | 2025-01-12    | -         | 0.00                 | 0                          |
| 16 | 2025-01-13    | -         | 0.00                 | 0                          |
| 17 | 2025-01-14    | -         | 0.00                 | 0                          |
| 18 | 2025-01-15    | -         | 0.00                 | 0                          |
| 19 | 2025-01-16    | -         | 0.00                 | 0                          |
| 20 | 2025-01-17    | -         | 0.00                 | 0                          |
| ... | ...          | ...       | ...                  | ...                        |
| 100 | 2025-04-07   | -         | 0.00                 | 0                          |

Algorithm:
  
WITH DateSeries AS (
    -- Generate daily dates within the range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
PaymentTransactions AS (
    -- Retrieve payments made within the specified date range
    SELECT
        p.payment_id,
        p.vendor_id,
        p.payment_date,
        p.payment_amount
    FROM acc_payments p
    WHERE p.payment_date BETWEEN '2025-01-01' AND '2025-12-31'
      AND p.payment_amount > 0  -- Ensure valid payment amounts
),
DailyVendorPayments AS (
    -- Join generated dates with payments to ensure all dates are represented
    SELECT
        d.transaction_date,
        p.vendor_id,
        COALESCE(SUM(p.payment_amount), 0) AS total_payments_made,
        COALESCE(COUNT(p.payment_id), 0) AS payment_transactions_count
    FROM DateSeries d
    LEFT JOIN PaymentTransactions p 
        ON d.transaction_date = p.payment_date
    GROUP BY d.transaction_date, p.vendor_id
)
-- Select the final report with daily vendor payments
SELECT
    dvp.transaction_date,
    dvp.vendor_id,
    dvp.total_payments_made,
    dvp.payment_transactions_count
FROM DailyVendorPayments dvp
ORDER BY dvp.transaction_date, dvp.vendor_id;
