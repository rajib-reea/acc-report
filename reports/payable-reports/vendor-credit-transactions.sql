Algorithm:
  
Vendor_Credit_Transactions(startDate, endDate):
  1. Retrieve all vendor credit note transactions within the specified date range (startDate to endDate).
  2. Group the credit note transactions by vendor.
  3. For each vendor, calculate the total credit amount issued.
  4. Optionally, group the credit transactions by reason (e.g., returns, adjustments).
  5. Calculate the overall total value of credit transactions within the period.
  6. Validate the credit amounts (ensure no invalid or negative values).
  7. Store the credit transactions data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH CreditNoteTransactions AS (
    -- Step 1: Retrieve all vendor credit note transactions within the specified date range
    SELECT
        ctn.credit_note_id,
        ctn.vendor_id,
        ctn.credit_note_date,
        ctn.credit_amount,
        ctn.reason_code
    FROM vendor_credit_notes ctn
    WHERE ctn.credit_note_date BETWEEN :startDate AND :endDate
),
CreditTransactions AS (
    -- Step 2: Group the credit note transactions by vendor
    SELECT
        ctn.vendor_id,
        SUM(ctn.credit_amount) AS total_credit_amount,
        ctn.reason_code
    FROM CreditNoteTransactions ctn
    WHERE ctn.credit_amount > 0  -- Ensure that credit amounts are positive
    GROUP BY ctn.vendor_id, ctn.reason_code
),
VendorCreditCategories AS (
    -- Step 4: Optionally, group the credit transactions by reason
    SELECT
        ct.vendor_id,
        ct.total_credit_amount,
        ct.reason_code,
        CASE
            WHEN ct.reason_code = 1 THEN 'Returns'
            WHEN ct.reason_code = 2 THEN 'Adjustments'
            ELSE 'Other'
        END AS reason_name
    FROM CreditTransactions ct
)
-- Step 5: Calculate the overall total value of credit transactions within the period
SELECT
    vcc.vendor_id,
    vcc.reason_name,
    SUM(vcc.total_credit_amount) AS total_credit_value
FROM VendorCreditCategories vcc
GROUP BY vcc.vendor_id, vcc.reason_name
ORDER BY vcc.vendor_id, vcc.reason_name;
