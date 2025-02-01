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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH PaymentProcessingTimes AS (
    -- Step 1: Retrieve all payment transactions within the specified date range
    SELECT
        p.payment_id,
        p.customer_id,
        p.payment_method,
        p.initiation_date,
        p.completion_date,
        -- Step 2: Calculate the time taken from initiation to completion
        EXTRACT(EPOCH FROM (p.completion_date - p.initiation_date)) / 3600 AS processing_time_hours -- processing time in hours
    FROM payments p
    WHERE p.initiation_date BETWEEN :startDate AND :endDate
    AND p.completion_date IS NOT NULL  -- Only consider payments with a completion date
),
AggregatedProcessingTimes AS (
    -- Step 3: Calculate the average, minimum, and maximum processing time
    SELECT
        payment_method,
        customer_id,
        AVG(processing_time_hours) AS avg_processing_time,
        MIN(processing_time_hours) AS min_processing_time,
        MAX(processing_time_hours) AS max_processing_time
    FROM PaymentProcessingTimes
    GROUP BY payment_method, customer_id
)
-- Step 5: Store and return the processing time data
SELECT
    apt.payment_method,
    apt.customer_id,
    apt.avg_processing_time,
    apt.min_processing_time,
    apt.max_processing_time
FROM AggregatedProcessingTimes apt
ORDER BY apt.payment_method, apt.customer_id;
