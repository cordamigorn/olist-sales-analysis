-- =============================================================
-- Quick check · semicolons, meaningful aliases, = vs LIKE · Olist (PostgreSQL)
-- =============================================================

-- K1. Customers in RJ
SELECT COUNT(*) AS rj_customer_count
FROM customers
WHERE customer_state = 'RJ';

-- K2. Products in furniture categories ('moveis_*')
SELECT COUNT(*) AS furniture_product_count
FROM products
WHERE product_category_name LIKE 'moveis%';

-- K3. Payments with more than 10 installments: count and total value
SELECT COUNT(*)           AS payment_count,
       SUM(payment_value) AS total_payment_value
FROM order_payments
WHERE payment_installments > 10;

-- K4. Top 5 states by unique customers (a person can have several customer_id values)
SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS unique_customer_count
FROM customers
GROUP BY customer_state
ORDER BY unique_customer_count DESC
LIMIT 5;

-- K5. Average freight by seller state
--     After GROUP BY you can only sort by grouped columns or aggregates → sort by the alias
SELECT s.seller_state, ROUND(AVG(oi.freight_value), 2) AS avg_freight
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY avg_freight DESC;
