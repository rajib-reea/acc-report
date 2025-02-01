Algorithm:
  CashFlowAnalysis(startDate, endDate):

Retrieve the opening cash balance for each day.
Retrieve daily cash inflows (Sales, Loans, Investments) for each day.
Retrieve daily cash outflows (Expenses, Loan Payments, Dividends) for each day.
Calculate net cash flow for each day:
Net Cash Flow = Total Inflows - Total Outflows
Calculate the closing cash balance for each day:
Closing Cash Balance = Opening Balance + Net Cash Flow
Categorize transactions into Operating, Investing, and Financing activities based on the category.
Generate the report with a daily breakdown of the cash flow.


  SQL:
  
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE,
        '2025-01-10'::DATE,
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
Inflows AS (
    SELECT transaction_date, COALESCE(SUM(amount), 0) AS inflow
    FROM acc_transactions
    WHERE is_active = TRUE 
      AND LOWER(category) IN ('sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital')
    GROUP BY transaction_date
),
Outflows AS (
    SELECT transaction_date, COALESCE(SUM(amount), 0) AS outflow
    FROM acc_transactions
    WHERE is_active = TRUE 
      AND LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance', 'taxes', 'loan payments', 'dividends', 'taxes payable', 'credit lines')
    GROUP BY transaction_date
),
NetCashFlow AS (
    SELECT D.transaction_date, 
           COALESCE(I.inflow, 0) AS inflows, 
           COALESCE(O.outflow, 0) AS outflows,
           COALESCE(I.inflow, 0) - COALESCE(O.outflow, 0) AS net_cash_flow
    FROM DateSeries D
    LEFT JOIN Inflows I ON D.transaction_date = I.transaction_date
    LEFT JOIN Outflows O ON D.transaction_date = O.transaction_date
),
InitialOpeningBalance AS (
    SELECT COALESCE(SUM(amount), 0) AS opening_balance
    FROM acc_transactions
    WHERE transaction_date < '2025-01-01' 
      AND transaction_type = 'revenue' 
      AND is_active = TRUE
),
ClosingBalance AS (
    SELECT transaction_date, 
           SUM(net_cash_flow) OVER (ORDER BY transaction_date) + (SELECT opening_balance FROM InitialOpeningBalance) AS closing_balance
    FROM NetCashFlow
),
FinalReport AS (
    SELECT N.transaction_date, 
           LAG(closing_balance, 1, (SELECT opening_balance FROM InitialOpeningBalance)) OVER (ORDER BY N.transaction_date) AS opening_balance,
           N.inflows, N.outflows, N.net_cash_flow, 
           C.closing_balance,
           (LAG(closing_balance, 1, (SELECT opening_balance FROM InitialOpeningBalance)) OVER (ORDER BY N.transaction_date) + N.net_cash_flow) AS expected_closing_balance
    FROM NetCashFlow N
    JOIN ClosingBalance C ON N.transaction_date = C.transaction_date
)
SELECT transaction_date, opening_balance, inflows, outflows, net_cash_flow, closing_balance, expected_closing_balance,
       COALESCE(expected_closing_balance - closing_balance, 0.00) AS invariant_mismatch
FROM FinalReport
ORDER BY transaction_date;


