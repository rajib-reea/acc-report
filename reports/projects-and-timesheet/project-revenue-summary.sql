| project_id | project_name   | total_billable_hours_revenue | total_flat_fee_revenue | total_milestone_revenue | total_project_revenue |
|------------|----------------|------------------------------|------------------------|-------------------------|-----------------------|
| 1          | Project Alpha  | 1500.00                      | 2000.00                | 3000.00                 | 6500.00               |
| 2          | Project Alpha  | 1500.00                      | 2000.00                | 3000.00                 | 6500.00               |
| 3          | Project Alpha  | 1500.00                      | 2000.00                | 3000.00                 | 6500.00               |
| 4          | Project Alpha  | 1500.00                      | 2000.00                | 3000.00                 | 6500.00               |
| 5          | Project Alpha  | 1500.00                      | 2000.00                | 3000.00                 | 6500.00               |
| 6          | Project Beta   | 800.00                       | 1200.00                | 1000.00                 | 3000.00               |
| 7          | Project Beta   | 800.00                       | 1200.00                | 1000.00                 | 3000.00               |
| 8          | Project Beta   | 800.00                       | 1200.00                | 1000.00                 | 3000.00               |
| 9          | Project Beta   | 800.00                       | 1200.00                | 1000.00                 | 3000.00               |
| 10         | Project Beta   | 800.00                       | 1200.00                | 1000.00                 | 3000.00               |
| 11         | Project Beta   | 800.00                       | 1200.00                | 1000.00                 | 3000.00               |
| 12         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 13         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 14         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 15         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 16         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 17         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 18         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 19         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 20         | Project Gamma  | 1000.00                      | 1500.00                | 2000.00                 | 4500.00               |
| 21         | All Projects   | 3300.00                      | 4700.00                | 6000.00                 |                       |

Algorithm:
  
Project_Revenue_Summary(startDate, endDate):
  1. Retrieve all projects within the specified date range (startDate to endDate).
  2. Retrieve project revenue data (e.g., billable hours, contract value).
  3. For each project, calculate the total revenue:
     Total Project Revenue = Sum of all revenue associated with the project (billable hours, client payments).
  4. Optionally, calculate revenue by source (e.g., billable hours, flat fee, milestone payments).
  5. Calculate the total revenue across all projects.
  6. Validate the project revenue data (ensure no invalid or missing values).
  7. Store the project revenue summary data and return the results (total revenue, categorized by source).

SQL:
WITH DateSeries AS (
    -- Generate a series of dates between 2025-01-01 and 2025-01-10 (daily intervals)
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

-- Step 1: Retrieve all projects within the specified date range (using DateSeries to ensure daily granularity)
project_data AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date
    FROM acc_projects p
    WHERE p.start_date BETWEEN '2025-01-01' AND '2025-01-10'
      OR p.end_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 2: Retrieve project revenue data (billable hours, contract value, etc.)
project_revenue AS (
    SELECT
        pr.project_id,
        SUM(CASE WHEN pr.revenue_type = 'Billable Hours' THEN pr.amount ELSE 0 END) AS total_billable_hours_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Flat Fee' THEN pr.amount ELSE 0 END) AS total_flat_fee_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Milestone Payment' THEN pr.amount ELSE 0 END) AS total_milestone_revenue
    FROM project_revenues pr
    WHERE pr.project_id IN (SELECT project_id FROM project_data)
    GROUP BY pr.project_id
)

-- Step 3: Combine project data and revenue data to calculate total revenue for each project
SELECT
    pd.project_id,
    pd.project_name,
    COALESCE(pr.total_billable_hours_revenue, 0) AS total_billable_hours_revenue,
    COALESCE(pr.total_flat_fee_revenue, 0) AS total_flat_fee_revenue,
    COALESCE(pr.total_milestone_revenue, 0) AS total_milestone_revenue,
    (COALESCE(pr.total_billable_hours_revenue, 0) + COALESCE(pr.total_flat_fee_revenue, 0) + COALESCE(pr.total_milestone_revenue, 0)) AS total_project_revenue
FROM project_data pd
LEFT JOIN project_revenue pr ON pd.project_id = pr.project_id
LEFT JOIN DateSeries ds ON ds.transaction_date BETWEEN pd.start_date AND pd.end_date

-- Step 4: Optionally, calculate the total revenue across all projects
UNION ALL

SELECT
    NULL AS project_id,  -- Using NULL instead of 'Total' for project_id to avoid type mismatch
    'All Projects' AS project_name,
    SUM(COALESCE(pr.total_billable_hours_revenue, 0)) AS total_billable_hours_revenue,
    SUM(COALESCE(pr.total_flat_fee_revenue, 0)) AS total_flat_fee_revenue,
    SUM(COALESCE(pr.total_milestone_revenue, 0)) AS total_milestone_revenue,
    SUM(COALESCE(pr.total_billable_hours_revenue, 0) + COALESCE(pr.total_flat_fee_revenue, 0) + COALESCE(pr.total_milestone_revenue, 0)) AS total_project_revenue
FROM project_revenue pr

-- Step 5: Validate the project revenue data (ensure no invalid or missing values)
WHERE (pr.total_billable_hours_revenue IS NOT NULL 
    OR pr.total_flat_fee_revenue IS NOT NULL 
    OR pr.total_milestone_revenue IS NOT NULL)
