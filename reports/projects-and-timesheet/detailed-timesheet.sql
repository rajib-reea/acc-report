Algorithm:
  
Detailed_Timesheet_Report(startDate, endDate):
  1. Retrieve all timesheet entries within the specified date range (startDate to endDate).
  2. Group the timesheet entries by employee and project.
  3. For each employee and project, calculate the total hours worked:
     Total Hours Worked = Sum of all hours worked for the employee on the specific project.
  4. Optionally, calculate the total billable hours and non-billable hours for each employee or project.
  5. Calculate the total time spent on each task or activity (if applicable).
  6. Validate the timesheet data (ensure no missing or incorrect entries).
  7. Store the detailed timesheet data and return the results (employee/project breakdown, total hours worked).

 SQL: 
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-01-31'

WITH TimesheetEntries AS (
    -- Step 1: Retrieve all timesheet entries within the specified date range
    SELECT
        t.entry_id,
        t.employee_id,
        t.project_id,
        t.task_id,                -- Optional: If you want to track tasks
        t.hours_worked,
        t.entry_date,
        t.is_billable             -- Optional: To identify billable vs non-billable hours
    FROM timesheet_entries t
    WHERE t.entry_date BETWEEN :startDate AND :endDate
),
EmployeeProjectHours AS (
    -- Step 2: Group the timesheet entries by employee and project and calculate the total hours worked
    SELECT
        t.employee_id,
        t.project_id,
        SUM(t.hours_worked) AS total_hours_worked,
        SUM(CASE WHEN t.is_billable = TRUE THEN t.hours_worked ELSE 0 END) AS total_billable_hours,
        SUM(CASE WHEN t.is_billable = FALSE THEN t.hours_worked ELSE 0 END) AS total_non_billable_hours
    FROM TimesheetEntries t
    GROUP BY t.employee_id, t.project_id
),
EmployeeProjectDetails AS (
    -- Step 5: Optionally, calculate the total time spent on each task (if applicable)
    SELECT
        t.employee_id,
        t.project_id,
        t.task_id,
        SUM(t.hours_worked) AS total_hours_per_task
    FROM TimesheetEntries t
    GROUP BY t.employee_id, t.project_id, t.task_id
),
ValidatedTimesheets AS (
    -- Step 6: Validate the timesheet data (ensure no missing or incorrect entries)
    SELECT
        t.entry_id,
        t.employee_id,
        t.project_id,
        t.task_id,
        t.hours_worked,
        t.entry_date,
        t.is_billable
    FROM TimesheetEntries t
    WHERE t.hours_worked > 0   -- Validate that the hours worked is greater than zero
    AND t.employee_id IS NOT NULL
    AND t.project_id IS NOT NULL
)
-- Step 7: Store the detailed timesheet data and return the results
SELECT
    e.employee_id,
    e.project_id,
    e.total_hours_worked,
    e.total_billable_hours,
    e.total_non_billable_hours,
    t.task_id,
    t.total_hours_per_task
FROM EmployeeProjectHours e
LEFT JOIN EmployeeProjectDetails t
    ON e.employee_id = t.employee_id
    AND e.project_id = t.project_id
ORDER BY e.employee_id, e.project_id, t.task_id;
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    department VARCHAR(100)
);
