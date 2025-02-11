| customer_id | total_outstanding_balance | age_0_30_days | age_31_60_days | age_61_90_days | age_91_plus_days | overall_outstanding_receivables |
|-------------|----------------------------|---------------|----------------|----------------|------------------|---------------------------------|
| 101         | 9000.00                    | 3000.00       | 0              | 0              | 0                | 22000.00                        |
| 102         | 7000.00                    | 2000.00       | 0              | 0              | 0                | 22000.00                        |
| 103         | 3000.00                    | 0             | 0              | 0              | 0                | 22000.00                        |
| 104         | 3000.00                    | 0             | 0              | 0              | 0                | N/A                             |

Algorithm:

  Receivables_Summary_Report(startDate, endDate):
  1. Retrieve all receivables transactions within the specified date range (startDate to endDate).
  2. Group the transactions by customer.
  3. Calculate the total outstanding receivables for each customer.
  4. Optionally, calculate the aging of receivables for each customer.
  5. Calculate the overall total of outstanding receivables.
  6. Validate the totals (check for invalid or negative balances).
  7. Store the summary of receivables and return the results.\

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
    -- Step 1: Retrieve all receivables transactions within the specified date range
    SELECT
        ar.customer_id,
        ar.invoice_id,
        ar.total_amount AS receivable_amount,
        ar.due_date,
        ar.total_amount - COALESCE(p.payment_amount, 0) AS outstanding_balance
    FROM acc_receivables ar
    LEFT JOIN acc_payments p ON ar.invoice_id = p.invoice_id
    WHERE ar.due_date BETWEEN '2025-01-01' AND '2025-12-31'
),
AgingBreakdown AS (
    -- Step 4: Optionally calculate the aging of receivables for each customer
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
ReceivablesSummary AS (
    -- Step 3: Calculate the total outstanding receivables for each customer
    SELECT 
        customer_id,
        SUM(outstanding_balance) AS total_outstanding_balance
    FROM OutstandingReceivables
    GROUP BY customer_id
)
-- Step 5: Calculate the overall total of outstanding receivables
SELECT 
    rs.customer_id,
    rs.total_outstanding_balance,
    ab.age_0_30_days,
    ab.age_31_60_days,
    ab.age_61_90_days,
    ab.age_91_plus_days,
    (SELECT SUM(outstanding_balance) FROM OutstandingReceivables) AS overall_outstanding_receivables
FROM ReceivablesSummary rs
JOIN AgingBreakdown ab ON rs.customer_id = ab.customer_id
ORDER BY rs.customer_id;

