-- Drop the trigger and function if they exist
DROP TRIGGER IF EXISTS trg_update_status ON acc_account_payable;
DROP FUNCTION IF EXISTS update_account_payable_status;

-- Drop existing table if it exists
DROP TABLE IF EXISTS acc_account_payable;

-- Create the table without the generated column
CREATE TABLE acc_account_payable (
    transaction_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    invoice_id VARCHAR(50) NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_amount DECIMAL(10,2) NOT NULL,
    payment_amount DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20)  -- Manually updated by a trigger
);

-- Create the trigger function to update the status field
CREATE OR REPLACE FUNCTION update_account_payable_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.status := CASE 
        WHEN NEW.payment_amount >= NEW.invoice_amount THEN 'Paid'
        WHEN NEW.payment_amount > 0 AND NEW.payment_amount < NEW.invoice_amount THEN 'Partially Paid'
        WHEN CURRENT_DATE > NEW.due_date AND NEW.payment_amount = 0 THEN 'Overdue'
        ELSE 'Unpaid'
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function before insert or update
CREATE TRIGGER trg_update_status
BEFORE INSERT OR UPDATE ON acc_account_payable
FOR EACH ROW
EXECUTE FUNCTION update_account_payable_status();

-- Insert sample data
INSERT INTO acc_account_payable (vendor_id, invoice_id, invoice_date, due_date, invoice_amount, payment_amount) 
VALUES 
    -- Vendor 1 Invoices
    (1, 'INV-1001', '2025-01-01', '2025-01-10', 1000.00, 0),        -- Unpaid
    (1, 'INV-1002', '2025-01-03', '2025-01-15', 1500.00, 0),        -- Unpaid
    -- Vendor 2 Invoices
    (2, 'INV-2001', '2025-01-02', '2025-01-12', 2000.00, 500.00),   -- Partially Paid
    (2, 'INV-2002', '2025-01-05', '2025-01-20', 1200.00, 0),        -- Unpaid
    -- Vendor 3 Invoices
    (3, 'INV-3001', '2024-12-28', '2025-01-08', 2500.00, 0),        -- Overdue
    (3, 'INV-3002', '2025-01-07', '2025-01-25', 1800.00, 300.00),   -- Partially Paid
    -- Vendor 4 Invoices
    (4, 'INV-4001', '2025-01-09', '2025-01-30', 500.00, 0),         -- Unpaid
    (4, 'INV-4002', '2025-01-10', '2025-02-05', 750.00, 0),         -- Unpaid
    -- Vendor 5 Invoices (Fully Paid)
    (5, 'INV-5001', '2025-01-15', '2025-01-25', 3000.00, 3000.00),  -- Paid
    (5, 'INV-5002', '2025-01-20', '2025-02-10', 2000.00, 2000.00);  -- Paid
