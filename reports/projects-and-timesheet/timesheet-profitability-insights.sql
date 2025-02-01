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
-- Step 1: Retrieve all timesheet entries within the specified date range (startDate to endDate)
WITH timesheet_data AS (
    SELECT
        te.employee_id,
        te.project_id,
        te.hours_worked,
        te.is_billable,
        te.entry_date
    FROM timesheet_entries te
    WHERE te.entry_date BETWEEN :startDate AND :endDate
),

-- Step 2: Retrieve project cost and revenue data
project_cost_revenue AS (
    SELECT
        pr.project_id,
        prc.total_cost,
        pr.client_rate
    FROM projects_revenue pr
    JOIN projects_costs prc ON pr.project_id = prc.project_id
)

-- Step 3: Calculate total hours worked per project and total cost and revenue
SELECT
    ts.project_id,
    SUM(ts.hours_worked) AS total_hours_worked,
    SUM(CASE WHEN ts.is_billable THEN ts.hours_worked ELSE 0 END) AS total_billable_hours,
    SUM(CASE WHEN NOT ts.is_billable THEN ts.hours_worked ELSE 0 END) AS total_non_billable_hours,
    prc.total_cost,
    prc.client_rate,
    
    -- Step 4: Calculate the associated project cost
    prc.total_cost + SUM(ts.hours_worked * er.hourly_rate) AS project_cost,

    -- Step 5: Calculate the project revenue (if billable)
    prc.client_rate * SUM(CASE WHEN ts.is_billable THEN ts.hours_worked ELSE 0 END) AS project_revenue,

    -- Step 6: Calculate profitability
    (prc.client_rate * SUM(CASE WHEN ts.is_billable THEN ts.hours_worked ELSE 0 END)) - 
    (prc.total_cost + SUM(ts.hours_worked * er.hourly_rate)) AS profitability

FROM timesheet_data ts
JOIN employee_rates er ON ts.employee_id = er.employee_id
JOIN project_cost_revenue prc ON ts.project_id = prc.project_id

-- Step 7: Optionally group by employee or department for deeper insights (you can extend this part if needed)
GROUP BY ts.project_id, prc.total_cost, prc.client_rate
ORDER BY profitability DESC;
