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
-- Generate a series of dates for the report period
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
-- Categorizing cash inflows (Operating, Investing, Financing)
OperatingActivities AS (
    SELECT transaction_date, category, SUM(amount) AS operating_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'received from customers', 'paid to suppliers')  
    GROUP BY transaction_date, category
),
InvestingActivities AS (
    SELECT transaction_date, category, SUM(amount) AS investing_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('asset purchases', 'investments', 'sale of assets')
    GROUP BY transaction_date, category
),
FinancingActivities AS (
    SELECT transaction_date, category, SUM(amount) AS financing_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('loan payments', 'dividends', 'capital injections')
    GROUP BY transaction_date, category
),
-- Daily Cash movement for each category (Inflows and Outflows)
DailyNetCashFlow AS (
    SELECT 
        ds.transaction_date,
        COALESCE(SUM(oa.operating_inflow), 0) AS total_operating_inflows,
        COALESCE(SUM(ia.investing_inflow), 0) AS total_investing_inflows,
        COALESCE(SUM(fa.financing_inflow), 0) AS total_financing_inflows
    FROM DateSeries ds
    LEFT JOIN OperatingActivities oa ON ds.transaction_date = oa.transaction_date
    LEFT JOIN InvestingActivities ia ON ds.transaction_date = ia.transaction_date
    LEFT JOIN FinancingActivities fa ON ds.transaction_date = fa.transaction_date
    GROUP BY ds.transaction_date
),
-- Daily Closing Cash Calculation
DailyClosingBalance AS (
    SELECT 
        dnc.transaction_date,
        (SELECT opening_cash FROM OpeningBalance) + 
        SUM(dnc.total_operating_inflows + dnc.total_investing_inflows + dnc.total_financing_inflows) 
        OVER (ORDER BY dnc.transaction_date) AS closing_cash
    FROM DailyNetCashFlow dnc
)
-- Final Daily Report
SELECT 
    dnc.transaction_date,
    (SELECT opening_cash FROM OpeningBalance) AS opening_cash,
    dnc.total_operating_inflows,
    dnc.total_investing_inflows,
    dnc.total_financing_inflows,
    (dnc.total_operating_inflows + dnc.total_investing_inflows + dnc.total_financing_inflows) AS net_cash_change,
    dcb.closing_cash
FROM DailyNetCashFlow dnc
JOIN DailyClosingBalance dcb ON dnc.transaction_date = dcb.transaction_date
ORDER BY dnc.transaction_date;
