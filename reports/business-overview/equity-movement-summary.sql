Algorithm:
  EquityMovementSummary(startDate, endDate):
  1. Retrieve opening equity balance.
  2. Retrieve changes in equity (Retained Earnings, New Investments, Dividends Paid).
  3. Calculate equity movements:
     Adjusted Equity = Opening Equity + Retained Earnings + New Investments - Dividends
  4. Validate the updated equity balance.
  5. Store the report and return the results.

  SQL:
WITH DateSeries AS (
    -- Generate a date range from Jan 1 to Jan 10, 2025
    SELECT generate_series(
        '2025-01-01'::DATE,
        '2025-01-10'::DATE,
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
EquityData AS (
    -- Step 1: Retrieve the opening equity balance for each day (cumulative before the day)
    SELECT 
        D.transaction_date,  -- Explicitly qualify the column with the table alias
        COALESCE(SUM(CASE WHEN LOWER(category) = 'equity' AND acc_transactions.transaction_date < D.transaction_date THEN amount ELSE 0 END), 0) AS opening_equity
    FROM acc_transactions
    CROSS JOIN DateSeries D  -- Use CROSS JOIN to generate all combinations
    WHERE is_active = TRUE
    GROUP BY D.transaction_date  -- Group by the date from DateSeries
),
EquityChanges AS (
    -- Step 2: Retrieve changes in equity: Retained Earnings, New Investments, Dividends Paid for each day
    SELECT 
        transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'retained earnings' THEN amount ELSE 0 END), 0) AS retained_earnings,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'new investments' THEN amount ELSE 0 END), 0) AS new_investments,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'dividends paid' THEN amount ELSE 0 END), 0) AS dividends_paid
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
    GROUP BY transaction_date
),
EquityMovement AS (
    -- Step 3: Calculate equity movements for each day
    SELECT 
        D.transaction_date,
        E.opening_equity,
        COALESCE(C.retained_earnings, 0) AS retained_earnings,
        COALESCE(C.new_investments, 0) AS new_investments,
        COALESCE(C.dividends_paid, 0) AS dividends_paid,
        -- Adjusted Equity = Opening Equity + Retained Earnings + New Investments - Dividends Paid
        E.opening_equity + COALESCE(C.retained_earnings, 0) + COALESCE(C.new_investments, 0) - COALESCE(C.dividends_paid, 0) AS adjusted_equity
    FROM DateSeries D
    LEFT JOIN EquityData E ON D.transaction_date = E.transaction_date
    LEFT JOIN EquityChanges C ON D.transaction_date = C.transaction_date
)
-- Step 4: Return the daily equity movement report
SELECT 
    transaction_date,
    opening_equity,
    retained_earnings,
    new_investments,
    dividends_paid,
    adjusted_equity
FROM EquityMovement
ORDER BY transaction_date;
