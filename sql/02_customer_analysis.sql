-- ============================================================================
-- 02_customer_analysis.sql
-- Business area: CUSTOMER BEHAVIOR
-- Concepts used: CTE (WITH), subquery, CASE WHEN, GROUP BY, HAVING-style logic,
--                COUNT DISTINCT, aggregate functions
--
-- IMPORTANT: every query here uses customers.customer_unique_id (the real person),
-- NOT customer_id (which is one-per-order). See docs/01_dataset_understanding.md
-- section 3.1 for why.
-- ============================================================================

-- Query 1: Total unique customers
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;

-- Query 2: Repeat vs one-time customers
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE WHEN orders_count = 1 THEN 'one_time_customer' ELSE 'repeat_customer' END AS customer_type,
    COUNT(*) AS customers_count
FROM customer_orders
GROUP BY customer_type;

-- Query 3: Percentage of repeat customers
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    ROUND(100.0 * SUM(CASE WHEN orders_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_repeat_customers
FROM customer_orders;

-- Query 4: Top 10 highest-value customers
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spend,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spend DESC
LIMIT 10;

-- Query 5: Customer order-frequency distribution
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN orders_count = 1 THEN '1 order'
        WHEN orders_count = 2 THEN '2 orders'
        WHEN orders_count BETWEEN 3 AND 5 THEN '3-5 orders'
        ELSE '6+ orders'
    END AS frequency_bucket,
    COUNT(*) AS customers_count
FROM customer_orders
GROUP BY frequency_bucket
ORDER BY MIN(orders_count);

-- Query 6: Average total spend per customer
WITH customer_spend AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_spend
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT ROUND(AVG(total_spend), 2) AS avg_spend_per_customer
FROM customer_spend;
