-- Drop the table if it exists
DROP TABLE IF EXISTS acc_inventory_transactions;

-- Create the table with the new `inventory_status` column
CREATE TABLE acc_inventory_transactions (
    transaction_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'sale' or 'purchase'
    quantity INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    estimated_value DECIMAL(10, 2) NOT NULL,
    inventory_status ENUM('pending', 'processed') NOT NULL -- New column for inventory status
);

-- Insert data with inventory_status column
INSERT INTO acc_inventory_transactions (item_id, transaction_date, transaction_type, quantity, unit_cost, estimated_value, inventory_status) 
VALUES
(1, '2025-01-01', 'purchase', 100, 50.00, 5000.00, 'processed'),
(2, '2025-01-02', 'sale', 50, 60.00, 3000.00, 'processed'),
(3, '2025-01-03', 'purchase', 200, 45.00, 9000.00, 'pending'),
(4, '2025-01-04', 'sale', 30, 55.00, 1650.00, 'processed'),
(5, '2025-01-05', 'purchase', 150, 40.00, 6000.00, 'pending'),
(6, '2025-01-06', 'sale', 70, 50.00, 3500.00, 'processed'),
(7, '2025-01-07', 'purchase', 120, 48.00, 5760.00, 'pending'),
(8, '2025-01-08', 'sale', 90, 55.00, 4950.00, 'processed'),
(9, '2025-01-09', 'purchase', 50, 60.00, 3000.00, 'processed'),
(10, '2025-01-10', 'sale', 110, 52.00, 5720.00, 'pending');


drop table if exists acc_inventory;
CREATE TABLE acc_inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(255),
    quantity INT,
    reorder_level INT,
    transaction_date DATE
);

-- Insert sample data into the inventory table
INSERT INTO acc_inventory (item_id, item_name, quantity, reorder_level, transaction_date) VALUES
(1, 'Item A', 165, 50, '2025-01-01'),
(2, 'Item B', 320, 150, '2025-01-02'),
(3, 'Item C', 180, 90, '2025-01-03'),
(4, 'Item D', 320, 160, '2025-01-04'),
(5, 'Item E', 300, 150, '2025-01-05'),
(6, 'Item F', 80, 40, '2025-01-06'),
(7, 'Item G', 240, 100, '2025-01-07'),
(8, 'Item H', 150, 75, '2025-01-08'),
(9, 'Item I', 110, 55, '2025-01-09'),
(10, 'Item J', 130, 60, '2025-01-10');

