CREATE TABLE tasks (
    task_id INT PRIMARY KEY,
    project_id INT,
    task_name VARCHAR(255),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE timesheet_entries (
    entry_id INT PRIMARY KEY,
    employee_id INT,
    project_id INT,
    task_id INT,                        -- Optional: Link to specific tasks if needed
    hours_worked DECIMAL(10, 2),
    entry_date DATE,
    is_billable BOOLEAN,                 -- Flag for billable vs non-billable hours
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) -- Optional: for task-level granularity
);

CREATE TABLE employee_rates (
    employee_id INT PRIMARY KEY,
    hourly_rate DECIMAL(10, 2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
CREATE TABLE projects_revenue (
    project_id INT PRIMARY KEY,
    client_rate DECIMAL(10, 2),     -- Hourly rate charged to the client
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE projects_costs (
    project_id INT PRIMARY KEY,
    total_cost DECIMAL(10, 2),       -- Total cost for the project
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

