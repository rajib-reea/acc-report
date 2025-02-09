-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_expenses CASCADE;

-- Create the table with an additional column for category_id
CREATE TABLE acc_expenses (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    employee_id INTEGER,  -- New column for employee ID
    category_id INTEGER,  -- New column for category ID
    amount NUMERIC(10, 2),
    transaction_date DATE
);

-- Insert data into acc_expenses table with category_id values
INSERT INTO acc_expenses (customer_id, employee_id, category_id, amount, transaction_date) VALUES
(1, 101, 1, 150.00, '2025-01-01'),
(3, 102, 2, 500.00, '2025-01-01'),
(2, 103, 3, 300.00, '2025-01-02'),
(1, 101, 1, 200.00, '2025-01-03'),
(2, 103, 3, 100.00, '2025-01-03'),
(3, 102, 2, 50.00,  '2025-01-04'),
(1, 101, 1, 250.00, '2025-01-05'),
(1, 101, 1, 100.00, '2025-01-06'),
(2, 103, 3, 600.00, '2025-01-06'),
(3, 102, 2, 300.00, '2025-01-06'),
(1, 101, 1, 120.00, '2025-01-08'),
(2, 103, 3, 180.00, '2025-01-09'),
(3, 102, 2, 210.00, '2025-01-10');
