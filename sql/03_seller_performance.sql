/*
=================================================================
FILE    : 03_seller_performance.sql
PROJECT : Olist E-Commerce SQL Business Intelligence Case Study
AUTHOR  : Ismail Mukmin
TOOL    : Google BigQuery
-----------------------------------------------------------------
THEME   : Seller Performance
QUESTIONS:
  Q5 — Who are the top performing sellers?
  Q6 — What is seller activity trend over time?
=================================================================
*/


-- ================================================================
-- Q5: Top Performing Sellers
-- ================================================================
-- Business context:
-- Identifying top sellers helps replicate their success patterns
-- and build better seller onboarding and support programs.
-- ================================================================

WITH seller_metrics AS (
  SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)                     AS total_orders,
    COUNT(DISTINCT oi.product_id)                   AS unique_products,
    ROUND(SUM(oi.price), 2)                         AS total_revenue,
    ROUND(AVG(oi.price), 2)                         AS avg_item_price,
    ROUND(AVG(r.review_score), 2)                   AS avg_review_score,
    ROUND(AVG(
      DATE_DIFF(
        DATE(o.order_delivered_customer_date),
        DATE(o.order_purchase_timestamp),
        DAY
      )
    ), 1)                                           AS avg_delivery_days
  FROM `olist.order_items` oi
  JOIN `olist.orders` o
    ON oi.order_id = o.order_id
  JOIN `olist.sellers` s
    ON oi.seller_id = s.seller_id
  LEFT JOIN `olist.reviews` r
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.seller_id, s.seller_state
)

SELECT
  seller_id,
  seller_state,
  total_orders,
  unique_products,
  total_revenue,
  avg_item_price,
  avg_review_score,
  avg_delivery_days,
  RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM seller_metrics
ORDER BY revenue_rank
LIMIT 20;

/*
INSIGHT TO LOOK FOR:
- Do top revenue sellers also have high review scores?
- Is there a correlation between delivery speed and review score?
- Which states produce the top sellers?
*/

-- ================================================================
-- Q6: Seller Activity Trend Over Time
-- ================================================================
-- Business context:
-- Tracking how many active sellers operate each month shows
-- marketplace health and supply-side growth.
-- ================================================================

SELECT
  FORMAT_DATE('%Y-%m', o.order_purchase_timestamp) AS year_month,
  COUNT(DISTINCT oi.seller_id)                      AS active_sellers,
  COUNT(DISTINCT oi.order_id)                       AS total_orders,
  ROUND(SUM(oi.price), 2)                           AS total_revenue,
  ROUND(SUM(oi.price) / COUNT(DISTINCT oi.seller_id), 2) AS avg_revenue_per_seller
FROM `olist.order_items` oi
JOIN `olist.orders` o
  ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY year_month
ORDER BY year_month;

/*
INSIGHT TO LOOK FOR:
- Is seller count growing month over month?
- Does avg revenue per seller increase as more sellers join? (market saturation?)
- Are there months where seller count drops? (investigate churn)
*/