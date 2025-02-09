CREATE TABLE acc_billable_expenses (
    transaction_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,         -- Replace with customer_id if needed
    amount NUMERIC(10, 2) NOT NULL,
    transaction_date DATE NOT NULL
);
INSERT INTO acc_billable_expenses (project_id, amount, transaction_date)
VALUES
    -- Project 1 Transactions
    (1, 150.00, '2025-01-01'),
    (1, 200.00, '2025-01-03'),
    (1, 250.00, '2025-01-05'),

    -- Project 2 Transactions
    (2, 300.00, '2025-01-02'),
    (2, 100.00, '2025-01-03'),
    (2, 400.00, '2025-01-06'),

    -- Project 3 Transactions (fewer entries)
    (3, 500.00, '2025-01-01'),
    (3, 50.00,  '2025-01-04'),

    -- Transactions on the same date for different projects
    (1, 100.00, '2025-01-06'),
    (2, 200.00, '2025-01-06'),
    (3, 300.00, '2025-01-06'),

    -- Later in the month
    (1, 120.00, '2025-01-15'),
    (2, 180.00, '2025-01-20'),
    (3, 210.00, '2025-01-25'),

    -- No transactions for some dates to test the DateSeries gap filling
    (1, 90.00,  '2025-01-31');
