-- =============================================================
-- Warm-up Set B · Aggregates, GROUP BY, HAVING, subqueries · Olist (PostgreSQL)
-- Written by me as SQL practice before the main analysis.
-- =============================================================

-- Q11. Total payment value
SELECT SUM(payment_value) AS total_payment_value
FROM order_payments;

-- Q12. Min, max and average item price
SELECT MIN(price)            AS min_price,
       MAX(price)            AS max_price,
       ROUND(AVG(price), 2)  AS avg_price
FROM order_items;
-- Note: avg (~120) is far below max (~6,735): a few expensive items pull the mean up,
-- so the median is a better "typical price".

-- Q13. Number of payments by payment type
SELECT payment_type, COUNT(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- Q14. Customers per state, most first
SELECT customer_state, COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;

-- Q15. States with more than 1,000 customers (HAVING filters groups, WHERE filters rows)
SELECT customer_state, COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
HAVING COUNT(*) > 1000
ORDER BY customer_count DESC;

-- Q16. Number of order items priced above the average price
SELECT COUNT(*) AS above_avg_items
FROM order_items
WHERE price > (SELECT AVG(price) FROM order_items);

-- Q17. Top 5 product categories by items sold (English names)
SELECT ct.product_category_name_english, COUNT(*) AS items_sold
FROM order_items oi
JOIN products p              ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY items_sold DESC
LIMIT 5;

-- Q18. 1-star reviews by customer state
SELECT c.customer_state, COUNT(*) AS one_star_reviews
FROM order_reviews r
JOIN orders o    ON r.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE r.review_score = 1
GROUP BY c.customer_state
ORDER BY one_star_reviews DESC;
-- Note: SP leads in absolute numbers because it has the most customers;
-- a fair comparison uses the share of 1-star reviews per state.

-- Q19. COUNT(*) vs COUNT(column)
SELECT COUNT(*)                             AS all_orders,
       COUNT(order_delivered_customer_date) AS delivered_orders
FROM orders;
-- COUNT(*) counts every row; COUNT(column) skips NULLs.
-- The ~2,965 difference = orders never delivered (shipped, canceled, unavailable, ...),
-- which have no delivery date.

-- Q20. Review score distribution with percentage of total
SELECT review_score,
       COUNT(*) AS review_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM order_reviews), 1) AS pct
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;
-- Same result with a window function: 100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
