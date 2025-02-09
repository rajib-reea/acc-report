| #   | project_id | project_name  | transaction_date | total_labor_cost | total_material_cost | total_overhead_cost | total_project_cost |
|-----|------------|---------------|------------------|------------------|---------------------|---------------------|--------------------|
| 1   | 1          | Project Alpha | 2025-01-01       | 500.00           | 200.00              | 0                   | 700.00             |
| 2   | 2          | Project Beta  | 2025-01-01       | 0                | 0                   | 0                   | 0                  |
| 3   | 3          | Project Gamma | 2025-01-01       | 0                | 0                   | 0                   | 0                  |
| 4   | Total      | All Projects  | 2025-01-01       | 500.00           | 200.00              | 0                   | 700.00             |
| 5   | 1          | Project Alpha | 2025-01-02       | 450.00           | 0                   | 0                   | 450.00             |
| 6   | 2          | Project Beta  | 2025-01-02       | 0                | 0                   | 0                   | 0                  |
| 7   | 3          | Project Gamma | 2025-01-02       | 700.00           | 0                   | 0                   | 700.00             |
| 8   | Total      | All Projects  | 2025-01-02       | 1150.00          | 0                   | 0                   | 1150.00            |
| 9   | 1          | Project Alpha | 2025-01-03       | 0                | 0                   | 150.00              | 150.00             |
| 10  | 2          | Project Beta  | 2025-01-03       | 600.00           | 0                   | 0                   | 600.00             |
| 11  | 3          | Project Gamma | 2025-01-03       | 0                | 0                   | 0                   | 0                  |
| 12  | Total      | All Projects  | 2025-01-03       | 600.00           | 0                   | 150.00              | 750.00             |
| 13  | 1          | Project Alpha | 2025-01-04       | 0                | 0                   | 0                   | 0                  |
| 14  | 2          | Project Beta  | 2025-01-04       | 0                | 300.00              | 0                   | 300.00             |
| 15  | 3          | Project Gamma | 2025-01-04       | 0                | 0                   | 0                   | 0                  |
| 16  | Total      | All Projects  | 2025-01-04       | 0                | 300.00              | 0                   | 300.00             |
| 17  | 1          | Project Alpha | 2025-01-05       | 0                | 0                   | 0                   | 0                  |
| 18  | 2          | Project Beta  | 2025-01-05       | 0                | 0                   | 250.00              | 250.00             |
| 19  | 3          | Project Gamma | 2025-01-05       | 0                | 0                   | 0                   | 0                  |
| 20  | Total      | All Projects  | 2025-01-05       | 0                | 0                   | 250.00              | 250.00             |
| 21  | 1          | Project Alpha | 2025-01-06       | 0                | 0                   | 0                   | 0                  |
| 22  | 2          | Project Beta  | 2025-01-06       | 0                | 0                   | 0                   | 0                  |
| 23  | 3          | Project Gamma | 2025-01-06       | 0                | 400.00              | 0                   | 400.00             |
| 24  | Total      | All Projects  | 2025-01-06       | 0                | 400.00              | 0                   | 400.00             |
| 25  | 1          | Project Alpha | 2025-01-07       | 0                | 0                   | 0                   | 0                  |
| 26  | 2          | Project Beta  | 2025-01-07       | 0                | 0                   | 0                   | 0                  |
| 27  | 3          | Project Gamma | 2025-01-07       | 0                | 0                   | 0                   | 0                  |
| 28  | Total      | All Projects  | 2025-01-07       | 0                | 0                   | 0                   | 0                  |
| 29  | 1          | Project Alpha | 2025-01-08       | 0                | 0                   | 0                   | 0                  |
| 30  | 2          | Project Beta  | 2025-01-08       | 0                | 0                   | 0                   | 0                  |
| 31  | 3          | Project Gamma | 2025-01-08       | 0                | 0                   | 300.00              | 300.00             |
| 32  | Total      | All Projects  | 2025-01-08       | 0                | 0                   | 300.00              | 300.00             |
| 33  | 1          | Project Alpha | 2025-01-09       | 0                | 0                   | 0                   | 0                  |
| 34  | 2          | Project Beta  | 2025-01-09       | 0                | 0                   | 0                   | 0                  |
| 35  | 3          | Project Gamma | 2025-01-09       | 0                | 0                   | 0                   | 0                  |
| 36  | Total      | All Projects  | 2025-01-09       | 0                | 0                   | 0                   | 0                  |
| 37  | 1          | Project Alpha | 2025-01-10       | 0                | 0                   | 0                   | 0                  |
| 38  | 2          | Project Beta  | 2025-01-10       | 0                | 0                   | 0                   | 0                  |
| 39  | 3          | Project Gamma | 2025-01-10       | 0                | 0                   | 0                   | 0                  |
| 40  | Total      | All Projects  | 2025-01-10       | 0                | 0                   | 0                   | 0                  |

