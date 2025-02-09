-- Drop the acc_projects table if it exists
DROP TABLE IF EXISTS acc_projects cascade;

-- Create acc_projects table with planned_completion_date and actual_completion_date
CREATE TABLE acc_projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    planned_completion_date DATE,
    actual_completion_date DATE
);

-- Insert sample data into acc_projects with planned_completion_date and actual_completion_date
INSERT INTO acc_projects (project_name, start_date, end_date, planned_completion_date, actual_completion_date) VALUES
('Project Alpha', '2025-01-01', '2025-01-05', '2025-01-04', '2025-01-05'),
('Project Beta', '2025-01-03', '2025-01-08', '2025-01-07', '2025-01-08'),
('Project Gamma', '2025-01-02', '2025-01-10', '2025-01-09', '2025-01-10');

-- Drop the project_revenues table if it exists
DROP TABLE IF EXISTS acc_project_revenues cascade;

-- Create project_revenues table to store revenue data related to each project
CREATE TABLE acc_project_revenues (
    revenue_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    revenue_type VARCHAR(50) NOT NULL,  -- 'Billable Hours', 'Flat Fee', 'Milestone Payment', etc.
    amount DECIMAL(10, 2) NOT NULL,     -- Revenue amount for the respective type
    FOREIGN KEY (project_id) REFERENCES acc_projects(project_id)
);

-- Insert sample data into project_revenues
INSERT INTO acc_project_revenues (project_id, revenue_type, amount) VALUES
-- For Project Alpha
(1, 'Billable Hours', 1500.00),
(1, 'Flat Fee', 2000.00),
(1, 'Milestone Payment', 3000.00),
(1, 'Labor Cost', 1000.00),
(1, 'Material Cost', 500.00),
-- For Project Beta
(2, 'Billable Hours', 800.00),
(2, 'Flat Fee', 1200.00),
(2, 'Milestone Payment', 1000.00),
(2, 'Labor Cost', 600.00),
(2, 'Material Cost', 300.00),
-- For Project Gamma
(3, 'Billable Hours', 1000.00),
(3, 'Flat Fee', 1500.00),
(3, 'Milestone Payment', 2000.00),
(3, 'Labor Cost', 700.00),
(3, 'Material Cost', 400.00);

-- Drop the project_costs table if it exists
DROP TABLE IF EXISTS acc_project_costs cascade;

-- Create project_costs table
CREATE TABLE acc_project_costs (
    cost_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES acc_projects(project_id),
    transaction_date DATE NOT NULL,
    cost_type VARCHAR(50) NOT NULL,  -- 'Labor', 'Material', or 'Overhead'
    amount NUMERIC(10, 2) NOT NULL
);

-- Insert sample data into project_costs
INSERT INTO acc_project_costs (project_id, transaction_date, cost_type, amount) VALUES
(1, '2025-01-01', 'Labor', 500.00),
(1, '2025-01-01', 'Material', 200.00),
(1, '2025-01-02', 'Labor', 450.00),
(1, '2025-01-03', 'Overhead', 150.00),
(2, '2025-01-03', 'Labor', 600.00),
(2, '2025-01-04', 'Material', 300.00),
(2, '2025-01-05', 'Overhead', 250.00),
(3, '2025-01-02', 'Labor', 700.00),
(3, '2025-01-06', 'Material', 400.00),
(3, '2025-01-08', 'Overhead', 300.00);
