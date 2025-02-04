CREATE TABLE acc_payable_transactions (
    transaction_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,  -- Can be 'Invoice', 'Payment', or 'Credit Note'
    invoice_amount DECIMAL(10, 2) NOT NULL,
    payment_amount DECIMAL(10, 2) DEFAULT 0,
    credit_note_amount DECIMAL(10, 2) DEFAULT 0,
    transaction_date DATE NOT NULL,
    due_date DATE NOT NULL
);

INSERT INTO acc_payable_transactions (vendor_id, transaction_type, invoice_amount, payment_amount, credit_note_amount, transaction_date, due_date)
VALUES
    -- Vendor 1 Invoices
    (1, 'Invoice', 1000.00, 0.00, 0.00, '2025-01-01', '2025-01-10'),
    (1, 'Invoice', 1500.00, 0.00, 0.00, '2025-01-03', '2025-01-15'),
    -- Vendor 1 Payments
    (1, 'Payment', 0.00, 1000.00, 0.00, '2025-01-05', '2025-01-10'),
    -- Vendor 2 Invoices
    (2, 'Invoice', 2000.00, 0.00, 0.00, '2025-01-02', '2025-01-12'),
    (2, 'Invoice', 1200.00, 0.00, 0.00, '2025-01-05', '2025-01-20'),
    -- Vendor 2 Payments
    (2, 'Payment', 0.00, 500.00, 0.00, '2025-01-07', '2025-01-12'),
    -- Vendor 3 Invoices
    (3, 'Invoice', 2500.00, 0.00, 0.00, '2024-12-28', '2025-01-08'),
    (3, 'Invoice', 1800.00, 0.00, 0.00, '2025-01-07', '2025-01-25'),
    -- Vendor 3 Payments
    (3, 'Payment', 0.00, 300.00, 0.00, '2025-01-10', '2025-01-08'),
    -- Vendor 4 Invoices
    (4, 'Invoice', 500.00, 0.00, 0.00, '2025-01-09', '2025-01-30'),
    (4, 'Invoice', 750.00, 0.00, 0.00, '2025-01-10', '2025-02-05'),
    -- Vendor 4 Payments
    (4, 'Payment', 0.00, 500.00, 0.00, '2025-01-15', '2025-01-30');

