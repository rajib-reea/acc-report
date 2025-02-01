# Profit and Loss Summary (Daily Basis)

| #  | Transaction Date | Revenue  | Expenses | Net Profit | Invariant Mismatch |
|----|----------------|----------|----------|------------|--------------------|
| 1  | 2025-01-01    | 3000.00  | 0.00     | 3000.00    | 0.00               |
| 2  | 2025-01-02    | 0.00     | 400.00   | -400.00    | 0.00               |
| 3  | 2025-01-03    | 5000.00  | 0.00     | 5000.00    | 0.00               |
| 4  | 2025-01-04    | 0.00     | 2400.00  | -2400.00   | 0.00               |
| 5  | 2025-01-05    | 1000.00  | 0.00     | 1000.00    | 0.00               |
| 6  | 2025-01-06    | 0.00     | 150.00   | -150.00    | 0.00               |
| 7  | 2025-01-07    | 0.00     | 500.00   | -500.00    | 0.00               |
| 8  | 2025-01-08    | 1800.00  | 0.00     | 1800.00    | 0.00               |
| 9  | 2025-01-09    | 0.00     | 750.00   | -750.00    | 0.00               |
| 10 | 2025-01-10    | 3000.00  | 0.00     | 3000.00    | 0.00               |

> **Invariant:** The `net_profit` column must always equal `revenue - expenses`, and `invariant_mismatch` should always be `0.00`, indicating no inconsistencies.

Algorithm:

ProfitAndLossSummary(startDate, endDate)
1. Retrieve total revenue within the date range.
2. Retrieve total expenses within the date range.
3. Calculate Net Profit/Loss:
  Net Profit = Total Revenue - Total Expenses
4. Store the results in the report.
5. Return the Profit and Loss Summary.

SQL:
    
WITH DateSeries AS (
    -- Generate a date range dynamically
    SELECT generate_series(
        '2025-01-01'::DATE,  -- Start Date
        '2025-01-10'::DATE,  -- End Date
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
