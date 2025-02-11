CREATE TABLE acc_recurring_invoices (
    invoice_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,  -- Invoice status: 'Paid', 'Unpaid', 'Overdue'
    outstanding_balance DECIMAL(10, 2) NOT NULL
);
INSERT INTO acc_recurring_invoices (customer_id, invoice_date, due_date, amount, status, outstanding_balance)
VALUES
    (101, '2025-01-15', '2025-02-15', 5000.00, 'Unpaid', 3000.00),
    (101, '2025-03-05', '2025-04-05', 4500.00, 'Unpaid', 4500.00),
    (101, '2025-07-15', '2025-08-15', 4000.00, 'Unpaid', 3000.00),
    (102, '2025-02-10', '2025-03-10', 3000.00, 'Unpaid', 2000.00),
    (102, '2025-10-15', '2025-11-15', 5000.00, 'Not Paid', 5000.00),
    (103, '2025-04-01', '2025-05-01', 2000.00, 'Paid', 1500.00),
    (103, '2025-08-25', '2025-09-25', 3500.00, 'Unpaid', 1500.00),
    (104, '2025-05-20', '2025-06-20', 6000.00, 'Unpaid', 3000.00);
