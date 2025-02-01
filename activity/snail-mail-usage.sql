Algorithm:
  
Snail_Mail_Credit_Usage_Report(startDate, endDate):
  1. Retrieve all snail mail (physical mail) transactions for the specified date range (startDate to endDate).
  2. For each snail mail transaction, extract the following details:
     - Transaction ID
     - Date sent
     - Number of credits used (for postage or related costs)
     - Recipient details (e.g., name, address)
     - Mail type (e.g., letter, package, registered)
  3. Calculate the total number of credits used for snail mail during the period:
     - Total Credits Used = Sum of credits used for each transaction.
  4. Optionally, break down the usage by mail type (e.g., letters, packages).
  5. Validate the data (ensure no missing or incorrect entries).
  6. Store the credit usage data and return the results (total credits used, breakdown by mail type, and transaction details).

SQL:  
CREATE TABLE snail_mail_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    date_sent DATETIME NOT NULL,
    credits_used DECIMAL(10, 2) NOT NULL,  -- The number of credits used for the transaction
    recipient_name VARCHAR(255) NOT NULL,  -- Recipient's name
    recipient_address TEXT NOT NULL,       -- Recipient's address
    mail_type ENUM('letter', 'package', 'registered') NOT NULL -- Type of mail
);

-- Step 1: Retrieve all snail mail transactions within the specified date range
WITH snail_mail_data AS (
    SELECT
        transaction_id,
        date_sent,
        credits_used,
        recipient_name,
        recipient_address,
        mail_type
    FROM snail_mail_transactions
    WHERE date_sent >= :startDate
      AND date_sent <= :endDate
),

-- Step 2: Calculate total credits used and breakdown by mail type
credits_usage AS (
    SELECT
        SUM(credits_used) AS total_credits_used,
        mail_type,
        SUM(credits_used) AS credits_by_mail_type
    FROM snail_mail_data
    GROUP BY mail_type
)

-- Step 3: Return the detailed transaction data and total credits used
SELECT
    smd.transaction_id,
    smd.date_sent,
    smd.credits_used,
    smd.recipient_name,
    smd.recipient_address,
    smd.mail_type,
    cu.total_credits_used,
    cu.credits_by_mail_type
FROM snail_mail_data smd
JOIN credits_usage cu ON smd.mail_type = cu.mail_type
ORDER BY smd.date_sent;
