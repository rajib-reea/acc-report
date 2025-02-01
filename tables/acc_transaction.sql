CREATE TABLE acc_transactions (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL, -- Added user_id
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'revenue' or 'expense'
    amount NUMERIC(15,2) NOT NULL,
    description VARCHAR(255),
    currency_code CHAR(3) DEFAULT 'USD',
    category VARCHAR(100),
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
    deleted_at TIMESTAMP
);

INSERT INTO acc_transactions (user_id, transaction_date, transaction_type, amount, description, currency_code, category, department, project_id, invoice_id, is_reconciled, is_active, created_by, modified_by, deleted_by, created_at, updated_at, deleted_at)
VALUES
(1, '2025-01-01', 'revenue', 1500.00, 'Sales Revenue from Client A', 'USD', 'sales', 'sales', 1, 1001, FALSE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(2, '2025-01-02', 'expense', 200.00, 'Office Supplies', 'USD', 'operating expenses', 'purchasing', NULL, 1002, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(1, '2025-01-03', 'revenue', 2500.00, 'Project Revenue for Project X', 'USD', 'project revenue', 'sales', 101, 1003, TRUE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(3, '2025-01-04', 'expense', 1200.00, 'Rent for office space', 'USD', 'rent', 'operations', NULL, 1004, FALSE, TRUE, 3, 3, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO acc_transactions (user_id, transaction_date, transaction_type, amount, description, currency_code, category, department, project_id, invoice_id, is_reconciled, is_active, created_by, modified_by, deleted_by, created_at, updated_at, deleted_at)
VALUES
(1, '2025-01-01', 'revenue', 1500.00, 'Sales Revenue from Client A', 'USD', 'sales', 'sales', 1, 1001, FALSE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(2, '2025-01-02', 'expense', 200.00, 'Office Supplies', 'USD', 'operating expenses', 'purchasing', NULL, 1002, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(1, '2025-01-03', 'revenue', 2500.00, 'Project Revenue for Project X', 'USD', 'project revenue', 'sales', 101, 1003, TRUE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(3, '2025-01-04', 'expense', 1200.00, 'Rent for office space', 'USD', 'rent', 'operations', NULL, 1004, FALSE, TRUE, 3, 3, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(2, '2025-01-05', 'revenue', 1000.00, 'Product Sale to Client B', 'USD', 'sales', 'sales', 2, 1005, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(3, '2025-01-06', 'expense', 150.00, 'Internet Service for Office', 'USD', 'utilities', 'IT', NULL, 1006, FALSE, TRUE, 3, 3, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(4, '2025-01-07', 'expense', 500.00, 'Advertising Expense for Product Launch', 'USD', 'marketing', 'marketing', NULL, 1007, FALSE, TRUE, 4, 4, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(1, '2025-01-08', 'revenue', 1800.00, 'Subscription Service Income', 'USD', 'subscriptions', 'sales', 3, 1008, TRUE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(2, '2025-01-09', 'expense', 750.00, 'Consulting Fees for Project Y', 'USD', 'professional services', 'operations', 102, 1009, FALSE, TRUE, 2, 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(1, '2025-01-10', 'revenue', 3000.00, 'Payment Received from Client C', 'USD', 'sales', 'sales', 4, 1010, FALSE, TRUE, 1, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
