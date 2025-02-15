drop table if exists acc_products cascade;
CREATE TABLE acc_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_inventory cascade;
CREATE TABLE acc_inventory (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    cost_per_unit DECIMAL(10,2) NOT NULL,
    received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_sales cascade;
CREATE TABLE acc_sales (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    quantity_sold INT NOT NULL CHECK (quantity_sold >= 0),
    selling_price DECIMAL(10,2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_purchases cascade;
CREATE TABLE acc_purchases (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    quantity_purchased INT NOT NULL CHECK (quantity_purchased >= 0),
    purchase_price DECIMAL(10,2) NOT NULL,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_purchase_orders  cascade;
CREATE TABLE acc_purchase_orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    supplier VARCHAR(255) NOT NULL,
    quantity_ordered INT NOT NULL CHECK (quantity_ordered >= 0),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_delivery TIMESTAMP
);

INSERT INTO acc_products (name, sku, category, unit) VALUES
('Product A', 'SKU001', 'Electronics', 'pcs'),
('Product B', 'SKU002', 'Groceries', 'kg'),
('Product C', 'SKU003', 'Clothing', 'pcs');

INSERT INTO acc_inventory (product_id, warehouse_id, quantity, cost_per_unit, received_date) VALUES
(1, 1, 100, 50.00, '2024-02-01'),
(2, 1, 200, 30.00, '2024-02-05'),
(3, 2, 150, 40.00, '2024-02-10');

INSERT INTO acc_sales (product_id, quantity_sold, selling_price, sale_date) VALUES
(1, 10, 70.00, '2024-02-10'),
(2, 20, 35.00, '2024-02-11'),
(3, 15, 45.00, '2024-02-12');

INSERT INTO acc_purchases (product_id, quantity_purchased, purchase_price, purchase_date) VALUES
(1, 50, 50.00, '2024-01-25'),
(2, 100, 30.00, '2024-01-30'),
(3, 75, 40.00, '2024-02-05');

INSERT INTO acc_purchase_orders (product_id, supplier, quantity_ordered, order_date, expected_delivery) VALUES
(1, 'Supplier A', 50, '2024-02-01', '2024-02-15'),
(2, 'Supplier B', 75, '2024-02-03', '2024-02-18');

