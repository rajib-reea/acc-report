-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_purchases CASCADE;

-- Create the table with necessary columns including vendor_id
CREATE TABLE acc_purchases (
    transaction_id SERIAL PRIMARY KEY,
    item_id INTEGER,
    vendor_id INTEGER,  -- New column for vendor ID
    purchase_amount NUMERIC(10, 2),
    quantity INTEGER,
    transaction_date DATE
);

-- Insert data into acc_purchases table with vendor_id
INSERT INTO acc_purchases (item_id, vendor_id, purchase_amount, quantity, transaction_date) VALUES
(1, 101, 100.00, 10, '2025-01-01'),
(2, 102, 200.00, 5, '2025-01-01'),
(1, 101, 150.00, 20, '2025-01-02'),
(3, 103, 250.00, 15, '2025-01-03'),
(2, 102, 300.00, 10, '2025-01-04'),
(1, 101, 120.00, 8, '2025-01-05'),
(3, 103, 180.00, 12, '2025-01-06'),
(2, 102, 220.00, 7, '2025-01-07'),
(1, 101, 110.00, 9, '2025-01-08'),
(3, 103, 260.00, 14, '2025-01-09'),
(1, 101, 130.00, 11, '2025-01-10');
