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
-- Step 1: Retrieve all projects within the specified date range
WITH project_data AS (
    SELECT
        p.project_id,
        p.project_name,
        p.start_date,
        p.end_date
    FROM projects p
    WHERE p.start_date BETWEEN :startDate AND :endDate
      OR p.end_date BETWEEN :startDate AND :endDate
),

-- Step 2: Retrieve project cost data (labor costs, material costs, overhead)
project_costs AS (
    SELECT
        pc.project_id,
        SUM(CASE WHEN pc.cost_type = 'Labor' THEN pc.amount ELSE 0 END) AS total_labor_cost,
        SUM(CASE WHEN pc.cost_type = 'Material' THEN pc.amount ELSE 0 END) AS total_material_cost,
        SUM(CASE WHEN pc.cost_type = 'Overhead' THEN pc.amount ELSE 0 END) AS total_overhead_cost
    FROM project_costs pc
    WHERE pc.project_id IN (SELECT project_id FROM project_data)
    GROUP BY pc.project_id
)

-- Step 3: Combine project data and cost data to calculate the total cost for each project
SELECT
    pd.project_id,
    pd.project_name,
    COALESCE(pc.total_labor_cost, 0) AS total_labor_cost,
    COALESCE(pc.total_material_cost, 0) AS total_material_cost,
    COALESCE(pc.total_overhead_cost, 0) AS total_overhead_cost,
    (COALESCE(pc.total_labor_cost, 0) + COALESCE(pc.total_material_cost, 0) + COALESCE(pc.total_overhead_cost, 0)) AS total_project_cost
FROM project_data pd
LEFT JOIN project_costs pc ON pd.project_id = pc.project_id

-- Step 4: Optionally, you can calculate the total project costs across all projects
UNION ALL

SELECT
    'Total' AS project_id,
    'All Projects' AS project_name,
    SUM(COALESCE(pc.total_labor_cost, 0)) AS total_labor_cost,
    SUM(COALESCE(pc.total_material_cost, 0)) AS total_material_cost,
    SUM(COALESCE(pc.total_overhead_cost, 0)) AS total_overhead_cost,
    SUM(COALESCE(pc.total_labor_cost, 0) + COALESCE(pc.total_material_cost, 0) + COALESCE(pc.total_overhead_cost, 0)) AS total_project_cost
FROM project_costs pc

-- Step 5: Validate the project cost data (ensure no invalid or missing values)
WHERE (pc.total_labor_cost IS NOT NULL AND pc.total_material_cost IS NOT NULL AND pc.total_overhead_cost IS NOT NULL)
