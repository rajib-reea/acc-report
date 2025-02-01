CREATE TABLE acc_transactions (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL, -- Added user_id
    account_id INT NOT NULL, -- Added account_id
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'revenue' or 'expense'
    amount NUMERIC(15,2) NOT NULL,
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
    FOREIGN KEY (account_id) REFERENCES acc_accounts(account_id) -- Reference to the acc_accounts table
);
