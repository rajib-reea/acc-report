CREATE TABLE acc_budgets (
    id SERIAL PRIMARY KEY,
    category VARCHAR(255) NOT NULL,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    daily_budgeted_amount NUMERIC(10,2) NOT NULL
);

INSERT INTO acc_budgets (category, period_start_date, period_end_date, daily_budgeted_amount)
VALUES
    ('Revenue', '2025-01-01', '2025-01-10', 5000.00),
    ('Sales', '2025-01-01', '2025-01-10', 3000.00),
    ('Expenses', '2025-01-01', '2025-01-10', 2000.00),
    ('Cost of Goods Sold', '2025-01-01', '2025-01-10', 1500.00);

