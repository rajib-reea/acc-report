# Financial Report (Jan 1 - Jan 10, 2025)

| #  | Transaction Date | Revenue  | COGS  | Gross Profit | Operating Expenses | Operating Profit | Taxes | Net Profit | Invariant Mismatch |
|----|----------------|---------|------|--------------|-------------------|----------------|------|-----------|-------------------|
| 1  | 2025-01-01    | 3000.00 | 0    | 3000.00      | 0                 | 3000.00        | 0    | 3000.00   | 0.00              |
| 2  | 2025-01-02    | 0       | 0    | 0            | 400.00            | -400.00        | 0    | -400.00   | 0.00              |
| 3  | 2025-01-03    | 0       | 0    | 0            | 0                 | 0              | 0    | 0         | 0.00              |
| 4  | 2025-01-04    | 0       | 0    | 0            | 2400.00           | -2400.00       | 0    | -2400.00  | 0.00              |
| 5  | 2025-01-05    | 1000.00 | 0    | 1000.00      | 0                 | 1000.00        | 0    | 1000.00   | 0.00              |
| 6  | 2025-01-06    | 0       | 0    | 0            | 150.00            | -150.00        | 0    | -150.00   | 0.00              |
| 7  | 2025-01-07    | 0       | 0    | 0            | 500.00            | -500.00        | 0    | -500.00   | 0.00              |
| 8  | 2025-01-08    | 1800.00 | 0    | 1800.00      | 0                 | 1800.00        | 0    | 1800.00   | 0.00              |
| 9  | 2025-01-09    | 0       | 0    | 0            | 750.00            | -750.00        | 0    | -750.00   | 0.00              |
| 10 | 2025-01-10    | 3000.00 | 0    | 3000.00      | 0                 | 3000.00        | 0    | 3000.00   | 0.00              |


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
        COALESCE(SUM(amount), 0.00) AS revenue
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
        COALESCE(SUM(CASE WHEN LOWER(category) = 'cogs' THEN amount ELSE 0 END), 0.00) AS cogs,
        COALESCE(SUM(CASE WHEN LOWER(category) IN (
            'operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance'
        ) THEN amount ELSE 0 END), 0.00) AS operating_expenses,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'taxes' THEN amount ELSE 0 END), 0.00) AS taxes
    FROM acc_transactions
    WHERE transaction_type = 'expense' 
        AND transaction_date BETWEEN '2025-01-01' AND '2025-01-10' 
        AND is_active = TRUE
    GROUP BY transaction_date
),
Aggregated AS (
    SELECT 
        ds.transaction_date,
        COALESCE(r.revenue, 0.00) AS revenue,
        COALESCE(e.cogs, 0.00) AS cogs,
        COALESCE(e.operating_expenses, 0.00) AS operating_expenses,
        COALESCE(e.taxes, 0.00) AS taxes
    FROM DateSeries ds
    LEFT JOIN Revenue r ON ds.transaction_date = r.transaction_date
    LEFT JOIN Expenses e ON ds.transaction_date = e.transaction_date
),
Calculated AS (
    SELECT 
        transaction_date,
        revenue,
        cogs,
        (revenue - cogs) AS gross_profit,
        operating_expenses,
        (revenue - cogs - operating_expenses) AS operating_profit,
        taxes,
        (revenue - cogs - operating_expenses - taxes) AS net_profit
    FROM Aggregated
),
InvariantCheck AS (
    -- Invariant: Operating Profit + Taxes should equal Net Profit
    SELECT 
        transaction_date,
        ABS(COALESCE(operating_profit, 0.00) + COALESCE(taxes, 0.00) - COALESCE(net_profit, 0.00)) AS invariant_mismatch
    FROM Calculated
)
SELECT 
    c.transaction_date,
    c.revenue,
    c.cogs,
    c.gross_profit,
    c.operating_expenses,
    c.operating_profit,
    c.taxes,
    c.net_profit,
    i.invariant_mismatch
FROM Calculated c
LEFT JOIN InvariantCheck i ON c.transaction_date = i.transaction_date
ORDER BY c.transaction_date;
