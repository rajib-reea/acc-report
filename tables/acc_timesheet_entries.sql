CREATE TABLE acc_timesheet_entries (
    entry_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    project_id INT NOT NULL,
    task_id INT,
    hours_worked NUMERIC(5, 2) NOT NULL,
    entry_date DATE NOT NULL,
    is_billable BOOLEAN DEFAULT TRUE
);
-- Sample data for January 2025
INSERT INTO acc_timesheet_entries (employee_id, project_id, task_id, hours_worked, entry_date, is_billable) VALUES
(1, 101, 1001, 8.00, '2025-01-01', TRUE),
(1, 101, 1002, 4.00, '2025-01-02', FALSE),
(1, 102, 1003, 6.50, '2025-01-03', TRUE),
(2, 101, 1001, 7.00, '2025-01-01', TRUE),
(2, 103, 1004, 5.00, '2025-01-02', FALSE),
(2, 103, 1005, 4.00, '2025-01-03', TRUE),
(3, 104, 1006, 8.00, '2025-01-04', TRUE),
(3, 104, 1007, 7.50, '2025-01-05', FALSE),
(1, 102, 1003, 8.00, '2025-01-05', TRUE),
(2, 103, 1004, 3.00, '2025-01-06', FALSE),
(3, 104, 1006, 4.00, '2025-01-06', TRUE),
(1, 101, 1002, 5.00, '2025-01-07', TRUE),
(2, 101, 1001, 6.50, '2025-01-07', TRUE),
(3, 104, 1007, 7.00, '2025-01-08', FALSE),
(1, 102, 1003, 4.50, '2025-01-09', TRUE),
(2, 103, 1005, 8.00, '2025-01-09', TRUE),
(3, 104, 1006, 7.50, '2025-01-10', TRUE);
