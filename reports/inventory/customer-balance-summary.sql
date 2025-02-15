| #   | customer_id | customer_name | total_invoiced | total_paid | balance_due |
|-----|-------------|---------------|----------------|------------|-------------|
| 1   | 1           | John Doe      | 3200.00        | 0          | 3200.00     |
| 2   | 3           | Acme Corp     | 2800.00        | 0          | 2800.00     |
| 3   | 2           | Jane Smith    | 500.00         | 0          | 500.00      |
  
SELECT 
    c.id AS customer_id, 
    c.name AS customer_name, 
    COALESCE(SUM(inv.total_amount), 0) AS total_invoiced, 
    COALESCE(SUM(pmt.amount_paid), 0) AS total_paid, 
    (COALESCE(SUM(inv.total_amount), 0) - COALESCE(SUM(pmt.amount_paid), 0)) AS balance_due
FROM acc_customers c
LEFT JOIN acc_invoices inv ON c.id = inv.customer_id
LEFT JOIN acc_payments pmt ON inv.id = pmt.invoice_id
GROUP BY c.id, c.name
HAVING (COALESCE(SUM(inv.total_amount), 0) - COALESCE(SUM(pmt.amount_paid), 0)) > 0
ORDER BY balance_due DESC;
