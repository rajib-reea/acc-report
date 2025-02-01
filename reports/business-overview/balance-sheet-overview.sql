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

  -- Define the date range for the balance sheet overview
\set start_date '2025-01-01'
\set end_date '2025-01-10'

-- Step 1: Retrieve total assets per day
WITH DailyAssets AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'cash' THEN amount ELSE 0 END), 0) AS total_cash,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'inventory' THEN amount ELSE 0 END), 0) AS total_inventory,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'accounts receivable' THEN amount ELSE 0 END), 0) AS total_ar,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'fixed assets' THEN amount ELSE 0 END), 0) AS total_fixed_assets
    FROM acc_transactions
    WHERE transaction_date BETWEEN :start_date AND :end_date
      AND is_active = TRUE
    GROUP BY transaction_date
),

-- Step 2: Retrieve total liabilities per day
DailyLiabilities AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'loans' THEN amount ELSE 0 END), 0) AS total_loans,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'accounts payable' THEN amount ELSE 0 END), 0) AS total_ap,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'other debts' THEN amount ELSE 0 END), 0) AS total_other_debts
    FROM acc_transactions
    WHERE transaction_date BETWEEN :start_date AND :end_date
      AND is_active = TRUE
    GROUP BY transaction_date
),

-- Step 3: Retrieve total equity per day
DailyEquity AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'owner capital' THEN amount ELSE 0 END), 0) AS total_owner_capital,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'retained earnings' THEN amount ELSE 0 END), 0) AS total_retained_earnings
    FROM acc_transactions
    WHERE transaction_date BETWEEN :start_date AND :end_date
      AND is_active = TRUE
    GROUP BY transaction_date
),

-- Step 4: Validate balance equation per day
BalanceValidation AS (
    SELECT 
        A.transaction_date,
        (A.total_cash + A.total_inventory + A.total_ar + A.total_fixed_assets) AS total_assets,
        (L.total_loans + L.total_ap + L.total_other_debts) AS total_liabilities,
        (E.total_owner_capital + E.total_retained_earnings) AS total_equity
    FROM DailyAssets A
    LEFT JOIN DailyLiabilities L ON A.transaction_date = L.transaction_date
    LEFT JOIN DailyEquity E ON A.transaction_date = E.transaction_date
)

-- Step 5: Generate the daily balance sheet report
SELECT 
    transaction_date,
    total_assets,
    total_liabilities,
    total_equity,
    CASE 
        WHEN total_assets = (total_liabilities + total_equity) THEN 'Balanced'
        ELSE 'Unbalanced'
    END AS balance_status
FROM BalanceValidation
ORDER BY transaction_date;

        ELSE 'Unbalanced'
    END AS balance_status
FROM BalanceValidation;
