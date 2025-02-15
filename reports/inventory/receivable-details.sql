| #   | customer_name | invoice_number | invoice_date | due_date   | balance_due | aging_category |
|-----|---------------|----------------|--------------|------------|-------------|----------------|
| 1   | John Doe      | INV-5001       | 2025-02-05   | 2025-03-05 | 3200.00     | 0-30 Days      |
  
SELECT 
    c.name AS customer_name, 
    inv.invoice_number, 
    inv.invoice_date, 
    inv.due_date, 
    (inv.total_amount - COALESCE(SUM(pmt.amount_paid), 0)) AS balance_due, 
    CASE 
        WHEN inv.due_date < CURRENT_DATE THEN 'Overdue'
        WHEN inv.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' THEN '0-30 Days'
        WHEN inv.due_date BETWEEN CURRENT_DATE + INTERVAL '31 days' AND CURRENT_DATE + INTERVAL '60 days' THEN '31-60 Days'
        WHEN inv.due_date BETWEEN CURRENT_DATE + INTERVAL '61 days' AND CURRENT_DATE + INTERVAL '90 days' THEN '61-90 Days'
        ELSE '90+ Days'
    END AS aging_category
FROM acc_invoices inv
JOIN acc_customers c ON inv.customer_id = c.id
LEFT JOIN acc_payments pmt ON inv.id = pmt.invoice_id
WHERE inv.status = 'Unpaid'
GROUP BY c.name, inv.invoice_number, inv.invoice_date, inv.due_date, inv.total_amount
ORDER BY inv.due_date ASC;
