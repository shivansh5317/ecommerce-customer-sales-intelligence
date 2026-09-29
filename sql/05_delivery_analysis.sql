-- ============================================================================
-- 05_delivery_analysis.sql
-- Business area: DELIVERY / OPERATIONS PERFORMANCE
-- Concepts used: CTE, CASE WHEN, JOIN, GROUP BY, HAVING, date functions (julianday)
-- ============================================================================

-- Query 1: Overall average delivery time (in days) for delivered orders
SELECT
    ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 1) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;

-- Query 2: On-time vs late delivery (actual delivery date vs Olist's own estimate)
WITH delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
            ELSE 'late'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
)
SELECT
    delivery_status,
    COUNT(*) AS orders_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM delivery_status), 2) AS pct
FROM delivery_status
GROUP BY delivery_status;

-- Query 3: Slowest 10 states by average delivery time (states with >= 30 delivered orders)
SELECT
    c.customer_state AS state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp)), 1) AS avg_delivery_days
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY state
HAVING delivered_orders >= 30
ORDER BY avg_delivery_days DESC
LIMIT 10;

-- Query 4: Delivery performance vs customer satisfaction (review score)
WITH delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
            ELSE 'late'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
)
SELECT
    ds.delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS orders_count
FROM delivery_status ds
JOIN order_reviews r ON r.order_id = ds.order_id
GROUP BY ds.delivery_status;
