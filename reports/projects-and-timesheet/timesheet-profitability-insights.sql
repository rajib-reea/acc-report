| project_id | total_hours_worked | total_billable_hours | total_non_billable_hours | project_cost | project_revenue | profitability |
|------------|---------------------|-----------------------|---------------------------|--------------|------------------|---------------|
| 1          | 30.50               | 26.50                 | 4.00                      | 0            | 0                | 0             |
| 2          | 19.00               | 19.00                 | 0                         | 0            | 0                | 0             |
| 3          | 20.00               | 12.00                 | 8.00                      | 0            | 0                | 0             |
| 4          | 34.00               | 19.50                 | 14.50                     | 0            | 0                | 0             |

Algorithm:
  
Timesheet_Profitability_Insights(startDate, endDate):
  1. Retrieve all timesheet entries within the specified date range (startDate to endDate).
  2. Retrieve project cost and revenue data for the same date range.
  3. For each project, calculate the total time spent by employees:
     Total Hours Worked = Sum of all hours worked by all employees on the project.
  4. Calculate the associated project costs based on the employee hourly rate and total hours worked.
  5. Calculate the project revenue (if billable) based on the total billable hours and client rates.
  6. Calculate profitability:
     Profitability = Project Revenue - Project Cost.
  7. Optionally, calculate profitability by employee or department.
  8. Validate the profitability data (ensure no invalid or missing values).
  9. Store the profitability insights data and return the results (profitability per project, employee, or department).

 SQL: 

 -- Step 1: Generate daily date series for the specified date range
WITH DateSeries AS (
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

-- Step 2: Retrieve all timesheet entries within the specified date range
timesheet_data AS (
    SELECT
        te.employee_id,
        te.project_id,
        te.hours_worked,
        te.is_billable,
        te.entry_date
    FROM acc_timesheets te
    WHERE te.entry_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Retrieve project cost data for the specified date range
project_cost_data AS (
    SELECT
        pc.project_id,
        pc.transaction_date,
        SUM(pc.amount) AS total_cost
    FROM acc_project_costs pc
    WHERE pc.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
    GROUP BY pc.project_id, pc.transaction_date
),

-- Step 4: Retrieve project revenue data for the specified date range
project_revenue_data AS (
    SELECT
        pr.project_id,
        SUM(pr.amount) AS total_revenue
    FROM acc_project_revenues pr
    WHERE pr.revenue_type IN ('Billable Hours', 'Flat Fee', 'Milestone Payment')  -- Focus on revenue-generating types
    GROUP BY pr.project_id
)

-- Step 5: Calculate total hours worked per project, total cost, and revenue
SELECT
    ts.project_id,
    -- Total hours worked (sum of all timesheet entries)
    SUM(ts.hours_worked) AS total_hours_worked,
    
    -- Total billable hours (only count billable entries)
    SUM(CASE WHEN ts.is_billable THEN ts.hours_worked ELSE 0 END) AS total_billable_hours,
    
    -- Total non-billable hours (only count non-billable entries)
    SUM(CASE WHEN NOT ts.is_billable THEN ts.hours_worked ELSE 0 END) AS total_non_billable_hours,
    
    -- Retrieve the total cost for the project within the specified date range
    COALESCE(pc.total_cost, 0) AS project_cost,

    -- Retrieve the total revenue for the project
    COALESCE(prd.total_revenue, 0) AS project_revenue,

    -- Calculate profitability: Revenue - Cost
    COALESCE(prd.total_revenue, 0) - COALESCE(pc.total_cost, 0) AS profitability

FROM timesheet_data ts
LEFT JOIN project_cost_data pc ON ts.project_id = pc.project_id
LEFT JOIN project_revenue_data prd ON ts.project_id = prd.project_id

-- Step 6: Optionally group by project to get the overall profitability
GROUP BY ts.project_id, pc.total_cost, prd.total_revenue
ORDER BY profitability DESC;
