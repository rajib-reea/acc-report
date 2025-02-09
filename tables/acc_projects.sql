drop table if exists acc_projects;
-- Create acc_projects table
CREATE TABLE acc_projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- Insert sample data into acc_projects
INSERT INTO acc_projects (project_name, start_date, end_date) VALUES
('Project Alpha', '2025-01-01', '2025-01-05'),
('Project Beta', '2025-01-03', '2025-01-08'),
('Project Gamma', '2025-01-02', '2025-01-10');

drop table if exists project_costs;
-- Create project_costs table
CREATE TABLE project_costs (
    cost_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES acc_projects(project_id),
    transaction_date DATE NOT NULL,
    cost_type VARCHAR(50) NOT NULL,  -- 'Labor', 'Material', or 'Overhead'
    amount NUMERIC(10, 2) NOT NULL
);

-- Insert sample data into project_costs
INSERT INTO project_costs (project_id, transaction_date, cost_type, amount) VALUES
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
