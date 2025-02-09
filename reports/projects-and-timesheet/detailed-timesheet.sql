| #   | employee_id | project_id | entry_date  | total_hours_worked | total_billable_hours | total_non_billable_hours | task_id | total_hours_per_task |
|-----|-------------|------------|-------------|--------------------|----------------------|--------------------------|---------|----------------------|
| 1   | 1           | 101        | 2025-01-01  | 8.00               | 8.00                 | 0.00                     | 1001    | 8.00                 |
| 2   | 1           | 101        | 2025-01-02  | 4.00               | 0.00                 | 4.00                     | 1002    | 4.00                 |
| 3   | 1           | 101        | 2025-01-07  | 5.00               | 5.00                 | 0.00                     | 1002    | 5.00                 |
| 4   | 1           | 102        | 2025-01-03  | 6.50               | 6.50                 | 0.00                     | 1003    | 6.50                 |
| 5   | 1           | 102        | 2025-01-05  | 8.00               | 8.00                 | 0.00                     | 1003    | 8.00                 |
| 6   | 1           | 102        | 2025-01-09  | 4.50               | 4.50                 | 0.00                     | 1003    | 4.50                 |
| 7   | 2           | 101        | 2025-01-01  | 7.00               | 7.00                 | 0.00                     | 1001    | 7.00                 |
| 8   | 2           | 101        | 2025-01-07  | 6.50               | 6.50                 | 0.00                     | 1001    | 6.50                 |
| 9   | 2           | 103        | 2025-01-02  | 5.00               | 0.00                 | 5.00                     | 1004    | 5.00                 |
| 10  | 2           | 103        | 2025-01-03  | 4.00               | 4.00                 | 0.00                     | 1005    | 4.00                 |
| 11  | 2           | 103        | 2025-01-06  | 3.00               | 0.00                 | 3.00                     | 1004    | 3.00                 |
| 12  | 2           | 103        | 2025-01-09  | 8.00               | 8.00                 | 0.00                     | 1005    | 8.00                 |
| 13  | 3           | 104        | 2025-01-04  | 8.00               | 8.00                 | 0.00                     | 1006    | 8.00                 |
| 14  | 3           | 104        | 2025-01-05  | 7.50               | 0.00                 | 7.50                     | 1007    | 7.50                 |
| 15  | 3           | 104        | 2025-01-06  | 4.00               | 4.00                 | 0.00                     | 1006    | 4.00                 |
| 16  | 3           | 104        | 2025-01-08  | 7.00               | 0.00                 | 7.00                     | 1007    | 7.00                 |
| 17  | 3           | 104        | 2025-01-10  | 7.50               | 7.50                 | 0.00                     | 1006    | 7.50                 |

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
-- Create a series of dates for the daily breakdown
WITH DateSeries AS (
    SELECT generate_series('2025-01-01'::DATE, '2025-01-31'::DATE, INTERVAL '1 day')::DATE AS entry_date
),

TimesheetEntries AS (
    -- Step 2: Retrieve all timesheet entries within the specified date range
    SELECT
        t.entry_id,
        t.employee_id,
        t.project_id,
        t.task_id,
        t.hours_worked,
        t.entry_date,
        t.is_billable
    FROM acc_timesheet_entries t
    JOIN DateSeries d ON t.entry_date = d.entry_date
),

ValidatedTimesheets AS (
    -- Step 6: Validate the timesheet data
    SELECT
        t.entry_id,
        t.employee_id,
        t.project_id,
        t.task_id,
        t.hours_worked,
        t.entry_date,
        t.is_billable
    FROM TimesheetEntries t
    WHERE t.hours_worked > 0
      AND t.employee_id IS NOT NULL
      AND t.project_id IS NOT NULL
),

EmployeeProjectDailyHours AS (
    -- Step 3 & 4: Group by employee, project, and date to calculate daily hours
    SELECT
        t.employee_id,
        t.project_id,
        t.entry_date,
        SUM(t.hours_worked) AS total_hours_worked,
        SUM(CASE WHEN t.is_billable = TRUE THEN t.hours_worked ELSE 0 END) AS total_billable_hours,
        SUM(CASE WHEN t.is_billable = FALSE THEN t.hours_worked ELSE 0 END) AS total_non_billable_hours
    FROM ValidatedTimesheets t
    GROUP BY t.employee_id, t.project_id, t.entry_date
),

EmployeeProjectTaskDetails AS (
    -- Step 5: Task-level breakdown (if applicable)
    SELECT
        t.employee_id,
        t.project_id,
        t.task_id,
        t.entry_date,
        SUM(t.hours_worked) AS total_hours_per_task
    FROM ValidatedTimesheets t
    GROUP BY t.employee_id, t.project_id, t.task_id, t.entry_date
)

-- Step 7: Return the detailed timesheet report
SELECT
    e.employee_id,
    e.project_id,
    e.entry_date,
    e.total_hours_worked,
    e.total_billable_hours,
    e.total_non_billable_hours,
    t.task_id,
    t.total_hours_per_task
FROM EmployeeProjectDailyHours e
LEFT JOIN EmployeeProjectTaskDetails t
    ON e.employee_id = t.employee_id
    AND e.project_id = t.project_id
    AND e.entry_date = t.entry_date
ORDER BY e.employee_id, e.project_id, e.entry_date, t.task_id;
