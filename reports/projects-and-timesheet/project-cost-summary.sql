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
  
-- Step 1: Generate a series of dates for daily breakdown
WITH DateSeries AS (
    SELECT generate_series('2025-01-01'::DATE, '2025-01-10'::DATE, INTERVAL '1 day')::DATE AS transaction_date
),

-- Step 2: Retrieve all projects within the specified date range
project_data AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date
    FROM acc_projects p
    JOIN DateSeries d ON (p.start_date <= d.transaction_date AND p.end_date >= d.transaction_date)
),

-- Step 3: Retrieve project cost data (labor costs, material costs, overhead)
project_costs AS (
    SELECT
        pc.project_id,
        pc.transaction_date,
        SUM(CASE WHEN pc.cost_type = 'Labor' THEN pc.amount ELSE 0 END) AS total_labor_cost,
        SUM(CASE WHEN pc.cost_type = 'Material' THEN pc.amount ELSE 0 END) AS total_material_cost,
        SUM(CASE WHEN pc.cost_type = 'Overhead' THEN pc.amount ELSE 0 END) AS total_overhead_cost
    FROM project_costs pc
    JOIN DateSeries d ON pc.transaction_date = d.transaction_date
    WHERE pc.project_id IN (SELECT project_id FROM project_data)
    GROUP BY pc.project_id, pc.transaction_date
),

-- Step 4: Combine project data and cost data to calculate the total cost for each project per day
DailyProjectCosts AS (
    SELECT
        pd.project_id,
        pd.project_name,
        pc.transaction_date,
        COALESCE(pc.total_labor_cost, 0) AS total_labor_cost,
        COALESCE(pc.total_material_cost, 0) AS total_material_cost,
        COALESCE(pc.total_overhead_cost, 0) AS total_overhead_cost,
        (COALESCE(pc.total_labor_cost, 0) + COALESCE(pc.total_material_cost, 0) + COALESCE(pc.total_overhead_cost, 0)) AS total_project_cost
    FROM project_data pd
    LEFT JOIN project_costs pc ON pd.project_id = pc.project_id
),

-- Step 5: Calculate the total project costs across all projects per day
TotalDailyProjectCosts AS (
    SELECT
        'Total' AS project_id,
        'All Projects' AS project_name,
        transaction_date,
        SUM(total_labor_cost) AS total_labor_cost,
        SUM(total_material_cost) AS total_material_cost,
        SUM(total_overhead_cost) AS total_overhead_cost,
        SUM(total_project_cost) AS total_project_cost
    FROM DailyProjectCosts
    GROUP BY transaction_date
)

-- Step 6: Return the detailed daily project cost summary
SELECT * FROM DailyProjectCosts

UNION ALL

SELECT * FROM TotalDailyProjectCosts

-- Step 7: Validate the project cost data (ensure no invalid or missing values)
WHERE (total_labor_cost IS NOT NULL AND total_material_cost IS NOT NULL AND total_overhead_cost IS NOT NULL)

ORDER BY transaction_date, project_id;
