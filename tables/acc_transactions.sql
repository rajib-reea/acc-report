drop table if exists acc_accounts;
CREATE TABLE acc_accounts (
    account_id SERIAL PRIMARY KEY,        -- Auto-incremented account ID
    account_name VARCHAR(255) NOT NULL,    -- Account name (e.g., 'Cash', 'Accounts Receivable')
    account_type VARCHAR(50) NOT NULL,     -- Account type (e.g., 'cash', 'receivables', 'payables')
    category VARCHAR(100) NOT NULL         -- Category for the account (e.g., 'current asset', 'liability', etc.)
);
INSERT INTO acc_accounts (account_name, account_type, category) VALUES
    ('Cash', 'cash', 'current asset'),
    ('Accounts Receivable', 'receivables', 'current asset'),
    ('Accounts Payable', 'payables', 'current liability'),
    ('Inventory', 'asset', 'current asset'),
    ('Revenue', 'income', 'revenue'),
    ('Expenses', 'expense', 'operating expense');

-- Drop the table if it already exists
DROP TABLE IF EXISTS acc_transactions;

-- Create the table with the added customer_id, max_days_outstanding, quantity, and price columns
CREATE TABLE acc_transactions (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,  -- Added customer_id
    user_id INT NOT NULL,
    account_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'revenue' or 'expense'
    amount NUMERIC(15,2) NOT NULL,
    quantity INT NOT NULL,  -- Added quantity column
    price NUMERIC(15,2) NOT NULL,  -- Added price column
    description VARCHAR(255),
    currency_code CHAR(3) DEFAULT 'USD',
    department VARCHAR(100),
    project_id INT,
    invoice_id INT,
    is_reconciled BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    modified_by INT,
    deleted_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    max_days_outstanding INT DEFAULT 0, -- Added max_days_outstanding
    FOREIGN KEY (account_id) REFERENCES acc_accounts(account_id) -- Reference to the acc_accounts table
);
-- Insert data into acc_transactions table with customer_id, max_days_outstanding, quantity, and price
INSERT INTO acc_transactions (
    customer_id, user_id, account_id, transaction_date, transaction_type, amount, quantity, price, description, currency_code, 
    department, project_id, invoice_id, is_reconciled, is_active, created_by, modified_by, deleted_by, created_at, updated_at, deleted_at, max_days_outstanding
)
VALUES
(101, 1, 1, '2025-01-01', 'revenue', 1500.00, 10, 150.00, 'Sales Revenue from Client A', 'USD', 'sales', 1, 1001, FALSE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 30),
(102, 2, 2, '2025-01-02', 'expense', 200.00, 5, 40.00, 'Office Supplies', 'USD', 'purchasing', NULL, 1002, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 30),
(101, 1, 1, '2025-01-03', 'revenue', 2500.00, 15, 166.67, 'Project Revenue for Project X', 'USD', 'sales', 101, 1003, TRUE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 25),
(103, 3, 3, '2025-01-04', 'expense', 1200.00, 3, 400.00, 'Rent for office space', 'USD', 'operations', NULL, 1004, FALSE, TRUE, 3, 3, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 60),
(102, 2, 2, '2025-01-05', 'revenue', 1000.00, 8, 125.00, 'Product Sale to Client B', 'USD', 'sales', 2, 1005, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 20),
(103, 3, 3, '2025-01-06', 'expense', 150.00, 2, 75.00, 'Internet Service for Office', 'USD', 'IT', NULL, 1006, FALSE, TRUE, 3, 3, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 50),
(104, 4, 4, '2025-01-07', 'expense', 500.00, 1, 500.00, 'Advertising Expense for Product Launch', 'USD', 'marketing', NULL, 1007, FALSE, TRUE, 4, 4, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 40),
(101, 1, 1, '2025-01-08', 'revenue', 1800.00, 20, 90.00, 'Subscription Service Income', 'USD', 'sales', 3, 1008, TRUE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 10),
(102, 2, 2, '2025-01-09', 'expense', 750.00, 4, 187.50, 'Consulting Fees for Project Y', 'USD', 'operations', 102, 1009, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 30),
(101, 1, 1, '2025-01-10', 'revenue', 3000.00, 25, 120.00, 'Payment Received from Client C', 'USD', 'sales', 4, 1010, FALSE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 5);
