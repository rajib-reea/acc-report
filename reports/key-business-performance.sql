Algorithm:
  BusinessPerformanceRatios(startDate, endDate):
  1. Retrieve financial data:
     a) Revenue, Net Profit, Total Assets, Liabilities, Equity
  2. Calculate key ratios:
     a) Gross Margin = (Revenue - COGS) / Revenue
     b) Net Profit Margin = Net Profit / Revenue
     c) Current Ratio = Current Assets / Current Liabilities
     d) Debt-to-Equity = Total Liabilities / Equity
     e) Return on Assets (ROA) = Net Profit / Total Assets
     f) Return on Equity (ROE) = Net Profit / Equity
  3. Store the ratios in the report.
  4. Return performance insights.

  SQL:
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH FinancialData AS (
    -- Step 1: Retrieve the financial data
    SELECT 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'revenue' THEN amount ELSE 0 END), 0) AS revenue,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'net profit' THEN amount ELSE 0 END), 0) AS net_profit,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'total assets' THEN amount ELSE 0 END), 0) AS total_assets,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'total liabilities' THEN amount ELSE 0 END), 0) AS total_liabilities,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'equity' THEN amount ELSE 0 END), 0) AS equity,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'cogs' THEN amount ELSE 0 END), 0) AS cogs,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'current assets' THEN amount ELSE 0 END), 0) AS current_assets,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'current liabilities' THEN amount ELSE 0 END), 0) AS current_liabilities
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
),
Ratios AS (
    -- Step 2: Calculate the key ratios
    SELECT 
        revenue,
        net_profit,
        total_assets,
        total_liabilities,
        equity,
        cogs,
        current_assets,
        current_liabilities,
        -- Gross Margin = (Revenue - COGS) / Revenue
        CASE WHEN revenue != 0 THEN (revenue - cogs) / revenue ELSE NULL END AS gross_margin,
        -- Net Profit Margin = Net Profit / Revenue
        CASE WHEN revenue != 0 THEN net_profit / revenue ELSE NULL END AS net_profit_margin,
        -- Current Ratio = Current Assets / Current Liabilities
        CASE WHEN current_liabilities != 0 THEN current_assets / current_liabilities ELSE NULL END AS current_ratio,
        -- Debt-to-Equity = Total Liabilities / Equity
        CASE WHEN equity != 0 THEN total_liabilities / equity ELSE NULL END AS debt_to_equity,
        -- Return on Assets (ROA) = Net Profit / Total Assets
        CASE WHEN total_assets != 0 THEN net_profit / total_assets ELSE NULL END AS roa,
        -- Return on Equity (ROE) = Net Profit / Equity
        CASE WHEN equity != 0 THEN net_profit / equity ELSE NULL END AS roe
    FROM FinancialData
)
-- Step 3: Store and return the ratios in the report
SELECT 
    revenue,
    net_profit,
    total_assets,
    total_liabilities,
    equity,
    gross_margin,
    net_profit_margin,
    current_ratio,
    debt_to_equity,
    roa,
    roe
FROM Ratios;
