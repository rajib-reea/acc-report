| #   | invoice_id | invoice_number | customer_name | product_name | quantity | unit_price | total_amount | invoice_date | due_date   | status         |
|-----|------------|----------------|---------------|--------------|----------|------------|--------------|--------------|------------|----------------|
| 1   | 3          | INV-5003       | Acme Corp     | Laptop       | 1        | 1200.00    | 1200.00      | 2025-02-07   | 2025-03-07 | Partially Paid |
| 2   | 3          | INV-5003       | Acme Corp     | Smartphone   | 2        | 800.00     | 1600.00      | 2025-02-07   | 2025-03-07 | Partially Paid |
| 3   | 2          | INV-5002       | Jane Smith    | Tablet       | 1        | 500.00     | 500.00       | 2025-02-06   | 2025-03-06 | Paid           |
| 4   | 1          | INV-5001       | John Doe      | Laptop       | 2        | 1200.00    | 2400.00      | 2025-02-05   | 2025-03-05 | Unpaid         |
| 5   | 1          | INV-5001       | John Doe      | Smartphone   | 1        | 800.00     | 800.00       | 2025-02-05   | 2025-03-05 | Unpaid         |
  
SELECT 
    inv.id AS invoice_id, 
    inv.invoice_number, 
    c.name AS customer_name, 
    p.name AS product_name, 
    invd.quantity, 
    invd.unit_price, 
    (invd.quantity * invd.unit_price) AS total_amount,
    inv.invoice_date, 
    inv.due_date, 
    inv.status
FROM acc_invoices inv
JOIN acc_invoice_details invd ON inv.id = invd.invoice_id
JOIN acc_customers c ON inv.customer_id = c.id
JOIN acc_products p ON invd.product_id = p.id
ORDER BY inv.invoice_date DESC;
