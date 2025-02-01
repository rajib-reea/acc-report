Algorithm:
  
System_Notifications_and_Mails_Report(startDate, endDate):
  1. Retrieve all system notifications and mail sent within the specified date range (startDate to endDate).
  2. For each notification or mail, extract the following details:
     - Notification/Email ID
     - Date and time sent
     - Sender or system initiating the notification
     - Recipient(s)
     - Notification type (e.g., alert, reminder, update)
     - Delivery status (e.g., delivered, failed)
  3. Group the notifications by type (e.g., system alerts, user notifications, email reports).
  4. Calculate the delivery success rate:
     - Success Rate = (Number of Successful Deliveries / Total Notifications) * 100.
  5. Optionally, filter by specific notification types or delivery statuses.
  6. Validate the data (ensure no missing or incorrect entries).
  7. Store the notification and mail data and return the results (list of notifications and their delivery status with success rate).

SQL: 
-- Step 1: Retrieve all system notifications and mails within the specified date range
WITH notifications_and_mails AS (
    SELECT
        n.notification_id,
        n.date_sent,
        n.sender,
        n.recipient,
        n.notification_type,
        n.delivery_status
    FROM system_notifications n
    WHERE n.date_sent >= :startDate
      AND n.date_sent <= :endDate

    UNION ALL

    SELECT
        e.email_id AS notification_id,
        e.date_sent,
        e.sender,
        e.recipient,
        'Email' AS notification_type,
        e.delivery_status
    FROM system_emails e
    WHERE e.date_sent >= :startDate
      AND e.date_sent <= :endDate
),

-- Step 2: Group the notifications and emails by type and calculate the success rate
notification_stats AS (
    SELECT
        notification_type,
        COUNT(*) AS total_notifications,
        SUM(CASE WHEN delivery_status = 'delivered' THEN 1 ELSE 0 END) AS successful_deliveries
    FROM notifications_and_mails
    GROUP BY notification_type
),

-- Step 3: Calculate the success rate for each notification type
success_rate AS (
    SELECT
        notification_type,
        total_notifications,
        successful_deliveries,
        -- Calculate success rate = (Successful Deliveries / Total Notifications) * 100
        (successful_deliveries * 100.0 / total_notifications) AS delivery_success_rate
    FROM notification_stats
)

-- Step 4: Return the list of notifications with their delivery status, including the success rate by type
SELECT
    n.notification_id,
    n.date_sent,
    n.sender,
    n.recipient,
    n.notification_type,
    n.delivery_status,
    s.delivery_success_rate
FROM notifications_and_mails n
JOIN success_rate s ON n.notification_type = s.notification_type
ORDER BY n.date_sent;
CREATE TABLE system_notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    date_sent DATETIME NOT NULL,
    sender VARCHAR(255) NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    notification_type VARCHAR(50) NOT NULL,  -- e.g., Alert, Reminder, Update
    delivery_status ENUM('delivered', 'failed') NOT NULL  -- Status of delivery
);

CREATE TABLE system_emails (
    email_id INT PRIMARY KEY AUTO_INCREMENT,
    date_sent DATETIME NOT NULL,
    sender VARCHAR(255) NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    delivery_status ENUM('delivered', 'failed') NOT NULL  -- Status of delivery
);
