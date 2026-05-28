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