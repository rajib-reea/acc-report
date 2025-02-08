DROP TABLE IF EXISTS acc_payments;

CREATE TABLE acc_payments (
    payment_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    initiation_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL
);

-- Insert data with initiation_date
INSERT INTO acc_payments (vendor_id, initiation_date, payment_date, payment_amount) VALUES
(1, '2024-12-30', '2025-01-01', 100.50),
(1, '2025-01-01', '2025-01-02', 200.75),
(2, '2024-12-31', '2025-01-01', 50.00),
(2, '2025-01-01', '2025-01-03', 75.25),
(3, '2025-01-01', '2025-01-02', 300.00),
(3, '2025-01-02', '2025-01-04', 150.00),
(1, '2025-01-02', '2025-01-04', 250.00),
(2, '2025-01-03', '2025-01-05', 125.75);
