CREATE TABLE acc_accounts (
    account_id SERIAL PRIMARY KEY,        -- Auto-incremented account ID
    account_name VARCHAR(255) NOT NULL,    -- Account name (e.g., 'Cash', 'Accounts Receivable')
    account_type VARCHAR(50) NOT NULL      -- Account type (e.g., 'cash', 'receivables', 'payables')
);

INSERT INTO acc_accounts (account_name, account_type) VALUES
    ('Cash', 'cash'),
    ('Accounts Receivable', 'receivables'),
    ('Accounts Payable', 'payables'),
    ('Inventory', 'asset'),
    ('Revenue', 'income'),
    ('Expenses', 'expense');
