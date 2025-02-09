| project_id | project_name  | total_cost | total_revenue | total_hours_worked | total_billable_hours | total_non_billable_hours | discrepancy_in_revenue | discrepancy_in_hours_worked |
|------------|---------------|------------|----------------|---------------------|-----------------------|--------------------------|-------------------------|------------------------------|
| 1          | Project Alpha | 1300.00    | 6500.00        | 0.00                | 0.00                  | 0.00                     | 5200.00                 | -0.20                        |
| 2          | Project Alpha | 1300.00    | 6500.00        | 0.00                | 0.00                  | 0.00                     | 5200.00                 | -0.20                        |
| 3          | Project Alpha | 1300.00    | 6500.00        | 0.00                | 0.00                  | 0.00                     | 5200.00                 | -0.20                        |
| 4          | Project Alpha | 1300.00    | 6500.00        | 0.00                | 0.00                  | 0.00                     | 5200.00                 | -0.20                        |
| 5          | Project Alpha | 1300.00    | 6500.00        | 0.00                | 0.00                  | 0.00                     | 5200.00                 | -0.20                        |

Algorithm:
  
Project_Specific_Breakdown(projectId, startDate, endDate):
  1. Retrieve the specific project data using the project ID for the specified date range (startDate to endDate).
  2. Retrieve timesheet entries, project costs, and project revenue for the project.
  3. For the project, calculate the total cost, total revenue, and total hours worked.
  4. Optionally, calculate the total billable and non-billable hours for the project.
  5. Optionally, calculate any discrepancies between planned and actual project costs or hours worked.
  6. Validate the project data (ensure no invalid or missing values).
  7. Store the project-specific breakdown data and return the results (detailed view of the project’s cost, revenue, and hours worked).

 SQL:
  
-- Step 1: Retrieve specific project data using the project ID within the specified date range
WITH DateSeries AS (
    -- Generate a series of dates between '2025-01-01' and '2025-01-10' (daily intervals)
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

project_data AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date
    FROM acc_projects p
    WHERE p.project_id = 1
      AND p.start_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 2: Retrieve timesheet entries for the specified project
timesheet_data AS (
    SELECT
        te.project_id,
        SUM(te.hours_worked) AS total_hours_worked,
        SUM(CASE WHEN te.is_billable = TRUE THEN te.hours_worked ELSE 0 END) AS total_billable_hours,
        SUM(CASE WHEN te.is_billable = FALSE THEN te.hours_worked ELSE 0 END) AS total_non_billable_hours
    FROM acc_timesheets te  -- Assuming acc_timesheets exists
    WHERE te.project_id = 1
      AND te.entry_date BETWEEN '2025-01-01' AND '2025-01-10'
    GROUP BY te.project_id
),

-- Step 3: Retrieve project cost and revenue data
project_cost_revenue AS (
    SELECT
        pr.project_id,
        SUM(prc.amount) AS total_revenue  -- Summing all revenue entries for the project
    FROM acc_project_revenues pr
    JOIN acc_project_costs prc ON pr.project_id = prc.project_id
    WHERE pr.project_id = 1
    GROUP BY pr.project_id
),

-- Step 4: Calculate total cost for each project from the `acc_project_costs` table
project_total_cost AS (
    SELECT
        prc.project_id,
        SUM(prc.amount) AS total_cost  -- Summing cost amounts for each project
    FROM acc_project_costs prc
    WHERE prc.project_id = 1
    GROUP BY prc.project_id
)

-- Step 5: Combine all the data to calculate total cost, total revenue, total hours worked, etc.
SELECT
    pd.project_id,
    pd.project_name,
    ROUND(COALESCE(ptc.total_cost, 0), 2) AS total_cost,  -- Now using the summed total cost from project_total_cost CTE
    ROUND(COALESCE(prcr.total_revenue, 0), 2) AS total_revenue,  -- From the project_cost_revenue CTE
    ROUND(COALESCE(tsd.total_hours_worked, 0), 2) AS total_hours_worked,
    ROUND(COALESCE(tsd.total_billable_hours, 0), 2) AS total_billable_hours,
    ROUND(COALESCE(tsd.total_non_billable_hours, 0), 2) AS total_non_billable_hours,
    -- Step 6: Calculate discrepancies between planned and actual costs or hours worked (if applicable)
    ROUND(COALESCE(prcr.total_revenue, 0) - COALESCE(ptc.total_cost, 0), 2) AS discrepancy_in_revenue,
    ROUND(COALESCE(tsd.total_hours_worked, 0) - COALESCE(ptc.total_cost / NULLIF(COALESCE(prcr.total_revenue, 0), 0), 0), 2) AS discrepancy_in_hours_worked

FROM project_data pd
LEFT JOIN timesheet_data tsd ON pd.project_id = tsd.project_id
LEFT JOIN project_cost_revenue prcr ON pd.project_id = prcr.project_id
LEFT JOIN project_total_cost ptc ON pd.project_id = ptc.project_id  -- Using the project_total_cost CTE for total cost
LEFT JOIN DateSeries ds ON ds.transaction_date BETWEEN pd.start_date AND pd.end_date;
