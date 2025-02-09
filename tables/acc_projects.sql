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
