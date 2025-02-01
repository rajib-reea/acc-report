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
-- Opening Cash Balance (for the first day)
OpeningBalance AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(amount), 0) AS opening_balance
    FROM acc_transactions
    WHERE transaction_date < '2025-01-01'  -- Transactions before the startDate
      AND transaction_type = 'revenue'  -- Assuming cash balance comes from revenue transactions
      AND is_active = TRUE
    GROUP BY transaction_date
),
-- Cash inflows for each day: Sales, Loans, Investments, Owner Capital
Inflows AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(amount), 0) AS inflow
    FROM acc_transactions
    WHERE 
      is_active = TRUE
      AND LOWER(category) IN ('sales', 'subscriptions', 'service income', 'loans', 'investments', 'owner capital')  -- Categories for inflows
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
      AND LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance', 'taxes', 'loan payments', 'dividends', 'taxes payable', 'credit lines')  -- Categories for outflows
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
-- Closing Cash Balance for each day
ClosingBalance AS (
    SELECT 
        N.transaction_date,
        -- Fetch the opening balance from OpeningBalance or default to 0 if none exists
        (SELECT COALESCE(opening_balance, 0) FROM OpeningBalance WHERE transaction_date = N.transaction_date) 
        + N.net_cash_flow AS closing_balance
    FROM NetCashFlow N
)
-- Final Report: Day-wise breakdown of Cash Flow
SELECT 
    N.transaction_date,
    COALESCE(O.opening_balance, 0) AS opening_balance,
    N.inflows,
    N.outflows,
    N.net_cash_flow,
    COALESCE(C.closing_balance, 0) AS closing_balance,  -- Ensure closing balance is not null
    -- Calculate the expected closing balance (opening_balance + net_cash_flow)
    (COALESCE(O.opening_balance, 0) + N.net_cash_flow) AS expected_closing_balance,
    -- Calculate invariant mismatch (closing_balance - expected_closing_balance)
    COALESCE(C.closing_balance, 0) - (COALESCE(O.opening_balance, 0) + N.net_cash_flow) AS invariant_mismatch
FROM NetCashFlow N
LEFT JOIN OpeningBalance O ON N.transaction_date = O.transaction_date
LEFT JOIN ClosingBalance C ON N.transaction_date = C.transaction_date
ORDER BY N.transaction_date;

