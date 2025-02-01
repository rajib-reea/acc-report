Algorithm:
  BalanceSheetOverview(date):
  1. Retrieve total assets (Cash, Inventory, Accounts Receivable, Fixed Assets).
  2. Retrieve total liabilities (Loans, Accounts Payable, Other Debts).
  3. Retrieve total equity (Owner’s Capital, Retained Earnings).
  4. Validate the balance equation:
     Total Assets = Total Liabilities + Total Equity
  5. If balanced, generate the report.
  6. Return the balance sheet overview.

  SQL:
-- Define the date parameter
\set date '2025-12-31'

-- Step 1: Retrieve total assets (Cash, Inventory, Accounts Receivable, Fixed Assets)
WITH TotalAssets AS (
    SELECT 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'cash' THEN amount ELSE 0 END), 0) AS total_cash,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'inventory' THEN amount ELSE 0 END), 0) AS total_inventory,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'accounts receivable' THEN amount ELSE 0 END), 0) AS total_ar,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'fixed assets' THEN amount ELSE 0 END), 0) AS total_fixed_assets
    FROM acc_transactions
    WHERE transaction_date <= :date
      AND is_active = TRUE
),
-- Step 2: Retrieve total liabilities (Loans, Accounts Payable, Other Debts)
TotalLiabilities AS (
    SELECT 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'loans' THEN amount ELSE 0 END), 0) AS total_loans,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'accounts payable' THEN amount ELSE 0 END), 0) AS total_ap,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'other debts' THEN amount ELSE 0 END), 0) AS total_other_debts
    FROM acc_transactions
    WHERE transaction_date <= :date
      AND is_active = TRUE
),
-- Step 3: Retrieve total equity (Owner’s Capital, Retained Earnings)
TotalEquity AS (
    SELECT 
        COALESCE(SUM(CASE WHEN LOWER(category) = 'owner capital' THEN amount ELSE 0 END), 0) AS total_owner_capital,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'retained earnings' THEN amount ELSE 0 END), 0) AS total_retained_earnings
    FROM acc_transactions
    WHERE transaction_date <= :date
      AND is_active = TRUE
),
-- Step 4: Validate the balance equation
BalanceValidation AS (
    SELECT 
        (SELECT total_cash + total_inventory + total_ar + total_fixed_assets FROM TotalAssets) AS total_assets,
        (SELECT total_loans + total_ap + total_other_debts FROM TotalLiabilities) AS total_liabilities,
        (SELECT total_owner_capital + total_retained_earnings FROM TotalEquity) AS total_equity
)
-- Step 5: Generate the report and return the balance sheet overview
SELECT 
    total_assets,
    total_liabilities,
    total_equity,
    CASE 
        WHEN total_assets = (total_liabilities + total_equity) THEN 'Balanced'
        ELSE 'Unbalanced'
    END AS balance_status
FROM BalanceValidation;
