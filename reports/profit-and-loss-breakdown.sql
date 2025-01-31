Algorithm:
  ProfitAndLossBreakdown(startDate, endDate):
  1. Retrieve revenue categories (Sales, Services, Other Income).
  2. Retrieve expense categories (COGS, Operating Expenses, Taxes).
  3. Sum up revenue and expense values for each category.
  4. Calculate gross profit:
     Gross Profit = Revenue - COGS
  5. Calculate operating profit:
     Operating Profit = Gross Profit - Operating Expenses
  6. Calculate net profit:
     Net Profit = Operating Profit - Taxes
  7. Format the breakdown and return the report.

  SQL:
\set startDate '2025-01-01' 
\set endDate '2025-12-31'
WITH Revenue AS (
    SELECT category, SUM(amount) AS total_revenue
    FROM acc_transactions
    WHERE transaction_type = 'revenue' 
      AND transaction_date BETWEEN :startDate AND :endDate  -- Use the variables for date range
      AND LOWER(category) IN ('sales', 'services', 'other income')  -- Use lowercase for categories
      AND is_active = TRUE
    GROUP BY category
),
Expenses AS (
    SELECT category, SUM(amount) AS total_expense
    FROM acc_transactions
    WHERE transaction_type = 'expense' 
      AND transaction_date BETWEEN :startDate AND :endDate  -- Use the variables for date range
      AND LOWER(category) IN ('cogs', 'operating expenses', 'taxes')  -- Use lowercase for categories
      AND is_active = TRUE
    GROUP BY category
),
Aggregated AS (
    SELECT 
        (SELECT COALESCE(SUM(total_revenue), 0) FROM Revenue) AS total_revenue,
        (SELECT COALESCE(SUM(total_expense) FILTER (WHERE LOWER(category) = 'cogs'), 0) FROM Expenses) AS total_cogs,
        (SELECT COALESCE(SUM(total_expense) FILTER (WHERE LOWER(category) = 'operating expenses'), 0) FROM Expenses) AS total_operating_expenses,
        (SELECT COALESCE(SUM(total_expense) FILTER (WHERE LOWER(category) = 'taxes'), 0) FROM Expenses) AS total_taxes
)
SELECT 
    total_revenue,
    total_cogs,
    (total_revenue - total_cogs) AS gross_profit,
    total_operating_expenses,
    (total_revenue - total_cogs - total_operating_expenses) AS operating_profit,
    total_taxes,
    (total_revenue - total_cogs - total_operating_expenses - total_taxes) AS net_profit
FROM Aggregated;

