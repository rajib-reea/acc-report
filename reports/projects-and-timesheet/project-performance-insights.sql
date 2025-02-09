| #  | project_id | project_name  | total_project_revenue | total_project_cost | profitability | total_hours_worked | total_estimated_hours | actual_vs_estimated_hours_percentage | timeline_adherence_days |
|----|------------|---------------|-----------------------|--------------------|---------------|--------------------|-----------------------|--------------------------------------|-------------------------|
| 1  | 1          | Project Alpha | 6500.00               | 1500.00            | 5000.00       | 0                  | 0                     | 0                                    | 1                       |
| 2  | 1          | Project Alpha | 6500.00               | 1500.00            | 5000.00       | 0                  | 0                     | 0                                    | 1                       |
| 3  | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 4  | 1          | Project Alpha | 6500.00               | 1500.00            | 5000.00       | 0                  | 0                     | 0                                    | 1                       |
| 5  | 2          | Project Beta  | 3000.00               | 900.00             | 2100.00       | 0                  | 0                     | 0                                    | 1                       |
| 6  | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 7  | 1          | Project Alpha | 6500.00               | 1500.00            | 5000.00       | 0                  | 0                     | 0                                    | 1                       |
| 8  | 2          | Project Beta  | 3000.00               | 900.00             | 2100.00       | 0                  | 0                     | 0                                    | 1                       |
| 9  | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 10 | 1          | Project Alpha | 6500.00               | 1500.00            | 5000.00       | 0                  | 0                     | 0                                    | 1                       |
| 11 | 2          | Project Beta  | 3000.00               | 900.00             | 2100.00       | 0                  | 0                     | 0                                    | 1                       |
| 12 | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 13 | 2          | Project Beta  | 3000.00               | 900.00             | 2100.00       | 0                  | 0                     | 0                                    | 1                       |
| 14 | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 15 | 2          | Project Beta  | 3000.00               | 900.00             | 2100.00       | 0                  | 0                     | 0                                    | 1                       |
| 16 | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 17 | 2          | Project Beta  | 3000.00               | 900.00             | 2100.00       | 0                  | 0                     | 0                                    | 1                       |
| 18 | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 19 | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |
| 20 | 3          | Project Gamma | 4500.00               | 1100.00            | 3400.00       | 0                  | 0                     | 0                                    | 1                       |

Algorithm:
  
Project_Performance_Insights(startDate, endDate):
  1. Retrieve all projects within the specified date range (startDate to endDate).
  2. Retrieve project-related data (e.g., cost, revenue, hours worked, completion status).
  3. For each project, calculate key performance metrics:
     - Profitability (Revenue - Cost).
     - Actual hours worked vs. estimated hours.
     - Project timeline adherence (actual completion date vs. planned completion date).
  4. Optionally, calculate performance metrics by employee or department.
  5. Optionally, identify high-performing and underperforming projects based on profitability or other KPIs.
  6. Validate the performance data (ensure no invalid or missing values).
  7. Store the project performance data and return the results (performance insights by project, employee, or department).

SQL:
  
WITH DateSeries AS (
    -- Generate a series of dates between 2025-01-01 and 2025-01-10 (daily intervals)
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

project_data AS (
    -- Step 1: Retrieve all projects within the specified date range
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date,
        p.planned_completion_date,
        p.actual_completion_date
    FROM acc_projects p
    WHERE p.start_date BETWEEN '2025-01-01' AND '2025-01-10'
       OR p.end_date BETWEEN '2025-01-01' AND '2025-01-10'
),

project_cost_revenue AS (
    -- Step 2: Retrieve project-related data (cost, revenue, etc.)
    SELECT
        pr.project_id,
        SUM(CASE WHEN pr.revenue_type = 'Billable Hours' THEN pr.amount ELSE 0 END) AS total_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Flat Fee' THEN pr.amount ELSE 0 END) AS total_flat_fee_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Milestone Payment' THEN pr.amount ELSE 0 END) AS total_milestone_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Labor Cost' THEN pr.amount ELSE 0 END) AS total_labor_cost,
        SUM(CASE WHEN pr.revenue_type = 'Material Cost' THEN pr.amount ELSE 0 END) AS total_material_cost
    FROM acc_project_revenues pr
    WHERE pr.project_id IN (SELECT project_id FROM project_data)
    GROUP BY pr.project_id
),

project_timesheet AS (
    -- Step 3: Retrieve timesheet data (hours worked by employees on the project)
    SELECT
        ts.project_id,
        SUM(ts.hours_worked) AS total_hours_worked
    FROM acc_timesheets ts
    WHERE ts.project_id IN (SELECT project_id FROM project_data)
    GROUP BY ts.project_id
)

-- Step 4: Calculate key performance metrics and combine all data
SELECT
    pd.project_id,
    pd.project_name,
    -- Calculate total revenue (sum of different revenue types)
    COALESCE(pr.total_revenue, 0) + COALESCE(pr.total_flat_fee_revenue, 0) + COALESCE(pr.total_milestone_revenue, 0) AS total_project_revenue,
    -- Calculate total cost (sum of labor and material costs)
    COALESCE(pr.total_labor_cost, 0) + COALESCE(pr.total_material_cost, 0) AS total_project_cost,
    -- Calculate profitability (Revenue - Cost)
    (COALESCE(pr.total_revenue, 0) + COALESCE(pr.total_flat_fee_revenue, 0) + COALESCE(pr.total_milestone_revenue, 0)) - 
    (COALESCE(pr.total_labor_cost, 0) + COALESCE(pr.total_material_cost, 0)) AS profitability,
    -- Actual hours worked
    COALESCE(pt.total_hours_worked, 0) AS total_hours_worked,
    -- Estimated hours (if available, adjust accordingly)
    0 AS total_estimated_hours,  -- Placeholder since we don't have `estimated_hours`
    -- Actual vs. Estimated hours percentage (set to 0 since we don't have `estimated_hours`)
    0 AS actual_vs_estimated_hours_percentage,
    -- Timeline adherence (Actual completion date vs. Planned completion date)
    CASE 
        WHEN pd.planned_completion_date IS NOT NULL AND pd.actual_completion_date IS NOT NULL THEN 
            (pd.actual_completion_date - pd.planned_completion_date)
        ELSE NULL
    END AS timeline_adherence_days

FROM project_data pd
LEFT JOIN project_cost_revenue pr ON pd.project_id = pr.project_id
LEFT JOIN project_timesheet pt ON pd.project_id = pt.project_id
LEFT JOIN DateSeries ds ON ds.transaction_date BETWEEN pd.start_date AND pd.end_date

WHERE (pr.total_revenue IS NOT NULL OR pr.total_labor_cost IS NOT NULL)
  AND pd.project_id IS NOT NULL
ORDER BY ds.transaction_date, pd.project_id;
