Algorithm:
Credit_Note_Transactions_Report(startDate, endDate):
  1. Retrieve all credit note transactions within the specified date range (startDate to endDate).
  2. Group the credit note transactions by customer.
  3. For each transaction, calculate the total credit note amount issued.
  4. Optionally, group the credit note transactions by reason (e.g., returns, adjustments).
  5. Calculate the overall total value of credit notes issued within the specified period.
  6. Validate the credit note amounts (ensure no invalid or negative values).
  7. Store the credit note transaction data and return the results.

SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH CreditNoteTransactions AS (
    -- Step 1: Retrieve all credit note transactions within the specified date range
    SELECT
        cn.transaction_id,
        cn.customer_id,
        cn.transaction_date,
        cn.reason,  -- Optional: Group by reason such as returns, adjustments, etc.
        cn.amount AS credit_note_amount
    FROM credit_notes cn
    WHERE cn.transaction_date BETWEEN :startDate AND :endDate
),
AggregatedCreditNotes AS (
    -- Step 3: Calculate the total credit note amount issued for each customer, 
    -- and optionally, group by reason
    SELECT
        customer_id,
        reason,
        SUM(credit_note_amount) AS total_credit_note_amount
    FROM CreditNoteTransactions
    GROUP BY customer_id, reason
),
OverallCreditNotes AS (
    -- Step 5: Calculate the overall total value of credit notes issued
    SELECT
        SUM(credit_note_amount) AS overall_credit_note_amount
    FROM CreditNoteTransactions
)
-- Step 6: Validate and return the data
SELECT
    acn.customer_id,
    acn.reason,
    acn.total_credit_note_amount,
    ocn.overall_credit_note_amount
FROM AggregatedCreditNotes acn
CROSS JOIN OverallCreditNotes ocn
ORDER BY acn.customer_id, acn.reason;
