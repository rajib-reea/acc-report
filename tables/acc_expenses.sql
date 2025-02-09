-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_expenses CASCADE;

-- Create the table with additional columns for category_id and expense_type
CREATE TABLE acc_expenses (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    employee_id INTEGER,  -- New column for employee ID
    category_id INTEGER,  -- New column for category ID
    expense_type VARCHAR(50),  -- New column for expense type
    amount NUMERIC(10, 2),
    transaction_date DATE
);

-- Insert data into acc_expenses table with category_id and expense_type values
INSERT INTO acc_expenses (customer_id, employee_id, category_id, expense_type, amount, transaction_date) VALUES
(1, 101, 1, 'Office Supplies', 150.00, '2025-01-01'),
(3, 102, 2, 'Travel', 500.00, '2025-01-01'),
(2, 103, 3, 'Utilities', 300.00, '2025-01-02'),
(1, 101, 1, 'Office Supplies', 200.00, '2025-01-03'),
(2, 103, 3, 'Utilities', 100.00, '2025-01-03'),
(3, 102, 2, 'Travel', 50.00,  '2025-01-04'),
(1, 101, 1, 'Office Supplies', 250.00, '2025-01-05'),
(1, 101, 1, 'Office Supplies', 100.00, '2025-01-06'),
(2, 103, 3, 'Utilities', 600.00, '2025-01-06'),
(3, 102, 2, 'Travel', 300.00, '2025-01-06'),
(1, 101, 1, 'Office Supplies', 120.00, '2025-01-08'),
(2, 103, 3, 'Utilities', 180.00, '2025-01-09'),
(3, 102, 2, 'Travel', 210.00, '2025-01-10');
