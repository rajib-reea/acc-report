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
    SELECT generate_series(
        '2025-01-01'::DATE,
        '2025-01-10'::DATE,
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
-- Opening Cash Balance (assumed from previous period or a fixed value)
OpeningBalance AS (
    SELECT COALESCE(SUM(amount), 0) AS opening_cash
    FROM acc_transactions
    WHERE transaction_date < '2025-01-01'
      AND transaction_type = 'revenue'
      AND is_active = TRUE
),
-- Categorizing transactions into Assets, Liabilities, and Equity
AssetsTransactions AS (
    SELECT transaction_date, category, SUM(amount) AS asset_amount
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'subscriptions', 'service income', 'operating expenses', 
                              'rent', 'utilities', 'marketing', 'professional services', 
                              'salaries', 'insurance', 'taxes', 'inventory', 'accounts receivable (ar)',
                              'fixed assets', 'intangible assets')
    GROUP BY transaction_date, category
),
LiabilitiesTransactions AS (
    SELECT transaction_date, category, SUM(amount) AS liability_amount
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('loans', 'accounts payable (ap)', 'other debts', 'taxes payable', 'credit lines')
    GROUP BY transaction_date, category
),
EquityTransactions AS (
    SELECT transaction_date, category, SUM(amount) AS equity_amount
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('owner capital')
    GROUP BY transaction_date, category
),
-- Daily movement of Assets, Liabilities, and Equity
DailyNetCashFlow AS (
    SELECT 
        ds.transaction_date,
        COALESCE(SUM(at.asset_amount), 0) AS total_assets,
        COALESCE(SUM(lt.liability_amount), 0) AS total_liabilities,
        COALESCE(SUM(et.equity_amount), 0) AS total_equity
    FROM DateSeries ds
    LEFT JOIN AssetsTransactions at ON ds.transaction_date = at.transaction_date
    LEFT JOIN LiabilitiesTransactions lt ON ds.transaction_date = lt.transaction_date
    LEFT JOIN EquityTransactions et ON ds.transaction_date = et.transaction_date
    GROUP BY ds.transaction_date
),
-- Daily Closing Cash Calculation
DailyClosingBalance AS (
    SELECT 
        dnc.transaction_date,
        (SELECT opening_cash FROM OpeningBalance) + 
        SUM(dnc.total_assets - dnc.total_liabilities + dnc.total_equity) 
        OVER (ORDER BY dnc.transaction_date) AS closing_cash
    FROM DailyNetCashFlow dnc
)
-- Final Daily Report
SELECT 
    dnc.transaction_date,
    (SELECT opening_cash FROM OpeningBalance) AS opening_cash,
    dnc.total_assets,
    dnc.total_liabilities,
    dnc.total_equity,
    (dnc.total_assets - dnc.total_liabilities + dnc.total_equity) AS net_cash_change,
    dcb.closing_cash
FROM DailyNetCashFlow dnc
JOIN DailyClosingBalance dcb ON dnc.transaction_date = dcb.transaction_date
ORDER BY dnc.transaction_date;
