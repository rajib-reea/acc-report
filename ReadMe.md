
# Accounting Reports Microservice

## Overview
The **Accounting Reports Microservice** provides financial reporting capabilities, including Profit & Loss summaries, ledger details, and other key accounting insights. It processes transactions stored in the database and generates structured financial reports.

## Features
- **Profit and Loss Summary Report**
- **General Ledger Report**
- **Trial Balance Report**
- **Balance Sheet Report**
- **Cash Flow Statement**
- **Pending Transactions Report**
- **Expense & Revenue Breakdown**

## System Requirements
- **Database:** MySQL / PostgreSQL (Supports SQL-based queries)
- **Framework:** Laravel / Node.js / Python (Optional, for API endpoints)
- **Authentication:** JWT / OAuth2 (if secured API access is needed)

#### Liabilities Categories: [loans, accounts payable (ap), other debts, taxes payable, credit lines]
#### Assets Categories: [sales, subscriptions, service income, operating expenses, rent, utilities, marketing, professional services, salaries, insurance, taxes, inventory, accounts receivable (ar), fixed assets, intangible assets]
#### Equity Category: [owner capital]



## Report Algorithms & Queries

### **1. Profit and Loss Summary**
#### Algorithm:
1. Retrieve total revenue within the specified date range.
2. Retrieve total expenses within the specified date range.
3. Calculate Net Profit/Loss:
   - Net Profit = Total Revenue - Total Expenses
4. Store the results in the report.
5. Return the Profit and Loss Summary.

#### SQL:
```sql
SELECT
    COALESCE(SUM(CASE WHEN transaction_type = 'revenue' THEN amount ELSE 0 END), 0) AS total_revenue,
    COALESCE(SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END), 0) AS total_expenses,
    COALESCE(SUM(CASE WHEN transaction_type = 'revenue' THEN amount ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END), 0) AS net_profit
FROM acc_transactions
WHERE transaction_date BETWEEN :startDate AND :endDate AND is_active = TRUE;
```

### **2. General Ledger Report**
#### Algorithm:
1. Retrieve all accounting transactions within the given date range.
2. Categorize transactions based on debit/credit entries.
3. Compute running balances per account.
4. Format transactions into an ordered ledger view.
5. Return the ledger report.

#### SQL:
```sql
SELECT
    account_id, transaction_date, description,
    CASE WHEN transaction_type = 'debit' THEN amount ELSE 0 END AS debit,
    CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END AS credit,
    (SUM(CASE WHEN transaction_type = 'debit' THEN amount ELSE -amount END)
        OVER (PARTITION BY account_id ORDER BY transaction_date)) AS running_balance
FROM acc_transactions
WHERE transaction_date BETWEEN :startDate AND :endDate
ORDER BY account_id, transaction_date;
```

### **3. Trial Balance Report**
#### Algorithm:
1. Retrieve all account balances within the date range.
2. Sum debit and credit transactions separately.
3. Ensure debits equal credits for balance verification.
4. Return the trial balance summary.

#### SQL:
```sql
SELECT
    account_id, account_name,
    SUM(CASE WHEN transaction_type = 'debit' THEN amount ELSE 0 END) AS total_debits,
    SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END) AS total_credits
FROM acc_transactions
WHERE transaction_date BETWEEN :startDate AND :endDate
GROUP BY account_id, account_name;
```

## Deployment & Usage
### **Setup**
1. Clone this repository:
   ```sh
   git clone https://github.com/your-repo/accounting-reports-microservice.git
   cd accounting-reports-microservice
   ```
2. Configure the database connection in `.env`.
3. Run database migrations (if applicable):
   ```sh
   php artisan migrate  # Laravel
   ```
4. Start the service:
   ```sh
   php artisan serve  # Laravel
   ```

### **API Endpoints (Example)**
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/api/reports/profit-loss?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD` | Fetch Profit & Loss Summary |
| GET | `/api/reports/general-ledger?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD` | Fetch General Ledger |
| GET | `/api/reports/trial-balance?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD` | Fetch Trial Balance |

## Security Considerations
- Ensure API endpoints are authenticated using JWT or OAuth.
- Restrict database queries to prevent SQL injection.
- Encrypt sensitive financial data.

## Future Enhancements
- Add **automated scheduled reports**.
- Support **multi-currency transactions**.
- Integrate with **external accounting systems (e.g., QuickBooks, SAP)**.

## License
MIT License

## Contact
For support, reach out to `support@yourcompany.com`. Happy accounting!

