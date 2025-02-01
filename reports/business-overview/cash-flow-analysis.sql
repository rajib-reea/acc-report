| #  | Transaction Date | Opening Balance | Inflows | Outflows | Net Cash Flow | Closing Balance | Expected Closing Balance | Invariant Mismatch |
|----|----------------|----------------|---------|----------|---------------|-----------------|--------------------------|--------------------|
| 1  | 2025-01-01    | 0.00           | 3000.00 | 0.00     | 3000.00       | 3000.00         | 3000.00                  | 0.00               |
| 2  | 2025-01-02    | 3000.00        | 0.00    | 400.00   | -400.00       | 2600.00         | 2600.00                  | 0.00               |
| 3  | 2025-01-03    | 2600.00        | 0.00    | 0.00     | 0.00          | 2600.00         | 2600.00                  | 0.00               |
| 4  | 2025-01-04    | 2600.00        | 0.00    | 2400.00  | -2400.00      | 200.00          | 200.00                   | 0.00               |
| 5  | 2025-01-05    | 200.00         | 1000.00 | 0.00     | 1000.00       | 1200.00         | 1200.00                  | 0.00               |
| 6  | 2025-01-06    | 1200.00        | 0.00    | 150.00   | -150.00       | 1050.00         | 1050.00                  | 0.00               |
| 7  | 2025-01-07    | 1050.00        | 0.00    | 500.00   | -500.00       | 550.00          | 550.00                   | 0.00               |
| 8  | 2025-01-08    | 550.00         | 1800.00 | 0.00     | 1800.00       | 2350.00         | 2350.00                  | 0.00               |
| 9  | 2025-01-09    | 2350.00        | 0.00    | 750.00   | -750.00       | 1600.00         | 1600.00                  | 0.00               |
| 10 | 2025-01-10    | 1600.00        | 3000.00 | 0.00     | 3000.00       | 4600.00         | 4600.00                  | 0.00               |


Algorithm:
  CashFlowAnalysis(startDate, endDate):

1. Retrieve the opening cash balance for each day.
2. Retrieve daily cash inflows (Sales, Loans, Investments) for each day.
3. Retrieve daily cash outflows (Expenses, Loan Payments, Dividends) for each day.
4. Calculate net cash flow for each day:
  Net Cash Flow = Total Inflows - Total Outflows
6. Calculate the closing cash balance for each day:
  Closing Cash Balance = Opening Balance + Net Cash Flow
7. Categorize transactions into Operating, Investing, and Financing activities based on the category.
8. Generate the report with a daily breakdown of the cash flow.


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
)
-- Final Daily Report
SELECT 
    dnc.transaction_date,
    (SELECT opening_cash FROM OpeningBalance) AS opening_cash,
    dnc.total_inflows,
    dnc.total_outflows,
    (dnc.total_inflows - dnc.total_outflows) AS net_cash_change,
    dcb.closing_cash
FROM DailyNetCashFlow dnc
JOIN DailyClosingBalance dcb ON dnc.transaction_date = dcb.transaction_date
ORDER BY dnc.transaction_date;



