/*
=================================================================
FILE    : 05_delivery_logistics.sql
PROJECT : Olist E-Commerce SQL Business Intelligence Case Study
AUTHOR  : Ismail Mukmin
TOOL    : Google BigQuery
-----------------------------------------------------------------
THEME   : Delivery & Logistics
QUESTIONS:
  Q9  — How does delivery performance vary by region?
  Q10 — What is the relationship between delivery time & reviews?
=================================================================
*/

-- ================================================================
-- Q9: Delivery Performance by State
-- ================================================================
-- Business context:
-- Regional delivery gaps affect customer satisfaction and can
-- highlight where logistics investment is most needed.
-- ================================================================

WITH delivery_metrics AS (
  SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(
      DATE_DIFF(
        DATE(o.order_delivered_customer_date),
        DATE(o.order_purchase_timestamp),
        DAY
      )
    ), 1) AS avg_actual_delivery_days,
    ROUND(AVG(
      DATE_DIFF(
        DATE(o.order_estimated_delivery_date),
        DATE(o.order_purchase_timestamp),
        DAY
      )
    ), 1) AS avg_estimated_delivery_days,
    ROUND(AVG(
      DATE_DIFF(
        DATE(o.order_delivered_customer_date),
        DATE(o.order_estimated_delivery_date),
        DAY
      )
    ), 1) AS avg_delay_days,  -- negative = early, positive = late
    COUNTIF(
      o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS late_deliveries,
    ROUND(COUNTIF(
      o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) / COUNT(DISTINCT o.order_id) * 100, 2) AS late_delivery_rate_pct
  FROM `olist.orders` o
  JOIN `olist.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
  GROUP BY c.customer_state
)

SELECT *
FROM delivery_metrics
ORDER BY avg_actual_delivery_days DESC;