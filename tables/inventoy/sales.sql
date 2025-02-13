-- Tables and Sample Data

-- Customers Table
CREATE TABLE acc_customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
INSERT INTO acc_customers (name) VALUES ('John Doe'), ('Jane Smith');

-- Items Table
CREATE TABLE acc_items (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
INSERT INTO acc_items (name) VALUES ('Product A'), ('Product B');

-- Sales Table
CREATE TABLE acc_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES acc_customers(customer_id),
    total_amount DECIMAL(10,2) NOT NULL,
    sale_date DATE NOT NULL,
    salesperson_id INT
);
INSERT INTO acc_sales (customer_id, total_amount, sale_date, salesperson_id) VALUES 
(1, 100.50, CURRENT_DATE, 1), (2, 200.75, CURRENT_DATE, 2);

-- Order Items Table
CREATE TABLE acc_order_items (
    order_item_id SERIAL PRIMARY KEY,
    sale_id INT REFERENCES acc_sales(sale_id),
    item_id INT REFERENCES acc_items(item_id),
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);
INSERT INTO acc_order_items (sale_id, item_id, quantity, total_price) VALUES 
(1, 1, 2, 50.25), (2, 2, 3, 66.92);

-- Sales Returns Table
CREATE TABLE acc_sales_returns (
    return_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES acc_customers(customer_id),
    item_id INT REFERENCES acc_items(item_id),
    quantity INT NOT NULL,
    return_date DATE NOT NULL,
    reason TEXT
);
INSERT INTO acc_sales_returns (customer_id, item_id, quantity, return_date, reason) VALUES 
(1, 1, 1, CURRENT_DATE, 'Damaged item');

-- Salespersons Table
CREATE TABLE acc_salespersons (
    salesperson_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
INSERT INTO acc_salespersons (name) VALUES ('Alice Brown'), ('Bob White');

-- Orders Table
CREATE TABLE acc_orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL
);
INSERT INTO acc_orders (order_date, status) VALUES (CURRENT_DATE, 'Fulfilled');

-- Packing Table
CREATE TABLE acc_packing (
    packing_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES acc_orders(order_id),
    packed_by VARCHAR(255) NOT NULL,
    packing_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL
);
INSERT INTO acc_packing (order_id, packed_by, packing_date, status) VALUES 
(1, 'Warehouse A', CURRENT_DATE, 'Completed');
