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

/*
INSIGHT TO LOOK FOR:
- Which states have the worst late delivery rates? (logistics gap)
- Is there a big gap between estimated and actual delivery? (poor estimation)
- Which states are consistently early? (benchmark for others)
*/

-- ================================================================
-- Q10: Delivery Time vs Review Score Relationship
-- ================================================================
-- Business context:
-- Quantifying how delivery speed impacts satisfaction helps
-- justify investment in faster logistics with a business case.
-- ================================================================

WITH delivery_vs_review AS (
  SELECT
    o.order_id,
    DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_purchase_timestamp),
      DAY
    )                           AS delivery_days,
    DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_estimated_delivery_date),
      DAY
    )                           AS days_vs_estimate, -- negative = early
    r.review_score
  FROM `olist.orders` o
  JOIN `olist.reviews` r
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND r.review_score IS NOT NULL
),

bucketed AS (
  SELECT
    CASE
      WHEN delivery_days <= 5  THEN '1. 0-5 days'
      WHEN delivery_days <= 10 THEN '2. 6-10 days'
      WHEN delivery_days <= 20 THEN '3. 11-20 days'
      WHEN delivery_days <= 30 THEN '4. 21-30 days'
      ELSE                          '5. 30+ days'
    END AS delivery_bucket,
    CASE
      WHEN days_vs_estimate < 0  THEN 'Early'
      WHEN days_vs_estimate = 0  THEN 'On Time'
      ELSE                            'Late'
    END AS delivery_vs_estimate,
    review_score
  FROM delivery_vs_review
)

SELECT
  delivery_bucket,
  delivery_vs_estimate,
  COUNT(*)                        AS total_orders,
  ROUND(AVG(review_score), 2)     AS avg_review_score,
  COUNTIF(review_score = 5)       AS five_star_count,
  COUNTIF(review_score <= 2)      AS low_score_count
FROM bucketed
GROUP BY delivery_bucket, delivery_vs_estimate
ORDER BY delivery_bucket, delivery_vs_estimate;