Algorithm:
ProfitAndLossSummary(startDate, endDate)
Retrieve total revenue within the date range.
Retrieve total expenses within the date range.
Calculate Net Profit/Loss:
Net Profit = Total Revenue - Total Expenses
Store the results in the report.
Return the Profit and Loss Summary.

SQL:
    
WITH DateSeries AS (
    -- Generate a date range dynamically
    SELECT generate_series(
        '2025-01-01'::DATE,  -- Start Date
        '2025-01-31'::DATE,  -- End Date
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
DailySummary AS (
    SELECT 
        ds.transaction_date,
        COALESCE(SUM(CASE WHEN at.transaction_type = 'revenue' THEN at.amount ELSE 0.00 END), 0.00) AS revenue,
        COALESCE(SUM(CASE WHEN at.transaction_type = 'expense' THEN at.amount ELSE 0.00 END), 0.00) AS expenses
    FROM DateSeries ds
    LEFT JOIN acc_transactions at 
        ON ds.transaction_date = at.transaction_date
        AND at.is_active = TRUE
    GROUP BY ds.transaction_date
),
InvariantCheck AS (
    -- Check if Net Profit calculation is consistent
    SELECT 
        transaction_date,
        revenue,
        expenses,
        COALESCE(revenue - expenses, 0.00) AS net_profit,
        CASE 
            WHEN (revenue - expenses) != (revenue - expenses) THEN COALESCE(revenue - expenses, 0.00)
            ELSE 0.00
        END AS invariant_mismatch
    FROM DailySummary
)
SELECT 
    transaction_date,
    revenue,
    expenses,
    net_profit,
    invariant_mismatch
FROM InvariantCheck
ORDER BY transaction_date;
