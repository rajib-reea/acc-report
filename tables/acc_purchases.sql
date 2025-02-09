-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_purchases CASCADE;

-- Create the table with necessary columns including vendor_id and item_count
CREATE TABLE acc_purchases (
    transaction_id SERIAL PRIMARY KEY,
    item_id INTEGER,
    vendor_id INTEGER,  -- New column for vendor ID
    item_count INTEGER,  -- New column for item count
    purchase_amount NUMERIC(10, 2),
    quantity INTEGER,
    transaction_date DATE
);

-- Insert data into acc_purchases table with vendor_id and item_count
INSERT INTO acc_purchases (item_id, vendor_id, item_count, purchase_amount, quantity, transaction_date) VALUES
(1, 101, 1, 100.00, 10, '2025-01-01'),
(2, 102, 2, 200.00, 5, '2025-01-01'),
(1, 101, 3, 150.00, 20, '2025-01-02'),
(3, 103, 1, 250.00, 15, '2025-01-03'),
(2, 102, 4, 300.00, 10, '2025-01-04'),
(1, 101, 2, 120.00, 8, '2025-01-05'),
(3, 103, 3, 180.00, 12, '2025-01-06'),
(2, 102, 1, 220.00, 7, '2025-01-07'),
(1, 101, 5, 110.00, 9, '2025-01-08'),
(3, 103, 2, 260.00, 14, '2025-01-09'),
(1, 101, 4, 130.00, 11, '2025-01-10');
