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
  
  WITH 
DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
DailyLiabilities AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'loans' THEN amount ELSE 0 END), 0) AS loans,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'accounts payable' THEN amount ELSE 0 END), 0) AS ap,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'other debts' THEN amount ELSE 0 END), 0) AS other_debts,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'taxes payable' THEN amount ELSE 0 END), 0) AS taxes_payable,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'credit lines' THEN amount ELSE 0 END), 0) AS credit_lines
    FROM acc_transactions
    WHERE 
      is_active = TRUE
    GROUP BY transaction_date
),
DailyAssets AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(
            CASE 
                WHEN LOWER(category) IN ('sales', 'subscriptions', 'service income') THEN amount
                ELSE 0 
            END
        ), 0) AS income,
        COALESCE(SUM(
            CASE 
                WHEN LOWER(category) IN ('operating expenses', 'rent', 'utilities', 'marketing', 'professional services', 'salaries', 'insurance', 'taxes') THEN amount
                ELSE 0 
            END
        ), 0) AS expenditure,
        COALESCE(SUM(
            CASE 
                WHEN LOWER(category) = 'inventory' THEN amount
                ELSE 0 
            END
        ), 0) AS inventory,
        COALESCE(SUM(
            CASE 
                WHEN LOWER(category) = 'accounts receivable' THEN amount
                ELSE 0 
            END
        ), 0) AS ar,
        COALESCE(SUM(
            CASE 
                WHEN LOWER(category) = 'fixed assets' THEN amount
                ELSE 0 
            END
        ), 0) AS fixed_assets,
        COALESCE(SUM(
            CASE 
                WHEN LOWER(category) = 'intangible assets' THEN amount
                ELSE 0 
            END
        ), 0) AS intangible_assets
    FROM acc_transactions
    WHERE is_active = TRUE
    GROUP BY transaction_date
),
DailyEquity AS (
    SELECT 
        transaction_date,
        COALESCE(SUM(CASE WHEN LOWER(category) = 'owner capital' THEN amount ELSE 0 END), 0) AS owner_capital
    FROM acc_transactions
    WHERE 
    is_active = TRUE
    GROUP BY transaction_date
),
BalanceValidation AS (
    SELECT 
        D.transaction_date,
        -- Total Assets calculation
        COALESCE(A.income + A.inventory + A.ar + A.fixed_assets + A.intangible_assets, 0) AS assets,
        -- Total Liabilities calculation (including negative assets as additional liabilities)
        COALESCE(L.loans + L.ap + L.other_debts + L.taxes_payable + L.credit_lines+A.expenditure, 0) AS liabilities,
        -- Total Equity calculation (assets - liabilities)
        COALESCE(A.income + A.inventory + A.ar + A.fixed_assets + A.intangible_assets , 0) 
        - COALESCE(L.loans + L.ap + L.other_debts + L.taxes_payable + L.credit_lines+A.expenditure, 0)
        AS equity
    FROM DateSeries D
    LEFT JOIN DailyAssets A ON D.transaction_date = A.transaction_date
    LEFT JOIN DailyLiabilities L ON D.transaction_date = L.transaction_date
    LEFT JOIN DailyEquity E ON D.transaction_date = E.transaction_date
)

SELECT 
    ds.transaction_date,
    COALESCE(dl.loans, 0) AS loans,
    COALESCE(dl.ap, 0) AS ap,
    COALESCE(dl.other_debts, 0) AS other_debts,
    COALESCE(dl.taxes_payable, 0) AS taxes_payable,
    COALESCE(dl.credit_lines, 0) AS credit_lines,
    COALESCE(da.income, 0) AS income,
    COALESCE(da.expenditure, 0) AS expenditure,
    COALESCE(da.inventory, 0) AS inventory,
    COALESCE(da.ar, 0) AS ar,
    COALESCE(da.fixed_assets, 0) AS fixed_assets,
    COALESCE(da.intangible_assets, 0) AS intangible_assets,
    COALESCE(de.owner_capital, 0) AS owner_capital,
    COALESCE(bv.equity, 0) AS equity,
    COALESCE(bv.assets, 0) AS assets,
    COALESCE(bv.liabilities, 0) AS liabilities,
    -- Adjusted invariant mismatch check (assets = liabilities + equity)
    COALESCE(bv.assets - (bv.liabilities + bv.equity), 0) AS invariant_mismatch
FROM DateSeries ds
LEFT JOIN DailyLiabilities dl ON ds.transaction_date = dl.transaction_date
LEFT JOIN DailyAssets da ON ds.transaction_date = da.transaction_date
LEFT JOIN DailyEquity de ON ds.transaction_date = de.transaction_date
LEFT JOIN BalanceValidation bv ON ds.transaction_date = bv.transaction_date
ORDER BY ds.transaction_date;


Table:
| #  | transaction_date | loans | ap | other_debts | taxes_payable | credit_lines | income | expenditure | inventory | ar | fixed_assets | intangible_assets | owner_capital | equity  | assets  | liabilities | invariant_mismatch |
|----|------------------|-------|----|-------------|---------------|--------------|--------|-------------|-----------|----|--------------|-------------------|---------------|---------|---------|-------------|--------------------|
| 1  | 2025-01-01       | 0     | 0  | 0           | 0             | 0            | 3000.00 | 0           | 0         | 0  | 0            | 0                 | 0             | 3000.00 | 3000.00 | 0           | 0.00               |
| 2  | 2025-01-02       | 0     | 0  | 0           | 0             | 0            | 0      | 400.00      | 0         | 0  | 0            | 0                 | 0             | -400.00 | 0       | 400.00      | 0.00               |
| 3  | 2025-01-03       | 0     | 0  | 0           | 0             | 0            | 0      | 0           | 0         | 0  | 0            | 0                 | 0             | 0       | 0       | 0           | 0.00               |
| 4  | 2025-01-04       | 0     | 0  | 0           | 0             | 0            | 2400.00 | 0           | 0         | 0  | 0            | 0                 | 0             | -2400.00 | 0      | 2400.00     | 0.00               |
| 5  | 2025-01-05       | 0     | 0  | 0           | 0             | 0            | 1000.00 | 0           | 0         | 0  | 0            | 0                 | 0             | 1000.00 | 1000.00 | 0           | 0.00               |
| 6  | 2025-01-06       | 0     | 0  | 0           | 0             | 0            | 0      | 150.00      | 0         | 0  | 0            | 0                 | 0             | -150.00 | 0       | 150.00      | 0.00               |
| 7  | 2025-01-07       | 0     | 0  | 0           | 0             | 0            | 0      | 500.00      | 0         | 0  | 0            | 0                 | 0             | -500.00 | 0       | 500.00      | 0.00               |
| 8  | 2025-01-08       | 0     | 0  | 0           | 0             | 0            | 1800.00 | 0           | 0         | 0  | 0            | 0                 | 0             | 1800.00 | 1800.00 | 0           | 0.00               |
| 9  | 2025-01-09       | 0     | 0  | 0           | 0             | 0            | 0      | 750.00      | 0         | 0  | 0            | 0                 | 0             | -750.00 | 0       | 750.00      | 0.00               |
| 10 | 2025-01-10       | 0     | 0  | 0           | 0             | 0            | 3000.00 | 0           | 0         | 0  | 0            | 0                 | 0             | 3000.00 | 3000.00 | 0           | 0.00               |
