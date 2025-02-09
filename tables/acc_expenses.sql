-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_expenses CASCADE;

-- Create the table with additional columns for category_id, expense_type, and project_id
CREATE TABLE acc_expenses (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    employee_id INTEGER,  -- New column for employee ID
    category_id INTEGER,  -- New column for category ID
    expense_type VARCHAR(50),  -- New column for expense type
    project_id INTEGER,  -- New column for project ID
    amount NUMERIC(10, 2),
    transaction_date DATE
);

-- Insert data into acc_expenses table with category_id, expense_type, and project_id values
INSERT INTO acc_expenses (customer_id, employee_id, category_id, expense_type, project_id, amount, transaction_date) VALUES
(1, 101, 1, 'Office Supplies', 101, 150.00, '2025-01-01'),
(3, 102, 2, 'Travel', 102, 500.00, '2025-01-01'),
(2, 103, 3, 'Utilities', 103, 300.00, '2025-01-02'),
(1, 101, 1, 'Office Supplies', 101, 200.00, '2025-01-03'),
(2, 103, 3, 'Utilities', 103, 100.00, '2025-01-03'),
(3, 102, 2, 'Travel', 102, 50.00, '2025-01-04'),
(1, 101, 1, 'Office Supplies', 101, 250.00, '2025-01-05'),
(1, 101, 1, 'Office Supplies', 101, 100.00, '2025-01-06'),
(2, 103, 3, 'Utilities', 103, 600.00, '2025-01-06'),
(3, 102, 2, 'Travel', 102, 300.00, '2025-01-06'),
(1, 101, 1, 'Office Supplies', 101, 120.00, '2025-01-08'),
(2, 103, 3, 'Utilities', 103, 180.00, '2025-01-09'),
(3, 102, 2, 'Travel', 102, 210.00, '2025-01-10');
