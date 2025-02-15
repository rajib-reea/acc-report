No Data
  

SELECT p.name, p.sku, po.supplier, po.quantity_ordered, po.order_date, po.expected_delivery
FROM acc_products p
JOIN acc_purchase_orders po ON p.id = po.product_id
WHERE po.expected_delivery >= CURRENT_DATE;
