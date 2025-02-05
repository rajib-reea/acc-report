drop table if exists acc_payments;
CREATE TABLE acc_payments (
    payment_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL
);
INSERT INTO acc_payments (vendor_id, payment_date, payment_amount) VALUES
(1, '2025-01-01', 100.50),
(1, '2025-01-02', 200.75),
(2, '2025-01-01', 50.00),
(2, '2025-01-03', 75.25),
(3, '2025-01-02', 300.00),
(3, '2025-01-04', 150.00),
(1, '2025-01-04', 250.00),
(2, '2025-01-05', 125.75);
