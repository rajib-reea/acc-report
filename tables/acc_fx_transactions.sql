-- Create the acc_fx_transactions table
CREATE TABLE acc_fx_transactions (
    transaction_id SERIAL PRIMARY KEY,
    transaction_date DATE NOT NULL,
    original_currency_amount NUMERIC(15, 2) NOT NULL,
    original_exchange_rate NUMERIC(10, 6) NOT NULL,
    settlement_amount NUMERIC(15, 2) NOT NULL,
    settlement_exchange_rate NUMERIC(10, 6) NOT NULL
);

-- Insert sample data
INSERT INTO acc_fx_transactions (transaction_date, original_currency_amount, original_exchange_rate, settlement_amount, settlement_exchange_rate) 
VALUES
    ('2025-01-01', 1000, 1.2, 1200, 1.2),
    ('2025-01-02', 2000, 1.1, 2200, 1.1),
    ('2025-01-03', 1500, 1.15, 1725, 1.15),
    ('2025-01-04', 1800, 1.25, 2250, 1.25),
    ('2025-01-05', 1700, 1.3, 2210, 1.3),
    ('2025-01-06', 2500, 1.2, 3000, 1.2),
    ('2025-01-07', 1900, 1.05, 1995, 1.05),
    ('2025-01-08', 1600, 1.1, 1760, 1.1),
    ('2025-01-09', 1400, 1.2, 1680, 1.2),
    ('2025-01-10', 1300, 1.3, 1690, 1.3);

-- Create table acc_open_fx_transactions
CREATE TABLE acc_open_fx_transactions (
    position_id SERIAL PRIMARY KEY,
    transaction_date DATE NOT NULL,
    original_amount DECIMAL(18, 2) NOT NULL,
    original_exchange_rate DECIMAL(10, 6) NOT NULL,
    current_exchange_rate DECIMAL(10, 6) NOT NULL,
    settlement_status VARCHAR(20) NOT NULL  -- Values: 'pending', 'settled'
);

-- Insert sample data into acc_open_fx_transactions
INSERT INTO acc_open_fx_transactions (transaction_date, original_amount, original_exchange_rate, current_exchange_rate, settlement_status) 
VALUES 
    ('2025-01-01', 1000.00, 1.10, 1.15, 'pending'),
    ('2025-01-02', 1500.00, 1.12, 1.10, 'pending'),
    ('2025-01-03', 1200.00, 1.08, 1.09, 'pending'),
    ('2025-01-04', 1300.00, 1.05, 1.07, 'pending'),
    ('2025-01-05', 2000.00, 1.15, 1.12, 'pending'),
    ('2025-01-06', 1700.00, 1.09, 1.08, 'pending'),
    ('2025-01-07', 1600.00, 1.07, 1.10, 'pending'),
    ('2025-01-08', 1800.00, 1.12, 1.14, 'pending'),
    ('2025-01-09', 1400.00, 1.11, 1.13, 'pending'),
    ('2025-01-10', 1250.00, 1.10, 1.10, 'pending');

