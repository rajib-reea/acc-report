| #  | Transaction Date | Vendor ID | Aging 0-30 | Aging 31-60 | Aging 61-90 | Aging 91+ |
|----|----------------|-----------|------------|-------------|-------------|----------|
| 1  | 2025-01-01     | 1         | 1000.00    | 0           | 0           | 0        |
| 2  | 2025-01-02     | 1         | 1000.00    | 0           | 0           | 0        |
| 3  | 2025-01-02     | 2         | 2000.00    | 0           | 0           | 0        |
| 4  | 2025-01-03     | 1         | 2500.00    | 0           | 0           | 0        |
| 5  | 2025-01-03     | 2         | 2000.00    | 0           | 0           | 0        |
| 6  | 2025-01-04     | 1         | 2500.00    | 0           | 0           | 0        |
| 7  | 2025-01-04     | 2         | 2000.00    | 0           | 0           | 0        |
| 8  | 2025-01-05     | 1         | 2500.00    | 0           | 0           | 0        |
| 9  | 2025-01-05     | 2         | 3200.00    | 0           | 0           | 0        |
| 10 | 2025-01-06     | 1         | 2500.00    | 0           | 0           | 0        |
| 11 | 2025-01-06     | 2         | 3200.00    | 0           | 0           | 0        |
| 12 | 2025-01-07     | 1         | 2500.00    | 0           | 0           | 0        |
| 13 | 2025-01-07     | 2         | 3200.00    | 0           | 0           | 0        |
| 14 | 2025-01-07     | 3         | 1800.00    | 0           | 0           | 0        |
| 15 | 2025-01-08     | 1         | 2500.00    | 0           | 0           | 0        |
| 16 | 2025-01-08     | 2         | 3200.00    | 0           | 0           | 0        |
| 17 | 2025-01-08     | 3         | 1800.00    | 0           | 0           | 0        |
| 18 | 2025-01-09     | 1         | 2500.00    | 0           | 0           | 0        |
| 19 | 2025-01-09     | 2         | 3200.00    | 0           | 0           | 0        |
| 20 | 2025-01-09     | 3         | 1800.00    | 0           | 0           | 0        |
| 21 | 2025-01-09     | 4         | 500.00     | 0           | 0           | 0        |
| 22 | 2025-01-10     | 1         | 2500.00    | 0           | 0           | 0        |
| 23 | 2025-01-10     | 2         | 3200.00    | 0           | 0           | 0        |
| 24 | 2025-01-10     | 3         | 1800.00    | 0           | 0           | 0        |
| 25 | 2025-01-10     | 4         | 1250.00    | 0           | 0           | 0        |

Algorithm:
  
AP_Aging_Overview(startDate, endDate):
  1. Retrieve all AP transactions within the specified date range (startDate to endDate).
  2. Group the transactions by vendor.
  3. Calculate the aging of accounts payable for each vendor:
     - Group balances into aging categories (e.g., 0-30 days, 31-60 days, 61-90 days, 91+ days).
  4. Calculate the total amount for each aging category.
  5. Validate the amounts (check for negative or invalid balances).
  6. Store the aging overview data and return the results.

SQL:
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
), APTransactions AS (
    -- Step 1: Retrieve all AP transactions within the specified date range
    SELECT
        ap.transaction_id,
        ap.vendor_id,
        ap.invoice_date,
        ap.due_date,
        ap.invoice_amount,
        ap.payment_amount,
        GREATEST(CURRENT_DATE - ap.due_date, 0) AS days_past_due
    FROM acc_accounts_payable ap
    WHERE ap.invoice_date BETWEEN '2025-01-01'::DATE AND '2025-01-10'::DATE
), AgingCategories AS (
    -- Step 3: Calculate the aging of accounts payable for each vendor
    SELECT
        d.transaction_date,
        ap.vendor_id,
        SUM(CASE WHEN ap.days_past_due BETWEEN 0 AND 30 THEN ap.invoice_amount ELSE 0 END) AS aging_0_30,
        SUM(CASE WHEN ap.days_past_due BETWEEN 31 AND 60 THEN ap.invoice_amount ELSE 0 END) AS aging_31_60,
        SUM(CASE WHEN ap.days_past_due BETWEEN 61 AND 90 THEN ap.invoice_amount ELSE 0 END) AS aging_61_90,
        SUM(CASE WHEN ap.days_past_due > 90 THEN ap.invoice_amount ELSE 0 END) AS aging_91_plus
    FROM DateSeries d
    LEFT JOIN APTransactions ap 
        ON ap.invoice_date <= d.transaction_date -- Ensuring transactions are accumulated per day
    GROUP BY d.transaction_date, ap.vendor_id
)
-- Step 5: Store the aging overview data and return the results
SELECT
    ag.transaction_date,
    ag.vendor_id,
    ag.aging_0_30,
    ag.aging_31_60,
    ag.aging_61_90,
    ag.aging_91_plus
FROM AgingCategories ag
ORDER BY ag.transaction_date, ag.vendor_id;
