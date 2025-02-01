| #   | transaction_date | revenue | net_profit | total_assets | total_liabilities | equity | gross_margin | net_profit_margin | current_ratio | debt_to_equity | roa  | roe  |
|-----|------------------|---------|------------|--------------|--------------------|--------|--------------|-------------------|---------------|----------------|------|------|
| 1   | 2025-01-01       | 3000.00 | 0          | 0            | 0                  | 0      | 1.00         | 0.00              |               |                |      |      |
| 2   | 2025-01-02       | 0       | 0          | 0            | 0                  | 0      |              |                   |               |                |      |      |
| 3   | 2025-01-03       | 0       | 0          | 0            | 0                  | 0      |              |                   |               |                |      |      |
| 4   | 2025-01-04       | 0       | 0          | 0            | 0                  | 0      |              |                   |               |                |      |      |
| 5   | 2025-01-05       | 1000.00 | 0          | 0            | 0                  | 0      | 1.00         | 0.00              |               |                |      |      |
| 6   | 2025-01-06       | 0       | 0          | 0            | 0                  | 0      |              |                   |               |                |      |      |
| 7   | 2025-01-07       | 0       | 0          | 0            | 0                  | 0      |              |                   |               |                |      |      |
| 8   | 2025-01-08       | 1800.00 | 0          | 0            | 0                  | 0      | 1.00         | 0.00              |               |                |      |      |
| 9   | 2025-01-09       | 0       | 0          | 0            | 0                  | 0      |              |                   |               |                |      |      |
| 10  | 2025-01-10       | 3000.00 | 0          | 0            | 0                  | 0      | 1.00         | 0.00              |               |                |      |      |

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
WITH DateSeries AS (
    -- Generate a date range from Jan 1 to Jan 10, 2025 (you can modify the date range as needed)
    SELECT generate_series(
        '2025-01-01'::DATE,
        '2025-01-10'::DATE,
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
DailyFinancialData AS (
    -- Step 1: Retrieve daily financial data
    SELECT 
        ds.transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) IN ('sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital') THEN amount ELSE 0 END), 0) AS revenue,
        COALESCE(SUM(CASE WHEN LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance', 'taxes') THEN amount ELSE 0 END), 0) AS expenses,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'net profit' THEN amount ELSE 0 END), 0) AS net_profit,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'total assets' THEN amount ELSE 0 END), 0) AS total_assets,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'total liabilities' THEN amount ELSE 0 END), 0) AS total_liabilities,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'equity' THEN amount ELSE 0 END), 0) AS equity,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'cogs' THEN amount ELSE 0 END), 0) AS cogs,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'current assets' THEN amount ELSE 0 END), 0) AS current_assets,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'current liabilities' THEN amount ELSE 0 END), 0) AS current_liabilities
    FROM acc_transactions at
    RIGHT JOIN DateSeries ds ON at.transaction_date = ds.transaction_date
    WHERE at.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND at.is_active = TRUE
    GROUP BY ds.transaction_date
),
DailyRatios AS (
    -- Step 2: Calculate the daily key ratios
    SELECT 
        transaction_date,
        revenue,
        net_profit,
        total_assets,
        total_liabilities,
        equity,
        cogs,
        current_assets,
        current_liabilities,
        -- Gross Margin = (Revenue - COGS) / Revenue
        ROUND(CASE WHEN revenue != 0 THEN (revenue - cogs) / revenue ELSE NULL END, 2) AS gross_margin,
        -- Net Profit Margin = Net Profit / Revenue
        ROUND(CASE WHEN revenue != 0 THEN net_profit / revenue ELSE NULL END, 2) AS net_profit_margin,
        -- Current Ratio = Current Assets / Current Liabilities
        ROUND(CASE WHEN current_liabilities != 0 THEN current_assets / current_liabilities ELSE NULL END, 2) AS current_ratio,
        -- Debt-to-Equity = Total Liabilities / Equity
        ROUND(CASE WHEN equity != 0 THEN total_liabilities / equity ELSE NULL END, 2) AS debt_to_equity,
        -- Return on Assets (ROA) = Net Profit / Total Assets
        ROUND(CASE WHEN total_assets != 0 THEN net_profit / total_assets ELSE NULL END, 2) AS roa,
        -- Return on Equity (ROE) = Net Profit / Equity
        ROUND(CASE WHEN equity != 0 THEN net_profit / equity ELSE NULL END, 2) AS roe
    FROM DailyFinancialData
)
-- Step 3: Store and return the daily ratios in the report
SELECT 
    transaction_date,
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
FROM DailyRatios;
