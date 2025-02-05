-- Drop table if it exists
DROP TABLE IF EXISTS acc_vendor_credit_notes;

-- Create the acc_vendor_credit_notes table
CREATE TABLE acc_vendor_credit_notes (
    credit_note_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    credit_note_date DATE NOT NULL,
    credit_amount DECIMAL(10,2) NOT NULL,
    reason_code INT NOT NULL  -- Reason code: 1 for Returns, 2 for Adjustments, etc.
);
-- Insert sample data into acc_vendor_credit_notes
INSERT INTO acc_vendor_credit_notes (vendor_id, credit_note_date, credit_amount, reason_code)
VALUES
    -- Vendor 1 Credit Notes
    (1, '2025-01-05', 500.00, 1),  -- Return
    (1, '2025-02-10', 300.00, 2),  -- Adjustment
    -- Vendor 2 Credit Notes
    (2, '2025-03-12', 1000.00, 1), -- Return
    (2, '2025-04-15', 200.00, 2),  -- Adjustment
    -- Vendor 3 Credit Notes
    (3, '2025-02-28', 1500.00, 1), -- Return
    (3, '2025-05-05', 300.00, 2),  -- Adjustment
    -- Vendor 4 Credit Notes
    (4, '2025-06-20', 750.00, 1),  -- Return
    -- Vendor 5 Credit Notes
    (5, '2025-07-15', 1200.00, 2), -- Adjustment
    (5, '2025-08-30', 400.00, 1);  -- Return

