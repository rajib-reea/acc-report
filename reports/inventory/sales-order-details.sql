| #   | sales_order_id | order_number | customer_name | product_name | quantity_ordered | unit_price | total_amount | order_date | expected_delivery_date | status    |
|-----|----------------|--------------|---------------|--------------|------------------|------------|--------------|------------|------------------------|-----------|
| 1   | 3              | SO-1003      | Acme Corp     | Laptop       | 1                | 1200.00    | 1200.00      | 2025-02-03 | 2025-02-09             | Completed |
| 2   | 3              | SO-1003      | Acme Corp     | Smartphone   | 2                | 800.00     | 1600.00      | 2025-02-03 | 2025-02-09             | Completed |
| 3   | 2              | SO-1002      | Jane Smith    | Tablet       | 1                | 500.00     | 500.00       | 2025-02-02 | 2025-02-08             | Shipped   |
| 4   | 1              | SO-1001      | John Doe      | Laptop       | 2                | 1200.00    | 2400.00      | 2025-02-01 | 2025-02-07             | Pending   |
| 5   | 1              | SO-1001      | John Doe      | Smartphone   | 3                | 800.00     | 2400.00      | 2025-02-01 | 2025-02-07             | Pending   |
  
SELECT 
    so.id AS sales_order_id, 
    so.order_number, 
    c.name AS customer_name, 
    p.name AS product_name, 
    sod.quantity_ordered, 
    sod.unit_price, 
    (sod.quantity_ordered * sod.unit_price) AS total_amount,
    so.order_date, 
    so.expected_delivery_date, 
    so.status
FROM acc_sales_orders so
JOIN acc_sales_order_details sod ON so.id = sod.sales_order_id
JOIN acc_customers c ON so.customer_id = c.id
JOIN acc_products p ON sod.product_id = p.id
ORDER BY so.order_date DESC;
