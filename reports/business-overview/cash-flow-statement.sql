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
-- Define the start and end dates
\set startDate '2025-01-01'
\set endDate '2025-12-31'

-- Opening Cash Balance (assumed from previous period or a fixed value)
WITH OpeningBalance AS (
    SELECT COALESCE(SUM(amount), 0) AS opening_cash
    FROM acc_transactions
    WHERE transaction_date < :startDate
      AND transaction_type = 'revenue'
      AND is_active = TRUE
),
-- Categorizing cash inflows (Operating, Investing, Financing)
OperatingActivities AS (
    SELECT category, SUM(amount) AS operating_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'received from customers', 'paid to suppliers')  -- Example operating activities
    GROUP BY category
),
InvestingActivities AS (
    SELECT category, SUM(amount) AS investing_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
      AND LOWER(category) IN ('asset purchases', 'investments', 'sale of assets')  -- Example investing activities
    GROUP BY category
),
FinancingActivities AS (
    SELECT category, SUM(amount) AS financing_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
      AND LOWER(category) IN ('loan payments', 'dividends', 'capital injections')  -- Example financing activities
    GROUP BY category
),
-- Cash movement for each category (Inflows and Outflows)
NetCashFlow AS (
    SELECT 
        (SELECT COALESCE(SUM(operating_inflow), 0) FROM OperatingActivities) AS total_operating_inflows,
        (SELECT COALESCE(SUM(investing_inflow), 0) FROM InvestingActivities) AS total_investing_inflows,
        (SELECT COALESCE(SUM(financing_inflow), 0) FROM FinancingActivities) AS total_financing_inflows
),
-- Closing Cash Calculation
ClosingBalance AS (
    SELECT 
        (SELECT opening_cash FROM OpeningBalance) + 
        (SELECT (total_operating_inflows + total_investing_inflows + total_financing_inflows) FROM NetCashFlow) AS closing_cash
)
-- Final Report
SELECT 
    (SELECT opening_cash FROM OpeningBalance) AS opening_
