CREATE TABLE acc_quotes (
    quote_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    created_at DATE NOT NULL
);
INSERT INTO acc_quotes (customer_id, total_amount, created_at)
VALUES
    (101, 1500.00, '2025-01-10'),
    (101, 1800.00, '2025-02-01'),
    (101, 2500.00, '2025-03-05'),
    (101, 3000.00, '2025-04-01'),
    (102, 2000.00, '2025-01-20'),
    (102, 1200.00, '2025-03-15'),
    (103, 2500.00, '2025-02-10'),
    (103, 1800.00, '2025-04-05'),
    (104, 2200.00, '2025-04-10'),
    (104, 1100.00, '2025-05-01');
