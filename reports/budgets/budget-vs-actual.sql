| #  | Transaction Date | Category           | Budgeted Amount | Actual Amount | Variance  | Percentage Variance | Category Type |
|----|----------------|--------------------|----------------|--------------|----------|---------------------|--------------|
| 1  | 2025-01-01     | Cost of Goods Sold | 1500.00       | 0.00         | -1500.00  | -100.00%            | Expenses     |
| 2  | 2025-01-01     | Expenses           | 2000.00       | 0.00         | -2000.00  | -100.00%            | Expenses     |
| 3  | 2025-01-01     | Revenue            | 5000.00       | 0.00         | -5000.00  | -100.00%            | Revenue      |
| 4  | 2025-01-01     | Sales              | 3000.00       | 0.00         | -3000.00  | -100.00%            | Revenue      |
| 5  | 2025-01-01     | Total              | 11500.00      | 0.00         | -11500.00 | -100.00%            | Summary      |
| 6  | 2025-01-02     | Cost of Goods Sold | 1500.00       | 0.00         | -1500.00  | -100.00%            | Expenses     |
| 7  | 2025-01-02     | Expenses           | 2000.00       | 0.00         | -2000.00  | -100.00%            | Expenses     |
| 8  | 2025-01-02     | Revenue            | 5000.00       | 0.00         | -5000.00  | -100.00%            | Revenue      |
| 9  | 2025-01-02     | Sales              | 3000.00       | 0.00         | -3000.00  | -100.00%            | Revenue      |
| 10 | 2025-01-02     | Total              | 11500.00      | 0.00         | -11500.00 | -100.00%            | Summary      |
| 11 | 2025-01-03     | Cost of Goods Sold | 1500.00       | 0.00         | -1500.00  | -100.00%            | Expenses     |
| 12 | 2025-01-03     | Expenses           | 2000.00       | 0.00         | -2000.00  | -100.00%            | Expenses     |
| 13 | 2025-01-03     | Revenue            | 5000.00       | 0.00         | -5000.00  | -100.00%            | Revenue      |
| 14 | 2025-01-03     | Sales              | 3000.00       | 0.00         | -3000.00  | -100.00%            | Revenue      |
| 15 | 2025-01-03     | Total              | 11500.00      | 0.00         | -11500.00 | -100.00%            | Summary      |

Algorithm:
  
Budget_vs_Actuals_Report(startDate, endDate):
  1. Retrieve the planned budget data for the specified date range (startDate to endDate):
     - Budget data includes planned amounts for each category (e.g., revenue, expenses) for the period.
  2. Retrieve the actual financial data for the same date range:
     - Actuals data includes the actual amounts spent or earned for each category during the period.
  3. Compare the budgeted amounts to the actual amounts for each category:
     - For each category, calculate the variance:
       - Variance = Actuals - Budgeted Amount.
  4. For each category, calculate the percentage variance:
     - Percentage Variance = (Variance / Budgeted Amount) * 100.
  5. Optionally, categorize the results by type (e.g., revenue, expenses, profit, etc.).
  6. Optionally, calculate the cumulative totals for both budgeted and actual amounts:
     - Total Budget = Sum of all budgeted amounts for the period.
     - Total Actuals = Sum of all actual amounts for the period.
     - Cumulative Variance = Total Actuals - Total Budget.
  7. Identify any categories where the variance is significant (e.g., over-budget or under-budget by a certain threshold).
  8. Validate the budget and actual data (ensure no missing or incorrect entries).
  9. Store the Budget vs. Actuals report and return the results:
     - Include a breakdown of each category’s budgeted, actual, variance, and percentage variance.
     - Optionally, include a summary of total budget, total actuals, and overall variance.

 SQL: 
WITH DateSeries AS (
    -- Generate a daily date range within the specified period
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 1: Retrieve daily planned budget data
budget_data AS (
    SELECT
        d.transaction_date,
        b.category,
        COALESCE(b.daily_budgeted_amount, 0) AS budgeted_amount
    FROM DateSeries d
    LEFT JOIN acc_budgets b 
        ON d.transaction_date BETWEEN b.period_start_date AND b.period_end_date
),

-- Step 2: Retrieve actual financial data per day
actuals_data AS (
    SELECT
        t.transaction_date,
        a.category,
        SUM(t.amount) AS actual_amount
    FROM acc_transactions t
    JOIN acc_accounts a ON t.account_id = a.account_id
    WHERE t.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
    GROUP BY t.transaction_date, a.category
),

-- Step 3: Compute variance and handle missing actuals
variance_data AS (
    SELECT
        b.transaction_date,
        b.category,
        b.budgeted_amount,
        COALESCE(a.actual_amount, 0) AS actual_amount,
        COALESCE(a.actual_amount, 0) - b.budgeted_amount AS variance
    FROM budget_data b
    LEFT JOIN actuals_data a 
        ON b.transaction_date = a.transaction_date AND b.category = a.category
),

-- Step 4: Compute percentage variance (handling division by zero)
percentage_variance_data AS (
    SELECT
        transaction_date,
        category,
        budgeted_amount,
        actual_amount,
        variance,
        CASE 
            WHEN budgeted_amount != 0 THEN (variance / budgeted_amount) * 100
            ELSE 0
        END AS percentage_variance
    FROM variance_data
),

-- Step 5: Categorize financial data
categorized_results AS (
    SELECT
        transaction_date,
        category,
        budgeted_amount,
        actual_amount,
        variance,
        percentage_variance,
        CASE
            WHEN category IN ('Revenue', 'Sales') THEN 'Revenue'
            WHEN category IN ('Expenses', 'Cost of Goods Sold') THEN 'Expenses'
            ELSE 'Other'
        END AS category_type
    FROM percentage_variance_data
),

-- Step 6: Compute cumulative totals per day
totals AS (
    SELECT
        transaction_date,
        SUM(budgeted_amount) AS total_budget,
        SUM(actual_amount) AS total_actuals,
        SUM(actual_amount) - SUM(budgeted_amount) AS cumulative_variance
    FROM percentage_variance_data
    GROUP BY transaction_date
)

-- Step 7: Identify significant variances per day and return results
SELECT
    transaction_date,
    category,
    budgeted_amount,
    actual_amount,
    variance,
    percentage_variance,
    category_type
FROM categorized_results
WHERE ABS(variance) > 1000  -- Significant variance threshold

UNION ALL

-- Step 8: Return daily summary totals
SELECT
    transaction_date,
    'Total' AS category,
    total_budget,
    total_actuals,
    cumulative_variance AS variance,
    CASE 
        WHEN total_budget != 0 THEN (cumulative_variance / total_budget) * 100
        ELSE 0
    END AS percentage_variance,
    'Summary' AS category_type
FROM totals
ORDER BY transaction_date, category;
