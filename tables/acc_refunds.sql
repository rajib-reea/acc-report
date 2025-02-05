drop table if exists acc_refunds;
CREATE TABLE acc_refunds (
    refund_id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    refund_date DATE NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL CHECK (refund_amount >= 0),
    refund_reason TEXT NOT NULL
);
INSERT INTO acc_refunds (vendor_id, refund_date, refund_amount, refund_reason) VALUES
(1, '2025-01-01', 150.00, 'Order Cancellation'),
(2, '2025-01-01', 75.50, 'Product Defect'),
(1, '2025-01-02', 200.75, 'Customer Refund'),
(3, '2025-01-02', 125.00, 'Order Cancellation'),
(2, '2025-01-03', 50.25, 'Product Defect'),
(1, '2025-01-04', 180.00, 'Customer Refund'),
(3, '2025-01-04', 220.00, 'Order Cancellation'),
(2, '2025-01-05', 90.75, 'Product Defect');

