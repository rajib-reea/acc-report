-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_invoices;

-- Create the table for storing invoice details
CREATE TABLE acc_invoices (
    invoice_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,  -- Customer associated with the invoice
    invoice_date DATE NOT NULL, -- Invoice date
    total_amount NUMERIC(15, 2) NOT NULL,  -- Total amount of the invoice
    is_paid BOOLEAN DEFAULT FALSE, -- Flag indicating if the invoice is paid
    payment_amount NUMERIC(15, 2) DEFAULT 0, -- Payment amount made against the invoice
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Date and time the invoice was created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Date and time the invoice was last updated
);
-- Insert sample data into acc_invoices
INSERT INTO acc_invoices (customer_id, invoice_date, total_amount, is_paid, payment_amount)
VALUES
(101, '2025-01-01', 1500.00, FALSE, 0),
(102, '2025-02-01', 2000.00, FALSE, 500),
(103, '2025-03-01', 1800.00, FALSE, 800),
(101, '2025-04-01', 2500.00, FALSE, 0),
(102, '2025-05-01', 1200.00, FALSE, 1200),
(101, '2025-06-01', 1800.00, FALSE, 600),
(104, '2025-07-01', 2200.00, FALSE, 500),
(103, '2025-08-01', 2500.00, FALSE, 1000),
(101, '2025-09-01', 3000.00, FALSE, 1500),
(104, '2025-10-01', 1100.00, FALSE, 1100);
