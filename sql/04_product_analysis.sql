/*
=================================================================
FILE    : 04_product_analysis.sql
PROJECT : Olist E-Commerce SQL Business Intelligence Case Study
AUTHOR  : Ismail Mukmin
TOOL    : Google BigQuery
-----------------------------------------------------------------
THEME   : Product Analysis
QUESTIONS:
  Q7 — Which categories have the highest cancellation rate?
  Q8 — What is average order value by category?
=================================================================
*/

-- ================================================================
-- Q7: Cancellation Rate by Product Category
-- ================================================================
-- Business context:
-- High cancellation in specific categories may signal quality
-- issues, misleading listings, or logistics problems.
-- ================================================================

WITH order_status_by_category AS (
  SELECT
    COALESCE(ct.string_field_1, p.product_category_name, 'Unknown') AS category,
    COUNT(DISTINCT o.order_id)                                        AS total_orders,
    COUNTIF(o.order_status IN ('canceled', 'unavailable'))            AS cancelled_orders
  FROM `olist.orders` o
  JOIN `olist.order_items` oi
    ON o.order_id = oi.order_id
  JOIN `olist.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist.category_translation` ct
    ON p.product_category_name = ct.string_field_0
  GROUP BY category
)

SELECT
  category,
  total_orders,
  cancelled_orders,
  ROUND(cancelled_orders / NULLIF(total_orders, 0) * 100, 2) AS cancellation_rate_pct
FROM order_status_by_category
WHERE total_orders >= 50  -- filter out low-volume categories
ORDER BY cancellation_rate_pct DESC
LIMIT 15;

/*
INSIGHT TO LOOK FOR:
- Which categories consistently have >5% cancellation rate?
- Are high-cancellation categories also low-review-score categories?
- Are these categories worth investing in or cutting?
*/

-- ================================================================
-- Q8: Average Order Value (AOV) by Product Category
-- ================================================================
-- Business context:
-- AOV by category helps pricing strategy, promotion design,
-- and understanding which categories drive basket size.
-- ================================================================

WITH category_orders AS (
  SELECT
    o.order_id,
    COALESCE(ct.string_field_1, p.product_category_name, 'Unknown') AS category,
    SUM(oi.price + oi.freight_value)                                  AS order_value
  FROM `olist.orders` o
  JOIN `olist.order_items` oi
    ON o.order_id = oi.order_id
  JOIN `olist.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist.category_translation` ct
    ON p.product_category_name = ct.string_field_0
  WHERE o.order_status = 'delivered'
  GROUP BY o.order_id, category
)

SELECT
  category,
  COUNT(order_id)               AS total_orders,
  ROUND(AVG(order_value), 2)    AS avg_order_value,
  ROUND(MIN(order_value), 2)    AS min_order_value,
  ROUND(MAX(order_value), 2)    AS max_order_value,
  ROUND(STDDEV(order_value), 2) AS stddev_order_value
FROM category_orders
GROUP BY category
HAVING total_orders >= 50
ORDER BY avg_order_value DESC
LIMIT 20;