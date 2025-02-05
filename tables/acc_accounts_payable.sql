drop table acc_accounts_payable;
DROP TABLE IF EXISTS acc_account_payable;

CREATE TABLE acc_account_payable (
    transaction_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    invoice_id VARCHAR(50) NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_amount DECIMAL(10,2) NOT NULL,
    payment_amount DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) GENERATED ALWAYS AS (
        CASE 
            WHEN payment_amount >= invoice_amount THEN 'Paid'
            WHEN CURRENT_DATE > due_date THEN 'Overdue'
            ELSE 'Unpaid'
        END
    ) STORED  -- Automatically generates the status based on conditions
);


INSERT INTO acc_account_payable (vendor_id, invoice_id, invoice_date, due_date, invoice_amount, payment_amount) 
VALUES 
    (1, 'INV-1001', '2025-01-01', '2025-01-10', 1000.00, 0),
    (1, 'INV-1002', '2025-01-03', '2025-01-15', 1500.00, 0),
    (2, 'INV-2001', '2025-01-02', '2025-01-12', 2000.00, 500.00),
    (2, 'INV-2002', '2025-01-05', '2025-01-20', 1200.00, 0),
    (3, 'INV-3001', '2024-12-28', '2025-01-08', 2500.00, 0),
    (3, 'INV-3002', '2025-01-07', '2025-01-25', 1800.00, 300.00),
    (4, 'INV-4001', '2025-01-09', '2025-01-30', 500.00, 0),
    (4, 'INV-4002', '2025-01-10', '2025-02-05', 750.00, 0);
