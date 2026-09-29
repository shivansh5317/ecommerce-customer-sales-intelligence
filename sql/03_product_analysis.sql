-- ============================================================================
-- 03_product_analysis.sql
-- Business area: PRODUCT / CATEGORY PERFORMANCE
-- Concepts used: JOIN, GROUP BY, HAVING, ORDER BY, aggregate functions
-- ============================================================================

-- Query 1: Top 10 individual products by revenue
SELECT
    oi.product_id,
    p.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS product_revenue,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id, category
ORDER BY product_revenue DESC
LIMIT 10;

-- Query 2: Categories with high order volume but relatively low revenue-per-order
-- (HAVING filters groups AFTER aggregation, so we only look at categories with a
--  meaningful sample size of at least 100 orders)
SELECT
    p.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS category_revenue,
    ROUND(SUM(oi.price + oi.freight_value) * 1.0 / COUNT(DISTINCT oi.order_id), 2) AS avg_revenue_per_order
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'delivered'
GROUP BY category
HAVING orders_count >= 100
ORDER BY avg_revenue_per_order ASC
LIMIT 10;

-- Query 3: Categories with the poorest average customer ratings
SELECT
    p.product_category_name_english AS category,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT r.order_id) AS reviews_count
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN order_reviews r ON r.order_id = oi.order_id
GROUP BY category
HAVING reviews_count >= 30
ORDER BY avg_review_score ASC
LIMIT 10;

-- Query 4: Category-wise average selling price
SELECT
    p.product_category_name_english AS category,
    ROUND(AVG(oi.price), 2) AS avg_price,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY category
ORDER BY avg_price DESC
LIMIT 10;

-- Query 5: Categories with the widest product variety (catalog depth)
SELECT
    p.product_category_name_english AS category,
    COUNT(DISTINCT p.product_id) AS distinct_products
FROM products p
GROUP BY category
ORDER BY distinct_products DESC
LIMIT 10;
