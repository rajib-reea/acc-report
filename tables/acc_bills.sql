-- Create the bills table
CREATE TABLE acc_bills (
    bill_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    bill_date DATE NOT NULL,
    total_bill_amount DECIMAL(10,2) NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    category_id INT NOT NULL
);

-- Insert sample data
INSERT INTO acc_bills (vendor_id, bill_date, total_bill_amount, payment_amount, category_id) VALUES
(1, '2025-01-01', 1000.00, 200.00, 1),
(1, '2025-01-02', 1500.00, 500.00, 2),
(2, '2025-01-02', 2000.00, 1000.00, 1),
(2, '2025-01-03', 2500.00, 0.00, 2),
(3, '2025-01-04', 1800.00, 800.00, 1),
(3, '2025-01-05', 3000.00, 500.00, 2),
(4, '2025-01-06', 500.00, 0.00, 1),
(1, '2025-01-07', 2500.00, 1000.00, 2),
(2, '2025-01-08', 3200.00, 2000.00, 1),
(3, '2025-01-09', 1800.00, 400.00, 2),
(4, '2025-01-10', 1250.00, 500.00, 1);
