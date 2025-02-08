| #  | transaction_date | payment_method | customer_id | avg_processing_time | min_processing_time | max_processing_time |
|----|------------------|----------------|-------------|---------------------|----------------------|----------------------|
| 1  | 2025-01-01       | Bank Transfer  | 102         | 48.00               | 48.00                | 48.00                |
| 2  | 2025-01-01       | Credit Card    | 101         | 24.00               | 24.00                | 24.00                |
| 3  | 2025-01-01       | PayPal         | 103         | 24.00               | 24.00                | 24.00                |
| 4  | 2025-01-02       | Credit Card    | 101         | 48.00               | 48.00                | 48.00                |
| 5  | 2025-01-02       | PayPal         | 103         | 48.00               | 48.00                | 48.00                |
| 6  | 2025-01-03       | Bank Transfer  | 102         | 48.00               | 48.00                | 48.00                |

Algorithm:
  
Payment_Processing_Time_Report(startDate, endDate):
  1. Retrieve all payment transactions within the specified date range (startDate to endDate).
  2. For each payment transaction, calculate the time taken from payment initiation to payment completion:
     Processing Time = Payment Completion Date - Payment Initiation Date.
  3. Optionally, calculate the average, minimum, and maximum processing time.
  4. Optionally, group the results by payment method or customer to analyze performance.
  5. Validate the processing times (ensure no negative or invalid values).
  6. Store the processing time data and return the results.

  SQL:
  
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
PaymentProcessingTimes AS (
    -- Step 2: Retrieve all payment transactions matching the dates in the date series
    SELECT
        p.payment_id,
        p.customer_id,
        p.payment_method,
        p.initiation_date,
        p.payment_date,  -- using payment_date instead of completion_date
        -- Step 3: Calculate the time taken from initiation to payment_date (completion) in hours
        (p.payment_date - p.initiation_date) * 24 AS processing_time_hours -- Difference in days, multiplied by 24 for hours
    FROM acc_payments p
    JOIN DateSeries ds ON p.initiation_date::DATE = ds.transaction_date
    WHERE p.payment_date IS NOT NULL  -- Only consider payments with a payment date
),
AggregatedProcessingTimes AS (
    -- Step 4: Calculate the average, minimum, and maximum processing time
    SELECT
        ds.transaction_date,
        p.payment_method,
        p.customer_id,
        ROUND(AVG(p.processing_time_hours), 2) AS avg_processing_time,  -- Rounding to 2 decimal places
        ROUND(MIN(p.processing_time_hours), 2) AS min_processing_time,  -- Rounding to 2 decimal places
        ROUND(MAX(p.processing_time_hours), 2) AS max_processing_time   -- Rounding to 2 decimal places
    FROM PaymentProcessingTimes p
    JOIN DateSeries ds ON p.initiation_date::DATE = ds.transaction_date
    GROUP BY ds.transaction_date, p.payment_method, p.customer_id
)
-- Step 7: Store and return the processing time data
SELECT
    apt.transaction_date,
    apt.payment_method,
    apt.customer_id,
    apt.avg_processing_time,
    apt.min_processing_time,
    apt.max_processing_time
FROM AggregatedProcessingTimes apt
ORDER BY apt.transaction_date, apt.payment_method, apt.customer_id;