Algorithm:
  
Project_Cost_Summary(startDate, endDate):
  1. Retrieve all projects within the specified date range (startDate to endDate).
  2. Retrieve project cost data (e.g., employee labor cost, material cost, overhead).
  3. For each project, calculate the total cost:
     Total Project Cost = Sum of all costs associated with the project (labor, materials, overhead).
  4. Optionally, group the costs by category (e.g., labor costs, material costs).
  5. Calculate the total project costs across all projects.
  6. Validate the project cost data (ensure no invalid or missing values).
  7. Store the project cost summary data and return the results (total project costs, categorized by type).

SQL:  
  
-- Step 1: Generate a series of dates for the specified date range
WITH DateSeries AS (
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

-- Step 2: Retrieve all projects within the specified date range
ProjectData AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date
    FROM acc_projects p
    WHERE EXISTS (
        SELECT 1
        FROM DateSeries ds
        WHERE ds.transaction_date BETWEEN p.start_date AND p.end_date
    )
),

-- Step 3 & 4: Retrieve project cost data and calculate daily costs
DailyProjectCosts AS (
    SELECT
        pd.project_id::TEXT AS project_id,  -- Cast project_id to TEXT for type consistency
        pd.project_name,
        ds.transaction_date,
        COALESCE(SUM(CASE WHEN pc.cost_type = 'Labor' THEN pc.amount ELSE 0 END), 0) AS total_labor_cost,
        COALESCE(SUM(CASE WHEN pc.cost_type = 'Material' THEN pc.amount ELSE 0 END), 0) AS total_material_cost,
        COALESCE(SUM(CASE WHEN pc.cost_type = 'Overhead' THEN pc.amount ELSE 0 END), 0) AS total_overhead_cost,
        COALESCE(SUM(pc.amount), 0) AS total_project_cost
    FROM ProjectData pd
    CROSS JOIN DateSeries ds
    LEFT JOIN project_costs pc 
        ON pd.project_id = pc.project_id 
        AND pc.transaction_date = ds.transaction_date
    GROUP BY pd.project_id, pd.project_name, ds.transaction_date
),

-- Step 5: Calculate the total project costs across all projects per day
TotalDailyProjectCosts AS (
    SELECT
        'Total'::TEXT AS project_id,  -- Ensure project_id is TEXT to match DailyProjectCosts
        'All Projects' AS project_name,
        transaction_date,
        SUM(total_labor_cost) AS total_labor_cost,
        SUM(total_material_cost) AS total_material_cost,
        SUM(total_overhead_cost) AS total_overhead_cost,
        SUM(total_project_cost) AS total_project_cost
    FROM DailyProjectCosts
    GROUP BY transaction_date
),

-- Step 6: Combine the results
CombinedResults AS (
    SELECT * FROM DailyProjectCosts
    UNION ALL
    SELECT * FROM TotalDailyProjectCosts
)

-- Step 7: Apply validation to ensure no cost component is NULL
SELECT *
FROM CombinedResults cr
WHERE NOT EXISTS (
    SELECT 1
    FROM DailyProjectCosts dpc
    WHERE dpc.project_id = cr.project_id
      AND dpc.transaction_date = cr.transaction_date
      AND (dpc.total_labor_cost IS NULL OR dpc.total_material_cost IS NULL OR dpc.total_overhead_cost IS NULL)
)
ORDER BY cr.transaction_date, cr.project_id;
