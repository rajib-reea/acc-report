Algorithm:
  
Workflow_Execution_Summary(startDate, endDate):
  1. Retrieve all workflow executions within the specified date range (startDate to endDate).
  2. For each workflow execution, extract the following details:
     - Workflow ID
     - Date and time of execution
     - Status (e.g., successful, failed, pending)
     - Execution duration
     - Any errors or warnings encountered during execution
  3. Group workflows by their status (e.g., successful, failed, pending).
  4. Calculate the total number of workflows executed within the period.
  5. Calculate the success rate for all executed workflows:
     - Success Rate = (Number of Successful Workflows / Total Executed Workflows) * 100.
  6. Calculate the average duration of workflow executions:
     - Average Duration = Sum of execution durations / Total executed workflows.
  7. Optionally, identify any workflows that consistently fail or encounter issues.
  8. Validate the data (ensure no missing or incorrect workflow execution entries).
  9. Store the workflow execution summary data and return the results:
     - Summary of workflows by status, execution durations, success rate, and failure reasons.

SQL:  
CREATE TABLE workflow_executions (
    workflow_id INT PRIMARY KEY AUTO_INCREMENT,
    execution_time DATETIME NOT NULL,
    status ENUM('successful', 'failed', 'pending') NOT NULL,
    duration INT, -- Duration in seconds or any relevant time unit
    error_message TEXT
);
-- Step 1: Retrieve all workflow executions within the specified date range
WITH executions_in_range AS (
    SELECT
        workflow_id,
        execution_time,
        status,
        duration,
        error_message
    FROM workflow_executions
    WHERE execution_time BETWEEN :startDate AND :endDate
),

-- Step 2: Group the workflows by their status
grouped_workflows AS (
    SELECT
        status,
        COUNT(*) AS total_workflows,
        SUM(CASE WHEN status = 'successful' THEN 1 ELSE 0 END) AS successful_workflows,
        SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_workflows,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_workflows,
        AVG(duration) AS avg_duration -- Optional: Average duration of all executed workflows
    FROM executions_in_range
    GROUP BY status
)

-- Final SELECT: Return the summary of workflow executions by status
SELECT
    gw.status,
    gw.total_workflows,
    gw.successful_workflows,
    gw.failed_workflows,
    gw.pending_workflows,
    gw.avg_duration,
    -- List of failed workflow error messages
    GROUP_CONCAT(DISTINCT ew.error_message ORDER BY ew.execution_time SEPARATOR ', ') AS failure_reasons
FROM grouped_workflows gw
LEFT JOIN workflow_executions ew ON ew.status = gw.status
GROUP BY gw.status
ORDER BY gw.status;
