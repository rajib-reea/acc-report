CREATE TABLE acc_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE acc_inventory (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    cost_per_unit DECIMAL(10,2) NOT NULL,
    received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE acc_sales (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    quantity_sold INT NOT NULL CHECK (quantity_sold >= 0),
    selling_price DECIMAL(10,2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE acc_purchases (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    quantity_purchased INT NOT NULL CHECK (quantity_purchased >= 0),
    purchase_price DECIMAL(10,2) NOT NULL,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE acc_purchase_orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES acc_products(id),
    supplier VARCHAR(255) NOT NULL,
    quantity_ordered INT NOT NULL CHECK (quantity_ordered >= 0),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_delivery TIMESTAMP
);
