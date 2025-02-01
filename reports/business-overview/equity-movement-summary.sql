Note: Opening Equity:= Opening Equity + Adjusted Equity (for all rows except the first).
  Its not implemented yet
  
| #  | transaction_date | opening_equity | net_income | retained_earnings | new_investments | dividends_paid | adjusted_equity | invariant_mismatch |
|----|------------------|----------------|------------|-------------------|-----------------|----------------|-----------------|-----------------|
| 1  | 2025-01-01       | 0              | 3000.00    | 0                 | 0               | 0              | 3000.00         | 0.00            |
| 2  | 2025-01-02       | 0              | 0          | 0                 | 0               | 0              | 0               | 0.00            |
| 3  | 2025-01-03       | 0              | 0          | 0                 | 0               | 0              | 0               | 0.00            |
| 4  | 2025-01-04       | 0              | 0          | 0                 | 0               | 0              | 0               | 0.00            |
| 5  | 2025-01-05       | 0              | 1000.00    | 0                 | 0               | 0              | 1000.00         | 0.00            |
| 6  | 2025-01-06       | 0              | 0          | 0                 | 0               | 0              | 0               | 0.00            |
| 7  | 2025-01-07       | 0              | 0          | 0                 | 0               | 0              | 0               | 0.00            |
| 8  | 2025-01-08       | 0              | 1800.00    | 0                 | 0               | 0              | 1800.00         | 0.00            |
| 9  | 2025-01-09       | 0              | 0          | 0                 | 0               | 0              | 0               | 0.00            |
| 10 | 2025-01-10       | 0              | 3000.00    | 0                 | 0               | 0              | 3000.00         | 0.00            |

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
Inflows AS (
    SELECT 
        transaction_date,
        SUM(amount) AS total_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital')  -- Inflows
    GROUP BY transaction_date
),
Outflows AS (
    SELECT 
        transaction_date,
        SUM(amount) AS total_outflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 
                              'professional services', 'salaries', 'insurance', 'taxes')  -- Outflows
    GROUP BY transaction_date
),
NetIncome AS (
    SELECT 
        I.transaction_date,
        COALESCE(I.total_inflow, 0) - COALESCE(O.total_outflow, 0) AS net_income
    FROM Inflows I
    FULL OUTER JOIN Outflows O ON I.transaction_date = O.transaction_date
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
    -- Step 3: Calculate equity movements for each day, rolling over opening equity
    SELECT 
        D.transaction_date,
        -- Opening equity is the adjusted equity of the previous day (using LAG)
        COALESCE(LAG(E.opening_equity) OVER (ORDER BY D.transaction_date), 0) AS opening_equity,
        COALESCE(N.net_income, 0) AS net_income,
        COALESCE(C.retained_earnings, 0) AS retained_earnings,
        COALESCE(C.new_investments, 0) AS new_investments,
        COALESCE(C.dividends_paid, 0) AS dividends_paid,
        -- Adjusted Equity = Opening Equity + Net Income + New Investments - Dividends Paid
        COALESCE(LAG(E.opening_equity) OVER (ORDER BY D.transaction_date), 0) + COALESCE(N.net_income, 0) + COALESCE(C.new_investments, 0) - COALESCE(C.dividends_paid, 0) AS adjusted_equity
    FROM DateSeries D
    LEFT JOIN EquityChanges C ON D.transaction_date = C.transaction_date
    LEFT JOIN NetIncome N ON D.transaction_date = N.transaction_date
    LEFT JOIN EquityData E ON D.transaction_date = E.transaction_date
),
-- Step 4: Invariant check to compare adjusted equity with the sum of opening equity and net income
FinalReport AS (
    SELECT 
        transaction_date,
        opening_equity,
        net_income,
        retained_earnings,
        new_investments,
        dividends_paid,
        adjusted_equity,
        -- Invariant Check: If adjusted equity doesn't match the expected value, flag it
        CASE
            WHEN adjusted_equity != opening_equity + net_income THEN adjusted_equity - (opening_equity + net_income)
            ELSE 0.00
        END AS invariant_mismatch
    FROM EquityMovement
)
-- Return the final report with invariant check
SELECT 
    transaction_date,
    opening_equity,
    net_income,
    retained_earnings,
    new_investments,
    dividends_paid,
    adjusted_equity,
    invariant_mismatch
FROM FinalReport
ORDER BY transaction_date;

