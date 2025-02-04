CREATE TABLE accounts_payable (
    transaction_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_amount DECIMAL(10,2) NOT NULL,
    payment_amount DECIMAL(10,2) DEFAULT 0
);
INSERT INTO accounts_payable (vendor_id, invoice_date, due_date, invoice_amount, payment_amount) 
VALUES 
    (1, '2025-01-01', '2025-01-10', 1000.00, 0),
    (1, '2025-01-03', '2025-01-15', 1500.00, 0),
    (2, '2025-01-02', '2025-01-12', 2000.00, 500.00),
    (2, '2025-01-05', '2025-01-20', 1200.00, 0),
    (3, '2024-12-28', '2025-01-08', 2500.00, 0),
    (3, '2025-01-07', '2025-01-25', 1800.00, 300.00),
    (4, '2025-01-09', '2025-01-30', 500.00, 0),
    (4, '2025-01-10', '2025-02-05', 750.00, 0);
