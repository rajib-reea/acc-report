| #  | Transaction Date | Vendor ID | Category Name    | Total Outstanding Balance |
|----|----------------|-----------|------------------|--------------------------|
| 1  | 2025-01-01    | 1         | Purchase Orders  | 800.00                   |
| 2  | 2025-01-02    | 1         | Purchase Orders  | 800.00                   |
| 3  | 2025-01-02    | 1         | Service Fees     | 1000.00                  |
| 4  | 2025-01-02    | 2         | Purchase Orders  | 1000.00                  |
| 5  | 2025-01-03    | 1         | Purchase Orders  | 800.00                   |
| 6  | 2025-01-03    | 1         | Service Fees     | 1000.00                  |
| 7  | 2025-01-03    | 2         | Purchase Orders  | 1000.00                  |
| 8  | 2025-01-03    | 2         | Service Fees     | 2500.00                  |
| 9  | 2025-01-04    | 1         | Purchase Orders  | 800.00                   |
| 10 | 2025-01-04    | 1         | Service Fees     | 1000.00                  |
| 11 | 2025-01-04    | 2         | Purchase Orders  | 1000.00                  |
| 12 | 2025-01-04    | 2         | Service Fees     | 2500.00                  |
| 13 | 2025-01-04    | 3         | Purchase Orders  | 1000.00                  |
| 14 | 2025-01-05    | 1         | Purchase Orders  | 800.00                   |
| 15 | 2025-01-05    | 1         | Service Fees     | 1000.00                  |
| 16 | 2025-01-05    | 2         | Purchase Orders  | 1000.00                  |
| 17 | 2025-01-05    | 2         | Service Fees     | 2500.00                  |
| 18 | 2025-01-05    | 3         | Purchase Orders  | 1000.00                  |
| 19 | 2025-01-05    | 3         | Service Fees     | 2500.00                  |
| 20 | 2025-01-06    | 1         | Purchase Orders  | 800.00                   |
| 21 | 2025-01-06    | 1         | Service Fees     | 1000.00                  |
| 22 | 2025-01-06    | 2         | Purchase Orders  | 1000.00                  |
| 23 | 2025-01-06    | 2         | Service Fees     | 2500.00                  |
| 24 | 2025-01-06    | 3         | Purchase Orders  | 1000.00                  |
| 25 | 2025-01-06    | 3         | Service Fees     | 2500.00                  |
| 26 | 2025-01-06    | 4         | Purchase Orders  | 500.00                   |
| 27 | 2025-01-07    | 1         | Purchase Orders  | 800.00                   |
| 28 | 2025-01-07    | 1         | Service Fees     | 2500.00                  |
| 29 | 2025-01-07    | 2         | Purchase Orders  | 1000.00                  |
| 30 | 2025-01-07    | 2         | Service Fees     | 2500.00                  |
| 31 | 2025-01-07    | 3         | Purchase Orders  | 1000.00                  |
| 32 | 2025-01-07    | 3         | Service Fees     | 2500.00                  |
| 33 | 2025-01-07    | 4         | Purchase Orders  | 500.00                   |
| 34 | 2025-01-08    | 1         | Purchase Orders  | 800.00                   |
| 35 | 2025-01-08    | 1         | Service Fees     | 2500.00                  |
| 36 | 2025-01-08    | 2         | Purchase Orders  | 2200.00                  |
| 37 | 2025-01-08    | 2         | Service Fees     | 2500.00                  |
| 38 | 2025-01-08    | 3         | Purchase Orders  | 1000.00                  |
| 39 | 2025-01-08    | 3         | Service Fees     | 2500.00                  |
| 40 | 2025-01-08    | 4         | Purchase Orders  | 500.00                   |
| 41 | 2025-01-09    | 1         | Purchase Orders  | 800.00                   |
| 42 | 2025-01-09    | 1         | Service Fees     | 2500.00                  |
| 43 | 2025-01-09    | 2         | Purchase Orders  | 2200.00                  |
| 44 | 2025-01-09    | 2         | Service Fees     | 2500.00                  |
| 45 | 2025-01-09    | 3         | Purchase Orders  | 1000.00                  |
| 46 | 2025-01-09    | 3         | Service Fees     | 3900.00                  |
| 47 | 2025-01-09    | 4         | Purchase Orders  | 500.00                   |
| 48 | 2025-01-10    | 1         | Purchase Orders  | 800.00                   |
| 49 | 2025-01-10    | 1         | Service Fees     | 2500.00                  |
| 50 | 2025-01-10    | 2         | Purchase Orders  | 2200.00                  |
| 51 | 2025-01-10    | 2         | Service Fees     | 2500.00                  |
| 52 | 2025-01-10    | 3         | Purchase Orders  | 1000.00                  |
| 53 | 2025-01-10    | 3         | Service Fees     | 3900.00                  |
| 54 | 2025-01-10    | 4         | Purchase Orders  | 1250.00                  |

Algorithm:
  
Bills_Breakdown_Report(startDate, endDate):
  1. Retrieve all bills/receivables within the specified date range (startDate to endDate).
  2. Group the bills by vendor.
  3. For each bill, calculate the outstanding balance:
     Outstanding Balance = Total Bill Amount - Payments Made.
  4. Optionally, group the bills by category (e.g., purchase orders, service fees).
  5. Calculate the total value of outstanding bills per vendor and per category.
  6. Validate the bill amounts (ensure no invalid or negative balances).
  7. Store the bill breakdown data and return the results.

SQL:
WITH DateSeries AS (
    -- Generate daily dates within the range
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
), BillTransactions AS (
    -- Step 1: Retrieve all bills/receivables within the specified date range
    SELECT
        b.bill_id,
        b.vendor_id,
        b.bill_date,
        b.total_bill_amount,
        b.payment_amount,
        b.category_id
    FROM acc_bills b
    WHERE b.bill_date BETWEEN '2025-01-01' AND '2025-01-10'
), OutstandingBills AS (
    -- Step 3: Calculate the outstanding balance for each bill
    SELECT
        bt.vendor_id,
        bt.bill_id,
        bt.bill_date,
        bt.total_bill_amount - bt.payment_amount AS outstanding_balance,
        bt.category_id
    FROM BillTransactions bt
    WHERE bt.total_bill_amount > bt.payment_amount  -- Only consider bills with outstanding balances
), BillCategories AS (
    -- Step 4: Group the bills by category (e.g., purchase orders, service fees)
    SELECT
        ob.vendor_id,
        ob.bill_id,
        ob.bill_date,
        ob.outstanding_balance,
        ob.category_id,
        CASE
            WHEN ob.category_id = 1 THEN 'Purchase Orders'
            WHEN ob.category_id = 2 THEN 'Service Fees'
            ELSE 'Other'
        END AS category_name
    FROM OutstandingBills ob
), DailyBreakdown AS (
    -- Step 5: Associate bills with each date to provide a daily view
    SELECT
        d.transaction_date,
        bc.vendor_id,
        bc.category_name,
        SUM(bc.outstanding_balance) AS total_outstanding_balance
    FROM DateSeries d
    LEFT JOIN BillCategories bc
        ON bc.bill_date <= d.transaction_date  -- Accumulate outstanding balances daily
    GROUP BY d.transaction_date, bc.vendor_id, bc.category_name
)
-- Step 6: Return the daily breakdown of outstanding bills
SELECT
    db.transaction_date,
    db.vendor_id,
    db.category_name,
    db.total_outstanding_balance
FROM DailyBreakdown db
ORDER BY db.transaction_date, db.vendor_id, db.category_name;
