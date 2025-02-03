CREATE TABLE acc_inventory_transactions (
    transaction_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'sale' or 'purchase'
    quantity INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL
);
INSERT INTO acc_inventory_transactions (item_id, transaction_date, transaction_type, quantity, unit_cost)
VALUES 
    (1, '2025-01-01', 'sale', 10, 5.00),
    (1, '2025-01-02', 'sale', 15, 5.00),
    (1, '2025-01-03', 'sale', 8, 5.00),
    (2, '2025-01-02', 'sale', 20, 10.00),
    (2, '2025-01-05', 'sale', 12, 10.00),
    (3, '2025-01-04', 'sale', 5, 15.00),
    (3, '2025-01-06', 'sale', 7, 15.00),
    (4, '2025-01-01', 'sale', 30, 8.00),
    (4, '2025-01-07', 'sale', 10, 8.00),
    (5, '2025-01-03', 'sale', 25, 12.00);

-- Create the inventory table
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

