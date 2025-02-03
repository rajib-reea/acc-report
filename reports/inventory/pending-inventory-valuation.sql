| #  | Description                                          | Value     |
|----|------------------------------------------------------|-----------|
| 1  | Pending Inventory Value - Clothing - Supplier 103    | 2429200.00|
| 2  | Pending Inventory Value - Electronics - Supplier 101 | 691200.00 |
| 3  | Pending Inventory Value - Toys - Supplier 104        | 900000.00 |
| 4  | Total Pending Inventory Value                        | 4020400.00|

Algorithm:
  
Pending_Inventory_Valuation_Report(startDate, endDate):
  1. Retrieve all pending inventory transactions within the specified date range (startDate to endDate).
  2. For each pending inventory transaction, extract the following details:
     - Item ID
     - Date of transaction
     - Quantity of items pending valuation
     - Estimated value (or valuation criteria)
     - Current inventory status (e.g., pending, processed)
  3. Calculate the total pending inventory value:
     - Total Pending Value = Sum of all pending item valuations.
  4. Optionally, categorize pending inventory by type or status (e.g., by product category, supplier).
  5. Validate the data (ensure no missing or incorrect inventory entries).
  6. Store the pending inventory valuation data and return the results (total pending inventory value, categorized by type or status).

SQL:  
-- Step 1: Generate a series of dates within the specified range
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 2: Retrieve all pending inventory transactions within the specified date range
pending_inventory AS (
    SELECT
        item_id,
        transaction_date,
        quantity,
        estimated_value,
        inventory_status,
        product_category,
        supplier_id
    FROM acc_inventory_transactions
    WHERE inventory_status = 'pending'
      AND transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Calculate the total pending inventory value
total_pending_value AS (
    SELECT
        SUM(quantity * estimated_value) AS total_value
    FROM pending_inventory
),

-- Step 4: Categorize pending inventory by type (e.g., product category or supplier)
categorized_inventory AS (
    SELECT
        product_category,
        supplier_id,
        SUM(quantity * estimated_value) AS total_value
    FROM pending_inventory
    GROUP BY product_category, supplier_id
)

-- Final SELECT: Return the summary of total pending inventory value and categorized details
SELECT
    'Total Pending Inventory Value' AS description,
    tp.total_value AS value
FROM total_pending_value tp
UNION ALL
SELECT
    CONCAT('Pending Inventory Value - ', ci.product_category, ' - Supplier ', ci.supplier_id) AS description,
    ci.total_value AS value
FROM categorized_inventory ci
ORDER BY description;
-- Step 1: Generate a series of dates within the specified range
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 2: Retrieve all pending inventory transactions within the specified date range
pending_inventory AS (
    SELECT
        item_id,
        transaction_date,
        quantity,
        estimated_value,
        inventory_status,
        product_category,
        supplier_id
    FROM acc_inventory_transactions
    WHERE inventory_status = 'pending'
      AND transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Calculate the total pending inventory value
total_pending_value AS (
    SELECT
        SUM(quantity * estimated_value) AS total_value
    FROM pending_inventory
),

-- Step 4: Categorize pending inventory by type (e.g., product category or supplier)
categorized_inventory AS (
    SELECT
        product_category,
        supplier_id,
        SUM(quantity * estimated_value) AS total_value
    FROM pending_inventory
    GROUP BY product_category, supplier_id
)

-- Final SELECT: Return the summary of total pending inventory value and categorized details
SELECT
    'Total Pending Inventory Value' AS description,
    tp.total_value AS value
FROM total_pending_value tp
UNION ALL
SELECT
    CONCAT('Pending Inventory Value - ', ci.product_category, ' - Supplier ', ci.supplier_id) AS description,
    ci.total_value AS value
FROM categorized_inventory ci
ORDER BY description;

