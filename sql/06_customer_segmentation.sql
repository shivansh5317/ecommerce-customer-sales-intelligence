-- ============================================================================
-- 06_customer_segmentation.sql
-- Business area: BASIC RFM CUSTOMER SEGMENTATION
-- Concepts used: CTE (WITH), window functions (NTILE), CASE WHEN, VIEW, GROUP BY
--
-- RFM = Recency, Frequency, Monetary. Full concept explanation with Hinglish
-- walkthrough is in docs/04_customer_segmentation.md - read that alongside this file.
-- ============================================================================

-- Query 1: Raw RFM values per customer (building block - no scoring yet)
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price + oi.freight_value) AS monetary
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    last_order_date,
    -- "today" proxy = the most recent purchase date anywhere in this (historical, fixed) dataset
    CAST(
        julianday((SELECT MAX(order_purchase_timestamp) FROM orders WHERE order_status = 'delivered'))
        - julianday(last_order_date) AS INTEGER
    ) AS recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary
FROM rfm_base
ORDER BY customer_unique_id
LIMIT 10;

-- Query 2: Build the full RFM + scoring + segment view (this is the "real" pipeline).
-- We save it as a VIEW so we don't repeat this long CTE chain in every later query.
DROP VIEW IF EXISTS customer_rfm;
CREATE VIEW customer_rfm AS
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price + oi.freight_value) AS monetary
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_calc AS (
    SELECT
        customer_unique_id,
        CAST(
            julianday((SELECT MAX(order_purchase_timestamp) FROM orders WHERE order_status = 'delivered'))
            - julianday(last_order_date) AS INTEGER
        ) AS recency_days,
        frequency,
        ROUND(monetary, 2) AS monetary
    FROM rfm_base
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        -- NTILE(4) splits customers into 4 equal-size buckets ("quartiles").
        -- recency_days is ORDERED DESC so that the LARGEST (stalest) values land in
        -- bucket 1 and the SMALLEST (most recent) values land in bucket 4 - i.e.
        -- higher r_score always means "more recent / better", matching f_score/m_score.
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        -- Frequency is NOT scored with NTILE: ~97% of customers have frequency = 1
        -- (see docs/01 - repeat customers are rare), so an equal-population quartile
        -- split would just cut this one tied value into 4 arbitrary groups. A fixed,
        -- meaningful business bucket is simpler AND more correct here.
        CASE
            WHEN frequency = 1 THEN 1
            WHEN frequency = 2 THEN 2
            WHEN frequency BETWEEN 3 AND 5 THEN 3
            ELSE 4
        END AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_calc
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'High Value'
        WHEN f_score >= 3                                    THEN 'Loyal'
        WHEN r_score <= 2 AND m_score >= 3                   THEN 'At Risk'
        WHEN r_score >= 3                                    THEN 'Recent'
        ELSE 'Low Engagement'
    END AS customer_segment
FROM rfm_scores;

-- Query 3: Sample of the final RFM table
SELECT * FROM customer_rfm ORDER BY monetary DESC LIMIT 10;

-- Query 4: Segment summary - how many customers per segment, and their combined value
SELECT
    customer_segment,
    COUNT(*) AS customers_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer_rfm), 2) AS pct_of_customers,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(AVG(monetary), 2) AS avg_revenue_per_customer
FROM customer_rfm
GROUP BY customer_segment
ORDER BY total_revenue DESC;
