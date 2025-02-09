CREATE TABLE acc_expenses (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    amount NUMERIC(10, 2),
    transaction_date DATE
);
INSERT INTO acc_expenses (customer_id, amount, transaction_date) VALUES
(1, 150.00, '2025-01-01'),
(3, 500.00, '2025-01-01'),
(2, 300.00, '2025-01-02'),
(1, 200.00, '2025-01-03'),
(2, 100.00, '2025-01-03'),
(3, 50.00,  '2025-01-04'),
(1, 250.00, '2025-01-05'),
(1, 100.00, '2025-01-06'),
(2, 600.00, '2025-01-06'),
(3, 300.00, '2025-01-06'),
(1, 120.00, '2025-01-08'),
(2, 180.00, '2025-01-09'),
(3, 210.00, '2025-01-10');
