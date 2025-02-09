| #   | transaction_date | project_id | total_billable_expenses | num_transactions |
|-----|------------------|------------|-------------------------|------------------|
| 1   | 2025-01-01       | 1          | 150.00                  | 1                |
| 2   | 2025-01-01       | 3          | 500.00                  | 1                |
| 3   | 2025-01-02       | 2          | 300.00                  | 1                |
| 4   | 2025-01-03       | 1          | 200.00                  | 1                |
| 5   | 2025-01-03       | 2          | 100.00                  | 1                |
| 6   | 2025-01-04       | 3          | 50.00                   | 1                |
| 7   | 2025-01-05       | 1          | 250.00                  | 1                |
| 8   | 2025-01-06       | 1          | 100.00                  | 1                |
| 9   | 2025-01-06       | 2          | 600.00                  | 2                |
| 10  | 2025-01-06       | 3          | 300.00                  | 1                |
| 11  | 2025-01-07       |            | 0.00                    | 0                |
| 12  | 2025-01-08       |            | 0.00                    | 0                |
| 13  | 2025-01-09       |            | 0.00                    | 0                |
| 14  | 2025-01-10       |            | 0.00                    | 0                |
| 15  | 2025-01-11       |            | 0.00                    | 0                |
| 16  | 2025-01-12       |            | 0.00                    | 0                |
| 17  | 2025-01-13       |            | 0.00                    | 0                |
| 18  | 2025-01-14       |            | 0.00                    | 0                |
| 19  | 2025-01-15       | 1          | 120.00                  | 1                |
| 20  | 2025-01-16       |            | 0.00                    | 0                |
| 21  | 2025-01-17       |            | 0.00                    | 0                |
| 22  | 2025-01-18       |            | 0.00                    | 0                |
| 23  | 2025-01-19       |            | 0.00                    | 0                |
| 24  | 2025-01-20       | 2          | 180.00                  | 1                |
| 25  | 2025-01-21       |            | 0.00                    | 0                |
| 26  | 2025-01-22       |            | 0.00                    | 0                |
| 27  | 2025-01-23       |            | 0.00                    | 0                |
| 28  | 2025-01-24       |            | 0.00                    | 0                |
| 29  | 2025-01-25       | 3          | 210.00                  | 1                |
| 30  | 2025-01-26       |            | 0.00                    | 0                |
| 31  | 2025-01-27       |            | 0.00                    | 0                |
| 32  | 2025-01-28       |            | 0.00                    | 0                |
| 33  | 2025-01-29       |            | 0.00                    | 0                |
| 34  | 2025-01-30       |            | 0.00                    | 0                |
| 35  | 2025-01-31       | 1          | 90.00                   | 1                |

Algorithm:
  
Billable_Expenses_Report(startDate, endDate):
  1. Retrieve all billable expense transactions within the specified date range (startDate to endDate).
  2. Group the billable expenses by project or customer (depending on how the data is linked).
  3. For each project or customer, calculate the total billable expense amount:
     Total Billable Expenses = Sum of all billable expense amounts.
  4. Optionally, calculate the number of transactions for each project or customer.
  5. Validate the billable expense amounts (ensure no invalid or negative values).
  6. Store the billable expenses data and return the results.


SQL:
  
WITH DateSeries AS (
    -- Generate a series of dates from January 1, 2025, to January 31, 2025
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
BillableExpenses AS (
    -- Retrieve all billable expense transactions within the specified date range
    SELECT
        be.transaction_id,
        be.project_id, -- Replace with customer_id if needed
        be.amount,
        be.transaction_date
    FROM acc_billable_expenses be
    WHERE be.transaction_date BETWEEN '2025-01-01' AND '2025-01-31'
      AND be.amount > 0 -- Ensure only valid (positive) expenses are retrieved
),
DailyBillableSummary AS (
    -- Left join DateSeries to ensure every date is represented, even with zero transactions
    SELECT
        ds.transaction_date,
        be.project_id,
        COALESCE(SUM(be.amount), 0) AS total_billable_expenses,
        COALESCE(COUNT(be.transaction_id), 0) AS num_transactions
    FROM DateSeries ds
    LEFT JOIN BillableExpenses be
        ON ds.transaction_date = be.transaction_date
    GROUP BY ds.transaction_date, be.project_id
)
-- Final result: daily billable expenses per project
SELECT
    transaction_date,
    project_id,
    total_billable_expenses,
    num_transactions
FROM DailyBillableSummary
ORDER BY transaction_date, project_id;
