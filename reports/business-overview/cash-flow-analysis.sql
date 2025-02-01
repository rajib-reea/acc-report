Algorithm:
  CashFlowAnalysis(startDate, endDate):
  1. Retrieve opening cash balance.
  2. Retrieve all cash inflows (Sales, Loans, Investments).
  3. Retrieve all cash outflows (Expenses, Loan Payments, Dividends).
  4. Calculate net cash flow:
     Net Cash Flow = Total Inflows - Total Outflows
  5. Calculate closing cash balance:
     Closing Cash Balance = Opening Balance + Net Cash Flow
  6. Categorize transactions into Operating, Investing, and Financing activities.
  7. Generate the report and return the results.

  SQL:
-- Define the start and end dates
\set startDate '2025-01-01'
\set endDate '2025-12-31'

-- Opening Cash Balance (assumed from previous period or defined starting balance)
WITH OpeningBalance AS (
    SELECT COALESCE(SUM(amount), 0) AS opening_balance
    FROM acc_transactions
    WHERE transaction_date < :startDate  -- Transactions before the startDate
      AND transaction_type = 'revenue'  -- Assuming cash balance comes from revenue transactions
      AND is_active = TRUE
),
-- Cash inflows: Sales, Loans, Investments
Inflows AS (
    SELECT category, SUM(amount) AS total_inflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
      AND LOWER(category) IN ('sales', 'loans', 'investments')  -- Categories for inflows
    GROUP BY category
),
-- Cash outflows: Expenses, Loan Payments, Dividends
Outflows AS (
    SELECT category, SUM(amount) AS total_outflow
    FROM acc_transactions
    WHERE transaction_date BETWEEN :startDate AND :endDate
      AND is_active = TRUE
      AND LOWER(category) IN ('expenses', 'loan payments', 'dividends')  -- Categories for outflows
    GROUP BY category
),
-- Net cash flow calculation
NetCashFlow AS (
    SELECT 
        (SELECT COALESCE(SUM(total_inflow), 0) FROM Inflows) AS total_inflows,
        (SELECT COALESCE(SUM(total_outflow), 0) FROM Outflows) AS total_outflows
),
-- Closing Cash Balance calculation
ClosingBalance AS (
    SELECT 
        (SELECT opening_balance FROM OpeningBalance) + (SELECT (total_inflows - total_outflows) FROM NetCashFlow) AS closing_balance
)
-- Final Report
SELECT 
    (SELECT opening_balance FROM OpeningBalance) AS opening_balance,
    (SELECT total_inflows FROM NetCashFlow) AS total_inflows,
    (SELECT total_outflows FROM NetCashFlow) AS total_outflows,
    (SELECT total_inflows FROM NetCashFlow) - (SELECT total_outflows FROM NetCashFlow) AS net_cash_flow,
    (SELECT closing_balance FROM ClosingBalance) AS closing_balance
;
