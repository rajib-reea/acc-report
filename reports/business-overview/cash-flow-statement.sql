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
-- Opening Cash Balance (from previous period)
OpeningBalance AS (
    SELECT COALESCE(SUM(amount), 0) AS opening_cash
    FROM acc_transactions
    WHERE transaction_date < '2025-01-01'
      AND is_active = TRUE
),
-- Categorizing transactions (Inflows vs Outflows)
Inflows AS (
    SELECT transaction_date, category, SUM(amount) AS total_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital')  -- Inflows
    GROUP BY transaction_date, category
),
Outflows AS (
    SELECT transaction_date, category, SUM(amount) AS total_outflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 
                              'professional services', 'salaries', 'insurance', 'taxes')  -- Outflows
    GROUP BY transaction_date, category
),
-- Daily Net Cash Movement
DailyNetCashFlow AS (
    SELECT 
        ds.transaction_date,
        COALESCE(SUM(i.total_inflow), 0) AS total_inflows,
        COALESCE(SUM(o.total_outflow), 0) AS total_outflows
    FROM DateSeries ds
    LEFT JOIN Inflows i ON ds.transaction_date = i.transaction_date
    LEFT JOIN Outflows o ON ds.transaction_date = o.transaction_date
    GROUP BY ds.transaction_date
),
-- Daily Closing Cash Calculation
DailyClosingBalance AS (
    SELECT 
        dnc.transaction_date,
        (SELECT opening_cash FROM OpeningBalance) + 
        SUM(dnc.total_inflows - dnc.total_outflows) 
        OVER (ORDER BY dnc.transaction_date) AS closing_cash
    FROM DailyNetCashFlow dnc
),
-- Final Daily Report with Invariant Check
FinalReport AS (
    SELECT 
        dnc.transaction_date,
        (SELECT opening_cash FROM OpeningBalance) AS opening_cash,
        dnc.total_inflows,
        dnc.total_outflows,
        (dnc.total_inflows - dnc.total_outflows) AS net_cash_change,
        dcb.closing_cash,
        -- Calculate the expected closing balance
        (SELECT opening_cash FROM OpeningBalance) + 
        SUM(dnc.total_inflows - dnc.total_outflows) 
        OVER (ORDER BY dnc.transaction_date) AS expected_closing_cash
    FROM DailyNetCashFlow dnc
    JOIN DailyClosingBalance dcb ON dnc.transaction_date = dcb.transaction_date
)
-- Add invariant_mismatch check
SELECT 
    transaction_date,
    opening_cash,
    total_inflows,
    total_outflows,
    net_cash_change,
    closing_cash,
    expected_closing_cash,
    CASE
        WHEN closing_cash != expected_closing_cash THEN COALESCE(expected_closing_cash- closing_cash, 0.00)
        ELSE 0.00
    END AS invariant_check
FROM FinalReport
ORDER BY transaction_date;
