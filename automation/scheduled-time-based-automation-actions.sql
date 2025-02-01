Algorithm:
  
Scheduled_Time_Based_Automation_Actions(startDate, endDate):
  1. Retrieve all scheduled automation actions that are triggered based on specific times within the specified date range (startDate to endDate).
  2. For each scheduled automation action, extract the following details:
     - Action ID
     - Scheduled time for execution
     - Actual time of execution
     - Action status (e.g., executed, failed, pending)
     - Duration (time taken to execute)
     - Any errors or issues encountered during execution
  3. Group the automation actions by scheduled time.
  4. Calculate the number of actions triggered on each specific scheduled time within the range.
  5. Optionally, calculate the average duration for the execution of scheduled actions:
     - Average Duration = Sum of all durations / Total actions.
  6. Optionally, calculate the success rate of the actions based on status:
     - Success Rate = (Number of Successful Actions / Total Actions) * 100.
  7. Identify any actions that failed to execute or encountered issues during the scheduled time.
  8. Validate the data (ensure no missing or incorrect action details).
  9. Store the scheduled time-based automation actions data and return the results:
     - Summary of automation actions by scheduled time, success rate, duration, and failure reasons.
SQL:
  
CREATE TABLE scheduled_automation_actions (
    action_id INT PRIMARY KEY AUTO_INCREMENT,
    scheduled_time DATETIME NOT NULL,
    actual_time DATETIME NOT NULL,
    status ENUM('executed', 'failed', 'pending') NOT NULL,
    duration INT, -- Duration in seconds
    error_message TEXT
);
-- Step 1: Retrieve all scheduled automation actions within the specified date range
WITH actions_in_range AS (
    SELECT
        action_id,
        scheduled_time,
        actual_time,
        status,
        duration,
        error_message
    FROM scheduled_automation_actions
    WHERE scheduled_time BETWEEN :startDate AND :endDate
),

-- Step 2: Group the automation actions by their scheduled time
grouped_actions AS (
    SELECT
        scheduled_time,
        COUNT(*) AS total_actions,
        SUM(CASE WHEN status = 'executed' THEN 1 ELSE 0 END) AS successful_actions,
        SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_actions,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_actions,
        AVG(duration) AS avg_duration -- Optional: Average duration of all actions
    FROM actions_in_range
    GROUP BY scheduled_time
)

-- Final SELECT: Return the summary of actions by scheduled time
SELECT
    ga.scheduled_time,
    ga.total_actions,
    ga.successful_actions,
    ga.failed_actions,
    ga.pending_actions,
    ga.avg_duration,
    -- List of failed action error messages
    GROUP_CONCAT(DISTINCT aa.error_message ORDER BY aa.actual_time SEPARATOR ', ') AS failure_reasons
FROM grouped_actions ga
LEFT JOIN scheduled_automation_actions aa ON aa.scheduled_time = ga.scheduled_time
GROUP BY ga.scheduled_time
ORDER BY ga.scheduled_time;
