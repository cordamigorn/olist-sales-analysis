-- =============================================================
-- Warm-up Set A · Basics + JOIN · Olist (PostgreSQL)
-- Written by me as SQL practice before the main analysis.
-- =============================================================

-- Q1. First 10 rows of customers
SELECT *
FROM customers
LIMIT 10;

-- Q2. How many distinct customer states are there?
SELECT COUNT(DISTINCT customer_state) AS state_count
FROM customers;

-- Q3. How many customers are in 'SP'?
SELECT COUNT(*) AS total_sp_customers
FROM customers
WHERE customer_state = 'SP';

-- Q4. Distinct customer cities containing 'rio'
SELECT DISTINCT customer_city
FROM customers
WHERE customer_city ILIKE '%rio%'
ORDER BY customer_city;

-- Q5. Distinct order statuses
SELECT DISTINCT order_status
FROM orders;

-- Q6. Order items priced above 1000, most expensive first
SELECT order_id, product_id, price
FROM order_items
WHERE price > 1000
ORDER BY price DESC;

-- Q7. Number of canceled or unavailable orders
SELECT COUNT(order_id) AS total_canceled_unavailable
FROM orders
WHERE order_status IN ('canceled', 'unavailable');

-- Q8. Orders with customer city and state (first 20)
SELECT o.order_id, c.customer_id, c.customer_city, c.customer_state, o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 20;

-- Q9. Product categories without an English translation
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL;

-- Q10. Orders with no order items (anti-join pattern)
SELECT o.order_id, o.order_status
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;
