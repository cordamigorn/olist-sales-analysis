-- =============================================================
-- Warm-up Set C · Functions, dates, views, DDL, DML · Olist (PostgreSQL)
-- Written by me as SQL practice before the main analysis.
-- =============================================================

-- -------------------------------------------------------------
-- Part 1 · Functions and dates
-- -------------------------------------------------------------

-- Q21. 10 longest distinct customer city names, upper case
SELECT DISTINCT UPPER(customer_city)  AS city_upper,
                LENGTH(customer_city) AS name_length
FROM customers
ORDER BY name_length DESC
LIMIT 10;

-- Q22. Orders per purchase year
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
       COUNT(*) AS order_count
FROM orders
GROUP BY order_year
ORDER BY order_year;
-- Note: 2016 starts in September and 2018 ends in October,
-- so year-over-year comparisons on these totals are misleading.

-- Q23. Monthly orders in 2017
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
       COUNT(*) AS order_count
FROM orders
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2017
GROUP BY order_month
ORDER BY order_month;
-- Note: November 2017 peaks (Black Friday).

-- Q24. Average delivery time (days) for delivered orders
SELECT ROUND(AVG(order_delivered_customer_date::date - order_purchase_timestamp::date), 2)
       AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered';

-- -------------------------------------------------------------
-- Part 2 · Review of earlier weak spots
-- -------------------------------------------------------------

-- Q25. Delivered or shipped orders placed in 2018 (AND/OR precedence → parentheses)
SELECT order_status, COUNT(*) AS order_count
FROM orders
WHERE order_status IN ('delivered', 'shipped')
  AND EXTRACT(YEAR FROM order_purchase_timestamp) = 2018
GROUP BY order_status;

-- Q26. Sellers in São Paulo city (data is lower case and has spelling variants)
SELECT seller_city, COUNT(*) AS seller_count
FROM sellers
WHERE seller_city ILIKE '%sao paulo%'
GROUP BY seller_city
ORDER BY seller_count DESC;
-- Note: 'sao paulo', 'sao paulo - sp', 'sao paulo sp' ... → the same city written
-- differently; city names need cleaning before grouping.

-- Q27. Orders without any review (anti-join on the join key)
SELECT COUNT(*) AS orders_without_review
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

-- -------------------------------------------------------------
-- Part 3 · View, DDL, DML (on my own test tables only)
-- -------------------------------------------------------------

-- Q28. View with delivered orders only
CREATE OR REPLACE VIEW v_delivered_orders AS
SELECT * FROM orders WHERE order_status = 'delivered';

SELECT * FROM v_delivered_orders LIMIT 5;

-- Q29. Create a table, insert, update, delete
DROP TABLE IF EXISTS practice_notes;
CREATE TABLE practice_notes (
    id   SERIAL PRIMARY KEY,
    note TEXT NOT NULL
);
INSERT INTO practice_notes (note) VALUES ('first try'), ('second try');
UPDATE practice_notes SET note = 'edited row' WHERE id = 1;
DELETE FROM practice_notes WHERE id = 2;
SELECT * FROM practice_notes;

-- Q30. Add a column, drop it, drop the table
--      (DELETE removes rows; ALTER ... DROP COLUMN removes a column; DROP TABLE removes the table)
ALTER TABLE practice_notes ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
SELECT * FROM practice_notes;
ALTER TABLE practice_notes DROP COLUMN created_at;
DROP TABLE practice_notes;

-- Q31. Backup of São Paulo state sellers, count, drop
DROP TABLE IF EXISTS sellers_sp_backup;
CREATE TABLE sellers_sp_backup AS
SELECT * FROM sellers WHERE seller_state = 'SP';
SELECT COUNT(*) AS sp_seller_count FROM sellers_sp_backup;
DROP TABLE sellers_sp_backup;
