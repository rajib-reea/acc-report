| #   | aging_category | total_receivable |
|-----|----------------|------------------|
| 1   | 0-30 Days      | 3200.00          |
  
SELECT 
    CASE 
        WHEN inv.due_date < CURRENT_DATE THEN 'Overdue'
        WHEN inv.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' THEN '0-30 Days'
        WHEN inv.due_date BETWEEN CURRENT_DATE + INTERVAL '31 days' AND CURRENT_DATE + INTERVAL '60 days' THEN '31-60 Days'
        WHEN inv.due_date BETWEEN CURRENT_DATE + INTERVAL '61 days' AND CURRENT_DATE + INTERVAL '90 days' THEN '61-90 Days'
        ELSE '90+ Days'
    END AS aging_category, 
    SUM(inv.total_amount - COALESCE(pmt.amount_paid, 0)) AS total_receivable
FROM acc_invoices inv
LEFT JOIN acc_payments pmt ON inv.id = pmt.invoice_id
WHERE inv.status = 'Unpaid'
GROUP BY aging_category
ORDER BY aging_category;
