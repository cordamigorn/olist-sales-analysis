-- =============================================================
-- Analysis 1 · Monthly revenue trend
-- Question: how did Olist's revenue change month by month?
--
-- Revenue definition (used in every analysis):
--   item price + freight from order_items, delivered orders only.
--   order_payments includes installment interest and vouchers, so its total is
--   slightly higher, and it cannot be split by product or seller.
-- =============================================================

-- 1.1 · Orders and revenue per month
--   JOIN order_items multiplies rows (one row per item), so orders are counted
--   with COUNT(DISTINCT order_id).
SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
       COUNT(DISTINCT o.order_id)                      AS order_count,
       ROUND(SUM(oi.price + oi.freight_value), 2)      AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- 1.2 · Month-over-month growth (CTE + LAG window function)
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
           COUNT(DISTINCT o.order_id)                      AS order_count,
           ROUND(SUM(oi.price + oi.freight_value), 2)      AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
),
with_prev AS (
    SELECT order_month,
           order_count,
           revenue,
           LAG(revenue) OVER (ORDER BY order_month) AS prev_revenue
    FROM monthly
)
SELECT order_month,
       order_count,
       revenue,
       prev_revenue,
       ROUND(100.0 * (revenue - prev_revenue) / NULLIF(prev_revenue, 0), 1) AS growth_pct
FROM with_prev
ORDER BY order_month;

-- 1.3 · Same period comparison: January–August 2017 vs 2018
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
           SUM(oi.price + oi.freight_value)                AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT EXTRACT(YEAR FROM order_month) AS order_year,
       ROUND(SUM(revenue), 2)         AS jan_aug_revenue
FROM monthly
WHERE EXTRACT(MONTH FROM order_month) <= 8
  AND EXTRACT(YEAR FROM order_month) IN (2017, 2018)
GROUP BY order_year
ORDER BY order_year;

-- -------------------------------------------------------------
-- Findings
-- -------------------------------------------------------------
-- * Data coverage: Sep–Dec 2016 have only 1–265 delivered orders and November 2016
--   is missing; the dataset starts in late 2016. September–October 2018 orders exist
--   but are mostly not delivered, so they drop out with the 'delivered' filter.
--   These edge months are excluded when comparing trends.
-- * Peak: November 2017, revenue +53.6% vs October 2017, most likely driven by
--   Black Friday. December 2017 fell back.
-- * Growth: 2017 shows a steady ramp-up from about 750 orders in January;
--   query 1.3 compares January–August 2017 with the same months of 2018.
