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
    ) AS order_number  -- 1 = first ever order = new customer
  FROM `olist.orders` o
  JOIN `olist.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
),

customer_type AS (
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
FROM customer_type
GROUP BY year_month, customer_type
ORDER BY year_month, customer_type;