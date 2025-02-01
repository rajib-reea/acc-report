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
-- Step 1: Retrieve all projects within the specified date range
WITH project_data AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date,
        p.planned_completion_date,
        p.actual_completion_date
    FROM projects p
    WHERE p.start_date BETWEEN :startDate AND :endDate
      OR p.end_date BETWEEN :startDate AND :endDate
),

-- Step 2: Retrieve project-related data (cost, revenue, hours worked, etc.)
project_cost_revenue AS (
    SELECT
        pr.project_id,
        SUM(CASE WHEN pr.revenue_type = 'Billable Hours' THEN pr.amount ELSE 0 END) AS total_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Flat Fee' THEN pr.amount ELSE 0 END) AS total_flat_fee_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Milestone Payment' THEN pr.amount ELSE 0 END) AS total_milestone_revenue,
        SUM(CASE WHEN pr.revenue_type = 'Labor Cost' THEN pr.amount ELSE 0 END) AS total_labor_cost,
        SUM(CASE WHEN pr.revenue_type = 'Material Cost' THEN pr.amount ELSE 0 END) AS total_material_cost
    FROM project_revenues pr
    WHERE pr.project_id IN (SELECT project_id FROM project_data)
    GROUP BY pr.project_id
),

-- Step 3: Retrieve timesheet data (hours worked by employees on the project)
project_timesheet AS (
    SELECT
        ts.project_id,
        SUM(ts.hours_worked) AS total_hours_worked,
        SUM(ts.estimated_hours) AS total_estimated_hours
    FROM timesheets ts
    WHERE ts.project_id IN (SELECT project_id FROM project_data)
    GROUP BY ts.project_id
)

-- Step 4: Calculate key performance metrics and combine all data
SELECT
    pd.project_id,
    pd.project_name,
    COALESCE(pr.total_revenue, 0) + COALESCE(pr.total_flat_fee_revenue, 0) + COALESCE(pr.total_milestone_revenue, 0) AS total_project_revenue,
    COALESCE(pr.total_labor_cost, 0) + COALESCE(pr.total_material_cost, 0) AS total_project_cost,
    (COALESCE(pr.total_revenue, 0) + COALESCE(pr.total_flat_fee_revenue, 0) + COALESCE(pr.total_milestone_revenue, 0)) - 
    (COALESCE(pr.total_labor_cost, 0) + COALESCE(pr.total_material_cost, 0)) AS profitability,
    COALESCE(pt.total_hours_worked, 0) AS total_hours_worked,
    COALESCE(pt.total_estimated_hours, 0) AS total_estimated_hours,
    CASE 
        WHEN COALESCE(pt.total_estimated_hours, 0) > 0 THEN 
            (COALESCE(pt.total_hours_worked, 0) / COALESCE(pt.total_estimated_hours, 0)) * 100
        ELSE 0
    END AS actual_vs_estimated_hours_percentage,
    CASE 
        WHEN pd.planned_completion_date IS NOT NULL AND pd.actual_completion_date IS NOT NULL THEN 
            DATEDIFF(pd.actual_completion_date, pd.planned_completion_date)
        ELSE NULL
    END AS timeline_adherence_days

FROM project_data pd
LEFT JOIN project_cost_revenue pr ON pd.project_id = pr.project_id
LEFT JOIN project_timesheet pt ON pd.project_id = pt.project_id

-- Step 5: Optionally, calculate performance metrics by employee or department
-- (additional logic can be added if data is available for individual employees or departments)

-- Step 6: Optionally, identify high-performing and underperforming projects based on profitability or other KPIs
-- Example: Projects with positive profitability are high-performing, others are underperforming
-- Example: Projects with more than 20% overrun in hours or significant timeline delays can be flagged.

-- Step 7: Validate the performance data (ensure no invalid or missing values)
WHERE (pr.total_revenue IS NOT NULL OR pr.total_labor_cost IS NOT NULL)
