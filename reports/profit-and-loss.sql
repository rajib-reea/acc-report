Algorithm:
ProfitAndLossSummary(startDate, endDate)
Retrieve total revenue within the date range.
Retrieve total expenses within the date range.
Calculate Net Profit/Loss:
Net Profit = Total Revenue - Total Expenses
Store the results in the report.
Return the Profit and Loss Summary.

SQL:
SELECT
    COALESCE(SUM(CASE WHEN transaction_type = 'revenue' THEN amount ELSE 0 END), 0) AS total_revenue,
    COALESCE(SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END), 0) AS total_expenses,
    COALESCE(SUM(CASE WHEN transaction_type = 'revenue' THEN amount ELSE 0 END), 0) - 
    COALESCE(SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END), 0) AS net_profit
FROM acc_transactions
WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-31'
AND is_active = TRUE;  -- Replace with dynamic date range
