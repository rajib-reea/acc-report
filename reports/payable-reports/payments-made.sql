Algorithm:
  
Payments_Made_Report(startDate, endDate):
  1. Retrieve all payments made within the specified date range (startDate to endDate).
  2. Group the payments by vendor.
  3. For each vendor, calculate the total payments made:
     Total Payments Made = Sum of all payment amounts.
  4. Optionally, calculate the number of payment transactions for each vendor.
  5. Validate the payment amounts (ensure no invalid or negative values).
  6. Store the payments made data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH PaymentTransactions AS (
    -- Step 1: Retrieve all payments made within the specified date range
    SELECT
        p.payment_id,
        p.vendor_id,
        p.payment_date,
        p.payment_amount
    FROM payments p
    WHERE p.payment_date BETWEEN :startDate AND :endDate
),
VendorPayments AS (
    -- Step 2: Group the payments by vendor
    SELECT
        p.vendor_id,
        SUM(p.payment_amount) AS total_payments_made,
        COUNT(p.payment_id) AS payment_transactions_count
    FROM PaymentTransactions p
    WHERE p.payment_amount > 0  -- Ensure the payment amount is positive
    GROUP BY p.vendor_id
)
-- Step 5: Validate the payment amounts (ensure no invalid or negative values)
SELECT
    vp.vendor_id,
    vp.total_payments_made,
    vp.payment_transactions_count
FROM VendorPayments vp
WHERE vp.total_payments_made >= 0 -- Ensure no negative total payments
ORDER BY vp.vendor_id;
