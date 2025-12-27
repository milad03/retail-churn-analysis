-- 1. Monthly Revenue & Growth
-- Calculates total revenue and month-over-month growth %
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(revenue) AS total_revenue
    FROM orders
    GROUP BY 1
)
SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0) * 100, 2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- 2. Churn Risk Analysis
-- Identifies customers who haven't bought in 90+ days
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
),
reference_date AS (
    SELECT MAX(order_date) AS max_date FROM orders
)
SELECT
    lp.customer_id,
    c.region,
    EXTRACT(DAY FROM (rd.max_date - lp.last_order_date)) AS days_inactive,
    CASE
        WHEN EXTRACT(DAY FROM (rd.max_date - lp.last_order_date)) > 90 THEN 'High Risk'
        WHEN EXTRACT(DAY FROM (rd.max_date - lp.last_order_date)) > 60 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk
FROM last_purchase lp
CROSS JOIN reference_date rd
JOIN customers c ON lp.customer_id = c.customer_id
ORDER BY days_inactive DESC;

-- 3. RFM Segmentation
-- Segments customers based on Recency, Frequency, and Monetary value
WITH rfm_stats AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(order_id) AS count_orders,
        SUM(revenue) AS total_revenue
    FROM orders
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        last_order_date,
        count_orders,
        total_revenue,
        NTILE(4) OVER (ORDER BY last_order_date ASC) AS r_score,
        NTILE(4) OVER (ORDER BY count_orders ASC) AS f_score,
        NTILE(4) OVER (ORDER BY total_revenue ASC) AS m_score
    FROM rfm_stats
)
SELECT
    customer_id,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS total_score
FROM rfm_scores
ORDER BY total_score DESC;