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
-- Invariant Check: Ensure Closing Cash Balance = Opening Cash Balance + Net Cash Flow
WITH 
DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
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
Inflows AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(amount), 0) AS total_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'loans', 'investments')  -- Categories for inflows
    GROUP BY transaction_date
),
Outflows AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(amount), 0) AS total_outflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND is_active = TRUE
      AND LOWER(category) IN ('expenses', 'loan payments', 'dividends')  -- Categories for outflows
    GROUP BY transaction_date
),
NetCashFlow AS (
    SELECT 
        D.transaction_date,
        COALESCE(I.total_inflow, 0) AS total_inflows,
        COALESCE(O.total_outflow, 0) AS total_outflows,
        (COALESCE(I.total_inflow, 0) - COALESCE(O.total_outflow, 0)) AS net_cash_flow
    FROM DateSeries D
    LEFT JOIN Inflows I ON D.transaction_date = I.transaction_date
    LEFT JOIN Outflows O ON D.transaction_date = O.transaction_date
),
ClosingBalance AS (
    SELECT 
        N.transaction_date,
        (SELECT COALESCE(opening_balance, 0) FROM OpeningBalance WHERE transaction_date = N.transaction_date) 
        + N.net_cash_flow AS closing_balance
    FROM NetCashFlow N
),
-- Invariant Check: Ensure Closing Cash Balance = Opening Cash Balance + Net Cash Flow
InvariantCheck AS (
    SELECT 
        N.transaction_date,
        O.opening_balance,
        N.net_cash_flow,
        C.closing_balance,
        (O.opening_balance + N.net_cash_flow) AS expected_closing_balance,
        CASE
            WHEN C.closing_balance = (O.opening_balance + N.net_cash_flow) THEN 'Valid'
            ELSE 'Invalid'
        END AS invariant_status
    FROM NetCashFlow N
    LEFT JOIN OpeningBalance O ON N.transaction_date = O.transaction_date
    LEFT JOIN ClosingBalance C ON N.transaction_date = C.transaction_date
)
-- Final Report with Invariant Status
SELECT 
    I.transaction_date,
    I.opening_balance,
    I.net_cash_flow,
    I.closing_balance,
    I.expected_closing_balance,
    I.invariant_status
FROM InvariantCheck I
ORDER BY I.transaction_date;

