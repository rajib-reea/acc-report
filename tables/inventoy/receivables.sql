drop table if exists acc_customers cascade;
CREATE TABLE acc_customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_products cascade;
CREATE TABLE acc_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(15,2) NOT NULL
);

drop table if exists acc_invoices cascade;
CREATE TABLE acc_invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT REFERENCES acc_customers(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('Unpaid', 'Paid', 'Partially Paid', 'Overdue')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_invoice_details cascade;
CREATE TABLE acc_invoice_details (
    id SERIAL PRIMARY KEY,
    invoice_id INT REFERENCES acc_invoices(id) ON DELETE CASCADE,
    product_id INT REFERENCES acc_products(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

drop table if exists acc_sales_orders cascade;
CREATE TABLE acc_sales_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT REFERENCES acc_customers(id),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    status VARCHAR(50) CHECK (status IN ('Pending', 'Shipped', 'Completed', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists acc_sales_order_details cascade;
CREATE TABLE acc_sales_order_details (
    id SERIAL PRIMARY KEY,
    sales_order_id INT REFERENCES acc_sales_orders(id) ON DELETE CASCADE,
    product_id INT REFERENCES acc_products(id),
    quantity_ordered INT NOT NULL CHECK (quantity_ordered > 0),
    unit_price DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) GENERATED ALWAYS AS (quantity_ordered * unit_price) STORED
);

drop table if exists acc_payments cascade;
CREATE TABLE acc_payments (
    id SERIAL PRIMARY KEY,
    invoice_id INT REFERENCES acc_invoices(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(15,2) NOT NULL CHECK (amount_paid > 0),
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO acc_customers (name, email, phone, address) VALUES
('John Doe', 'john@example.com', '123-456-7890', '123 Main St, City A'),
('Jane Smith', 'jane@example.com', '987-654-3210', '456 Elm St, City B'),
('Acme Corp', 'contact@acmecorp.com', '555-123-4567', '789 Maple St, City C');

INSERT INTO acc_products (name, price) VALUES
('Laptop', 1200.00),
('Smartphone', 800.00),
('Tablet', 500.00);

-- Insert Sample Data into Sales Orders Table
INSERT INTO acc_sales_orders (order_number, customer_id, order_date, expected_delivery_date, status) VALUES
('SO-1001', 1, '2025-02-01', '2025-02-07', 'Pending'),
('SO-1002', 2, '2025-02-02', '2025-02-08', 'Shipped'),
('SO-1003', 3, '2025-02-03', '2025-02-09', 'Completed');

-- Insert Sample Data into Sales Order Details Table
INSERT INTO acc_sales_order_details (sales_order_id, product_id, quantity_ordered, unit_price) VALUES
(1, 1, 2, 1200.00),
(1, 2, 3, 800.00),
(2, 3, 1, 500.00),
(3, 1, 1, 1200.00),
(3, 2, 2, 800.00);

-- Insert Sample Data into Invoices Table
INSERT INTO acc_invoices (invoice_number, customer_id, invoice_date, due_date, total_amount, status) VALUES
('INV-5001', 1, '2025-02-05', '2025-03-05', 3200.00, 'Unpaid'),
('INV-5002', 2, '2025-02-06', '2025-03-06', 500.00, 'Paid'),
('INV-5003', 3, '2025-02-07', '2025-03-07', 2800.00, 'Partially Paid');

-- Insert Sample Data into Invoice Details Table
INSERT INTO acc_invoice_details (invoice_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 1200.00),
(1, 2, 1, 800.00),
(2, 3, 1, 500.00),
(3, 1, 1, 1200.00),
(3, 2, 2, 800.00);

INSERT INTO acc_sales_orders (order_number, customer_id, order_date, expected_delivery_date, status) VALUES
('SO-1001', 1, '2025-02-01', '2025-02-07', 'Pending'),
('SO-1002', 2, '2025-02-02', '2025-02-08', 'Shipped'),
('SO-1003', 3, '2025-02-03', '2025-02-09', 'Completed'),
('SO-1004', 1, '2025-02-04', '2025-02-10', 'Cancelled'),
('SO-1005', 2, '2025-02-05', '2025-02-11', 'Pending');

INSERT INTO acc_sales_order_details (sales_order_id, product_id, quantity_ordered, unit_price) VALUES
(1, 1, 2, 1200.00), -- John Doe orders 2 Laptops
(1, 2, 1, 800.00),  -- John Doe orders 1 Smartphone
(2, 3, 3, 500.00),  -- Jane Smith orders 3 Tablets
(3, 1, 1, 1200.00), -- Acme Corp orders 1 Laptop
(3, 2, 2, 800.00),  -- Acme Corp orders 2 Smartphones
(4, 1, 1, 1200.00), -- Cancelled order: 1 Laptop for John Doe
(5, 3, 2, 500.00);  -- Pending order: Jane Smith orders 2 Tablets


-- Insert Sample Data into Payments Table
INSERT INTO acc_payments (invoice_id, payment_date, amount_paid, payment_method) VALUES
(1, '2025-02-10', 1000.00, 'Credit Card'),
(2, '2025-02-12', 500.00, 'Bank Transfer'),
(3, '2025-02-14', 1500.00, 'Cash');
