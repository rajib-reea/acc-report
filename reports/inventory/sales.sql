-- Sales Reports

-- 1. Sales by Customer
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, c.customer_id, c.name, COALESCE(SUM(s.total_amount), 0) AS total_sales
FROM DateSeries d
LEFT JOIN acc_sales s ON d.transaction_date = s.sale_date
LEFT JOIN acc_customers c ON s.customer_id = c.customer_id
GROUP BY d.transaction_date, c.customer_id, c.name
ORDER BY d.transaction_date, total_sales DESC;

-- 2. Sales by Item
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, i.item_id, i.name, COALESCE(SUM(oi.quantity), 0) AS total_quantity, COALESCE(SUM(oi.total_price), 0) AS total_sales
FROM DateSeries d
LEFT JOIN acc_sales s ON d.transaction_date = s.sale_date
LEFT JOIN acc_order_items oi ON s.sale_id = oi.sale_id
LEFT JOIN acc_items i ON oi.item_id = i.item_id
GROUP BY d.transaction_date, i.item_id, i.name
ORDER BY d.transaction_date, total_sales DESC;

-- 3. Order Fulfillment by Item
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, i.item_id, i.name, COALESCE(COUNT(o.order_id), 0) AS total_orders, COALESCE(SUM(oi.quantity), 0) AS total_quantity
FROM DateSeries d
LEFT JOIN acc_orders o ON d.transaction_date = o.order_date AND o.status = 'Fulfilled'
LEFT JOIN acc_order_items oi ON o.order_id = oi.sale_id
LEFT JOIN acc_items i ON oi.item_id = i.item_id
GROUP BY d.transaction_date, i.item_id, i.name
ORDER BY d.transaction_date, total_quantity DESC;

-- 4. Sales Return History
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, sr.return_id, c.name AS customer_name, i.name AS item_name, sr.quantity, sr.return_date, sr.reason
FROM DateSeries d
LEFT JOIN acc_sales_returns sr ON d.transaction_date = sr.return_date
LEFT JOIN acc_customers c ON sr.customer_id = c.customer_id
LEFT JOIN acc_items i ON sr.item_id = i.item_id
ORDER BY d.transaction_date, sr.return_date DESC;

-- 5. Sales by Sales Person
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, sp.salesperson_id, sp.name, COALESCE(SUM(s.total_amount), 0) AS total_sales
FROM DateSeries d
LEFT JOIN acc_sales s ON d.transaction_date = s.sale_date
LEFT JOIN acc_salespersons sp ON s.salesperson_id = sp.salesperson_id
GROUP BY d.transaction_date, sp.salesperson_id, sp.name
ORDER BY d.transaction_date, total_sales DESC;

-- 6. Packing History
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
)
SELECT d.transaction_date, p.packing_id, o.order_id, p.packed_by, p.packing_date, p.status
FROM DateSeries d
LEFT JOIN acc_packing p ON d.transaction_date = p.packing_date
LEFT JOIN acc_orders o ON p.order_id = o.order_id
ORDER BY d.transaction_date, p.packing_date DESC;
