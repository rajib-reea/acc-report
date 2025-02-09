drop table if exists acc_expenses cascade;
CREATE TABLE acc_expenses (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    employee_id INTEGER,  -- New column for employee ID
    amount NUMERIC(10, 2),
    transaction_date DATE
);

INSERT INTO acc_expenses (customer_id, employee_id, amount, transaction_date) VALUES
(1, 101, 150.00, '2025-01-01'),
(3, 102, 500.00, '2025-01-01'),
(2, 103, 300.00, '2025-01-02'),
(1, 101, 200.00, '2025-01-03'),
(2, 103, 100.00, '2025-01-03'),
(3, 102, 50.00,  '2025-01-04'),
(1, 101, 250.00, '2025-01-05'),
(1, 101, 100.00, '2025-01-06'),
(2, 103, 600.00, '2025-01-06'),
(3, 102, 300.00, '2025-01-06'),
(1, 101, 120.00, '2025-01-08'),
(2, 103, 180.00, '2025-01-09'),
(3, 102, 210.00, '2025-01-10');
