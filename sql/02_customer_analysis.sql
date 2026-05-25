/*
=================================================================
FILE    : 02_customer_analysis.sql
PROJECT : Olist E-Commerce SQL Business Intelligence Case Study
AUTHOR  : Ismail Mukmin
TOOL    : Google BigQuery
-----------------------------------------------------------------
THEME   : Customer Analysis
QUESTIONS:
  Q3 — New vs returning customers over time
  Q4 — Which states have the highest customer lifetime value?
=================================================================
*/

-- ================================================================
-- Q3: New vs Returning Customer Trend
-- ================================================================
-- Business context:
-- Retention is cheaper than acquisition. Tracking new vs returning
-- customers monthly shows how well the platform retains its base.
-- ================================================================

WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    FORMAT_DATE('%Y-%m', o.order_purchase_timestamp) AS year_month,
    ROW_NUMBER() OVER (
      PARTITION BY c.customer_unique_id
      ORDER BY o.order_purchase_timestamp
    ) AS order_number
  FROM `olist.orders` o
  JOIN `olist.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
),

customer_segmented AS (
  SELECT
    year_month,
    customer_unique_id,
    CASE WHEN order_number = 1 THEN 'New' ELSE 'Returning' END AS customer_type
  FROM customer_orders
)

SELECT
  year_month,
  customer_type,
  COUNT(DISTINCT customer_unique_id) AS customer_count
FROM customer_segmented
GROUP BY year_month, customer_type
ORDER BY year_month, customer_type;

/*
INSIGHT TO LOOK FOR:
- What % of monthly customers are returning? (retention rate)
- Is the returning customer count growing or flat?
- Are there specific months where retention spikes? (post-campaign effect?)
*/

-- ================================================================
-- Q4: Customer Lifetime Value (CLV) by State
-- ================================================================
-- Business context:
-- CLV by region helps prioritize where to invest in
-- marketing, logistics, and customer success efforts.
-- ================================================================

WITH customer_spend AS (
  SELECT
    c.customer_unique_id,
    c.customer_state,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.price), 2)             AS total_spent,
    MIN(o.order_purchase_timestamp)     AS first_purchase,
    MAX(o.order_purchase_timestamp)     AS last_purchase
  FROM `olist.customers` c
  JOIN `olist.orders` o
    ON c.customer_id = o.customer_id
  JOIN `olist.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id, c.customer_state
)

SELECT
  customer_state,
  COUNT(DISTINCT customer_unique_id)          AS total_customers,
  ROUND(AVG(total_spent), 2)                  AS avg_clv,
  ROUND(AVG(total_orders), 2)                 AS avg_orders_per_customer,
  ROUND(SUM(total_spent), 2)                  AS total_state_revenue,
  RANK() OVER (ORDER BY AVG(total_spent) DESC) AS clv_rank
FROM customer_spend
GROUP BY customer_state
ORDER BY avg_clv DESC;