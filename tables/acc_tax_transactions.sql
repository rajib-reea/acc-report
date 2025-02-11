CREATE TABLE acc_tax_transactions (
    transaction_id SERIAL PRIMARY KEY,
    tax_category VARCHAR(50),  -- e.g., 'Sales Tax', 'VAT', 'Income Tax'
    tax_amount DECIMAL(10, 2),  -- Amount of tax involved
    transaction_type VARCHAR(10),  -- 'collected' or 'paid'
    entity_id INT,  -- ID of the vendor, customer, project, etc.
    region VARCHAR(50),  -- Region-specific tax info (if applicable)
    transaction_date DATE  -- Date of the transaction
);
INSERT INTO acc_tax_transactions (tax_category, tax_amount, transaction_type, entity_id, region, transaction_date)
VALUES
    ('Sales Tax', 150.00, 'collected', 1, 'North', '2025-01-01'),
    ('Sales Tax', 100.00, 'paid', 1, 'North', '2025-01-03'),
    ('VAT', 200.00, 'collected', 2, 'South', '2025-01-04'),
    ('VAT', 50.00, 'paid', 2, 'South', '2025-01-06'),
    ('Income Tax', 300.00, 'collected', 3, 'West', '2025-01-07'),
    ('Income Tax', 200.00, 'paid', 3, 'West', '2025-01-08'),
    ('Sales Tax', 50.00, 'collected', 4, 'East', '2025-01-10'),
    ('Sales Tax', 70.00, 'paid', 4, 'East', '2025-01-12'),
    ('VAT', 120.00, 'collected', 5, 'Central', '2025-01-14'),
    ('VAT', 100.00, 'paid', 5, 'Central', '2025-01-15'),
    ('Income Tax', 180.00, 'collected', 6, 'North', '2025-01-17'),
    ('Income Tax', 150.00, 'paid', 6, 'North', '2025-01-19');
