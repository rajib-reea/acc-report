CREATE TABLE acc_bank_transactions (
    transaction_id SERIAL PRIMARY KEY,         -- Automatically incrementing unique ID for each transaction
    transaction_date DATE NOT NULL,            -- The date of the transaction
    transaction_type VARCHAR(50) NOT NULL,     -- 'deposit', 'withdrawal', 'transfer'
    amount DECIMAL(15, 2) NOT NULL,            -- The amount of the transaction (with two decimal places)
    account_id INT NOT NULL,                   -- The ID of the account where the transaction belongs
    transaction_status VARCHAR(50) NOT NULL,   -- The status of the transaction ('matched', 'unmatched', 'pending')
    FOREIGN KEY (account_id) REFERENCES acc_accounts(account_id) -- Assuming 'acc_accounts' is the related accounts table
);

-- Insert sample bank transactions for the date range '2025-01-01' to '2025-01-10'
INSERT INTO acc_bank_transactions (transaction_id, transaction_date, transaction_type, amount, account_id, transaction_status)
VALUES
    (1, '2025-01-01', 'deposit', 1000.00, 101, 'matched'),
    (2, '2025-01-01', 'withdrawal', 200.00, 101, 'unmatched'),
    (3, '2025-01-02', 'deposit', 1500.00, 102, 'pending'),
    (4, '2025-01-03', 'withdrawal', 300.00, 103, 'matched'),
    (5, '2025-01-03', 'deposit', 1200.00, 104, 'unmatched'),
    (6, '2025-01-04', 'withdrawal', 100.00, 101, 'matched'),
    (7, '2025-01-04', 'deposit', 500.00, 105, 'pending'),
    (8, '2025-01-05', 'transfer', 200.00, 102, 'matched'),
    (9, '2025-01-06', 'withdrawal', 50.00, 106, 'matched'),
    (10, '2025-01-06', 'deposit', 800.00, 107, 'unmatched'),
    (11, '2025-01-07', 'deposit', 300.00, 108, 'matched'),
    (12, '2025-01-08', 'withdrawal', 500.00, 109, 'unmatched'),
    (13, '2025-01-09', 'deposit', 150.00, 110, 'pending'),
    (14, '2025-01-10', 'transfer', 1000.00, 111, 'matched'),
    (15, '2025-01-10', 'deposit', 600.00, 112, 'unmatched');
