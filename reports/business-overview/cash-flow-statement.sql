| #   | transaction_date | opening_cash | total_inflows | total_outflows | net_cash_change | closing_cash | expected_closing_cash | invariant_check |
| --- | ---------------- | ------------ | ------------- | -------------- | --------------- | ------------ | --------------------- | --------------- |
| 1   | 2025-01-01       | 0.00         | 3000.00       | 0.00           | 3000.00         | 3000.00      | 3000.00               | 0.00            |
| 2   | 2025-01-02       | 0.00         | 0.00          | 400.00         | -400.00         | 2600.00      | 2600.00               | 0.00            |
| 3   | 2025-01-03       | 0.00         | 0.00          | 0.00           | 0.00            | 2600.00      | 2600.00               | 0.00            |
| 4   | 2025-01-04       | 0.00         | 0.00          | 2400.00        | -2400.00        | 200.00       | 200.00                | 0.00            |
| 5   | 2025-01-05       | 0.00         | 1000.00       | 0.00           | 1000.00         | 1200.00      | 1200.00               | 0.00            |
| 6   | 2025-01-06       | 0.00         | 0.00          | 150.00         | -150.00         | 1050.00      | 1050.00               | 0.00            |
| 7   | 2025-01-07       | 0.00         | 0.00          | 500.00         | -500.00         | 550.00       | 550.00                | 0.00            |
| 8   | 2025-01-08       | 0.00         | 1800.00       | 0.00           | 1800.00         | 2350.00      | 2350.00               | 0.00            |
| 9   | 2025-01-09       | 0.00         | 0.00          | 750.00         | -750.00         | 1600.00      | 1600.00               | 0.00            |
| 10  | 2025-01-10       | 0.00         | 3000.00       | 0.00           | 3000.00         | 4600.00      | 4600.00               | 0.00            |


Algorithm:
CashFlowStatement(startDate, endDate):
  1. Retrieve cash transactions for the date range.
  2. Categorize transactions into:
     a) Operating Activities (Cash from customers, paid to suppliers)
     b) Investing Activities (Buying/Selling assets)
     c) Financing Activities (Loans, Dividends)
  3. Calculate total cash movement in each category.
  4. Compute net cash increase/decrease:
     Net Cash Change = Cash Inflows - Cash Outflows
  5. Determine closing cash balance:
     Closing Cash = Opening Cash + Net Cash Change
  6. Store the report and return results.

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
