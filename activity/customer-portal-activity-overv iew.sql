Algorithm:
  
Customer_Portal_Activity_Overview(startDate, endDate):
  1. Retrieve all customer portal activity logs for the specified date range (startDate to endDate).
  2. For each activity, extract the following details:
     - Activity ID
     - Customer ID
     - Date and time of the activity
     - Type of activity (e.g., login, purchase, support request)
     - Status of the activity (e.g., completed, failed)
  3. Group activities by type (e.g., purchases, support, logins).
  4. Calculate the total number of activities by type and status (e.g., successful logins, completed purchases).
  5. Optionally, calculate the average number of activities per day or per customer.
  6. Validate the data (ensure no missing or incorrect activity entries).
  7. Store the activity overview data and return the results (summary of activity types, total counts, and performance metrics).

SQL:  
CREATE TABLE customer_activity_logs (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,             -- The ID of the customer performing the activity
    activity_date DATETIME NOT NULL,      -- Date and time of the activity
    activity_type ENUM('login', 'purchase', 'support_request', 'other') NOT NULL, -- Type of activity
    activity_status ENUM('completed', 'failed') NOT NULL -- Status of the activity
);
-- Step 1: Retrieve all customer portal activity logs within the specified date range
WITH activity_data AS (
    SELECT
        activity_id,
        customer_id,
        activity_date,
        activity_type,
        activity_status
    FROM customer_activity_logs
    WHERE activity_date >= :startDate
      AND activity_date <= :endDate
),

-- Step 2: Group activities by type and status, and calculate the total number of activities
activity_summary AS (
    SELECT
        activity_type,
        activity_status,
        COUNT(*) AS activity_count
    FROM activity_data
    GROUP BY activity_type, activity_status
),

-- Step 3: Optionally, calculate the average number of activities per day or per customer
average_activity_per_day AS (
    SELECT
        COUNT(DISTINCT activity_date) AS total_days,
        COUNT(DISTINCT customer_id) AS total_customers,
        COUNT(*) AS total_activities
    FROM activity_data
)

-- Final SELECT: Return the activity summary and performance metrics
SELECT
    asy.activity_type,
    asy.activity_status,
    asy.activity_count,
    apd.total_days,
    apd.total_customers,
    apd.total_activities,
    (apd.total_activities / apd.total_days) AS avg_activities_per_day,
    (apd.total_activities / apd.total_customers) AS avg_activities_per_customer
FROM activity_summary asy, average_activity_per_day apd
ORDER BY asy.activity_type, asy.activity_status;
