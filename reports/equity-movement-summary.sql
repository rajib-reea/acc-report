Algorithm:
  EquityMovementSummary(startDate, endDate):
  1. Retrieve opening equity balance.
  2. Retrieve changes in equity (Retained Earnings, New Investments, Dividends Paid).
  3. Calculate equity movements:
     Adjusted Equity = Opening Equity + Retained Earnings + New Investments - Dividends
  4. Validate the updated equity balance.
  5. Store the report and return the results.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH EquityData AS (
    -- Step 1: Retrieve the opening equity balance (assuming it’s from the start of the period)
    SELECT 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'equity' AND transaction_date < :startDate THEN amount ELSE 0 END), 0) AS opening_equity
    FROM acc_transactions
    WHERE is_active = TRUE
),
EquityChanges AS (
    -- Step 2: Retrieve changes in equity: Retained Earnings, New Investments, Dividends Paid
    SELECT 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'retained earnings' THEN amount ELSE 0 END), 0) AS retained_earnings,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'new investments' THEN amount ELSE 0 END), 0) AS new_investments,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'dividends paid' THEN amount ELSE 0 END), 0) AS dividends_paid
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
),
EquityMovement AS (
    -- Step 3: Calculate equity movements
    SELECT 
        opening_equity,
        retained_earnings,
        new_investments,
        dividends_paid,
        -- Adjusted Equity = Opening Equity + Retained Earnings + New Investments - Dividends Paid
        opening_equity + retained_earnings + new_investments - dividends_paid AS adjusted_equity
    FROM EquityData, EquityChanges
)
-- Step 4: Validate the updated equity balance (return the equity summary)
SELECT 
    opening_equity,
    retained_earnings,
    new_investments,
    dividends_paid,
    adjusted_equity
FROM EquityMovement;
