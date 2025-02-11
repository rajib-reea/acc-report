-- Drop the tables if they already exist
DROP TABLE IF EXISTS acc_receivables CASCADE;
DROP TABLE IF EXISTS acc_payments CASCADE;

-- Create the acc_receivables table
CREATE TABLE acc_receivables (
    receivable_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    invoice_id INT NOT NULL,
    total_amount NUMERIC(15, 2) NOT NULL,
    due_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -- Create the acc_payments table
-- CREATE TABLE acc_payments (
--     payment_id SERIAL PRIMARY KEY,
--     invoice_id INT NOT NULL,
--     payment_amount NUMERIC(15, 2) NOT NULL,
--     payment_date DATE NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- Insert sample data into acc_receivables
INSERT INTO acc_receivables (customer_id, invoice_id, total_amount, due_date)
VALUES
(101, 1001, 5000.00, '2025-01-15'),
(102, 1002, 3000.00, '2025-02-10'),
(101, 1003, 4500.00, '2025-03-05'),
(103, 1004, 2000.00, '2025-04-01'),
(104, 1005, 6000.00, '2025-05-20'),
(102, 1006, 2500.00, '2025-06-10'),
(101, 1007, 4000.00, '2025-07-15'),
(103, 1008, 3500.00, '2025-08-25'),
(104, 1009, 1500.00, '2025-09-30'),
(102, 1010, 5000.00, '2025-10-15');

-- -- Insert sample data into acc_payments
-- INSERT INTO acc_payments (invoice_id, payment_amount, payment_date)
-- VALUES
-- (1001, 2000.00, '2025-01-20'),
-- (1002, 1000.00, '2025-02-15'),
-- (1003, 1500.00, '2025-03-10'),
-- (1004, 500.00,  '2025-04-05'),
-- (1005, 3000.00, '2025-05-25'),
-- (1006, 2500.00, '2025-06-15'), -- Fully paid
-- (1007, 1000.00, '2025-07-20'),
-- (1008, 2000.00, '2025-08-30'),
-- (1009, 1500.00, '2025-10-05'), -- Fully paid
-- (1010, 0.00,    '2025-10-20'); -- No payment made
