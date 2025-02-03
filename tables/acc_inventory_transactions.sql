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
