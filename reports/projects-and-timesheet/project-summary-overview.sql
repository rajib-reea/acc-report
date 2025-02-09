| #  | project_id | project_name  | total_cost | total_revenue | total_hours_worked | total_profit |
|----|------------|---------------|------------|----------------|---------------------|--------------|
| 1  | 1          | Project Alpha | 1300.00    | 8000.00        | 0                   | 6700.00      |
| 2  | 3          | Project Gamma | 1400.00    | 5600.00        | 0                   | 4200.00      |
| 3  | 2          | Project Beta  | 1150.00    | 3900.00        | 0                   | 2750.00      |



Algorithm:
  
Project_Summary_Overview(startDate, endDate):
  1. Retrieve all projects within the specified date range (startDate to endDate).
  2. Retrieve project-related data (e.g., cost, revenue, hours worked).
  3. For each project, calculate the total cost, total revenue, and total hours worked.
  4. Optionally, calculate the total profit for each project:
     Profit = Project Revenue - Project Cost.
  5. Calculate the overall total project costs, total revenue, and total profits across all projects.
  6. Optionally, calculate the total time spent on each project.
  7. Validate the data (ensure no invalid or missing values).
  8. Store the project summary data and return the results (overview of all projects).

SQL:

  -- Step 1: Generate daily date series for the specified date range
WITH DateSeries AS (
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

-- Step 2: Retrieve all projects within the specified date range
project_data AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date
    FROM acc_projects p
    WHERE p.start_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Retrieve project-related revenue data
project_revenue_data AS (
    SELECT
        pr.project_id,
        SUM(pr.amount) AS total_revenue  -- Summing up all revenue types (e.g., 'Billable Hours', 'Flat Fee', etc.)
    FROM acc_project_revenues pr
    GROUP BY pr.project_id
),

-- Step 4: Retrieve project-related cost data
project_cost_data AS (
    SELECT
        prc.project_id,
        SUM(prc.amount) AS total_cost  -- Summing up all costs (Labor, Material, Overhead, etc.)
    FROM acc_project_costs prc
    GROUP BY prc.project_id
),

-- Step 5: Calculate total hours worked per project (assuming timesheet_entries table exists and is used for hours worked)
project_hours AS (
    SELECT
        te.project_id,
        SUM(te.hours_worked) AS total_hours_worked
    FROM acc_timesheets te
    WHERE te.entry_date BETWEEN '2025-01-01' AND '2025-01-10'
    GROUP BY te.project_id
)

-- Step 6: Combine all data and calculate total cost, total revenue, and profit
SELECT
    pd.project_id,
    pd.project_name,
    COALESCE(pcd.total_cost, 0) AS total_cost,  -- Get total cost from project_cost_data CTE
    COALESCE(prd.total_revenue, 0) AS total_revenue,  -- Get total revenue from project_revenue_data CTE
    COALESCE(ph.total_hours_worked, 0) AS total_hours_worked,
    -- Step 7: Calculate profitability (revenue - cost)
    COALESCE(prd.total_revenue, 0) - COALESCE(pcd.total_cost, 0) AS total_profit
FROM project_data pd
LEFT JOIN project_revenue_data prd ON pd.project_id = prd.project_id
LEFT JOIN project_cost_data pcd ON pd.project_id = pcd.project_id
LEFT JOIN project_hours ph ON pd.project_id = ph.project_id

-- Step 8: Optional - Group by project to get the overall total project costs, revenue, and profits
ORDER BY total_profit DESC;
