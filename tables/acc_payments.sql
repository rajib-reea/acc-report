DROP TABLE IF EXISTS acc_payments;

CREATE TABLE acc_payments (
    payment_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    customer_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    initiation_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL
);

-- Insert data with initiation_date, customer_id, and payment_method
INSERT INTO acc_payments (vendor_id, customer_id, payment_method, initiation_date, payment_date, payment_amount) VALUES
(1, 101, 'Credit Card', '2024-12-30', '2025-01-01', 100.50),
(1, 101, 'Credit Card', '2025-01-01', '2025-01-02', 200.75),
(2, 102, 'Bank Transfer', '2024-12-31', '2025-01-01', 50.00),
(2, 102, 'Bank Transfer', '2025-01-01', '2025-01-03', 75.25),
(3, 103, 'PayPal', '2025-01-01', '2025-01-02', 300.00),
(3, 103, 'PayPal', '2025-01-02', '2025-01-04', 150.00),
(1, 101, 'Credit Card', '2025-01-02', '2025-01-04', 250.00),
(2, 102, 'Bank Transfer', '2025-01-03', '2025-01-05', 125.75);
