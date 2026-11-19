-- =============================================================
-- 03_constraints_and_checks.sql
-- Run after loading the data (pgAdmin > Query Tool > F5).
-- 1) Adds foreign keys (data integrity between tables)
-- 2) Adds indexes for faster JOINs
-- 3) Checks that every table has the expected number of rows
-- =============================================================

-- 1) Foreign keys
ALTER TABLE orders         ADD CONSTRAINT fk_orders_customer   FOREIGN KEY (customer_id) REFERENCES customers (customer_id);
ALTER TABLE order_items    ADD CONSTRAINT fk_items_order       FOREIGN KEY (order_id)    REFERENCES orders (order_id);
ALTER TABLE order_items    ADD CONSTRAINT fk_items_product     FOREIGN KEY (product_id)  REFERENCES products (product_id);
ALTER TABLE order_items    ADD CONSTRAINT fk_items_seller      FOREIGN KEY (seller_id)   REFERENCES sellers (seller_id);
ALTER TABLE order_payments ADD CONSTRAINT fk_payments_order    FOREIGN KEY (order_id)    REFERENCES orders (order_id);
ALTER TABLE order_reviews  ADD CONSTRAINT fk_reviews_order     FOREIGN KEY (order_id)    REFERENCES orders (order_id);

-- 2) Indexes on columns used in JOINs and filters
CREATE INDEX idx_orders_customer      ON orders (customer_id);
CREATE INDEX idx_orders_purchase_date ON orders (order_purchase_timestamp);
CREATE INDEX idx_items_product        ON order_items (product_id);
CREATE INDEX idx_items_seller         ON order_items (seller_id);
CREATE INDEX idx_reviews_order        ON order_reviews (order_id);

-- 3) Row count check: "actual" should equal "expected" in every row
SELECT t.table_name, t.actual, t.expected,
       CASE WHEN t.actual = t.expected THEN 'OK' ELSE 'CHECK' END AS status
FROM (
    SELECT 'customers'            AS table_name, (SELECT COUNT(*) FROM customers)            AS actual,   99441 AS expected
    UNION ALL SELECT 'geolocation',          (SELECT COUNT(*) FROM geolocation),          1000163
    UNION ALL SELECT 'sellers',              (SELECT COUNT(*) FROM sellers),                 3095
    UNION ALL SELECT 'products',             (SELECT COUNT(*) FROM products),               32951
    UNION ALL SELECT 'category_translation', (SELECT COUNT(*) FROM category_translation),      71
    UNION ALL SELECT 'orders',               (SELECT COUNT(*) FROM orders),                 99441
    UNION ALL SELECT 'order_items',          (SELECT COUNT(*) FROM order_items),           112650
    UNION ALL SELECT 'order_payments',       (SELECT COUNT(*) FROM order_payments),        103886
    UNION ALL SELECT 'order_reviews',        (SELECT COUNT(*) FROM order_reviews),          99224
) AS t
ORDER BY t.table_name;
