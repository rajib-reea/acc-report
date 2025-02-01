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
