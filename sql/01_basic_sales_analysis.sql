-- ============================================================================
-- 01_basic_sales_analysis.sql
-- Business area: SALES PERFORMANCE
-- Concepts used: SELECT, WHERE, JOIN, GROUP BY, ORDER BY, aggregate functions,
--                subquery, CASE WHEN, LIMIT
--
-- Scope rule used throughout this file (see docs/02_data_cleaning.md section 9):
-- revenue/AOV queries are scoped to order_status = 'delivered' only, because
-- canceled/unavailable orders never completed a real transaction.
-- ============================================================================

-- Query 1: Total revenue from delivered orders
SELECT
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- Query 2: Total orders placed (all statuses) vs delivered orders
SELECT
    COUNT(*) AS total_orders_all_status,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders
FROM orders;

-- Query 3: Average Order Value (AOV) for delivered orders
SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_total
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.order_id
) order_totals;

-- Query 4: Monthly revenue trend
SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_revenue,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- Query 5: Top 10 product categories by revenue
SELECT
    p.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS category_revenue,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY category_revenue DESC
LIMIT 10;

-- Query 6: Top 10 product categories by order volume
SELECT
    p.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY orders_count DESC
LIMIT 10;
