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
  
WITH 
DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE,
        '2025-01-10'::DATE,
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
-- Cash inflows for each day: Sales, Loans, Investments, Owner Capital
Inflows AS (
    SELECT
        transaction_date,
        COALESCE(SUM(amount), 0) AS inflow
    FROM acc_transactions
    WHERE
        is_active = TRUE
        AND LOWER(category) IN ('sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital')
    GROUP BY transaction_date
),
-- Cash outflows for each day: Expenses, Loan Payments, Dividends, Taxes Payable, Credit Lines
Outflows AS (
    SELECT
        transaction_date,
        COALESCE(SUM(amount), 0) AS outflow
    FROM acc_transactions
    WHERE
        is_active = TRUE
        AND LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance', 'taxes', 'loan payments', 'dividends', 'taxes payable', 'credit lines')
    GROUP BY transaction_date
),
-- Net cash flow calculation for each day
NetCashFlow AS (
    SELECT
        D.transaction_date,
        COALESCE(I.inflow, 0) AS inflows,
        COALESCE(O.outflow, 0) AS outflows,
        (COALESCE(I.inflow, 0) - COALESCE(O.outflow, 0)) AS net_cash_flow
    FROM DateSeries D
    LEFT JOIN Inflows I ON D.transaction_date = I.transaction_date
    LEFT JOIN Outflows O ON D.transaction_date = O.transaction_date
),
-- Calculate the cumulative sum of net cash flow to get the closing balance
ClosingBalance AS (
    SELECT
        transaction_date,
        SUM(net_cash_flow) OVER (ORDER BY transaction_date) AS closing_balance
    FROM NetCashFlow
),
-- Get the initial opening balance (if available)
InitialOpeningBalance AS (
    SELECT
        transaction_date,
        COALESCE(SUM(amount), 0) AS opening_balance
    FROM acc_transactions
    WHERE transaction_date < '2025-01-01'
        AND transaction_type = 'revenue'
        AND is_active = TRUE
    GROUP BY transaction_date
),
-- Combine opening balance with closing balance
CombinedBalance AS (
    SELECT
        N.transaction_date,
        COALESCE(I.opening_balance, 0) AS initial_opening_balance,
        N.net_cash_flow,
        C.closing_balance
    FROM NetCashFlow N
    LEFT JOIN InitialOpeningBalance I ON N.transaction_date = I.transaction_date
    LEFT JOIN ClosingBalance C ON N.transaction_date = C.transaction_date
),
-- Calculate the final opening balance for each day
FinalOpeningBalance AS (
    SELECT
        transaction_date,
        LAG(closing_balance, 1, initial_opening_balance) OVER (ORDER BY transaction_date) AS opening_balance 
    FROM CombinedBalance
),
-- Final Report: Day-wise breakdown of Cash Flow
FinalReport AS (
    SELECT
        F.transaction_date,
        F.opening_balance,
        N.inflows,
        N.outflows,
        N.net_cash_flow,
        C.closing_balance,
        (F.opening_balance + N.net_cash_flow) AS calculated_closing_balance
    FROM NetCashFlow N
    JOIN FinalOpeningBalance F ON N.transaction_date = F.transaction_date
    JOIN ClosingBalance C ON N.transaction_date = C.transaction_date
)
-- Add invariant_mismatch check
SELECT
    transaction_date,
    opening_balance,
    inflows,
    outflows,
    net_cash_flow,
    closing_balance,
    calculated_closing_balance,
    CASE
        WHEN closing_balance != calculated_closing_balance THEN 'invariant_mismatch'
        ELSE 'consistent'
    END AS invariant_check
FROM FinalReport
ORDER BY transaction_date;

