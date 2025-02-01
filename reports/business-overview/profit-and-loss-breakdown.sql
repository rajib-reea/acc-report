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
  
WITH DateSeries AS (
    -- Generate a date range from Jan 1 to Jan 10, 2025
    SELECT generate_series(
        '2025-01-01'::DATE,
        '2025-01-10'::DATE,
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
Revenue AS (
    SELECT 
        transaction_date, 
        COALESCE(SUM(amount), 0) AS total_revenue
    FROM acc_transactions
    WHERE transaction_type = 'revenue' 
        AND transaction_date BETWEEN '2025-01-01' AND '2025-01-10' 
        AND LOWER(category) IN (
            'sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital'
        ) 
        AND is_active = TRUE
    GROUP BY transaction_date
),
Expenses AS (
    SELECT 
        transaction_date, 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'cogs' THEN amount ELSE 0 END), 0) AS total_cogs,
        COALESCE(SUM(CASE WHEN LOWER(category) IN (
            'operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance'
        ) THEN amount ELSE 0 END), 0) AS operating_expenses,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'taxes' THEN amount ELSE 0 END), 0) AS total_taxes
    FROM acc_transactions
    WHERE transaction_type = 'expense' 
        AND transaction_date BETWEEN '2025-01-01' AND '2025-01-10' 
        AND is_active = TRUE
    GROUP BY transaction_date
),
Aggregated AS (
    SELECT 
        ds.transaction_date,
        COALESCE(r.total_revenue, 0) AS total_revenue,
        COALESCE(e.total_cogs, 0) AS total_cogs,
        COALESCE(e.operating_expenses, 0) AS operating_expenses,
        COALESCE(e.total_taxes, 0) AS total_taxes
    FROM DateSeries ds
    LEFT JOIN Revenue r ON ds.transaction_date = r.transaction_date
    LEFT JOIN Expenses e ON ds.transaction_date = e.transaction_date
),
Calculated AS (
    SELECT 
        transaction_date,
        total_revenue,
        total_cogs,
        (total_revenue - total_cogs) AS gross_profit,
        operating_expenses,
        (total_revenue - total_cogs - operating_expenses) AS operating_profit,
        total_taxes,
        (total_revenue - total_cogs - operating_expenses - total_taxes) AS net_profit
    FROM Aggregated
),
InvariantCheck AS (
    -- Invariant: Gross Profit + Operating Expenses + Taxes should equal Total Revenue
    SELECT 
        transaction_date,
        CASE 
            WHEN gross_profit + operating_expenses + total_taxes != total_revenue 
            THEN gross_profit + operating_expenses + total_taxes - total_revenue 
            ELSE 0.00 END AS invariant_mismatch
    FROM Calculated
)
SELECT 
    c.transaction_date,
    c.total_revenue,
    c.total_cogs,
    c.gross_profit,
    c.operating_expenses,
    c.operating_profit,
    c.total_taxes,
    c.net_profit,
    i.invariant_mismatch
FROM Calculated c
JOIN InvariantCheck i ON c.transaction_date = i.transaction_date
ORDER BY c.transaction_date;

