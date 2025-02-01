| #  | Transaction Date | Opening Balance | Inflows | Outflows | Net Cash Flow | Closing Balance | Expected Closing Balance | Invariant Mismatch |
|----|----------------|----------------|---------|----------|---------------|-----------------|--------------------------|--------------------|
| 1  | 2025-01-01    | 0.00           | 3000.00 | 0.00     | 3000.00       | 3000.00         | 3000.00                  | 0.00               |
| 2  | 2025-01-02    | 3000.00        | 0.00    | 400.00   | -400.00       | 2600.00         | 2600.00                  | 0.00               |
| 3  | 2025-01-03    | 2600.00        | 0.00    | 0.00     | 0.00          | 2600.00         | 2600.00                  | 0.00               |
| 4  | 2025-01-04    | 2600.00        | 0.00    | 2400.00  | -2400.00      | 200.00          | 200.00                   | 0.00               |
| 5  | 2025-01-05    | 200.00         | 1000.00 | 0.00     | 1000.00       | 1200.00         | 1200.00                  | 0.00               |
| 6  | 2025-01-06    | 1200.00        | 0.00    | 150.00   | -150.00       | 1050.00         | 1050.00                  | 0.00               |
| 7  | 2025-01-07    | 1050.00        | 0.00    | 500.00   | -500.00       | 550.00          | 550.00                   | 0.00               |
| 8  | 2025-01-08    | 550.00         | 1800.00 | 0.00     | 1800.00       | 2350.00         | 2350.00                  | 0.00               |
| 9  | 2025-01-09    | 2350.00        | 0.00    | 750.00   | -750.00       | 1600.00         | 1600.00                  | 0.00               |
| 10 | 2025-01-10    | 1600.00        | 3000.00 | 0.00     | 3000.00       | 4600.00         | 4600.00                  | 0.00               |


Algorithm:
  CashFlowAnalysis(startDate, endDate):

1. Retrieve the opening cash balance for each day.
2. Retrieve daily cash inflows (Sales, Loans, Investments) for each day.
3. Retrieve daily cash outflows (Expenses, Loan Payments, Dividends) for each day.
4. Calculate net cash flow for each day:
  Net Cash Flow = Total Inflows - Total Outflows
6. Calculate the closing cash balance for each day:
  Closing Cash Balance = Opening Balance + Net Cash Flow
7. Categorize transactions into Operating, Investing, and Financing activities based on the category.
8. Generate the report with a daily breakdown of the cash flow.


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
        (F.opening_balance + N.net_cash_flow) AS expected_closing_balance
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
    expected_closing_balance,
    CASE
        WHEN closing_balance != expected_closing_balance THEN COALESCE(expected_closing_balance-closing_balance, 0.00)
        ELSE 0.00
    END AS invariant_check
FROM FinalReport
ORDER BY transaction_date;



