drop table if exists acc_credit_notes;
CREATE TABLE acc_credit_notes (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    reason VARCHAR(255),
    amount NUMERIC(10, 2) NOT NULL
);

-- Insert sample data
INSERT INTO acc_credit_notes (customer_id, transaction_date, reason, amount) VALUES
(101, '2025-01-01', 'Return', 150.00),
(102, '2025-01-01', 'Adjustment', 200.00),
(101, '2025-01-02', 'Return', 100.00),
(103, '2025-01-02', 'Return', 50.00),
(104, '2025-01-03', 'Adjustment', 300.00),
(101, '2025-01-03', 'Return', -50.00),  -- Negative value (should be excluded)
(102, '2025-01-04', 'Return', 250.00),
(103, '2025-01-05', 'Adjustment', 0.00),  -- Zero value (should be excluded)
(105, '2025-01-06', 'Return', 400.00),
(101, '2025-01-07', 'Adjustment', 500.00),
(102, '2025-01-08', 'Return', 150.00),
(103, '2025-01-09', 'Adjustment', 350.00),
(104, '2025-01-10', 'Return', 450.00);
