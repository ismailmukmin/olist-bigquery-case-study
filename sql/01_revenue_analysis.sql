/*
=================================================================
FILE    : 01_revenue_analysis.sql
PROJECT : Olist E-Commerce SQL Business Intelligence Case Study
AUTHOR  : Ismail Mukmin
TOOL    : Google BigQuery
-----------------------------------------------------------------
THEME   : Revenue Analysis
QUESTIONS:
  Q1 — What is the monthly revenue trend and growth rate?
  Q2 — What is the revenue contribution by product category?
=================================================================
*/

-- ================================================================
-- Q1: Monthly Revenue Trend & Month-over-Month Growth Rate
-- ================================================================
-- Business context:
-- Understanding revenue trends helps identify seasonal patterns,
-- growth periods, and potential areas of concern for the business.
-- ================================================================

WITH monthly_revenue AS (
  SELECT
    FORMAT_DATE('%Y-%m', o.order_purchase_timestamp) AS year_month,
    ROUND(SUM(oi.price + oi.freight_value), 2)       AS total_revenue,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    COUNT(DISTINCT o.customer_id)                     AS unique_customers
  FROM `olist.orders` o
  JOIN `olist.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY year_month
),

revenue_with_growth AS (
  SELECT
    year_month,
    total_revenue,
    total_orders,
    unique_customers,
    LAG(total_revenue) OVER (ORDER BY year_month) AS prev_month_revenue,
    ROUND(
      (total_revenue - LAG(total_revenue) OVER (ORDER BY year_month))
      / NULLIF(LAG(total_revenue) OVER (ORDER BY year_month), 0) * 100
    , 2) AS mom_growth_pct
  FROM monthly_revenue
)

SELECT *
FROM revenue_with_growth
ORDER BY year_month;

/*
INSIGHT TO LOOK FOR:
- Which months show the highest revenue? (seasonality)
- Are there months with negative MoM growth? (investigate why)
- Is there an overall upward trend over time?
*/
