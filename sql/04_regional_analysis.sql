-- ============================================================================
-- 04_regional_analysis.sql
-- Business area: GEOGRAPHY / REGIONAL PERFORMANCE
-- Concepts used: JOIN, GROUP BY, HAVING, ORDER BY, CTE, scalar subquery
-- ============================================================================

-- Query 1: Revenue by state (top 10)
SELECT
    c.customer_state AS state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY revenue DESC
LIMIT 10;

-- Query 2: Average Order Value by state (states with at least 50 orders)
WITH order_totals AS (
    SELECT
        o.order_id,
        c.customer_state AS state,
        SUM(oi.price + oi.freight_value) AS order_total
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, state
)
SELECT
    state,
    COUNT(*) AS orders_count,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM order_totals
GROUP BY state
HAVING orders_count >= 50
ORDER BY avg_order_value DESC
LIMIT 10;

-- Query 3: Top 5 states by number of unique customers
SELECT
    customer_state AS state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY state
ORDER BY unique_customers DESC
LIMIT 5;

-- Query 4: Revenue concentration - each state's share of total revenue
SELECT
    c.customer_state AS state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS state_revenue,
    ROUND(100.0 * SUM(oi.price + oi.freight_value) / (
        SELECT SUM(oi2.price + oi2.freight_value)
        FROM order_items oi2
        JOIN orders o2 ON o2.order_id = oi2.order_id
        WHERE o2.order_status = 'delivered'
    ), 2) AS pct_of_total_revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY state_revenue DESC
LIMIT 5;
